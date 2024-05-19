
-- Create schema
CREATE SCHEMA IF NOT EXISTS ALT_SCHOOL;


-- create and populate tables
create table if not exists ALT_SCHOOL.PRODUCTS
(
    id  BIGINT primary key,
    name varchar not null,
    price FLOAT not null
);


COPY ALT_SCHOOL.PRODUCTS (id, name, price)
FROM '/data/products.csv' DELIMITER ',' CSV HEADER;

-- setup customers table following the example aboveC:\Users\pc\AltSchool Africa\alt-exam-poc\data

-- TODO: Provide the DDL statment to create this table ALT_SCHOOL.CUSTOMERS

-- TODO: provide the command to copy the customers data in the /dT_SCHOOL.CUSTOMERS



-- TODO: complete the table DDL statement to create this table ALT.SCHOOL.CUSTOMERS
create table if not exists ALT_SCHOOL.CUSTOMERS
(
    Customer_id uuid not null primary key,
    device_id uuid not null,
    location varchar not null,
     currency varchar(3) not NULL
);
    COPY ALT_SCHOOL.CUSTOMERS (Customer_id, device_id, location, currency)
    FROM '/data/customers.csv' DELIMITER',' CSV HEADER;

create table if not exists ALT_SCHOOL.ORDERS
(
    order_id uuid not null primary key,
    customer_id uuid not null,
    status varchar not null,
    check_out_at timestamp
);
-- provide the command to copy orders data into POSTGRES

COPY ALT_SCHOOL.ORDERS (order_id, customer_id, status, check_out_at)
FROM '/data/orders.csv' DELIMITER',' CSV HEADER;


create table if not exists ALT_SCHOOL.LINE_ITEMS
(
    line_item_id bigint primary key,
    order_id uuid not null,
    item_id bigint not null,
    quantity bigint not null
    -- provide the remaining fields
);


-- provide the command to copy ALT_SCHOOL.LINE_ITEMS data into POSTGRES

COPY ALT_SCHOOL.LINE_ITEMS (line_item_id, order_id, item_id, quantity)
FROM '/data/line_items.csv' DELIMITER ',' CSV HEADER;




-- setup the events table following the examle provided
create table if not exists ALT_SCHOOL.EVENTS
(
    -- TODO: PROVIDE THE FIELDS
 event_id bigint primary key,
 customer_id uuid not null,
 event_data jsonb,
 event_timestamp timestamp 
);

-- TODO: provide the command to copy ALT_SCHOOL.EVENTS data into POSTGRES


COPY  ALT_SCHOOL.EVENTS (event_id, customer_id, event_data, event_timestamp)
FROM '/data/events.csv' DELIMITER ',' CSV HEADER;




