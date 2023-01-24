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
-- 6. What was the maximum number of pizzas delivered in a single order?
-- 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
-- 8. How many pizzas were delivered that had both exclusions and extras?
-- 9. What was the total volume of pizzas ordered for each hour of the day?
-- 10. What was the volume of orders for each day of the week?