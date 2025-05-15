DO $$
DECLARE
    v_user_id INTEGER;
    v_product_id INTEGER;
    v_order_id INTEGER;
    v_payment_id INTEGER;
    v_order_address TEXT;
    v_store_id INTEGER;
    v_category_id INTEGER;
BEGIN
    -- Step 1: Insert user
    INSERT INTO users (email, password_hash, phone, full_name)
    VALUES ('gu@gmail.com', 'hashed_password', '328355333', 'assessment')
    RETURNING user_id INTO v_user_id;

    -- Step 2: Insert customer
    INSERT INTO customer (user_id, point)
    VALUES (v_user_id, 0);

    -- Step 3: Create a cart for this customer
    INSERT INTO cart (customerNo)
    VALUES (v_user_id);

    -- Step 4: Insert address
    INSERT INTO addresses (address_id, user_id, housing_type, detail_address, province, district, commune)
    VALUES (1, v_user_id, 'nhà riêng', '73 tân hoà 2', 'Bắc Kạn', 'Ba Bể', 'Phúc Lộc');

    -- Step 5: Insert store
    INSERT INTO store (phone, store_name)
    VALUES ('0901234567', 'Assessment Store')
    RETURNING store_id INTO v_store_id;

    -- Step 6: Insert category
    INSERT INTO category (category_name, category_description)
    VALUES ('Shoes', 'Category for sneakers')
    RETURNING category_id INTO v_category_id;

    -- Step 7: Insert product 
    INSERT INTO product (
        product_name, model, color, product_imageURL, brand, size, categoryNo, storeNo
    )
    VALUES (
        'KAPPA Women''s Sneakers', 'default', 'yellow', NULL, 'KAPPA', '36', v_category_id, v_store_id
    )
    RETURNING product_id INTO v_product_id;

    -- Step 8: Add to supply 
    INSERT INTO supply (store_id, product_id, quantity, price)
    VALUES (v_store_id, v_product_id, 100, 980000);

    -- Step 9: Get full address string
    SELECT detail_address || ', ' || commune || ', ' || district || ', ' || province
    INTO v_order_address
    FROM addresses
    WHERE user_id = v_user_id
    ORDER BY address_id
    LIMIT 1;

    -- Step 10: Insert order
    INSERT INTO orders (order_address, customerNo)
    VALUES (v_order_address, v_user_id)
    RETURNING order_id INTO v_order_id;

    -- Step 11: Insert initial order status 
    INSERT INTO order_status (order_id, orderstatus)
    VALUES (v_order_id, 'Processing');

    -- Step 12: Insert product into order
    INSERT INTO has (order_id, product_id, quantity, unitprice)
    VALUES (
        v_order_id,
        v_product_id,
        5,
        (SELECT price FROM supply WHERE product_id = v_product_id AND store_id = v_store_id)
    );

    -- Step 13: Insert payment using the price from supply
    INSERT INTO payment (orderNo, method, ammount)
    VALUES (
    v_order_id,
    'Credit Card',
    (
        SELECT SUM(h.quantity * h.unitprice)
        FROM has h
        WHERE h.order_id = v_order_id
    )
    )
    RETURNING payment_id INTO v_payment_id;

    -- Step 14: Update order status to 'Shipped' with current time
    UPDATE order_status
    SET orderstatus = 'Shipped',
        modified_date = NOW()
    WHERE order_id = v_order_id;

END $$;


-- Customer information
SELECT
    u.full_name AS name,
    u.email,
    u.phone,
    a.province,
    a.district,
    a.commune,
    a.detail_address AS address,
    a.housing_type
FROM users u
JOIN customer c ON u.user_id = c.user_id
JOIN addresses a ON u.user_id = a.user_id
WHERE u.email = 'gu@gmail.com';

-- Order information
SELECT
    p.product_name AS name,
    s.price,
    p.size,
    h.quantity,
    p.color,
    os.orderstatus,
    os.modified_date
FROM users u
JOIN customer c ON u.user_id = c.user_id
JOIN orders o ON c.user_id = o.customerNo
JOIN has h ON o.order_id = h.order_id
JOIN product p ON h.product_id = p.product_id
JOIN supply s ON s.product_id = p.product_id AND s.store_id = p.storeNo
JOIN order_status os ON os.order_id = o.order_id
WHERE u.email = 'gu@gmail.com';