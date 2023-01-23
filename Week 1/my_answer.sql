-- Case Study #1 - Danny's Diner https://8weeksqlchallenge.com/case-study-1/

-- 1. What is the total amount each customer spent at the restaurant?
SELECT customer_id, SUM(price) as total_amount FROM dannys_diner.sales INNER JOIN dannys_diner.menu USING(product_id)
GROUP BY customer_id
ORDER BY 1 

-- 2. How many days has each customer visited the restaurant?
SELECT customer_id, COUNT(DISTINCT order_date) FROM dannys_diner.sales
GROUP BY customer_id

-- 3. What was the first item from the menu purchased by each customer?
WITH first_purchased as (SELECT * FROM (SELECT *, ROW_NUMBER() OVER(Partition by customer_id order by order_date) as first_purchased FROM dannys_diner.sales) as t1
WHERE first_purchased = 1)

SELECT customer_id, order_date, product_name FROM first_purchased INNER JOIN dannys_diner.menu USING(product_id)

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
WITH most_purchased_item as(SELECT product_id, COUNT(product_id) as count_sales_product FROM dannys_diner.sales
GROUP BY product_id 
LIMIT 1)

SELECT * FROM most_purchased_item INNER JOIN dannys_diner.menu USING(product_id)

-- 5. Which item was the most popular for each customer?
SELECT customer_id, product_name, count_sales_product, price FROM (SELECT customer_id, product_id, COUNT(product_id) as count_sales_product, ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY COUNT(product_id) DESC) as rank_count FROM dannys_diner.sales
GROUP BY customer_id, product_id) as t1
INNER JOIN dannys_diner.menu USING(product_id)
WHERE rank_count = 1
ORDER BY customer_id 

-- 6. Which item was purchased first by the customer after they became a member?
WITH first_purchased_after_member as (SELECT customer_id, order_date, product_id FROM (SELECT *, ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY order_date) FROM dannys_diner.sales LEFT JOIN dannys_diner.members USING(customer_id)
WHERE order_date >= join_date) as t1
WHERE row_number = 1)

SELECT * FROM first_purchased_after_member INNER JOIN dannys_diner.menu USING(product_id)

-- 7. Which item was purchased just before the customer became a member?
WITH first_purchased_before_member as (SELECT customer_id, order_date, product_id FROM (SELECT *, ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY order_date DESC) FROM dannys_diner.sales LEFT JOIN dannys_diner.members USING(customer_id)
WHERE order_date < join_date) as t1
WHERE row_number = 1)

SELECT * FROM first_purchased_before_member INNER JOIN dannys_diner.menu USING(product_id)

-- 8. What is the total items and amount spent for each member before they became a member?
SELECT customer_id, COUNT(DISTINCT product_id) count_items, SUM(price) total_amount FROM dannys_diner.sales LEFT JOIN dannys_diner.members USING(customer_id) INNER JOIN dannys_diner.menu USING(product_id)
WHERE order_date < join_date
GROUP BY customer_id

-- 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
WITH points as (SELECT *,
CASE
WHEN product_name = 'sushi' THEN price*20
ELSE price*10
END as points
FROM dannys_diner.sales LEFT JOIN dannys_diner.members USING(customer_id) INNER JOIN dannys_diner.menu USING(product_id))

SELECT customer_id, SUM(points) as total_points FROM points
GROUP BY customer_id
ORDER BY customer_id

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
WITH table_points as(SELECT *, DATE(join_date+7) as plus_tujuh,
CASE
WHEN order_date BETWEEN join_date AND DATE(join_date+7) THEN 20
WHEN product_name = 'sushi' THEN 20
ELSE 10
END points
FROM dannys_diner.sales INNER JOIN dannys_diner.members USING(customer_id) INNER JOIN dannys_diner.menu USING(product_id))

SELECT customer_id, SUM(points) FROM table_points
WHERE DATE_PART('month', order_date) = 1
GROUP BY customer_id

-- Bonus question: Join All The Things
SELECT customer_id, order_date, product_name, price,
CASE
WHEN order_date < join_date THEN 'N'
WHEN join_date is NULL then 'N'
ELSE 'Y'
END as member
FROM dannys_diner.sales LEFT JOIN dannys_diner.members USING(customer_id) INNER JOIN dannys_diner.menu USING(product_id)
ORDER BY customer_id, order_date ASC

-- Bonus question: Rank All The Things
WITH categorize_member as(SELECT customer_id, order_date, product_name, price,
CASE
WHEN order_date < join_date THEN 'N'
WHEN join_date is NULL then 'N'
ELSE 'Y'
END as member
FROM dannys_diner.sales LEFT JOIN dannys_diner.members USING(customer_id) INNER JOIN dannys_diner.menu USING(product_id)
ORDER BY customer_id, order_date ASC)

SELECT *, RANK() OVER(PARTITION BY customer_id ORDER BY order_date) as ranking
FROM categorize_member
WHERE member = 'Y'
UNION ALL
SELECT *, NULL as ranking
FROM categorize_member
WHERE member = 'N'
ORDER BY customer_id, order_date ASC