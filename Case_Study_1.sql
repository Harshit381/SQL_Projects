CREATE SCHEMA db
use db
CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER);

INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 
CREATE TABLE menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
);

INSERT INTO menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  
CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);

INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');

  SELECT * from sales
  SELECT * from menu
  SELECT * from members


 -- 1. What is the total amount each customer spent at the restaurant?

 SELECT s.customer_id, SUM(price) AS total_amount_spend 
 FROM sales s JOIN menu m ON s.product_id=m.product_id
 GROUP BY s.customer_id

 -- 2. How many days has each customer visited the restaurant?

 SELECT customer_id , COUNT(DISTINCT order_date) AS no_of_distinct_days FROM sales 
 GROUP BY customer_id

 -- 3. What was the first item from the menu purchased by each customer?
 
 WITH cte AS ( 
 SELECT * , dense_rank () over (PARTITION BY customer_id ORDER BY order_date) AS dr FROM sales ) 

 SELECT c.customer_id, m.product_name FROM cte c LEFT JOIN menu m ON c.product_id = m.product_id
 WHERE dr = 1
 GROUP BY c.customer_id , m.product_name
 
 -- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
 
 SELECT top 1 product_id , COUNT(product_id) FROM sales
 GROUP BY product_id 
 ORDER BY product_id DESC 
 
 -- 5. Which item was the most popular for each customer?
 
 WITH cte AS (
 SELECT s.customer_id, m.product_name , COUNT(m.product_id) AS fav_items ,
 DENSE_RANK() over (partition BY customer_id ORDER BY COUNT(m.product_id)) AS dr 
 FROM menu m  JOIN sales s ON m.product_id = s.product_id
GROUP BY s.customer_id, m.product_name
 )
 SELECT * FROM cte 
 WHERE dr=1

 -- 6. Which item was purchased first by the customer after they became a member?
 
  SELECT * FROM sales
  SELECT * FROM menu 
  SELECT * FROM members

  WITH max_order AS (
  SELECT m.join_date,s.*, ROW_NUMBER()over(partition BY s.customer_id ORDER BY order_date)  AS rn
  FROM members m LEFT JOIN sales s ON  s.order_date >= m.join_date AND s.customer_id=m.customer_id ) 
  SELECT customer_id,product_id FROM max_order 
  WHERE rn = 1	

  -- 7. Which item was purchased just before the customer became a member?

  WITH just_before AS (
  SELECT m.join_date,s.*,dense_rank()over(partition BY s.customer_id ORDER BY order_date DESC) AS rn
  FROM members m LEFT JOIN sales s ON s.customer_id=m.customer_id  WHERE s.order_date < m.join_date ) 
  SELECT customer_id,product_id FROM just_before 
  WHERE rn = 1	

  -- 8. What is the total items and amount spent for each member before they became a member?

  WITH total_items AS (
		SELECT  m.join_date,s.*
  FROM members m LEFT JOIN sales s ON s.customer_id=m.customer_id WHERE s.order_date < m.join_date ),
  rate AS (
  SELECT t.customer_id,   u.product_name, sum(u.price) AS amount_spend FROM total_items t LEFT JOIN menu u ON t.product_id=u.product_id 
  GROUP BY t.customer_id, u.product_name)

  SELECT customer_id,COUNT(distinct product_name) AS no_of_items ,sum(amount_spend) AS total_amount_spend FROM rate
  GROUP BY customer_id

  -- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

  WITH cte AS (
  SELECT customer_id, m.product_name, m.price, CASE WHEN m.product_name = 'sushi' THEN 2*10*price ELSE 10*price END AS reward_point
  FROM sales s JOIN  menu m ON s.product_id=m.product_id )

  SELECT customer_id , SUM(reward_point) AS total_points FROM cte 
  GROUP BY customer_id
  
  -- 10. In the first week after a customer joins the program (including their join date), they earn 2x points on all items,
         --not just sushi - how many points do customers A and B have at the end of January?

   WITH dates_cte AS 
 (
 SELECT *, 
  DATEADD(DAY, 6, join_date) AS valid_date, 
  EOMONTH('2021-01-31') AS last_date
 FROM members
 )
 /*,
 rates as (
 select s.customer_id ,s.order_date, u.product_name, u.price , 10*price as reward_ini
 from sales s join menu u on s.product_id = u.product_id 
 )
 select customer_id , case when order_date 
 */

 SELECT d.customer_id, s.order_date, d.join_date, 
 d.valid_date, d.last_date, m.product_name, m.price,
 SUM(CASE
  WHEN m.product_name = 'sushi' THEN 2 * 10 * m.price
  WHEN s.order_date BETWEEN d.join_date AND d.valid_date THEN 2 * 10 * m.price
  ELSE 10 * m.price
  END) AS points
FROM dates_cte AS d
JOIN sales AS s
 ON d.customer_id = s.customer_id
JOIN menu AS m
 ON s.product_id = m.product_id
WHERE s.order_date < d.last_date
GROUP BY d.customer_id, s.order_date, d.join_date, d.valid_date, d.last_date, m.product_name, m.price

