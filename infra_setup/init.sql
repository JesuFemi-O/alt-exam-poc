
-- Create schema
CREATE SCHEMA IF NOT EXISTS ALT_SCHOOL;


-- setup the events table following the examle provided
create table ALT_SCHOOL.EVENTS
    (
        event_id bigint PRIMARY KEY,
        customer_id uuid,
        event_data JSONB NOT NULL,
        event_timestamp timestamp NOT NULL
    );

-- TODO: provide the command to copy ALT_SCHOOL.EVENTS data into POSTGRES


CREATE TABLE IF NOT EXISTS ALT_SCHOOL.CUSTOMERS
(
    customer_id uuid PRIMARY KEY,
    device_id uuid NOT NULL,
    location varchar,
    currency varchar
);

create table ALT_SCHOOL.ORDERS
    (
        order_id uuid not null primary key,
        customer_id uuid,
        status varchar,
        checked_out_at timestamp
    );

-- create and populate tables
create table if not exists ALT_SCHOOL.PRODUCTS
(
    id  serial primary key,
    name varchar not null,
    price numeric(10, 2) not null
);

-- provide the command to copy ALT_SCHOOL.LINE_ITEMS data into POSTGRES
create table ALT_SCHOOL.LINE_ITEMS
    (
        line_item_id BIGINT PRIMARY KEY,
        order_id uuid,
        item_id serial,
        quantity BIGINT
    );


COPY ALT_SCHOOL.EVENTS (event_id, customer_id, event_data, event_timestamp) FROM '/data/events.csv' DELIMITER ',' CSV HEADER;

COPY ALT_SCHOOL.CUSTOMERS (customer_id, device_id, location, currency) FROM '/data/customers.csv' DELIMITER ',' CSV HEADER;

COPY ALT_SCHOOL.ORDERS (order_id, customer_id, status, checked_out_at) FROM '/data/orders.csv' DELIMITER ',' CSV HEADER;

COPY ALT_SCHOOL.PRODUCTS (id, name, price) FROM '/data/products.csv' DELIMITER ',' CSV HEADER;

COPY ALT_SCHOOL.LINE_ITEMS (line_item_id, order_id, item_id, quantity) FROM '/data/line_items.csv' DELIMITER ',' CSV HEADER;


-- setup customers table following the example above

-- TODO: Provide the DDL statment to create this table ALT_SCHOOL.CUSTOMERS

-- TODO: provide the command to copy the customers data in the /data folder into ALT_SCHOOL.CUSTOMERS


-- provide the command to copy orders data into POSTGRES