-- C. Ingredient Optimisation
-- 1. What are the standard ingredients for each pizza?
SELECT pizza_id, toppings FROM pizza_runner.pizza_recipes

-- 2. What was the most commonly added extra?
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

SELECT extras, COUNT(extras) as extra_count FROM (SELECT unnest(string_to_array(extras, ', ')) as extras FROM data_orders_cleaned
WHERE extras IS NOT NULL) as t1
GROUP BY extras
ORDER BY 2 DESC

-- 3. What was the most common exclusion?
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

SELECT exclusions, COUNT(exclusions) as exclusions_count FROM (SELECT unnest(string_to_array(exclusions, ', ')) as exclusions FROM data_orders_cleaned
WHERE exclusions IS NOT NULL) as t1
GROUP BY exclusions
ORDER BY 2 DESC

-- 4. Generate an order item for each record in the customers_orders table in the format of one of the following:
--	Meat Lovers
--	Meat Lovers - Exclude Beef
--	Meat Lovers - Extra Bacon
--	Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers
-- 5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
--	For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"
-- 6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?