-- Create databases 
CREATE TABLE branches (
    branch_code VARCHAR(10) PRIMARY KEY,
    branch_name VARCHAR(100),
    city VARCHAR(100),
    manager_name VARCHAR(100),
    employee_count INT
);
CREATE TABLE accounts (
    account_id SERIAL PRIMARY KEY,
    account_holder VARCHAR(100) NOT NULL,
    account_type VARCHAR(50),
    balance NUMERIC(15,2),
    opening_date DATE,
    branch_code VARCHAR(10) REFERENCES branches(branch_code),
    status VARCHAR(20)
);

CREATE TABLE transactions (
    transaction_id SERIAL PRIMARY KEY,
    account_id INT REFERENCES accounts(account_id),
    transaction_date DATE,
    amount NUMERIC(15,2),
    transaction_type VARCHAR(50),
    description TEXT
); 

INSERT INTO branches (branch_code, branch_name, city, manager_name, employee_count) VALUES
('BR001', 'Central Branch', 'Astana', 'Aigul Nurtayeva', 18),
('BR002', 'Southern Branch', 'Shymkent', 'Marat Yermekov', 12),
('BR003', 'Almaty Branch', 'Almaty', 'Bota Sagintayeva', 25);

INSERT INTO accounts (account_holder, account_type, balance, opening_date, branch_code, status) VALUES
('Aigerim Shointay', 'Savings', 1500000, '2020-02-15', 'BR003', 'Active'),
('Nurlan Abdurakhmanov', 'Checking', 250000, '2021-06-10', 'BR001', 'Active'),
('Assel Kuanyshbayeva', 'Savings', 87000, '2022-04-22', 'BR002', 'Inactive'),
('Bekzat Akhmetov', 'Savings', 9500, '2023-01-18', 'BR001', 'Active'),
('Zhanel Toktarova', 'Checking', 12000, '2023-05-20', 'BR003', 'Active');

INSERT INTO transactions (account_id, transaction_date, amount, transaction_type, description) VALUES
(1, '2024-01-05', 50000, 'Deposit', 'Salary'),
(1, '2024-02-11', 10000, 'Withdrawal', 'ATM cash'),
(2, '2024-03-20', 1500, 'Withdrawal', NULL),
(3, '2024-03-25', 2500, 'Withdrawal', ''),
(3, '2024-04-01', 70000, 'Deposit', 'Bonus'),
(4, '2024-05-12', 800, 'Withdrawal', 'Visa card'),
(5, '2024-06-01', 15000, 'Deposit', 'Client transfer');

-- Part A 
-- Task A1 
SELECT 
    UPPER(account_holder) AS account_holder_upper,
    LEFT(branch_code, 5) AS branch_prefix,
    CONCAT(account_type, ' - ', status) AS account_type_status
FROM accounts; 
-- Task A2
SELECT 
    account_id,
    account_holder,
    balance,
    CASE
        WHEN balance > 100000 THEN 'High Value'
        WHEN balance BETWEEN 10000 AND 100000 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS balance_category
FROM accounts;
-- Task A3
SELECT * FROM accounts
WHERE LOWER(account_holder) LIKE '%a%'; 

-- Part B 
-- Task B1
SELECT * FROM transactions
WHERE amount BETWEEN 500 AND 5000
  AND transaction_type = 'Withdrawal';
-- Task B2
SELECT 
    account_id,
    account_holder,
    balance AS original_balance,
    ROUND(balance * 1.025, 2) AS balance_with_interest
FROM accounts
WHERE LOWER(account_type) = 'savings';
-- Task B3
SELECT * FROM branches
WHERE employee_count > 10
   OR city = 'New York';
-- Task B4
SELECT * FROM transactions
WHERE description IS NULL
   OR TRIM(description) = ''; 

-- Part C 
-- Task C1
SELECT 
    account_id,
    SUM(amount) AS total_transaction_amount
FROM transactions
GROUP BY account_id;
-- Task C2
SELECT 
    branch_code,
    COUNT(account_id) AS account_count
FROM accounts
GROUP BY branch_code
HAVING COUNT(account_id) > 5;
-- Task C3
SELECT 
    account_type,
    AVG(balance) AS average_balance
FROM accounts
GROUP BY account_type; 
-- Task C4
SELECT 
    transaction_date,
    SUM(amount) AS total_deposit_amount
FROM transactions
WHERE transaction_type = 'Deposit'
GROUP BY transaction_date
ORDER BY transaction_date; 

-- Part D 
-- Task D1
SELECT *
FROM accounts a
WHERE EXISTS (
    SELECT 1
    FROM transactions t
    WHERE t.account_id = a.account_id
);
-- Task D2
SELECT *
FROM accounts
WHERE balance > ANY (
    SELECT balance
    FROM accounts
    WHERE branch_code = 'BR001'
);
