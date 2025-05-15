-- Create database tables based on the ER diagram

-- USER table
CREATE TABLE "user" (
    user_id SERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    full_name VARCHAR(255),
    create_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ADMIN table
CREATE TABLE admin (
    user_id INTEGER PRIMARY KEY REFERENCES "user"(user_id),
    position VARCHAR(50) NOT NULL
);

-- CUSTOMER table
CREATE TABLE customer (
    user_id INTEGER PRIMARY KEY REFERENCES "user"(user_id),
    point INTEGER DEFAULT 0
);

-- ADDRESS table
CREATE TABLE address (
    user_id_address_id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES "user"(user_id),
    housing_type VARCHAR(50),
    detail_address TEXT NOT NULL,
    province VARCHAR(100) NOT NULL,
    district VARCHAR(100) NOT NULL,
    commune VARCHAR(100) NOT NULL
);

-- CATEGORY table
CREATE TABLE category (
    category_id SERIAL PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL,
    description TEXT,
    product_imageURL VARCHAR(255)
);

-- PRODUCT table
CREATE TABLE product (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(255) NOT NULL,
    model VARCHAR(100),
    price DECIMAL(10, 2) NOT NULL,
    color VARCHAR(50),
    product_imageURL VARCHAR(255),
    brand VARCHAR(100),
    size VARCHAR(50),
    categoryNo INTEGER REFERENCES category(category_id)
);

-- STORE table
CREATE TABLE store (
    store_id SERIAL PRIMARY KEY,
    phone VARCHAR(20),
    unitprice DECIMAL(10, 2),
    name VARCHAR(255) NOT NULL
);

-- SUPPLY table
CREATE TABLE supply (
    store_id_product_id SERIAL PRIMARY KEY,
    store_id INTEGER REFERENCES store(store_id),
    product_id INTEGER REFERENCES product(product_id),
    quantity INTEGER NOT NULL,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ORDER table
CREATE TABLE "order" (
    order_id SERIAL PRIMARY KEY,
    category_name VARCHAR(100),
    description TEXT,
    product_imageURL VARCHAR(255),
    customerNo INTEGER REFERENCES customer(user_id)
);

-- ORDER_STATUS table
CREATE TABLE order_status (
    order_id_o_status SERIAL PRIMARY KEY,
    order_id INTEGER REFERENCES "order"(order_id),
    status VARCHAR(50) NOT NULL,
    modified_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- VOUCHER table
CREATE TABLE voucher (
    voucher_id SERIAL PRIMARY KEY,
    percent INTEGER NOT NULL
);

-- CONFIG table
CREATE TABLE config (
    user_id_voucher_id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES "user"(user_id),
    percent INTEGER NOT NULL
);

-- PAYMENT table
CREATE TABLE payment (
    payment_id SERIAL PRIMARY KEY,
    orderNo INTEGER REFERENCES "order"(order_id),
    date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    method VARCHAR(50) NOT NULL,
    ammount DECIMAL(10, 2) NOT NULL
);

-- APPLY table
CREATE TABLE apply (
    voucher_id_payment_id SERIAL PRIMARY KEY,
    voucher_id INTEGER REFERENCES voucher(voucher_id),
    payment_id INTEGER REFERENCES payment(payment_id)
);

-- HAS table (relation between ORDER and PRODUCT)
CREATE TABLE has (
    order_id_product_id SERIAL PRIMARY KEY,
    order_id INTEGER REFERENCES "order"(order_id),
    product_id INTEGER REFERENCES product(product_id),
    quantity INTEGER NOT NULL,
    unitprice DECIMAL(10, 2) NOT NULL
);

-- CART table
CREATE TABLE cart (
    cart_id SERIAL PRIMARY KEY,
    customerNo INTEGER REFERENCES customer(user_id)
);

-- CONTAINS table (relation between CART and PRODUCT)
CREATE TABLE contains (
    cart_id_product_id SERIAL PRIMARY KEY,
    cart_id INTEGER REFERENCES cart(cart_id),
    product_id INTEGER REFERENCES product(product_id),
    quantity INTEGER NOT NULL
);

-- VIEW table
CREATE TABLE view (
    user_id_order_id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES "user"(user_id),
    order_id INTEGER REFERENCES "order"(order_id)
); 