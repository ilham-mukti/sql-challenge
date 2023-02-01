--1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
SELECT week, COUNT(week) as count_runners FROM(SELECT *, TO_CHAR(registration_date, 'W' ) as week FROM pizza_runner.runners) as t1
GROUP BY week
ORDER BY week

--2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
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
FROM pizza_runner.customer_orders),

time_arrived as (SELECT *, EXTRACT(minute FROM (TO_TIMESTAMP(pickup_time,'YYYY-MM-DD-HH24-MI-SS') - order_time)) as arrived_minutes FROM data_runner_cleaned INNER JOIN data_orders_cleaned USING(order_id)
WHERE cancellation is NULL)

SELECT runner_id, AVG(arrived_minutes) as avg_time_arrived_minutes FROM time_arrived
GROUP BY runner_id

--3. Is there any relationship between the number of pizzas and how long the order takes to prepare?
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
FROM pizza_runner.customer_orders),

time_arrived as (SELECT *, EXTRACT(minute FROM (TO_TIMESTAMP(pickup_time,'YYYY-MM-DD-HH24-MI-SS') - order_time)) as arrived_minutes FROM data_runner_cleaned INNER JOIN data_orders_cleaned USING(order_id)
WHERE cancellation is NULL)

SELECT runner_id, order_id, COUNT(order_id) count_pizza, AVG(arrived_minutes) as avg_time_arrived_minutes FROM time_arrived
GROUP BY runner_id, order_id
ORDER BY 3

--4. What was the average distance travelled for each customer?
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
FROM pizza_runner.customer_orders),

time_arrived as (SELECT *, EXTRACT(minute FROM (TO_TIMESTAMP(pickup_time,'YYYY-MM-DD-HH24-MI-SS') - order_time)) as arrived_minutes FROM data_runner_cleaned INNER JOIN data_orders_cleaned USING(order_id)
WHERE cancellation is NULL)

SELECT ROUND(AVG(TO_NUMBER(distance_in_km, '999.9')),2) as avg_distance_km FROM time_arrived

--5. What was the difference between the longest and shortest delivery times for all orders?
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

SELECT max(TO_NUMBER(duration_in_minutes, '999')) - min(TO_NUMBER(duration_in_minutes, '999')) as diff_distance_minutes FROM data_runner_cleaned INNER JOIN data_orders_cleaned USING(order_id)
WHERE cancellation is NULL

--6. What was the average speed for each runner for each delivery and do you notice any trend for these values?
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

SELECT runner_id, order_id, COUNT(order_id) as count_pizza, ROUND(AVG(TO_NUMBER(duration_in_minutes, '999.9')),0) as avg_duration_minutes FROM data_runner_cleaned INNER JOIN data_orders_cleaned USING(order_id)
WHERE cancellation is NULL
GROUP BY runner_id, order_id
ORDER BY 3

--7. What is the successful delivery percentage for each runner?
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
FROM pizza_runner.customer_orders),

raw_orders AS (SELECT runner_id, COUNT(runner_id) as total_order FROM data_runner_cleaned INNER JOIN data_orders_cleaned USING(order_id)
GROUP BY runner_id),

cleaned_orders AS(SELECT runner_id, COUNT(runner_id) as total_order_succes FROM data_runner_cleaned INNER JOIN data_orders_cleaned USING(order_id)
WHERE cancellation IS NULL
GROUP BY runner_id)

SELECT *, 100*total_order_succes/total_order percentage_succes_delivery FROM raw_orders ro LEFT JOIN cleaned_orders co USING(runner_id)