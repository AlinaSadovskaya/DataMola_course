--GET THE TOTAL SALES AMOUNTS FOR EACH PRODUCT
SELECT PRODUCT_NAME, LAST_VALUE(SUM(PRICE))
                        OVER (ORDER BY SUM(PRICE)ASC RANGE BETWEEN
                        UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS PRICE
FROM SA_CUSTOMERS.sa_transaction
GROUP BY(product_name) ;

--GET INFORMATION ABOUT THE MINIMUM AMOUNT FOR SPECIFIC PRODUCTS PURCHASED BY COUNTRY
SELECT DISTINCT GEO, PRODUCT_NAME, FIRST_VALUE(PRICE)
                        OVER (ORDER BY PRICE ASC RANGE BETWEEN
                        UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS PRICE
FROM SA_CUSTOMERS.sa_transaction
ORDER BY GEO;

--returns all products purchased with a 0% discount, and then calculates the rank for each unique sales amount
select DISTINCT PRODUCT_NAME, PRICE,
       DENSE_RANK() OVER (PARTITION BY PRICE_PERCENT ORDER BY PRICE) AS RANG
  from SA_CUSTOMERS.sa_transaction
 where PRICE_PERCENT = 0
 ORDER BY RANG;
 
--returns all products purchased with a 8% discount(the RANK function returns the same rank for both products with the same price)
select DISTINCT PRODUCT_NAME, PRICE,
       RANK() OVER (PARTITION BY PRICE_PERCENT ORDER BY PRICE) AS RANG
  from SA_CUSTOMERS.sa_transaction
 where PRICE_PERCENT = 8
 ORDER BY RANG;
 
--calculated the number of products with the maximum price
select count(*)  as count from (
SELECT DISTINCT PRODUCT_NAME, last_VALUE(PRICE)
                        OVER (ORDER BY PRICE ASC RANGE BETWEEN
                        UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS PRICE
FROM SA_CUSTOMERS.sa_transaction
ORDER BY product_name);

--now we have removed all products with the maximum price
SELECT * FROM
   (SELECT * FROM SA_CUSTOMERS.sa_transaction ORDER BY price desc)
   WHERE ROWNUM < 57;

--output the maximum price for each product
SELECT distinct product_name, MAX(price)
 FROM SA_CUSTOMERS.sa_transaction
 GROUP BY product_name;
 
 
--output the average value for each product
SELECT product_name, AVG(price) as average_price
 FROM SA_CUSTOMERS.sa_transaction
 GROUP BY product_name
 order by average_price;

--outputs the price value for each product and compares it with the average value
SELECT distinct product_name, price,
AVG(price)
OVER (ORDER BY PRICE_percent ASC RANGE BETWEEN
                        UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) avg_sal
FROM SA_CUSTOMERS.sa_transaction
order by price;

--output the price and maximum discount for each product
SELECT distinct product_name, price,
max(price_percent)
OVER (ORDER BY promotion ASC RANGE BETWEEN
                        UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) max_percent
FROM SA_CUSTOMERS.sa_transaction
order by price;

--output the price and maximum price for each product
SELECT distinct product_name, price,
min(price)
OVER (ORDER BY promotion ASC RANGE BETWEEN
                        UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) min_price
FROM SA_CUSTOMERS.sa_transaction
order by price;