import pool from '../db/db.js';


export const fetchProductsByCategory = async (req, res) => {
    try {
        const categoryId = parseInt(req.params.categoryId);

        if (isNaN(categoryId)) {
            return res.status(400).json({
                success: false,
                error: {
                    code: 400,
                    message: "Invalid category ID"
                }
            });
        }

        // Pagination defaults
        const page = parseInt(req.query.page) || 1;
        const limit = parseInt(req.query.limit) || 20;
        const offset = (page - 1) * limit;

        // Check if category exists
        const categoryQuery = `
            SELECT 
                category_id, 
                category_name, 
                category_description 
            FROM category 
            WHERE category_id = $1
        `;
        const categoryResult = await pool.query(categoryQuery, [categoryId]);

        if (categoryResult.rowCount === 0) {
            return res.status(404).json({
                success: false,
                error: {
                    code: 404,
                    message: "Category not found"
                }
            });
        }

        const category = categoryResult.rows[0];

        // Fetch paginated products by category with price
        const productsQuery = `
            SELECT 
                p.product_id, 
                p.product_name, 
                p.model, 
                p.color, 
                p.product_imageURL, 
                p.brand, 
                p.size,
                MIN(s.price) AS price  -- get the lowest price if multiple stores supply the product
            FROM product p
            JOIN supply s ON p.product_id = s.product_id
            WHERE p.categoryNo = $1
            GROUP BY p.product_id
            ORDER BY p.product_id
            LIMIT $2 OFFSET $3
        `;
        const productsResult = await pool.query(productsQuery, [categoryId, limit, offset]);

        // Count total products in the category
        const countQuery = `
            SELECT COUNT(DISTINCT p.product_id) AS total
            FROM product p
            WHERE p.categoryNo = $1
        `;
        const countResult = await pool.query(countQuery, [categoryId]);
        const total = parseInt(countResult.rows[0].total);
        const totalPages = Math.ceil(total / limit);

        return res.status(200).json({
            success: true,
            data: {
                category,
                products: productsResult.rows,
                pagination: {
                    total,
                    page,
                    limit,
                    pages: totalPages
                }
            }
        });

    } catch (error) {
        console.error('Error fetching products by category:', error);
        return res.status(500).json({
            success: false,
            error: {
                code: 500,
                message: 'Failed to fetch products',
                details: error.message
            }
        });
    }
};