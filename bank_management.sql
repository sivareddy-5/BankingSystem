CREATE DATABASE bank_management;
USE bank_management;

CREATE TABLE branches (
    branch_id INT AUTO_INCREMENT PRIMARY KEY,
    branch_name VARCHAR(100) NOT NULL,
    ifsc_code VARCHAR(11) NOT NULL UNIQUE,
    address VARCHAR(255) NOT NULL,
    city VARCHAR(80) NOT NULL
);

CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(60) NOT NULL,
    last_name VARCHAR(60) NOT NULL,
    email VARCHAR(120) NOT NULL UNIQUE,
    phone VARCHAR(20) UNIQUE,
    address VARCHAR(255),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE employees (
    employee_id INT AUTO_INCREMENT PRIMARY KEY,
    branch_id INT NOT NULL,
    first_name VARCHAR(60) NOT NULL,
    last_name VARCHAR(60) NOT NULL,
    role VARCHAR(60) NOT NULL,
    email VARCHAR(120) NOT NULL UNIQUE,
    FOREIGN KEY (branch_id) REFERENCES branches(branch_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE accounts (
    account_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    branch_id INT NOT NULL,
    account_type ENUM('Savings','Current','Salary','Fixed Deposit') NOT NULL,
    balance DECIMAL(14,2) NOT NULL DEFAULT 0.00,
    status ENUM('Active','Frozen','Closed') NOT NULL DEFAULT 'Active',
    opened_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (branch_id) REFERENCES branches(branch_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_nonnegative_balance CHECK (balance >= 0)
);

CREATE TABLE transactions (
    transaction_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    account_id BIGINT NOT NULL,
    transaction_type ENUM('Deposit','Withdrawal','Transfer In','Transfer Out') NOT NULL,
    amount DECIMAL(14,2) NOT NULL,
    transaction_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    description VARCHAR(255),
    FOREIGN KEY (account_id) REFERENCES accounts(account_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_positive_amount CHECK (amount > 0)
);

CREATE TABLE loans (
    loan_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    branch_id INT NOT NULL,
    loan_type ENUM('Home','Personal','Education','Vehicle','Business') NOT NULL,
    loan_amount DECIMAL(14,2) NOT NULL,
    interest_rate DECIMAL(5,2) NOT NULL,
    loan_status ENUM('Pending','Approved','Rejected','Closed') NOT NULL DEFAULT 'Pending',
    issued_at DATE,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (branch_id) REFERENCES branches(branch_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_loan_amount CHECK (loan_amount > 0),
    CONSTRAINT chk_interest_rate CHECK (interest_rate >= 0)
);

# Sample branches
INSERT INTO branches (branch_id, branch_name, ifsc_code, address, city) VALUES
(1,'Vizag Main Branch','BANK0000001','Dwaraka Nagar','Visakhapatnam'),
(2,'Hyderabad Central','BANK0000002','Abids Road','Hyderabad'),
(3,'Bengaluru City Branch','BANK0000003','MG Road','Bengaluru');

# Sample customers (fictional data)
INSERT INTO customers (customer_id, first_name, last_name, email, phone, address) VALUES
(1,'Arun','Kumar','arun.kumar@example.com','9000000101','Visakhapatnam'),
(2,'Sneha','Rao','sneha.rao@example.com','9000000102','Hyderabad'),
(3,'Rahul','Sharma','rahul.sharma@example.com','9000000103','Bengaluru'),
(4,'Meera','Das','meera.das@example.com','9000000104','Visakhapatnam'),
(5,'Kiran','Reddy','kiran.reddy@example.com','9000000105','Hyderabad'),
(6,'Divya','Nair','divya.nair@example.com','9000000106','Bengaluru');

INSERT INTO employees (employee_id, branch_id, first_name, last_name, role, email) VALUES
(1,1,'Ravi','Varma','Branch Manager','ravi.varma@bankexample.com'),
(2,1,'Sita','Devi','Teller','sita.devi@bankexample.com'),
(3,2,'Mohan','Rao','Loan Officer','mohan.rao@bankexample.com'),
(4,3,'Priya','Menon','Customer Service','priya.menon@bankexample.com');

INSERT INTO accounts (account_id, customer_id, branch_id, account_type, balance, status) VALUES
(100001,1,1,'Savings',25000.00,'Active'),
(100002,1,1,'Fixed Deposit',50000.00,'Active'),
(100003,2,2,'Current',82000.00,'Active'),
(100004,3,3,'Savings',12000.00,'Active'),
(100005,4,1,'Salary',18000.00,'Active'),
(100006,5,2,'Savings',5000.00,'Frozen'),
(100007,6,3,'Savings',34000.00,'Active');

INSERT INTO transactions (transaction_id, account_id, transaction_type, amount, transaction_date, description) VALUES
(1,100001,'Deposit',5000.00,'2026-01-03 10:00:00','Initial deposit'),
(2,100001,'Withdrawal',1000.00,'2026-01-05 11:30:00','ATM withdrawal'),
(3,100003,'Deposit',12000.00,'2026-01-07 09:15:00','Salary credit'),
(4,100004,'Withdrawal',2500.00,'2026-01-10 14:00:00','Bill payment'),
(5,100005,'Deposit',18000.00,'2026-01-15 09:00:00','Salary credit'),
(6,100006,'Deposit',2000.00,'2026-01-17 12:00:00','Cash deposit'),
(7,100007,'Withdrawal',1500.00,'2026-01-20 16:10:00','Online payment'),
(8,100003,'Withdrawal',3000.00,'2026-02-02 13:45:00','Office expense');

INSERT INTO loans (loan_id, customer_id, branch_id, loan_type, loan_amount, interest_rate, loan_status, issued_at) VALUES
(1,1,1,'Education',250000.00,8.50,'Approved','2025-08-10'),
(2,2,2,'Home',2500000.00,8.10,'Approved','2025-09-01'),
(3,3,3,'Vehicle',600000.00,9.25,'Pending',NULL),
(4,4,1,'Personal',150000.00,12.00,'Rejected',NULL),
(5,5,2,'Business',900000.00,10.50,'Approved','2025-11-15');


# Display all customers,employees,branches
SELECT * FROM customers;
SELECT * FROM branches;
SELECT * FROM employees;

# Display all bank accounts with customer names
SELECT a.account_id, CONCAT(c.first_name,' ',c.last_name) AS customer_name,
       a.account_type, a.balance, a.status
FROM accounts a JOIN customers c ON c.customer_id = a.customer_id;

# Count accounts held by each customer (include customers with zero accounts)
SELECT c.customer_id, CONCAT(c.first_name,' ',c.last_name) AS customer_name,
       COUNT(a.account_id) AS account_count
FROM customers c LEFT JOIN accounts a ON a.customer_id = c.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY c.customer_id;

# Find customers who have no bank account
SELECT c.customer_id, c.first_name, c.last_name
FROM customers c
WHERE NOT EXISTS (SELECT 1 FROM accounts a WHERE a.customer_id = c.customer_id);

# Find customers with at least one account
SELECT DISTINCT c.customer_id, c.first_name, c.last_name
FROM customers c JOIN accounts a ON a.customer_id = c.customer_id;

# Total balance across all accounts
SELECT SUM(balance) AS total_bank_balance FROM accounts WHERE status <> 'Closed';

# Total balance by branch
SELECT b.branch_name, SUM(a.balance) AS total_balance
FROM branches b LEFT JOIN accounts a ON a.branch_id = b.branch_id
GROUP BY b.branch_id, b.branch_name;

# Count accounts by account type
SELECT account_type, COUNT(*) AS account_count
FROM accounts GROUP BY account_type;

# Find accounts with balance above 20000
SELECT account_id, customer_id, account_type, balance
FROM accounts WHERE balance > 20000 ORDER BY balance DESC;

# Find all transactions for each account
SELECT t.transaction_id, t.account_id, t.transaction_type, t.amount,
       t.transaction_date, t.description
FROM transactions t ORDER BY t.account_id, t.transaction_date;

# Count transactions per account (including zero)
SELECT a.account_id, COUNT(t.transaction_id) AS transaction_count
FROM accounts a LEFT JOIN transactions t ON t.account_id = a.account_id
GROUP BY a.account_id ORDER BY a.account_id;

# Find accounts with no transactions
SELECT a.account_id FROM accounts a
WHERE NOT EXISTS (SELECT 1 FROM transactions t WHERE t.account_id = a.account_id);

# Find customers with approved loans
SELECT DISTINCT c.customer_id, c.first_name, c.last_name
FROM customers c JOIN loans l ON l.customer_id = c.customer_id
WHERE l.loan_status = 'Approved';

# Count loans by status
SELECT loan_status, COUNT(*) AS loan_count
FROM loans GROUP BY loan_status;

# Display loans with customer and branch details
SELECT l.loan_id, CONCAT(c.first_name,' ',c.last_name) AS customer_name,
       b.branch_name, l.loan_type, l.loan_amount, l.interest_rate, l.loan_status
FROM loans l
JOIN customers c ON c.customer_id = l.customer_id
JOIN branches b ON b.branch_id = l.branch_id;

# Find employees in each branch
SELECT b.branch_name, e.employee_id, CONCAT(e.first_name,' ',e.last_name) AS employee_name, e.role
FROM branches b LEFT JOIN employees e ON e.branch_id = b.branch_id
ORDER BY b.branch_id, e.employee_id;

# Find customers whose total account balance is above 30000
SELECT c.customer_id, CONCAT(c.first_name,' ',c.last_name) AS customer_name,
       SUM(a.balance) AS total_balance
FROM customers c JOIN accounts a ON a.customer_id = c.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING SUM(a.balance) > 30000;

# Find the largest loan
SELECT * FROM loans
WHERE loan_amount = (SELECT MAX(loan_amount) FROM loans);

# Find customers with more than one account
SELECT c.customer_id, CONCAT(c.first_name,' ',c.last_name) AS customer_name,
       COUNT(a.account_id) AS account_count
FROM customers c JOIN accounts a ON a.customer_id = c.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING COUNT(a.account_id) > 1;

# Final table row counts
SELECT 'branches' AS table_name, COUNT(*) AS total_rows FROM branches
UNION ALL SELECT 'customers', COUNT(*) FROM customers
UNION ALL SELECT 'employees', COUNT(*) FROM employees
UNION ALL SELECT 'accounts', COUNT(*) FROM accounts
UNION ALL SELECT 'transactions', COUNT(*) FROM transactions
UNION ALL SELECT 'loans', COUNT(*) FROM loans;


# views
CREATE VIEW account_summary AS
SELECT a.account_id, CONCAT(c.first_name,' ',c.last_name) AS customer_name,
       b.branch_name, b.city, a.account_type, a.balance, a.status, a.opened_at
FROM accounts a
JOIN customers c ON c.customer_id=a.customer_id
JOIN branches b ON b.branch_id=a.branch_id;

CREATE VIEW transaction_history AS
SELECT t.transaction_id, t.account_id,
       CONCAT(c.first_name,' ',c.last_name) AS customer_name,
       t.transaction_type, t.amount, t.transaction_date, t.description
FROM transactions t
JOIN accounts a ON a.account_id=t.account_id
JOIN customers c ON c.customer_id=a.customer_id;

CREATE VIEW loan_details AS
SELECT l.loan_id, CONCAT(c.first_name,' ',c.last_name) AS customer_name,
       b.branch_name, l.loan_type, l.loan_amount, l.interest_rate,
       l.loan_status, l.issued_at
FROM loans l
JOIN customers c ON c.customer_id=l.customer_id
JOIN branches b ON b.branch_id=l.branch_id;

START TRANSACTION;

# Transfer money from account 100001
UPDATE accounts
SET balance = balance - 1000
WHERE account_id = 100001
  AND balance >= 1000;

# Create a savepoint
SAVEPOINT after_withdrawal;

# Add money to account 100003
UPDATE accounts
SET balance = balance + 1000
WHERE account_id = 100003;

# Check the updated balances
SELECT account_id, balance
FROM accounts
WHERE account_id IN (100001, 100003);

COMMIT;

# INNER JOIN: matching accounts and customers
SELECT a.account_id, c.first_name, c.last_name, a.balance
FROM accounts a INNER JOIN customers c ON c.customer_id=a.customer_id;

# LEFT JOIN: every customer, whether or not they have an account
SELECT c.customer_id, c.first_name, a.account_id, a.balance
FROM customers c LEFT JOIN accounts a ON a.customer_id=c.customer_id;

# RIGHT JOIN: every customer, whether or not they have an account
SELECT c.customer_id, c.first_name, a.account_id, a.balance
FROM accounts a RIGHT JOIN customers c ON c.customer_id=a.customer_id;

# CROSS JOIN: each branch paired with each account type
SELECT b.branch_name, types.account_type
FROM branches b
CROSS JOIN (SELECT DISTINCT account_type FROM accounts) types;

# SELF JOIN: pairs of different accounts in the same branch
SELECT a1.account_id AS account_1, a2.account_id AS account_2, a1.branch_id
FROM accounts a1 JOIN accounts a2
  ON a1.branch_id=a2.branch_id AND a1.account_id<a2.account_id;

# FULL OUTER JOIN equivalent (MySQL does not support FULL OUTER JOIN directly)
SELECT c.customer_id, c.first_name, a.account_id, a.balance
FROM customers c LEFT JOIN accounts a ON a.customer_id=c.customer_id
UNION
SELECT c.customer_id, c.first_name, a.account_id, a.balance
FROM customers c RIGHT JOIN accounts a ON a.customer_id=c.customer_id;

# Multiple joins
SELECT a.account_id, CONCAT(c.first_name,' ',c.last_name) AS customer_name,
       b.branch_name, a.account_type, a.balance
FROM accounts a
JOIN customers c ON c.customer_id=a.customer_id
JOIN branches b ON b.branch_id=a.branch_id;

# WHERE, DISTINCT, ORDER BY, LIMIT
SELECT * FROM accounts WHERE balance>20000;
SELECT DISTINCT city FROM branches;
SELECT account_id,balance FROM accounts ORDER BY balance DESC;
SELECT account_id,balance FROM accounts ORDER BY balance DESC LIMIT 5;

# GROUP BY and HAVING
SELECT account_type, COUNT(*) AS account_count
FROM accounts GROUP BY account_type;
SELECT account_type, COUNT(*) AS account_count
FROM accounts GROUP BY account_type HAVING COUNT(*)>1;

# BETWEEN, IN, LIKE, IS NULL, IS NOT NULL
SELECT * FROM accounts WHERE balance BETWEEN 10000 AND 50000;
SELECT * FROM accounts WHERE account_type IN ('Savings','Salary');
SELECT * FROM customers WHERE first_name LIKE 'A%';
SELECT * FROM loans WHERE issued_at IS NULL;
SELECT * FROM loans WHERE issued_at IS NOT NULL;

# Comparison operators (=, <>, !=, >, <, >=, <=), AND, OR, NOT
SELECT * FROM accounts WHERE balance>=20000 AND balance<>50000;
SELECT * FROM accounts WHERE status='Active' OR balance>50000;
SELECT * FROM accounts WHERE NOT status='Frozen';

# Arithmetic operators (+, -, *, /)
SELECT account_id, balance, balance+500 AS plus_500,
       balance-500 AS minus_500, balance*1.05 AS multiplied, balance/2 AS half
FROM accounts;

# Aggregate functions: COUNT, SUM, AVG, MIN, MAX
SELECT COUNT(*) AS account_count, SUM(balance) AS total_balance,
       AVG(balance) AS average_balance, MIN(balance) AS minimum_balance,
       MAX(balance) AS maximum_balance
FROM accounts;

# CASE expression
SELECT account_id,balance,
 CASE WHEN balance>=50000 THEN 'High'
      WHEN balance>=20000 THEN 'Medium'
      ELSE 'Low' END AS balance_category
FROM accounts;

# EXISTS and NOT EXISTS
SELECT c.* FROM customers c
WHERE EXISTS (SELECT 1 FROM accounts a WHERE a.customer_id=c.customer_id);
SELECT c.* FROM customers c
WHERE NOT EXISTS (SELECT 1 FROM accounts a WHERE a.customer_id=c.customer_id);

# Scalar subquery
SELECT account_id,balance FROM accounts
WHERE balance>(SELECT AVG(balance) FROM accounts);

# UNION and UNION ALL
SELECT first_name,last_name,'Customer' AS person_type FROM customers
UNION
SELECT first_name,last_name,'Employee' AS person_type FROM employees;

SELECT first_name,last_name,'Customer' AS person_type FROM customers
UNION ALL
SELECT first_name,last_name,'Employee' AS person_type FROM employees;

# String functions
SELECT customer_id, UPPER(first_name), LOWER(last_name),
       CONCAT(first_name,' ',last_name) AS full_name, LENGTH(first_name) AS name_length
FROM customers;

# Date functions
SELECT transaction_id, transaction_date, DATE(transaction_date) AS transaction_day,
       YEAR(transaction_date) AS transaction_year, MONTH(transaction_date) AS transaction_month
FROM transactions;

# ROUND function
SELECT account_id, ROUND(balance,0) AS rounded_balance FROM accounts;

# Views: query saved views like tables
SELECT * FROM account_summary;
SELECT * FROM transaction_history;
SELECT * FROM loan_details;
SELECT * FROM account_summary WHERE balance>20000 ORDER BY balance DESC;

# Conditional aggregation
SELECT b.branch_name,
       SUM(CASE WHEN a.status='Active' THEN 1 ELSE 0 END) AS active_accounts,
       SUM(CASE WHEN a.status='Frozen' THEN 1 ELSE 0 END) AS frozen_accounts
FROM branches b LEFT JOIN accounts a ON a.branch_id=b.branch_id
GROUP BY b.branch_id,b.branch_name;

# IN subquery
SELECT * FROM customers
WHERE customer_id IN (SELECT customer_id FROM loans WHERE loan_status='Approved');

# Transactions grouped by type
SELECT transaction_type,COUNT(*) AS transaction_count,SUM(amount) AS total_amount
FROM transactions GROUP BY transaction_type ORDER BY total_amount DESC;

# Loans grouped by status
SELECT loan_status,COUNT(*) AS loan_count,SUM(loan_amount) AS total_loan_amount
FROM loans GROUP BY loan_status ORDER BY loan_count DESC;
