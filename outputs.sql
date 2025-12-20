-- 1. Retrieve the total number of orders placed.
SELECT COUNT(DISTINCT order_id) AS total_orders
FROM orders;

-- 2. Calculate the total revenue generated from pizza sales.
SELECT round(SUM(od.quantity * p.price),2) AS total_revenue
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id;

-- 3. Identify the highest-priced pizza.
SELECT pizza_id, price
FROM pizzas
ORDER BY price DESC
LIMIT 1;

-- 4. Identify the most common pizza size ordered.
SELECT p.size, SUM(od.quantity) AS total_quantity
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
GROUP BY p.size
ORDER BY total_quantity DESC
LIMIT 1;

-- 5. List the top 5 most ordered pizza types along with their quantities.
SELECT pt.name, SUM(od.quantity) AS total_quantity
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY total_quantity DESC
LIMIT 5;

-- 6. Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT pt.category, SUM(od.quantity) AS total_quantity
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.category
ORDER BY total_quantity DESC;

-- 7. Join relevant tables to find the category-wise distribution of pizzas.
SELECT pt.category, COUNT(DISTINCT p.pizza_id) AS pizza_count
FROM pizzas p
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.category
ORDER BY pizza_count DESC;

-- 8. Determine the top 3 most ordered pizza types based on revenue.
SELECT pt.name, SUM(od.quantity * p.price) AS total_revenue
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY total_revenue DESC
LIMIT 3;

-- 9. Calculate the percentage contribution of each pizza type to total revenue.
WITH revenue_per_pizza AS (
  SELECT pt.name, SUM(od.quantity * p.price) AS revenue
  FROM order_details od
  JOIN pizzas p ON od.pizza_id = p.pizza_id
  JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
  GROUP BY pt.name
),
total AS (
  SELECT SUM(revenue) AS total_revenue FROM revenue_per_pizza
)
SELECT rpp.name, 
       rpp.revenue, 
       ROUND((rpp.revenue / t.total_revenue) * 100, 2) AS percentage
FROM revenue_per_pizza rpp, total t
ORDER BY percentage DESC;



-- 10. Determine the top 3 most ordered pizza types based on revenue for each pizza category.

SELECT category, name, revenue
FROM (
  SELECT pt.category, pt.name, 
         SUM(od.quantity * p.price) AS revenue,
         RANK() OVER (PARTITION BY pt.category ORDER BY SUM(od.quantity * p.price) DESC) AS ranks
  FROM order_details od
  JOIN pizzas p ON od.pizza_id = p.pizza_id
  JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
  GROUP BY pt.category, pt.name
) ranked
WHERE ranks <= 3
ORDER BY category, ranks;