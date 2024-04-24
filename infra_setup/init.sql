
-- Create schema
CREATE SCHEMA IF NOT EXISTS ALT_SCHOOL;

-- Create and populate PRODUCTS table
CREATE TABLE IF NOT EXISTS ALT_SCHOOL.PRODUCTS
(
    id SERIAL PRIMARY KEY,
    name VARCHAR NOT NULL,
    price NUMERIC(10, 2) NOT NULL
);

COPY ALT_SCHOOL.PRODUCTS (id, name, price)
FROM '/data/products.csv' DELIMITER ',' CSV HEADER;

-- Create and populate CUSTOMERS table
CREATE TABLE IF NOT EXISTS ALT_SCHOOL.CUSTOMERS
(
    customer_id UUID PRIMARY KEY,
    device_id UUID,
    location VARCHAR,
    currency VARCHAR
);

COPY ALT_SCHOOL.CUSTOMERS (customer_id, device_id, location, currency)
FROM '/data/customers.csv' DELIMITER ',' CSV HEADER;

-- Create and populate ORDERS table
CREATE TABLE IF NOT EXISTS ALT_SCHOOL.ORDERS
(
    order_id UUID NOT NULL PRIMARY KEY,
    customer_id UUID,
    status VARCHAR,
    checked_out_at TIMESTAMP
);

COPY ALT_SCHOOL.ORDERS (order_id, customer_id, status, checked_out_at)
FROM '/data/orders.csv' DELIMITER ',' CSV HEADER;

-- Create and populate LINE_ITEMS table
CREATE TABLE IF NOT EXISTS ALT_SCHOOL.LINE_ITEMS
(
    line_item_id SERIAL PRIMARY KEY,
    order_id UUID,
    item_id BIGINT,
    quantity BIGINT
);

COPY ALT_SCHOOL.LINE_ITEMS (line_item_id, order_id, item_id, quantity)
FROM '/data/line_items.csv' DELIMITER ',' CSV HEADER;

-- Create and populate EVENTS table
CREATE TABLE IF NOT EXISTS ALT_SCHOOL.EVENTS
(
    event_id BIGINT PRIMARY KEY,
    customer_id UUID,
    event_date JSONB,
    event_timestamp TIMESTAMP
);

COPY ALT_SCHOOL.EVENTS (event_id, customer_id, event_date, event_timestamp)
FROM '/data/events.csv' DELIMITER ',' CSV HEADER;







