CREATE table menu_items (
item_id SERIAL PRIMARY KEY,
    item_name VARCHAR(50),
    category VARCHAR(50),
    department VARCHAR(50),
    base_price INTEGER,
	is_available VARCHAR(50),
    prep_time_minutes INTEGER
); 
CREATE table customer_orders (
order_id SERIAL PRIMARY KEY,
    customer_name VARCHAR(50),
	order_date DATE,
    total_amount INTEGER,
    payment_status VARCHAR(50),
    table_number INTEGER
); 
CREATE table order_details (
detail_id SERIAL PRIMARY KEY,
    order_id INTEGER,
    item_id INTEGER,
    quantity INTEGER,
    special_instructions VARCHAR(50)
); 
INSERT INTO menu_items (item_name, category, base_price, is_available, prep_time_minutes)
VALUES ('Chef Special Burger', 'Main Course', 12.00 * 1.25, TRUE, 20);
INSERT INTO customer_orders (customer_name, order_date, total_amount, payment_status, table_number)
VALUES 
('John Smith', CURRENT_DATE, 45.50, 'Paid', 5),
('Mary Johnson', CURRENT_DATE, 32.00, 'Pending', 8),
('Bob Wilson', CURRENT_DATE, 28.75, 'Paid', 3);
INSERT INTO customer_orders (customer_name)
VALUES ('Walk-in Customer');
