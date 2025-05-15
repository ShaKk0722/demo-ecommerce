



-- USER table
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    full_name VARCHAR(30),
    create_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ADMIN table
CREATE TABLE administrator (
    user_id INTEGER PRIMARY KEY REFERENCES users(user_id),
    position VARCHAR(50) NOT NULL
);

-- CUSTOMER table
CREATE TABLE customer (
    user_id INTEGER PRIMARY KEY REFERENCES users(user_id),
    point INTEGER DEFAULT 0
);

-- ADDRESSES table
CREATE TABLE addresses (
    address_id INTEGER,
    user_id INTEGER REFERENCES users(user_id),
    housing_type VARCHAR(30),
    detail_address VARCHAR(255) NOT NULL,
    province VARCHAR(100) NOT NULL,
    district VARCHAR(100) NOT NULL,
    commune VARCHAR(100) NOT NULL,
    PRIMARY KEY (user_id, address_id)
);

-- CATEGORY table
CREATE TABLE category (
    category_id SERIAL PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL,
    category_description VARCHAR(255),
    category_imageURL VARCHAR(255)
);

-- STORE table
CREATE TABLE store (
    store_id SERIAL PRIMARY KEY,
    phone VARCHAR(20),
    store_name VARCHAR(255) NOT NULL
);

-- PRODUCT table
CREATE TABLE product (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    model VARCHAR(30),
    color VARCHAR(30),
    product_imageURL VARCHAR(255),
    brand VARCHAR(30),
    size VARCHAR(30),
    categoryNo INTEGER REFERENCES category(category_id),
    storeNo INTEGER REFERENCES store(store_id)
);


-- SUPPLY table
CREATE TABLE supply (
    store_id INTEGER REFERENCES store(store_id),
    product_id INTEGER REFERENCES product(product_id),
    quantity INTEGER NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (store_id, product_id)
);

-- ORDER table
CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    order_address VARCHAR(255) NOT NULL,
    customerNo INTEGER REFERENCES customer(user_id)
);

-- ORDER_STATUS table
CREATE TABLE order_status (
    order_id INTEGER REFERENCES orders(order_id),
    orderstatus VARCHAR(50) NOT NULL,
    modified_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY(order_id)
);

-- VOUCHER table
CREATE TABLE voucher (
    voucher_id SERIAL PRIMARY KEY,
    percent INTEGER NOT NULL
);

-- CONFIG table
CREATE TABLE config (
    voucher_id INTEGER REFERENCES voucher(voucher_id),
    user_id INTEGER REFERENCES administrator(user_id),
    percent INTEGER NOT NULL,
    PRIMARY KEY(voucher_id, user_id)
);

-- PAYMENT table
CREATE TABLE payment (
    payment_id SERIAL PRIMARY KEY,
    orderNo INTEGER REFERENCES orders(order_id),
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    method VARCHAR(50) NOT NULL,
    ammount DECIMAL(10, 2) NOT NULL
);

-- APPLY table
CREATE TABLE applies (
    voucher_id INTEGER REFERENCES voucher(voucher_id),
    payment_id INTEGER REFERENCES payment(payment_id),
    PRIMARY KEY(voucher_id, payment_id)
);

-- HAS table (relation between ORDER and PRODUCT)
CREATE TABLE has (
    order_id INTEGER REFERENCES orders(order_id),
    product_id INTEGER REFERENCES product(product_id),
    quantity INTEGER NOT NULL,
    unitprice DECIMAL(10, 2) NOT NULL,
    PRIMARY KEY(order_id, product_id)
);

-- CART table
CREATE TABLE cart (
    cart_id SERIAL PRIMARY KEY,
    customerNo INTEGER REFERENCES customer(user_id)
);

-- CONTAINS table (relation between CART and PRODUCT)
CREATE TABLE contains (
    cart_id INTEGER REFERENCES cart(cart_id),
    product_id INTEGER REFERENCES product(product_id),
    quantity INTEGER NOT NULL,
    PRIMARY KEY(cart_id, product_id)
);

-- VIEW table
CREATE TABLE view (
    user_id INTEGER REFERENCES administrator(user_id),
    order_id INTEGER REFERENCES orders(order_id),
    PRIMARY KEY(user_id, order_id)
);


-- Insert users
INSERT INTO users (email, password_hash, phone, full_name)
VALUES 
('admin1@example.com', 'hash123', '0123456789', 'Admin One'),
('customer1@example.com', 'hash123', '0987654321', 'Customer One'),
('customer2@example.com', 'hash123', '0111222333', 'Customer Two');

-- USERS
INSERT INTO users (email, password_hash, phone, full_name)
VALUES 
('admin@example.com', 'hashpass1', '0123456789', 'Admin User'),
('john@example.com', 'hashpass2', '0987654321', 'John Doe'),
('jane@example.com', 'hashpass3', '0112233445', 'Jane Smith');

-- ADMINISTRATOR
INSERT INTO administrator (user_id, position)
VALUES 
(1, 'Manager');

-- CUSTOMER
INSERT INTO customer (user_id, point)
VALUES 
(2, 100),
(3, 200);

-- ADDRESSES
INSERT INTO addresses (address_id, user_id, housing_type, detail_address, province, district, commune)
VALUES 
(1, 2, 'Apartment', '123 Main St', 'Hanoi', 'Ba Dinh', 'Cong Vi'),
(1, 3, 'House', '456 Elm St', 'HCM', 'District 1', 'Ben Nghe');

-- STORE
INSERT INTO store (phone, store_name)
VALUES 
('0123897456', 'Main Store'),
('0987123456', 'Branch Store');

-- CATEGORY
INSERT INTO category (category_name, category_description, category_imageURL)
VALUES 
('Shoes', 'All kinds of shoes', 'shoes.jpg'),
('Clothing', 'Men and women clothing', 'clothing.jpg');

-- PRODUCT
INSERT INTO product (product_name, model, color, product_imageURL, brand, size, categoryNo, storeNo)
VALUES 
('Air Max 90', 'AM90', 'Red', 'airmax90.jpg', 'Nike', '42', 1, 1),
('T-Shirt', 'TS100', 'Black', 'tshirt.jpg', 'Uniqlo', 'M', 2, 1);

-- SUPPLY
INSERT INTO supply (store_id, product_id, quantity, price)
VALUES 
(1, 1, 50, 120.00),
(1, 2, 100, 25.00);

-- CART
INSERT INTO cart (customerNo)
VALUES 
(2), (3);

-- CONTAINS
INSERT INTO contains (cart_id, product_id, quantity)
VALUES 
(1, 1, 2),
(1, 2, 1),
(2, 2, 3);

-- ORDER
INSERT INTO orders (order_address, customerNo)
VALUES 
('123 Main St, Ba Dinh, Hanoi', 2),
('456 Elm St, District 1, HCM', 3);

-- ORDER_STATUS
INSERT INTO order_status (order_id, orderstatus)
VALUES 
(1, 'Processing'),
(2, 'Shipped');

-- PAYMENT
INSERT INTO payment (orderNo, method, ammount)
VALUES 
(1, 'Credit Card', 240.00),
(2, 'COD', 75.00);

-- VOUCHER
INSERT INTO voucher (percent)
VALUES 
(10), (15);

-- CONFIG (admin applies voucher)
INSERT INTO config (voucher_id, user_id, percent)
VALUES 
(1, 1, 10),
(2, 1, 15);

-- APPLIES
INSERT INTO applies (voucher_id, payment_id)
VALUES 
(1, 1),
(2, 2);

-- HAS (product in order)
INSERT INTO has (order_id, product_id, quantity, unitprice)
VALUES 
(1, 1, 2, 120.00),
(2, 2, 3, 25.00);

-- VIEW (admin views orders)
INSERT INTO view (user_id, order_id)
VALUES 
(1, 1),
(1, 2);