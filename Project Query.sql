-- Use Pizza_Sales;
# CREATE TABLE pizza
CREATE TABLE IF NOT EXISTS pizza (
    pizza_id TEXT,
    pizza_type_id TEXT,
    size TEXT,
    price DOUBLE
);
# load csv file to the table using 'Table Data Import Wizard' or Python
SELECT 
    *
FROM
    pizza;

# CREATE TABLE pizza_types
CREATE TABLE IF NOT EXISTS pizza_types (
    pizza_type_id TEXT,
    name TEXT,
    category TEXT,
    ingredients TEXT
);
# load csv file to the table using 'Table Data Import Wizard' or Python
SELECT 
    *
FROM
    pizza_types;

# CREATE TABLE orders
CREATE TABLE IF NOT EXISTS orders (
    order_id INT NOT NULL PRIMARY KEY,
    date DATE NOT NULL,
    time TEXT NOT NULL
);
# load csv file to the table using 'Table Data Import Wizard' or Python
SELECT 
    *
FROM
    orders;

# CREATE TABLE order_details
CREATE TABLE IF NOT EXISTS order_details (
    order_details_id INT NOT NULL PRIMARY KEY,
    order_id INT NOT NULL,
    pizza_id TEXT NOT NULL,
    quantity INT NOT NULL
);
# load csv file to the table using 'Table Data Import Wizard' or Python
SELECT 
    *
FROM
    order_details;

# Practice Questions
-- Basic:
-- Retrieve the total number of orders placed.
SELECT 
    COUNT(*) AS 'Total number of orders'
FROM
    orders;
-- Calculate the total revenue generated from pizza sales.
SELECT 
    ROUND(SUM(o.quantity * p.price), 2) AS 'Total revenue'
FROM
    order_details o
        JOIN
    pizza p ON o.pizza_id = p.pizza_id COLLATE utf8mb4_unicode_ci;
-- Identify the highest-priced pizza.
SELECT 
    pt.name, p.price
FROM
    pizza_types pt
        JOIN
    pizza p ON pt.pizza_type_id = p.pizza_type_id COLLATE utf8mb4_unicode_ci
ORDER BY p.price DESC
LIMIT 1;
-- Identify the most common pizza size ordered.
SELECT 
    p.size, COUNT(p.size) AS freq
FROM
    pizza p
        JOIN
    order_details o ON p.pizza_id = o.pizza_id COLLATE utf8mb4_unicode_ci
GROUP BY p.size
ORDER BY COUNT(p.size) DESC
LIMIT 1;
-- List the top 5 most ordered pizza types along with their quantities.
SELECT 
    pt.name, SUM(o.quantity) AS quantity
FROM
    pizza_types pt
        JOIN
    pizza p ON pt.pizza_type_id = p.pizza_type_id COLLATE utf8mb4_unicode_ci
        JOIN
    order_details o ON p.pizza_id = o.pizza_id COLLATE utf8mb4_unicode_ci
GROUP BY pt.name
ORDER BY quantity DESC
LIMIT 5;

-- Intermediate:
-- Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT 
    pt.category, SUM(o.quantity) AS 'total quantity'
FROM
    pizza_types pt
        JOIN
    pizza p ON pt.pizza_type_id = p.pizza_type_id COLLATE utf8mb4_unicode_ci
        JOIN
    order_details o ON p.pizza_id = o.pizza_id COLLATE utf8mb4_unicode_ci
GROUP BY pt.category;
-- Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(time) AS hour_of_day,
    COUNT(order_id) AS 'total number of order'
FROM
    orders
GROUP BY hour_of_day
ORDER BY hour_of_day;
-- Join relevant tables to find the category-wise distribution of pizzas.
# Table: pizza, pizza_types, order_details
# Attributes: category, quantity
SELECT 
    category, COUNT(pizza_type_id) AS 'quantity'
FROM
    pizza_types
GROUP BY category
ORDER BY 'quantity';
-- Group the orders by date and calculate the average number of pizzas ordered per day.
# Wrong as below shown:-
SELECT 
    o.date,
    ROUND(SUM(od.quantity) / COUNT(od.order_id), 2) AS 'average number of pizzas ordered per day'
FROM
    orders o
        JOIN
    order_details od ON o.order_id = od.order_id COLLATE utf8mb4_unicode_ci
GROUP BY o.date;

# Correct Answer:-
SELECT 
    ROUND(AVG(order_quantity), 0) AS average_quantity
FROM (
    SELECT 
        o.date, 
        SUM(od.quantity) AS order_quantity
    FROM
        orders o
    JOIN
        order_details od ON o.order_id = od.order_id
    GROUP BY 
        o.date
) AS daily_orders;
-- Determine the top 3 most ordered pizza types based on revenue.
SELECT 
    pt.name,
    ROUND(SUM(p.price * o.quantity), 0) AS 'total revenue'
FROM
    pizza_types pt
        JOIN
    pizza p ON pt.pizza_type_id = p.pizza_type_id COLLATE utf8mb4_unicode_ci
        JOIN
    order_details o ON p.pizza_id = o.pizza_id COLLATE utf8mb4_unicode_ci
GROUP BY pt.name
ORDER BY SUM(p.price * o.quantity) DESC
LIMIT 3;

-- Advanced:
-- Calculate the percentage contribution of each pizza type to total revenue.
SELECT 
    pt.category,
    ROUND(SUM(o.quantity * p.price) / (SELECT 
                    SUM(o.quantity * p.price)
                FROM
                    pizza_types pt
                        JOIN
                    pizza p ON pt.pizza_type_id = p.pizza_type_id COLLATE utf8mb4_unicode_ci
                        JOIN
                    order_details o ON p.pizza_id = o.pizza_id COLLATE utf8mb4_unicode_ci) * 100,
            2) AS 'percentage contribution'
FROM
    pizza_types pt
        JOIN
    pizza p ON pt.pizza_type_id = p.pizza_type_id COLLATE utf8mb4_unicode_ci
        JOIN
    order_details o ON p.pizza_id = o.pizza_id COLLATE utf8mb4_unicode_ci
GROUP BY pt.category;
-- Analyze the cumulative revenue generated over time.
SELECT DISTINCT
    o.date, SUM(od.quantity * p.price) OVER w as 'cumulative revenue'
FROM
    orders o
        JOIN
    order_details od ON o.order_id = od.order_id COLLATE utf8mb4_unicode_ci
        JOIN
    pizza p ON p.pizza_id = od.pizza_id COLLATE utf8mb4_unicode_ci
WINDOW w AS(ORDER BY o.date);
-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
WITH cte AS (
    SELECT 
        pt.name, 
        pt.category,
        SUM(o.quantity * p.price) AS revenue,
        ROW_NUMBER() OVER w AS a
    FROM
        pizza_types pt
        JOIN pizza p ON pt.pizza_type_id = p.pizza_type_id COLLATE utf8mb4_unicode_ci
        JOIN order_details o ON p.pizza_id = o.pizza_id COLLATE utf8mb4_unicode_ci
    GROUP BY
        pt.name, pt.category
	WINDOW w AS (PARTITION BY pt.category ORDER BY SUM(o.quantity * p.price) DESC)
)
SELECT
    name, revenue
FROM
    cte
WHERE
    a <= 3
ORDER BY
	revenue DESC;