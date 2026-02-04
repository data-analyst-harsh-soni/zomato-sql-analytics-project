DROP TABLE IF EXISTS delivery, orders, rider, restaurants, customers CASCADE;

CREATE TABLE customers (
    customer_id VARCHAR(15) PRIMARY KEY,
    customer_name VARCHAR(30),
    reg_date DATE
);

CREATE TABLE restaurants (
    restaurant_id VARCHAR(20) PRIMARY KEY,
    restaurant_name VARCHAR(100), 
    city VARCHAR(50),
    opening_hours VARCHAR(50)
);

CREATE TABLE rider (
    rider_id VARCHAR(20) PRIMARY KEY,
    rider_name VARCHAR(25),
    sign_up_date DATE
);

-- 4. Orders Table (CORRECTED)
CREATE TABLE orders (
    order_id VARCHAR(30) PRIMARY KEY, 
    customer_id VARCHAR(15),
    restaurant_id VARCHAR(20),
    order_item VARCHAR(50), 
    order_date DATE,
    order_time TIME,
    order_status VARCHAR(50), 
    total_amount NUMERIC(10,2) 
);

CREATE TABLE delivery (
    delivery_id VARCHAR(15) PRIMARY KEY,
    order_id VARCHAR(30), 
    delivery_status VARCHAR(20),
    delivery_time TIME,
    rider_id VARCHAR(20)
);

ALTER TABLE orders
ADD CONSTRAINT fk_customer
FOREIGN KEY (customer_id)
REFERENCES customers(customer_id);

ALTER TABLE orders
ADD CONSTRAINT fk_restaurant
FOREIGN KEY (restaurant_id)
REFERENCES restaurants(restaurant_id);

ALTER TABLE delivery
ADD CONSTRAINT fk_rider
FOREIGN KEY (rider_id)
REFERENCES rider(rider_id);

ALTER TABLE delivery
ADD CONSTRAINT fk_order
FOREIGN KEY (order_id)
REFERENCES orders(order_id);