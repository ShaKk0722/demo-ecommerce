-- 1. Insert user if not exists
INSERT INTO "user" (email, password_hash, phone, full_name)
VALUES ('gu@gmail.com', 'password_hash', '3283553333', 'assessment')
ON CONFLICT (email) DO NOTHING
RETURNING user_id;

-- Store the user_id for further use
DO $$
DECLARE
    user_id_val INTEGER;
BEGIN
    SELECT user_id INTO user_id_val FROM "user" WHERE email = 'gu@gmail.com';
    
    -- 2. Ensure user is a customer
    INSERT INTO customer (user_id)
    VALUES (user_id_val)
    ON CONFLICT (user_id) DO NOTHING;
    
    -- 3. Insert address
    INSERT INTO address (user_id, housing_type, detail_address, province, district, commune)
    VALUES (user_id_val, 'nhà riêng', '73 tán hoá 2', 'Bắc Kạn', 'Ba Bể', 'Phúc Lộc');
    
    -- 4. Insert order (assuming the product exists)
    WITH new_order AS (
        INSERT INTO "order" (customerNo)
        VALUES (user_id_val)
        RETURNING order_id
    ),
    -- Find product ID
    product_info AS (
        SELECT product_id, price FROM product 
        WHERE product_name = 'KAPPA Women''s Sneakers' 
        AND color = 'yellow' 
        AND size = '36'
    )
    -- 5. Link order with product
    INSERT INTO has (order_id, product_id, quantity, unitprice)
    SELECT new_order.order_id, product_info.product_id, 1, product_info.price
    FROM new_order, product_info;
    
    -- 6. Insert order status
    INSERT INTO order_status (order_id, status)
    SELECT order_id, 'Pending' FROM "order" 
    WHERE customerNo = user_id_val
    ORDER BY order_id DESC LIMIT 1;
END $$;

-- Alternative approach (without DO block) if product already exists:
-- First, get the user_id
-- SELECT user_id FROM "user" WHERE email = 'gu@gmail.com';

-- Then, get the product_id
-- SELECT product_id FROM product WHERE product_name = 'KAPPA Women''s Sneakers' AND color = 'yellow' AND size = '36';

-- Then use the retrieved IDs in further queries 