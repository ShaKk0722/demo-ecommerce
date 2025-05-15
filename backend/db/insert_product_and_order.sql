-- 1. First, make sure we have a category for sneakers
INSERT INTO category (category_name, description)
VALUES ('Footwear', 'Shoes, sneakers, and other footwear')
ON CONFLICT DO NOTHING;

-- 2. Insert the product (KAPPA Women's Sneakers)
INSERT INTO product (product_name, price, color, size, brand, categoryNo)
VALUES (
    'KAPPA Women''s Sneakers',
    980000,
    'yellow',
    '36',
    'KAPPA',
    (SELECT category_id FROM category WHERE category_name = 'Footwear')
)
ON CONFLICT DO NOTHING;

-- 3. Insert user if not exists
INSERT INTO "user" (email, password_hash, phone, full_name)
VALUES ('gu@gmail.com', 'password_hash', '3283553333', 'assessment')
ON CONFLICT (email) DO NOTHING;

-- Store the user_id and product_id for further use
DO $$
DECLARE
    user_id_val INTEGER;
    product_id_val INTEGER;
BEGIN
    -- Get user ID
    SELECT user_id INTO user_id_val FROM "user" WHERE email = 'gu@gmail.com';
    
    -- Get product ID
    SELECT product_id INTO product_id_val FROM product 
    WHERE product_name = 'KAPPA Women''s Sneakers' AND color = 'yellow' AND size = '36';
    
    -- 4. Ensure user is a customer
    INSERT INTO customer (user_id)
    VALUES (user_id_val)
    ON CONFLICT (user_id) DO NOTHING;
    
    -- 5. Insert address
    INSERT INTO address (user_id, housing_type, detail_address, province, district, commune)
    VALUES (user_id_val, 'nhà riêng', '73 tán hoá 2', 'Bắc Kạn', 'Ba Bể', 'Phúc Lộc');
    
    -- 6. Create a new order
    WITH new_order AS (
        INSERT INTO "order" (customerNo)
        VALUES (user_id_val)
        RETURNING order_id
    )
    -- 7. Link order with product (has relationship)
    INSERT INTO has (order_id, product_id, quantity, unitprice)
    SELECT new_order.order_id, product_id_val, 1, 980000
    FROM new_order;
    
    -- 8. Insert order status
    INSERT INTO order_status (order_id, status)
    SELECT order_id, 'Pending' FROM "order" 
    WHERE customerNo = user_id_val
    ORDER BY order_id DESC LIMIT 1;
END $$;

-- This complete script will:
-- 1. Create the product category if needed
-- 2. Add the KAPPA Women's Sneakers product
-- 3. Add the user "assessment" 
-- 4. Insert their address details
-- 5. Create an order for 1 pair of yellow, size 36 KAPPA Women's Sneakers
-- 6. Set the order status to "Pending" 