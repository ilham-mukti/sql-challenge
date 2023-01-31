-- https://www.db-fiddle.com/f/7VcQKQwsS3CTkGRFG7vu98/65

-- 1. How many pizzas were ordered?
SELECT COUNT(pizza_id) as count_pizza_ordered FROM pizza_runner.customer_orders

-- 2. How many unique customer orders were made?
SELECT COUNT(DISTINCT customer_id) as customer_unique FROM pizza_runner.customer_orders

-- 3. How many successful orders were delivered by each runner?
WITH data_runner_cleaned as (SELECT order_id, runner_id, pickup_time, 
CASE
  WHEN distance LIKE '%km%' THEN TRIM(REPLACE(distance, 'km', ''))
  ELSE TRIM(distance)
END distance_in_km,

CASE
  WHEN duration LIKE '%min%' THEN LEFT(duration, 2)
  ELSE duration
END duration_in_minutes,
                           
CASE
  WHEN cancellation = '' then NULL
  WHEN cancellation = 'null' then NULL
  WHEN cancellation is NULL then NULL
ELSE cancellation
END cancellation
FROM pizza_runner.runner_orders)

SELECT COUNT(*) FROM data_runner_cleaned
WHERE cancellation IS NULL

-- 4. How many of each type of pizza was delivered?
WITH data_runner_cleaned as (SELECT order_id, runner_id, pickup_time, 
CASE
  WHEN distance LIKE '%km%' THEN TRIM(REPLACE(distance, 'km', ''))
  ELSE TRIM(distance)
END distance_in_km,

CASE
  WHEN duration LIKE '%min%' THEN LEFT(duration, 2)
  ELSE duration
END duration_in_minutes,
                           
CASE
  WHEN cancellation = '' then NULL
  WHEN cancellation = 'null' then NULL
  WHEN cancellation is NULL then NULL
ELSE cancellation
END cancellation
FROM pizza_runner.runner_orders),

data_orders_cleaned as(SELECT order_id, customer_id, pizza_id,
CASE
  WHEN exclusions = '' then NULL
  WHEN exclusions = 'null' then NULL
  WHEN exclusions is NULL then NULL
ELSE exclusions
END exclusions,

CASE
  WHEN extras = '' then NULL
  WHEN extras = 'null' then NULL
  WHEN extras is NULL then NULL
ELSE extras
END extras,
order_time
FROM pizza_runner.customer_orders)

SELECT pizza_id, count(pizza_id) as count_pizza FROM data_runner_cleaned INNER JOIN data_orders_cleaned USING(order_id)
WHERE cancellation is NULL
GROUP BY pizza_id

-- 5. How many Vegetarian and Meatlovers were ordered by each customer?
WITH data_orders_cleaned as(SELECT order_id, customer_id, pizza_id,
CASE
  WHEN exclusions = '' then NULL
  WHEN exclusions = 'null' then NULL
  WHEN exclusions is NULL then NULL
ELSE exclusions
END exclusions,

CASE
  WHEN extras = '' then NULL
  WHEN extras = 'null' then NULL
  WHEN extras is NULL then NULL
ELSE extras
END extras,
order_time
FROM pizza_runner.customer_orders),

count_order_pizza as (SELECT customer_id, pizza_id, COUNT(pizza_id) count_orders FROM data_orders_cleaned
GROUP BY 1, 2)

SELECT customer_id, pizza_id, pizza_name, count_orders FROM count_order_pizza INNER JOIN pizza_runner.pizza_names USING(pizza_id)
ORDER BY 1, 2

-- 6. What was the maximum number of pizzas delivered in a single order?
WITH data_runner_cleaned as (SELECT order_id, runner_id, pickup_time, 
CASE
  WHEN distance LIKE '%km%' THEN TRIM(REPLACE(distance, 'km', ''))
  ELSE TRIM(distance)
END distance_in_km,

CASE
  WHEN duration LIKE '%min%' THEN LEFT(duration, 2)
  ELSE duration
END duration_in_minutes,
                           
CASE
  WHEN cancellation = '' then NULL
  WHEN cancellation = 'null' then NULL
  WHEN cancellation is NULL then NULL
ELSE cancellation
END cancellation
FROM pizza_runner.runner_orders),

data_orders_cleaned as(SELECT order_id, customer_id, pizza_id,
CASE
  WHEN exclusions = '' then NULL
  WHEN exclusions = 'null' then NULL
  WHEN exclusions is NULL then NULL
ELSE exclusions
END exclusions,

CASE
  WHEN extras = '' then NULL
  WHEN extras = 'null' then NULL
  WHEN extras is NULL then NULL
ELSE extras
END extras,
order_time
FROM pizza_runner.customer_orders)

SELECT order_id, COUNT(order_id) as count_pizza FROM data_runner_cleaned INNER JOIN data_orders_cleaned USING(order_id)
WHERE cancellation is NULL
GROUP BY order_id
ORDER BY 2 DESC
LIMIT 1

-- 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
WITH data_runner_cleaned as (SELECT order_id, runner_id, pickup_time, 
CASE
  WHEN distance LIKE '%km%' THEN TRIM(REPLACE(distance, 'km', ''))
  ELSE TRIM(distance)
END distance_in_km,

CASE
  WHEN duration LIKE '%min%' THEN LEFT(duration, 2)
  ELSE duration
END duration_in_minutes,
                           
CASE
  WHEN cancellation = '' then NULL
  WHEN cancellation = 'null' then NULL
  WHEN cancellation is NULL then NULL
ELSE cancellation
END cancellation
FROM pizza_runner.runner_orders),

data_orders_cleaned as(SELECT order_id, customer_id, pizza_id,
CASE
  WHEN exclusions = '' then NULL
  WHEN exclusions = 'null' then NULL
  WHEN exclusions is NULL then NULL
ELSE exclusions
END exclusions,

CASE
  WHEN extras = '' then NULL
  WHEN extras = 'null' then NULL
  WHEN extras is NULL then NULL
ELSE extras
END extras,
order_time
FROM pizza_runner.customer_orders)

SELECT customer_id, changed, COUNT(changed) as changed FROM (SELECT *,
CASE
WHEN exclusions IS NULL AND extras IS NULL THEN 'No changes'
WHEN exclusions IS NOT NULL OR extras IS NOT NULL THEN 'Changes'
else 'yuhu'
END changed
FROM data_runner_cleaned INNER JOIN data_orders_cleaned USING(order_id)
WHERE cancellation IS NULL) as t1
GROUP BY customer_id, changed
ORDER BY 1, 2

-- 8. How many pizzas were delivered that had both exclusions and extras?
WITH data_runner_cleaned as (SELECT order_id, runner_id, pickup_time, 
CASE
  WHEN distance LIKE '%km%' THEN TRIM(REPLACE(distance, 'km', ''))
  ELSE TRIM(distance)
END distance_in_km,

CASE
  WHEN duration LIKE '%min%' THEN LEFT(duration, 2)
  ELSE duration
END duration_in_minutes,
                           
CASE
  WHEN cancellation = '' then NULL
  WHEN cancellation = 'null' then NULL
  WHEN cancellation is NULL then NULL
ELSE cancellation
END cancellation
FROM pizza_runner.runner_orders),

data_orders_cleaned as(SELECT order_id, customer_id, pizza_id,
CASE
  WHEN exclusions = '' then NULL
  WHEN exclusions = 'null' then NULL
  WHEN exclusions is NULL then NULL
ELSE exclusions
END exclusions,

CASE
  WHEN extras = '' then NULL
  WHEN extras = 'null' then NULL
  WHEN extras is NULL then NULL
ELSE extras
END extras,
order_time
FROM pizza_runner.customer_orders)

SELECT COUNT(*) as had_both
FROM data_runner_cleaned INNER JOIN data_orders_cleaned USING(order_id)
WHERE (cancellation IS NULL) AND (exclusions IS NOT NULL AND extras IS NOT NULL)
GROUP BY order_id

-- 9. What was the total volume of pizzas ordered for each hour of the day?
WITH data_orders_cleaned as(SELECT order_id, customer_id, pizza_id,
CASE
  WHEN exclusions = '' then NULL
  WHEN exclusions = 'null' then NULL
  WHEN exclusions is NULL then NULL
ELSE exclusions
END exclusions,

CASE
  WHEN extras = '' then NULL
  WHEN extras = 'null' then NULL
  WHEN extras is NULL then NULL
ELSE extras
END extras,
order_time
FROM pizza_runner.customer_orders)

SELECT order_time_hour, COUNT(*) as count_orders FROM (SELECT *, EXTRACT(hour FROM order_time) as order_time_hour FROM data_orders_cleaned) as t1
GROUP BY order_time_hour
ORDER BY 1

-- 10. What was the volume of orders for each day of the week?
WITH data_orders_cleaned as(SELECT order_id, customer_id, pizza_id,
CASE
  WHEN exclusions = '' then NULL
  WHEN exclusions = 'null' then NULL
  WHEN exclusions is NULL then NULL
ELSE exclusions
END exclusions,

CASE
  WHEN extras = '' then NULL
  WHEN extras = 'null' then NULL
  WHEN extras is NULL then NULL
ELSE extras
END extras,
order_time
FROM pizza_runner.customer_orders)

SELECT day, count(day) as count_orders FROM (SELECT *, to_char(order_time, 'day') AS day FROM data_orders_cleaned) as t1
GROUP BY day