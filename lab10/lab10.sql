CREATE TABLE accounts (
                          id SERIAL PRIMARY KEY,
                          name VARCHAR(100) NOT NULL,
                          balance DECIMAL(10, 2) DEFAULT 0.00
);
CREATE TABLE products (
                          id SERIAL PRIMARY KEY,
                          shop VARCHAR(100) NOT NULL,
                          product VARCHAR(100) NOT NULL,
                          price DECIMAL(10, 2) NOT NULL
);
-- Insert test data
INSERT INTO accounts (name, balance) VALUES
                                         ('Alice', 1000.00),
                                         ('Bob', 500.00),
                                         ('Wally', 750.00);
INSERT INTO products (shop, product, price) VALUES
                                                ('Joe''s Shop', 'Coke', 2.50),
                                                ('Joe''s Shop', 'Pepsi', 3.00);

-- 3.2 Task 1: Basic Transaction with COMMIT
BEGIN;
UPDATE accounts SET balance = balance - 100.00 WHERE name = 'Alice';
UPDATE accounts SET balance = balance + 100.00 WHERE name = 'Bob';
COMMIT;
--a) After transaction: Alice = 900, Bob = 600
--b) It's important because both updates must happen together. If one fails, the other shouldn't happen
--c) Without transaction, Alice would lose money but Bob wouldn't get it if system crashes

-- 3.3 Task 2: Using ROLLBACK
BEGIN;
UPDATE accounts SET balance = balance - 500.00
WHERE name = 'Alice';
SELECT * FROM accounts WHERE name = 'Alice';
ROLLBACK;
SELECT * FROM accounts WHERE name = 'Alice';
--a) After UPDATE: Alice balance = 400
--b) After ROLLBACK: Alice balance = 900 (back to previous)
--c) Use ROLLBACK when user makes mistake or system error occurs

-- 3.4 Task 3: Working with SAVEPOINTs
BEGIN;
UPDATE accounts SET balance = balance - 100.00
WHERE name = 'Alice';
SAVEPOINT my_savepoint;
UPDATE accounts SET balance = balance + 100.00
WHERE name = 'Bob';
ROLLBACK TO my_savepoint;
UPDATE accounts SET balance = balance + 100.00
WHERE name = 'Wally';
COMMIT;
--a) Final balances: Alice = 800, Bob = 600, Wally = 850
--b) Bob's account was credited temporarily but then undone with ROLLBACK TO
--c) SAVEPOINT lets you fix small mistakes without restarting whole transaction

-- 3.5 Task 4: Isolation Level Demonstration
-- Scenario A: READ COMMITTED
BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;
SELECT * FROM products WHERE shop = 'Joe''s Shop';
BEGIN;
DELETE FROM products WHERE shop = 'Joe''s Shop';
INSERT INTO products (shop, product, price)
VALUES ('Joe''s Shop', 'Fanta', 3.50);
COMMIT;
SELECT * FROM products WHERE shop = 'Joe''s Shop';
COMMIT;
-- Scenario B: SERIALIZABLE
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
SELECT * FROM products WHERE shop = 'Joe''s Shop';
BEGIN;
DELETE FROM products WHERE shop = 'Joe''s Shop';
INSERT INTO products (shop, product, price) VALUES ('Joe''s Shop', 'Fanta', 3.50);
COMMIT;
SELECT id, product, price FROM products WHERE shop = 'Joe''s Shop' ORDER BY id;
COMMIT;
--a) READ COMMITTED: sees changes after they're committed
--b) SERIALIZABLE: doesn't see other transaction's changes until finished
--c) Difference: READ COMMITTED allows seeing committed changes immediately, SERIALIZABLE doesn't

-- 3.6 Task 5: Phantom Read Demonstration
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SELECT MAX(price), MIN(price) FROM products
WHERE shop = 'Joe''s Shop';
BEGIN;
INSERT INTO products (shop, product, price)
VALUES ('Joe''s Shop', 'Sprite', 4.00);
COMMIT;
SELECT MAX(price), MIN(price) FROM products
WHERE shop = 'Joe''s Shop';
COMMIT;
--a) No, Terminal 1 didn't see Sprite
--b) Phantom read = seeing new rows appear between reads
--c) SERIALIZABLE prevents phantom reads

-- 3.7 Task 6: Dirty Read Demonstration
BEGIN TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SELECT * FROM products WHERE shop = 'Joe''s Shop';
BEGIN;
UPDATE products SET price = 99.99
WHERE product = 'Fanta';
SELECT * FROM products WHERE shop = 'Joe''s Shop';
ROLLBACK;
SELECT * FROM products WHERE shop = 'Joe''s Shop';
COMMIT;
--a) Yes, saw 99.99 price. Problematic because that change was never permanent!
--b) Dirty read = reading uncommitted data that might disappear
--c) Avoid READ UNCOMMITTED because you might use wrong data

-- 4. Independent Exercises
-- Exercise 1
DO $$
    DECLARE
        bob_balance NUMERIC;
    BEGIN
        SELECT balance INTO bob_balance
        FROM accounts
        WHERE name = 'Bob';

        IF bob_balance < 200 THEN
            RAISE EXCEPTION 'Transfer failed: insufficient funds.';
        END IF;

        BEGIN
            UPDATE accounts
            SET balance = balance - 200
            WHERE name = 'Bob';

            UPDATE accounts
            SET balance = balance + 200
            WHERE name = 'Wally';

            COMMIT;
        EXCEPTION
            WHEN OTHERS THEN
                ROLLBACK;
                RAISE;
        END;
    END $$;

-- Exercise 2
BEGIN;

INSERT INTO products (shop, product, price)
VALUES ('Joe''s Shop', '7up', 3.20);

SAVEPOINT sp1;

UPDATE products
SET price = 4.99
WHERE product = '7up';

SAVEPOINT sp2;

DELETE FROM products
WHERE product = '7up';

ROLLBACK TO sp1;

COMMIT;

-- Exercise 3
INSERT INTO accounts (name, balance)
VALUES ('Shared', 700.00);

-- Terminal 1 (example code)
-- READ COMMITTED: unsafe scenario
-- BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;
-- SELECT balance FROM accounts WHERE name='Shared';
-- UPDATE accounts SET balance = balance - 500 WHERE name='Shared';
-- -- WAIT for Terminal 2
-- COMMIT;

-- Terminal 2 (example code)
-- BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;
-- SELECT balance FROM accounts WHERE name='Shared';
-- UPDATE accounts SET balance = balance - 500 WHERE name='Shared';
-- COMMIT;

-- REPEATABLE READ example (safe)
-- BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
-- SELECT balance FROM accounts WHERE name='Shared';
-- UPDATE accounts SET balance = balance - 500 WHERE name='Shared';
-- -- WAIT
-- COMMIT;

-- SERIALIZABLE example (safest)
-- BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
-- SELECT balance FROM accounts WHERE name='Shared';
-- UPDATE accounts SET balance = balance - 500 WHERE name='Shared';
-- COMMIT;
-- -- If conflict occurs:
-- -- ERROR: could not serialize access due to concurrent update

-- Exercise 4
CREATE TABLE IF NOT EXISTS Sells (
                                     shop VARCHAR(100),
                                     product VARCHAR(100),
                                     price NUMERIC
);

DELETE FROM Sells;
INSERT INTO Sells VALUES
                      ('Shop1', 'A', 10),
                      ('Shop1', 'B', 20),
                      ('Shop1', 'C', 30);

-- Bad scenario (NO transactions)
-- Terminal 1:
-- SELECT MAX(price) FROM Sells WHERE shop='Shop1';

-- Terminal 2:
-- DELETE FROM Sells WHERE price=30;
-- UPDATE Sells SET price=5 WHERE price=10;

-- Terminal 1:
-- SELECT MIN(price) FROM Sells WHERE shop='Shop1';
-- This leads to MAX < MIN anomaly

-- Correct scenario using REPEATABLE READ
-- Terminal 1:
-- BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
-- SELECT MAX(price) FROM Sells WHERE shop='Shop1';
-- SELECT MIN(price) FROM Sells WHERE shop='Shop1';
-- COMMIT;

-- Terminal 2:
-- Any modifications here are NOT visible to Terminal 1
-- until Terminal 1 commits

-- 5. Questions for Self-Assessment
-- 1. Atomicity means a transaction is all-or-nothing; Consistency ensures rules are never violated; Isolation ensures concurrent transactions don’t interfere; Durability guarantees committed data is saved even after crashes.
-- 2. COMMIT saves all changes permanently, while ROLLBACK cancels all changes made in the transaction.
-- 3. SAVEPOINT is used when you want to undo only part of a transaction instead of rolling back the entire transaction.
-- 4. READ UNCOMMITTED allows dirty reads; READ COMMITTED avoids dirty reads but allows non-repeatable reads; REPEATABLE READ prevents non-repeatable reads; SERIALIZABLE prevents both non-repeatable and phantom reads.
-- 5. A dirty read is reading uncommitted data from another transaction, and it is allowed only in READ UNCOMMITTED.
-- 6. A non-repeatable read occurs when a row is read twice and returns different values because another transaction modified it in between.
-- 7. A phantom read happens when new rows appear between repeated queries; SERIALIZABLE prevents phantom reads (and REPEATABLE READ in PostgreSQL also prevents them).
-- 8. READ COMMITTED is faster and creates fewer locks, making it better for high-traffic systems than SERIALIZABLE.
-- 9. Transactions ensure consistency by isolating operations so conflicts, partial updates, and race conditions cannot corrupt the database.
-- 10. All uncommitted changes are lost if the system crashes, since only committed data is durable.