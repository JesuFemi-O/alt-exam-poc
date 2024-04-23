
-- Create schema
CREATE SCHEMA IF NOT EXISTS ALT_SCHOOL;


-- create and populate tables
create table if not exists ALT_SCHOOL.PRODUCTS
(
    id  serial primary key,
    name varchar not null,
    price numeric(10, 2) not null
);


COPY ALT_SCHOOL.PRODUCTS (id, name, price)
FROM '/data/products.csv' DELIMITER ',' CSV HEADER;

-- setup customers table following the example above

-- TODO: Provide the DDL statment to create this table ALT_SCHOOL.CUSTOMERS
create table if not exists ALT_SCHOOL.CUSTOMERS
(
    customer_id  uuid not null primary key,
    device_id uuid not null,
    location varchar not NULL,
    currency varchar(4) not NULL
);

-- TODO: provide the command to copy the customers data in the /data folder into ALT_SCHOOL.CUSTOMERS
COPY ALT_SCHOOL.CUSTOMERS (customer_id, device_id, location, currency)
FROM '/data/customers.csv' DELIMITER ',' CSV HEADER;


-- TODO: complete the table DDL statement
create table if not exists ALT_SCHOOL.ORDERS
(
    order_id uuid not null primary key,
    -- provide the other fields
    customer_id uuid NOT null,
    status varchar NOT null,
    checked_out_at timestamp NOT null
);


-- provide the command to copy orders data into POSTGRES
COPY ALT_SCHOOL.ORDERS (order_id, customer_id, status, checked_out_at)
FROM '/data/orders.csv' DELIMITER ',' CSV HEADER;

create table if not exists ALT_SCHOOL.LINE_ITEMS
(
    line_item_id serial primary key,
    -- provide the remaining fields
    order_id uuid NOT NULL,
    item_id bigint NOT NULL,
    quantity bigint NOT NULL
);


-- provide the command to copy ALT_SCHOOL.LINE_ITEMS data into POSTGRES
COPY ALT_SCHOOL.LINE_ITEMS (lline_item_id, order_id, item_id, quantity)
FROM '/data/line_items.csv' DELIMITER ',' CSV HEADER;

-- setup the events table following the examle provided
create table if not exists ALT_SCHOOL.EVENTS
(
    -- TODO: PROVIDE THE FIELDS
	event id seriel PRIMARY KEY,
	customer_id uuid NOT NULL,
	event_data jsonb NOT null,
	event_timestamp timestamp NOT null
);

-- TODO: provide the command to copy ALT_SCHOOL.EVENTS data into POSTGRES
COPY ALT_SCHOOL.EVENTS (lline_item_id, order_id, item_id, quantity)
FROM '/data/events.csv' DELIMITER ',' CSV HEADER;






