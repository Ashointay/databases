-- name: Shointay Aigerim
-- student id: 24B032117

-- Part 1: CHECK Constraints

-- Task 1.1: Basic CHECK Constraint
CREATE TABLE employees (
    employee_id integer PRIMARY KEY,
    first_name text,
    last_name text,
    age integer CHECK ( age BETWEEN 18 AND 65 ), --age must be between 18 and 65
    salary numeric CHECK ( salary > 0 ) -- salary must be > 0
);

-- Task 1.2: Named CHECK Constraint
CREATE TABLE  products_catalog (
    product_id integer PRIMARY KEY,
    product_name text,
    regular_price numeric,
    discount_price numeric,
    CONSTRAINT valid_discount CHECK (
        regular_price > 0
        AND discount_price > 0
        AND discount_price < regular_price
        )
);

-- Task 1.3: Multiple Column CHECK
CREATE TABLE booking (
    booking_id integer PRIMARY KEY,
    check_in_date date,
    check_out_date date,
    num_guests integer,
    CHECK ( num_guests BETWEEN 1 AND 10 ),
    CHECK ( check_out_date > check_in_date )
);

-- Task 1.4: Testing CHECK Constraints
INSERT INTO employees VALUES (1, 'Ivan', 'Petrov', 28, 45000);
INSERT INTO employees VALUES (2, 'Sara', 'Ivanova', 34, 65000);
-- INSERT INTO employees VALUES (3, 'Ivan', 'Petrov', 16, 45000); -- violates age constraint
-- INSERT INTO employees VALUES (4, 'Sara', 'Ivanova', 34, 0); -- violates salary constraint

INSERT INTO products_catalog VALUES (1, 'smth 1',100, 80);
INSERT INTO products_catalog VALUES (2, 'smth 2',50, 45);
-- INSERT INTO products_catalog VALUES (3, 'smth 3',100, 120); -- discount more regular prices
-- INSERT INTO products_catalog VALUES (4, 'smth 4',0, 0); -- invalid zero prices

INSERT INTO booking VALUES (1, '2025-10-10','2025-10-15', 2);
INSERT INTO booking VALUES (2, '2025-9-10','2025-9-15', 4);
-- INSERT INTO booking VALUES (3, '2025-10-10','2025-10-15', 0); -- invalid guest count
-- INSERT INTO booking VALUES (4, '2025-9-10','2025-10-15', 4); -- invalid date order


-- Part 2: NOT NULL Constraints

-- Task 2.1: NOT NULL Implementation
CREATE TABLE customers (
    customers_id integer NOT NULL PRIMARY KEY,
    email text NOT NULL,
    phone text,
    registration_date date NOT NULL
);

-- Task 2.2: Combining Constraints
CREATE TABLE inventory (
    item_id integer NOT NULL PRIMARY KEY,
    item_name text NOT NULL,
    quantity integer NOT NULL CHECK ( quantity >= 0 ),
    unit_price numeric NOT NULL CHECK ( unit_price >= 0 ),
    last_updated timestamp NOT NULL
);

-- Task 2.3: Testing NOT NULL
INSERT INTO customers VALUES (1, 'smth@gmail.com', '77001234567', '2024-05-10');
INSERT INTO customers VALUES (2, 'smth2@gmail.com', NULL, '2024-06-12');
-- INSERT INTO customers VALUES (3, NULL, '77471230956', '2024-06-12'); -- violates NOT NULL in email

INSERT INTO inventory VALUES (1, 'Screwdriver', 50, 5.99, now());
INSERT INTO inventory VALUES (2, 'Hammer', 20, 12.50, now());
-- INSERT INTO inventory VALUES (3, 'smth', -5, 5.99, now()); -- violates CHECK in quantity
-- INSERT INTO inventory VALUES (4, NULL, 20, 12.50, now()); -- violates NOT NULL in item name


-- Part 3: UNIQUE Constraints

-- Task 3.1: Single Column UNIQUE

CREATE TABLE users (
    user_id integer PRIMARY KEY,
    username text UNIQUE,
    email text UNIQUE,
    created_at timestamp DEFAULT now()
);

-- Task 3.2: Multi-Column UNIQUE
CREATE TABLE course_enrollments (
    enrollment_id integer PRIMARY KEY,
    student_id integer,
    course_code text,
    semester text,
    CONSTRAINT unique_enrollment UNIQUE (student_id, course_code, semester)
);

-- Task 3.3: Named UNIQUE Constraints
ALTER TABLE users
    ADD CONSTRAINT unique_username UNIQUE (username),
    ADD CONSTRAINT unique_email UNIQUE (email);

INSERT INTO users VALUES (1, 'alice', 'alice@example.com', now());
INSERT INTO users VALUES (2, 'bob', 'bob@example.com', now());
-- INSERT INTO users VALUES (3, 'alice', 'alice2@example.com', now()); -- duplicate username
-- INSERT INTO users VALUES (4, 'alex', 'bob@example.com', now()); -- duplicate email


-- Part 4: PRIMARY KEY Constraints

-- Task 4.1: Single Column Primary Key
CREATE TABLE departments (
    dept_id integer PRIMARY KEY,
    dept_name text NOT NULL,
    location text
);

INSERT INTO departments VALUES (1, 'IT', 'Almaty');
INSERT INTO departments VALUES (2, 'HR', 'Astana');
INSERT INTO departments VALUES (3, 'Finance', 'Shymkent');
-- INSERT INTO departments VALUES (1, 'IT', 'Almaty'); -- duplicate id
-- INSERT INTO departments VALUES (NULL, 'HR', 'Astana'); -- id cannot be NULL

--Task 4.2: Composite Primary Key
CREATE TABLE student_courses (
    student_id integer,
    course_id integer,
    enrollment_date date,
    grade text,
    PRIMARY KEY (student_id, course_id)
);

INSERT INTO student_courses VALUES (1, 2001, '2025-02-01', 'A');
INSERT INTO student_courses VALUES (2, 2002, '2025-02-05', 'B');

-- Task 4.3: Comparison Exercise
-- 1) UNIQUE allows NULLs (depending on DB) and enforces uniqueness for a column;
--    PRIMARY KEY enforces uniqueness and NOT NULL and identifies rows.
-- 2) Use composite PK when a single column cannot uniquely identify a row
--    (for example, many-to-many join table).
-- 3) A table can have only one PRIMARY KEY because it is the main identifier;
--    multiple UNIQUE constraints are allowed to enforce alternate candidate keys.


-- Part 5: FOREIGN KEY Constraints
-- Task 5.1: Basic Foreign Key
CREATE TABLE employees_dept (
    emp_id integer PRIMARY KEY,
    emp_name text NOT NULL,
    dept_id integer REFERENCES departments(dept_id),
    hire_date date
);

INSERT INTO employees_dept VALUES (10, 'Aida', 1, '2024-01-10');
-- INSERT INTO employees_dept VALUES (11, 'Ai', 99, '2024-02-10'); -- invalid dept id

-- Task 5.2: Multiple Foreign Keys
CREATE TABLE authors (
    author_id integer PRIMARY KEY,
    author_name text NOT NULL,
    country text
);

CREATE TABLE publishers (
    publisher_id integer PRIMARY KEY,
    publisher_name text NOT NULL,
    city text
);

CREATE TABLE books (
    book_id integer PRIMARY KEY,
    title text NOT NULL,
    author_id integer REFERENCES authors(author_id),
    publisher_id integer REFERENCES publishers(publisher_id),
    publication_year integer,
    isbn text UNIQUE
);

INSERT INTO authors VALUES (1, 'Gabriel Garcia Marquez', 'Colombia');
INSERT INTO authors VALUES (2, 'Fyodor Dostoevsky', 'Russia');
INSERT INTO publishers VALUES (1, 'Vintage', 'London');
INSERT INTO publishers VALUES (2, 'Penguin', 'New York');
INSERT INTO books VALUES (10001, 'One Hundred Years of Solitude', 1, 1, 1967, '978-0-123456-47-2');
INSERT INTO books VALUES (10002, 'Crime and Punishment', 2, 2, 1866, '978-0-765432-10-9');

-- Task 5.3: ON DELETE Options
CREATE TABLE IF NOT EXISTS categories (
    category_id integer PRIMARY KEY,
    category_name text NOT NULL
);

CREATE TABLE IF NOT EXISTS products_fk (
    product_id integer PRIMARY KEY,
    product_name text NOT NULL,
    category_id integer REFERENCES categories(category_id) ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS orders (
    order_id integer PRIMARY KEY,
    order_date date NOT NULL
);

CREATE TABLE IF NOT EXISTS order_items (
    item_id integer PRIMARY KEY,
    order_id integer REFERENCES orders(order_id) ON DELETE CASCADE,
    product_id integer REFERENCES products_fk(product_id),
    quantity integer CHECK (quantity > 0)
);

INSERT INTO categories VALUES (900, 'Electronics');
INSERT INTO categories VALUES (901, 'Home');
INSERT INTO products_fk VALUES (7001, 'Smartphone', 900);
INSERT INTO products_fk VALUES (7002, 'Vacuum Cleaner', 901);
INSERT INTO orders VALUES (8001, '2025-09-01');
INSERT INTO orders VALUES (8002, '2025-09-10');
INSERT INTO order_items VALUES (1, 8001, 7001, 2);
INSERT INTO order_items VALUES (2, 8001, 7002, 1);
INSERT INTO order_items VALUES (3, 8002, 7001, 1);
-- DELETE FROM categories WHERE category_id = 900; -- restrict example
-- DELETE FROM orders WHERE order_id = 8001; -- -- cascade example


-- Part 6: Practical Application

-- Task 6.1: E-commerce Database Design
CREATE TABLE ecommerce_customers (
    customer_id integer PRIMARY KEY,
    name text NOT NULL,
    email text NOT NULL UNIQUE,
    phone text,
    registration_date date NOT NULL
);

CREATE TABLE ecommerce_products (
    product_id integer PRIMARY KEY,
    name text NOT NULL,
    description text,
    price numeric NOT NULL CHECK (price >= 0),
    stock_quantity integer NOT NULL CHECK (stock_quantity >= 0)
);

CREATE TABLE ecommerce_orders (
    order_id integer PRIMARY KEY,
    customer_id integer REFERENCES ecommerce_customers(customer_id) ON DELETE SET NULL,
    order_date date NOT NULL,
    total_amount numeric NOT NULL CHECK (total_amount >= 0),
    status text NOT NULL CHECK (status IN ('pending','processing','shipped','delivered','cancelled'))
);

CREATE TABLE ecommerce_order_details (
    order_detail_id integer PRIMARY KEY,
    order_id integer REFERENCES ecommerce_orders(order_id) ON DELETE CASCADE,
    product_id integer REFERENCES ecommerce_products(product_id),
    quantity integer NOT NULL CHECK (quantity > 0),
    unit_price numeric NOT NULL CHECK (unit_price >= 0)
);

INSERT INTO ecommerce_customers VALUES (6001, 'Zhanar Abay', 'zhanar@example.kz', '77001112233', '2024-01-10');
INSERT INTO ecommerce_customers VALUES (6002, 'Bektas N.', 'bektas@example.kz', NULL, '2024-02-20');
INSERT INTO ecommerce_customers VALUES (6003, 'Aida K.', 'aida.k@example.kz', '77002223344', '2024-03-15');
INSERT INTO ecommerce_customers VALUES (6004, 'Ruslan T', 'ruslan.t@example.kz', '77003334455', '2024-04-01');
INSERT INTO ecommerce_customers VALUES (6005, 'Leyla M', 'leyla.m@example.kz', '77004445566', '2024-05-05');

INSERT INTO ecommerce_products VALUES (4001, 'USB-C Cable', '1m braided cable', 4.50, 200);
INSERT INTO ecommerce_products VALUES (4002, 'Wireless Mouse', 'Optical, 1600 DPI', 15.00, 120);
INSERT INTO ecommerce_products VALUES (4003, 'Mechanical Keyboard', 'Blue switches', 55.00, 40);
INSERT INTO ecommerce_products VALUES (4004, 'Monitor 24"', '1080p IPS', 120.00, 15);
INSERT INTO ecommerce_products VALUES (4005, 'Laptop Stand', 'Aluminum', 20.00, 80);

INSERT INTO ecommerce_orders VALUES (90001, 6001, '2025-09-20', 34.50, 'pending');
INSERT INTO ecommerce_orders VALUES (90002, 6002, '2025-09-21', 175.00, 'processing');
INSERT INTO ecommerce_orders VALUES (90003, 6003, '2025-09-22', 120.00, 'shipped');
INSERT INTO ecommerce_orders VALUES (90004, 6004, '2025-09-23', 75.00, 'delivered');
INSERT INTO ecommerce_orders VALUES (90005, 6005, '2025-09-24', 20.00, 'cancelled');

INSERT INTO ecommerce_order_details VALUES (110001, 90001, 4001, 3, 4.50);
INSERT INTO ecommerce_order_details VALUES (110002, 90002, 4004, 1, 120.00);
INSERT INTO ecommerce_order_details VALUES (110003, 90002, 4002, 1, 15.00);
INSERT INTO ecommerce_order_details VALUES (110004, 90003, 4004, 1, 120.00);
INSERT INTO ecommerce_order_details VALUES (110005, 90004, 4003, 1, 55.00);

-- INSERT INTO ecommerce_customers VALUES (6006, 'Duplicate', 'zhanar@example.kz', '77005556677', '2024-06-06'); -- duplicate email
-- INSERT INTO ecommerce_products VALUES (4999, 'Broken', 'Bad price', -5.00, 1); -- violates CHECK(price >= 0)
-- INSERT INTO ecommerce_orders VALUES (99999, 6001, '2025-10-01', 10.00, 'on-hold'); -- invalid status
-- INSERT INTO ecommerce_order_details VALUES (119999, 90001, 4001, 0, 4.50); -- invalid quantity
