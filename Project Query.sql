# Alter the data type and assign primary key to the table orders
alter table orders
modify column order_id int not null,
modify column date date not null,
modify column time text not null,
add primary key(order_id);

select * from orders;

# Alter the data type and assign primary key to the table order_details
alter table order_details
modify column order_details_id int not null,
modify column order_id int not null,
modify column pizza_id text not null,
modify column quantity int not null,
add primary key(order_details_id);

select * from order_details;

# Practice Questions
-- Basic:
-- Retrieve the total number of orders placed.
-- Calculate the total revenue generated from pizza sales.
-- Identify the highest-priced pizza.
-- Identify the most common pizza size ordered.
-- List the top 5 most ordered pizza types along with their quantities.


-- Intermediate:
-- Join the necessary tables to find the total quantity of each pizza category ordered.
-- Determine the distribution of orders by hour of the day.
-- Join relevant tables to find the category-wise distribution of pizzas.
-- Group the orders by date and calculate the average number of pizzas ordered per day.
-- Determine the top 3 most ordered pizza types based on revenue.

-- Advanced:
-- Calculate the percentage contribution of each pizza type to total revenue.
-- Analyze the cumulative revenue generated over time.
-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
