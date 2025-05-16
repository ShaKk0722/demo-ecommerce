import pool from '../db/db.js';
import sendMail from '../utils/sendMail.js';


export const orderAndPayment = async (req, res) => {

    const client = await pool.connect();
    
    try {
        await client.query('BEGIN');
        
        const { customer_id, address, products, payment, voucher_id } = req.body;
        
        if (!customer_id || !address || !products || !payment || !products.length) {
            return res.status(400).json({
                success: false,
                error: {
                    code: 400,
                    message: "Missing required fields"
                }
            });
        }
        
        const customerQuery = `
            SELECT c.user_id, u.email 
            FROM customer c
            JOIN users u ON c.user_id = u.user_id
            WHERE c.user_id = $1
        `;
        const customerResult = await client.query(customerQuery, [customer_id]);
        
        if (customerResult.rowCount === 0) {
            return res.status(404).json({
                success: false,
                error: {
                    code: 404,
                    message: "Customer not found"
                }
            });
        }

        const email = customerResult.rows[0].email;

        const orderQuery = `
            INSERT INTO orders (order_address, customerNo)
            VALUES ($1, $2)
            RETURNING order_id
        `;
        const orderResult = await client.query(orderQuery, [address, customer_id]);
        const orderId = orderResult.rows[0].order_id;
        

        const statusQuery = `
            INSERT INTO order_status (order_id, orderstatus)
            VALUES ($1, $2)
        `;
        await client.query(statusQuery, [orderId, 'Processing']);
        

        let totalAmount = 0;
        const orderItems = [];
        
        for (const item of products) {

            const productQuery = `
                SELECT p.product_id, p.product_name, s.quantity as available_quantity, s.price
                FROM product p
                JOIN supply s ON p.product_id = s.product_id
                WHERE p.product_id = $1
            `;
            const productResult = await client.query(productQuery, [item.product_id]);
            
            if (productResult.rowCount === 0) {
                await client.query('ROLLBACK');
                return res.status(404).json({
                    success: false,
                    error: {
                        code: 404,
                        message: `Product with ID ${item.product_id} not found`
                    }
                });
            }
            
            const product = productResult.rows[0];
            

            if (product.available_quantity < item.quantity) {
                await client.query('ROLLBACK');
                return res.status(400).json({
                    success: false,
                    error: {
                        code: 400,
                        message: `Not enough stock for product ${product.product_name}`
                    }
                });
            }
            

            const itemQuery = `
                INSERT INTO has (order_id, product_id, quantity, unitprice)
                VALUES ($1, $2, $3, $4)
            `;
            await client.query(itemQuery, [orderId, item.product_id, item.quantity, product.price]);

            const updateStockQuery = `
                UPDATE supply
                SET quantity = quantity - $1
                WHERE product_id = $2
            `;
            await client.query(updateStockQuery, [item.quantity, item.product_id]);
            

            const itemTotal = parseFloat(product.price) * item.quantity;
            totalAmount += itemTotal;
            

            orderItems.push({
                product_id: product.product_id,
                product_name: product.product_name,
                quantity: item.quantity,
                unit_price: parseFloat(product.price),
                subtotal: itemTotal
            });
        }
        

        let discountAmount = 0;
        let finalAmount = totalAmount;
        
        if (voucher_id) {
            const voucherQuery = 'SELECT percent FROM voucher WHERE voucher_id = $1';
            const voucherResult = await client.query(voucherQuery, [voucher_id]);
            
            if (voucherResult.rowCount > 0) {
                const discountPercent = voucherResult.rows[0].percent;
                discountAmount = (totalAmount * discountPercent) / 100;
                finalAmount = totalAmount - discountAmount;
            }
        }
        

        const paymentQuery = `
            INSERT INTO payment (orderNo, method, ammount)
            VALUES ($1, $2, $3)
            RETURNING payment_id
        `;
        const paymentResult = await client.query(
            paymentQuery, 
            [orderId, payment.method, finalAmount]
        );
        const paymentId = paymentResult.rows[0].payment_id;
        

        if (voucher_id && discountAmount > 0) {
            const applyVoucherQuery = `
                INSERT INTO applies (voucher_id, payment_id)
                VALUES ($1, $2)
            `;
            await client.query(applyVoucherQuery, [voucher_id, paymentId]);
        }
        
        // Commit transaction
        await client.query('COMMIT');
        

        try {
            const html = `
                <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
                    <div style="background-color: #f8f9fa; padding: 20px; text-align: center;">
                        <h2 style="color: #333;">Order Confirmation #${orderId}</h2>
                    </div>
                    <div style="padding: 20px;">
                        <p>Dear Customer,</p>
                        <p>Thank you for your order. We're pleased to confirm that your order has been received and is being processed.</p>
                        `;
            await sendMail({ email, html, subject: 'Confirm order through web ABC' });
        } catch (error) {
            console.error('Error in email notification process:', error);
        }
        
        return res.status(201).json({
            success: true,
            data: {
                order: {
                    order_id: orderId,
                    order_date: new Date().toISOString(),
                    status: 'Processing',
                    address: address,
                    total_amount: totalAmount,
                    discount_amount: discountAmount,
                    items: orderItems
                },
                payment: {
                    payment_id: paymentId,
                    method: payment.method,
                    amount: finalAmount,
                    payment_date: new Date().toISOString()
                }
            }
        });
        
    } catch (error) {
        await client.query('ROLLBACK');
        console.error('Error creating order and processing payment:', error);
        
        return res.status(500).json({
            success: false,
            error: {
                code: 500,
                message: 'Failed to create order and process payment',
                details: error.message
            }
        });
        
    } finally {
        client.release();
    }
}


