-- SELECT operator
SELECT last_name, first_name, points,
  (points + 10) * 100 AS discount_factor
FROM customers;

-- SELECT DISTINCT operator: Removes duplicate data

-- Return all products
-- name
-- Unit price
-- new price (unit price * 1.1)
Select name, unit_price, unit_price * 1.1 AS 'new price'
FROM products;
----------------------------------------------------

-- WHERE operator
-- Get customers where points > 3000
SELECT *
FROM customers
WHERE points > 3000;

SELECT *
FROM customers
WHERE state != 'VA';

-- Customers born after 1990
SELECT *
FROM customers
WHERE birth_date > '1990-01-01'; -- standard for SQL dates: year-month-day

-- Get the orders placed this year
SELECT *
FROM orders
WHERE order_date >= '2019-01-01'
----------------------------------------------------

-- AND, OR, NOT operators
-- Customers that meet both conditions
SELECT *
FROM customers
WHERE birth_date > '1990-01-01' AND points > 1000;

SELECT *
FROM customers
WHERE birth_date > '1990-01-01' OR 
	(points > 1000 AND state = 'VA');

-- Customers NOT in the criteria chosen
SELECT *
FROM customers
WHERE NOT (birth_date > '1990-01-01' OR points > 1000);

-- From order_items get items
--  for order #6
--  where total price > 30
SELECT * 
FROM order_items
WHERE order_id = 6 AND (quantity * unit_price) > 30 -- total = quantity * unit price
----------------------------------------------------

-- IN operator
-- Allows for selection of multiple values in WHERE with less code

SELECT *
FROM customers
WHERE state NOT IN ('VA', 'FL', 'GA');

-- Return products with
--  quantity in stock = 49, 38, 72
SELECT *
FROM products
WHERE quantity_in_stock IN (49, 38, 72)
----------------------------------------------------

-- BETWEEN operator: selection between given values

SELECT *
FROM customers
WHERE points >= 1000 AND points <= 3000;

-- ^ same as 
SELECT *
FROM customers
WHERE points BETWEEN 1000 AND 3000;

-- Customers born between 1/1/1990 and 1/1/2000
SELECT *
FROM customers
WHERE birth_date BETWEEN '1990-01-01' AND '2000-01-01'
----------------------------------------------------

-- LIKE operator: rows that match specific pattern, REGEX is better!!!!!!!
-- %: any number of chars
-- _: single char

-- all last names that begin with b
SELECT *
FROM customers
WHERE last_name LIKE 'b%'; -- %: any # of chars after b

-- b anywhere in last name
SELECT *
FROM customers
WHERE last_name LIKE '%b%';

SELECT *
FROM customers
WHERE last_name LIKE '_y'; -- _: exactly single char

-- Customers with
--   addresses contain TRAIL or AVENUE
SELECT *
FROM customers
WHERE address LIKE '%trail%' OR 
	  address LIKE '%avenue%';
--   phone numbers that end with 9
SELECT *
FROM customers
WHERE phone LIKE '%9'
----------------------------------------------------

-- RegEx operations: REGEXP
-- Search for complex patterns
-- ^ start with, $ end with, | OR boolean operations
-- [] matches any letters in bracket, [a-z] a to z characters
SELECT *
FROM customers
WHERE last_name REGEXP 'field';

SELECT *
FROM customers
WHERE last_name REGEXP '[gim]e';

-- Exercises
-- firstnames are ELKA or AMBUR
SELECT *
FROM customers
WHERE first_name REGEXP 'ELKA|AMBUR';
-- last names end with EY or ON
SELECT *
FROM customers
WHERE last_name REGEXP 'ey$|on$';
-- last names start with MY or contains SE
SELECT *
FROM customers
WHERE last_name REGEXP '^my|se';
-- last name contain B followed by R or u
SELECT *
FROM customers
WHERE last_name REGEXP 'b[r|u]';
----------------------------------------------------

-- NULL operator
-- Check for null records with null

-- Customer withour phone number
SELECT *
FROM customers
WHERE phone is NULL;

-- Exercise: Get orders that are not shipped
SELECT *
FROM orders
WHERE shipped_date is NULL OR shipper_id is NULL;
----------------------------------------------------

-- ORDER BY clause: sort by specified condition
-- DESC: descending order
SELECT *
FROM customers
ORDER BY first_name DESC;

SELECT *
FROM customers
ORDER BY state, first_name;

SELECT *, quantity * unit_price AS total_price
FROM order_items
WHERE order_id = 2
ORDER BY total_price DESC
----------------------------------------------------

-- LIMIT clause: limit number of records returned, clause should always be at the end
-- Offset: 1, 3 -> skip one record and return next 3
SELECT *
FROM customers
LIMIT 6, 3;

-- Exercise: Get top 3 loyal customers
SELECT *
FROM customers
ORDER BY points DESC
LIMIT 3;
----------------------------------------------------
 
-- INNER JOIN operator: combine rows from two or more tables, based on a related column between them
-- Join orders and customers by id
SELECT *
FROM orders
JOIN customers ON orders.customer_id = customers.customer_id;

-- Prefix table if both tables have same column
SELECT order_id, orders.customer_id, first_name, last_name
FROM orders
JOIN customers ON orders.customer_id = customers.customer_id;

-- Use alias
SELECT order_id, o.customer_id, first_name, last_name
FROM orders o -- o = alias
JOIN customers c -- c = alias
ON o.customer_id = c.customer_id;

-- Exercise
-- Join order_items with products, 
	-- products: return product_id and name
  -- order_items: return quantity and unit_price
SELECT order_id, p.product_id, name, quantity, oi.unit_price
FROM products p
JOIN order_items oi
ON oi.product_id = p.product_id;
----------------------------------------------------

-- Joining across databases: Combine columns
-- Join order_items table with products table from sql_inventory database
SELECT *
FROM order_items oi
JOIN sql_inventory.products p -- sql_inventory = separate database
ON oi.product_id = p.product_id;
----------------------------------------------------

-- Self joins: Join a table with itself
-- Select name of each employee and their manager
USE sql_hr;
SELECT e.employee_id, e.first_name, m.first_name AS manager
FROM employees e -- employee alias
JOIN employees m -- manager alias
ON e.reports_to = m.employee_id;
----------------------------------------------------

-- Joining multiple tables: 
-- Join orders, customers, and order statuses
USE sql_store;
SELECT o.order_id, o.order_date, c.first_name, c.last_name, os.name AS status
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN order_statuses os ON o.status = os.order_status_id;

-- Exercise: Join payments, clients, and payment methods
	-- Shows the payment with name of client and payment method
USE sql_invoicing;
SELECT p.invoice_id, p.date, p.amount, c.name, pm.name
FROM payments p
JOIN clients c ON p.client_id = c.client_id
JOIN payment_methods pm ON p.payment_method = pm.payment_method_id
----------------------------------------------------

-- Compound join conditions: Used for composite primary keys -> table with multiple primary keys
-- Join customers with order items
USE sql_store;
SELECT *
FROM order_items oi
JOIN order_item_notes oin ON oi.order_id = oin.order_Id 
	AND oi.product_id = oin.product_id;
----------------------------------------------------

-- Implicit join syntax: Better to use an explicit approach
SELECT *
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id;

-- Above query is equal to the following Implicit join syntax query
SELECT *
FROM orders o, customers c
WHERE o.customer_id = c.customer_id;
----------------------------------------------------

-- Outer joins: 
-- Left outer join: All records from left table, and matched records from the right table
-- Right outer join: All records from right table, and matched records from the left table
-- Inner join
	-- Only shows customers with orders, due to the ON condition in JOIN
SELECT c.customer_id, c.first_name, o.order_id
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
ORDER BY c.customer_id;

-- Outer left join
	-- Show customers with and without orders
SELECT c.customer_id, c.first_name, o.order_id
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
ORDER BY c.customer_id;

-- Outer right join
	-- Show customers with orders
SELECT c.customer_id, c.first_name, o.order_id
FROM customers c
RIGHT JOIN orders o ON c.customer_id = o.customer_id
ORDER BY c.customer_id;

-- Exercise: Join products with order items - ordered and not ordered
	-- Return product id, name, and quantity
SELECT p.product_id, p.name, oi.quantity
FROM products p
LEFT JOIN order_items oi ON p.product_id = oi.product_id
ORDER BY p.product_id;
----------------------------------------------------

-- Outer join between multiple tables:
-- Join orders with shippers table: Left outer join and inner join
	-- All orders, including null 
SELECT c.customer_id, c.first_name, o.order_id, sh.name AS shipper
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
LEFT JOIN shippers sh ON o.shipper_id = sh.shipper_id
ORDER BY c.customer_id;

-- Exercise: Join customers, orders, shippers, and order_statuses
SELECT o.order_id, o.order_date, c.first_name AS customer, sh.name AS shipper, os.name AS status
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
LEFT JOIN shippers sh ON o.shipper_id = sh.shipper_id
LEFT JOIN order_statuses os ON o.status = os.order_status_id
ORDER BY o.order_id;
----------------------------------------------------

-- Self Outer Joins:
-- Retrieve all employees and match them with their manager, include employees with null manager
USE sql_hr;

SELECT e.employee_id, e.first_name, m.first_name AS manager
FROM employees e
LEFT JOIN employees m ON e.reports_to = m.employee_id
----------------------------------------------------

-- Using clause:
-- You can replace ON with USING clause, only works when both tables have the same column name
USE sql_store;

SELECT o.order_id, c.first_name, sh.name AS shipper
FROM orders o
JOIN customers c 
	-- ON o.customer_id = c.customer_id
    USING (customer_id) -- Same as above
LEFT JOIN shippers sh USING (shipper_id);

-- -- Join order_items with order_item_notes
SELECT *
FROM order_items oi
JOIN order_item_notes oin USING (order_id, product_id);

-- Exercise: Join payments with clients, and payment_methods
	-- Include date, client name, amount, and type of payment
USE sql_invoicing;

SELECT p.date, c.name AS client, p.amount, pm.name AS payment_method
FROM payments p
JOIN clients c USING (client_id)
LEFT JOIN payment_methods pm ON p.payment_method = pm.payment_method_id
----------------------------------------------------

-- Cross joins: Combine or join every record with multiple tables
-- Good situation for a cross join: Match table of sizes to their colors
USE sql_store;

SELECT c.first_name AS customer, p.name AS product
FROM customers c
CROSS JOIN products p
ORDER BY c.first_name;

-- Exercise: Cross join shippers and products

SELECT s.name AS shipper, p.name AS product
FROM shippers s
CROSS JOIN products p
ORDER BY s.name;
----------------------------------------------------












