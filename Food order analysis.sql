1. What IS the total amount EACH customer spent ON food ORDER?

SELECT s.userid,SUM(p.price)AS total_amount FROM sales s JOIN product p USING(product_id) GROUP BY s.userid;



2. How many days has EACH customer visited the platform?

SELECT userid,COUNT(*)AS days_visited FROM sales GROUP BY userid ORDER BY userid;



3. What was the fisrt product purchased BY EACH customer?

SELECT * FROM sales  WHERE date_created IN(SELECT MIN(date_created) FROM sales GROUP BY userid) ORDER BY userid;



4. What IS the most purchased item ON the menu AND how many times was it purchased BY ALL customers?

SELECT userid,COUNT(*)AS times FROM sales WHERE product_id IN(SELECT product_id FROM sales GROUP BY product_id HAVING COUNT(*)=
(SELECT MAX(n) FROM(SELECT COUNT(*)AS n FROM sales GROUP BY product_id)a)) GROUP BY userid ORDER BY userid;



5. Which item was the most popular FOR EACH customer?

SELECT userid,product_id,MAX(cnt) FROM(SELECT userid,product_id,COUNT(*)AS cnt FROM sales GROUP BY userid,product_id)a 
GROUP BY userid ORDER BY userid;



6. Which item was purchased FIRST BY the customer AFTER they became a MEMBER?

SELECT userid,date_created,product_id,gold_signup_date FROM(SELECT userid,date_created,product_id,gold_signup_date,
RANK() OVER(PARTITION BY userid ORDER BY date_created)AS rnk FROM(SELECT s.userid,date_created,product_id,gold_signup_date 
FROM sales s JOIN goldusers_signup gs ON s.userid=gs.userid AND date_created>=gold_signup_date)a)b WHERE rnk=1;



7. Which item was purchased just BEFORE the customer became a MEMBER?

SELECT userid,date_created,product_id,gold_signup_date FROM(SELECT userid,date_created,product_id,gold_signup_date,
RANK() OVER(PARTITION BY userid ORDER BY date_created DESC)AS rnk FROM(SELECT s.userid,date_created,product_id,gold_signup_date 
FROM sales s JOIN goldusers_signup gs ON s.userid=gs.userid AND date_created<gold_signup_date)a)b WHERE rnk=1;



8. What IS the total orders AND amount spent FOR EACH MEMBER BEFORE they became a mamber?

SELECT userid,COUNT(date_created)AS order_purch,SUM(price)AS total_amt FROM(SELECT s.userid,date_created,p.product_id,gold_signup_date,
price FROM sales s JOIN goldusers_signup gs ON s.userid=gs.userid AND date_created<gold_signup_date JOIN product p 
ON s.product_id=p.product_id)a GROUP BY userid;



9. RANK ALL the transactions OF the customers

SELECT *,RANK() OVER(PARTITION BY userid ORDER BY date_created)AS rnk FROM sales;



10. RANK ALL the transactions FOR EACH MEMBER whenever they are a gold MEMBER AND FOR EVERY non gold MEMBER transactions mark AS NA

SELECT a.*,CAST((CASE WHEN gold_signup_date IS NULL THEN 'NA' ELSE RANK() OVER(PARTITION BY userid ORDER BY date_created DESC) END) 
AS CHAR)AS rnk FROM(SELECT s.userid,date_created,product_id,gold_signup_date FROM sales s LEFT JOIN goldusers_signup gs ON 
s.userid=gs.userid AND date_created>=gold_signup_date)a