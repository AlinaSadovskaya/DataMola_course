CREATE OR REPLACE PACKAGE body pkg__transaction_FACTS
AS  
   PROCEDURE load_CLEAN_transaction
   AS
      CURSOR c_v
      IS
         SELECT DISTINCT FIRST_NAME
                       , LAST_NAME
                       , PRODUCT_NAME
                       , LINE_NAME
                       , COLLECTION_NAME
                       , SIZE_CLOTHES
                       , PRICE
                       , PROMOTION
                       , VALID_FROM
                       , VALID_TO
                       , PRICE_PERCENT
                       , DATE_TRANSACTION
                       , GEO
           FROM SA_CUSTOMERS.sa_transaction
           WHERE FIRST_NAME IS NOT NULL 
           AND LAST_NAME IS NOT NULL
           AND LINE_NAME IS NOT NULL
           AND PRODUCT_NAME IS NOT NULL
           AND PROMOTION IS NOT NULL
           AND VALID_FROM IS NOT NULL
           AND SIZE_CLOTHES IS NOT NULL
           AND VALID_TO IS NOT NULL
           AND PRICE IS NOT NULL
           AND COLLECTION_NAME IS NOT NULL
           AND PRICE_PERCENT IS NOT NULL
           AND DATE_TRANSACTION IS NOT NULL
           AND GEO IS NOT NULL;
   BEGIN
      FOR i IN c_v LOOP
         INSERT INTO DW_CL.dw_cl_transaction( 
                        FIRST_NAME
                       , LAST_NAME
                       , PRODUCT_NAME
                       , LINE_NAME
                       , COLLECTION_NAME
                       , SIZE_CLOTHES
                       , PRICE
                       , PROMOTION
                       , VALID_FROM
                       , VALID_TO
                       , PRICE_PERCENT
                       , DATE_TRANSACTION
                       , GEO)
              VALUES ( i.FIRST_NAME
                       , i.LAST_NAME
                       , i.PRODUCT_NAME
                       , i.LINE_NAME
                       , i.COLLECTION_NAME
                       , i.SIZE_CLOTHES
                       , i.PRICE
                       , i.PROMOTION
                       , i.VALID_FROM
                       , i.VALID_TO
                       , i.PRICE_PERCENT
                       , i.DATE_TRANSACTION
                       , i.GEO);

         EXIT WHEN c_v%NOTFOUND;
      END LOOP;

      COMMIT;
   END load_CLEAN_transaction;
   
   
   PROCEDURE load_transaction_DW
   AS
   BEGIN
      DECLARE
	   TYPE CURSOR_INT IS TABLE OF INT;
       TYPE CURSOR_FLOAT IS TABLE OF FLOAT;
       TYPE CURSOR_DATE IS TABLE OF DATE;
	   TYPE BIG_CURSOR IS REF CURSOR ;
	
	   ALL_INF BIG_CURSOR;
	   
	   CUST_ID CURSOR_INT;
	   PROD_ID CURSOR_INT;
	   PROM_ID CURSOR_INT;
	   DATE_RT CURSOR_DATE;
       GEO CURSOR_INT;
       TRANS_ID CURSOR_INT;
       PRICE CURSOR_FLOAT;
	BEGIN
	   OPEN ALL_INF FOR
	       SELECT  DISTINCT  CUSTOMERS.CUSTOMER_ID AS CUST_ID
                 , PRODUCTS.PRODUCT_ID PROD_ID
                 , promotion.promotion_id PROM_ID
                 , source_CL.DATE_TRANSACTION AS DATE_RT
                 , SOURCE_CL.GEO AS GEO
                 , TRANSACTIONS.TRANSACTION_ID TRANS_ID
                 , PRODUCTS.PRICE PRICE
	          FROM (SELECT DISTINCT *
                           FROM dw_CL.DW_CL_TRANSACTION) source_CL
                     LEFT JOIN
                        dw_data.DW_CUSTOMERS_DATA CUSTOMERS
                     ON (CUSTOMERS.first_name=source_CL.FIRST_NAME AND
                            source_CL.LAST_NAME = CUSTOMERS.LAST_NAME )
                     LEFT JOIN
                        dw_data.DW_PRODUCT_DATA PRODUCTS
                     ON (PRODUCTS.PRODUCT_NAME = source_CL.PRODUCT_NAME AND
                        PRODUCTS.LINE_NAME = source_CL.LINE_NAME  AND 
                        PRODUCTS.COLLECTION_NAME =source_CL.COLLECTION_NAME  AND
                        PRODUCTS.SIZE_CLOTHES  =source_CL.SIZE_CLOTHES  AND
                        PRODUCTS.PRICE =source_CL.PRICE)
                     LEFT JOIN
                        dw_data.DW_GEN_PROMOTION_TYPE PROMOTION
                     ON (PROMOTION.PROMOTION= source_CL.PROMOTION AND
                         PROMOTION.PRICE_PERCENT = source_CL.PRICE_PERCENT)
                     LEFT JOIN
                        dw_data.DW_TRANSACTION TRANSACTIONS
                     ON (CUSTOMERS.CUSTOMER_ID = TRANSACTIONS.CUSTOMER_ID AND
                         PRODUCTS.PRODUCT_ID = TRANSACTIONS.PRODUCT_ID AND
                         PROMOTION.PROMOTION_ID = TRANSACTIONS.PROMOTION_TYPE_ID AND
                         source_CL.DATE_TRANSACTION = transactions.date_transaction AND
                         SOURCE_CL.GEO = transactions.GEO);
                     
	
	   FETCH ALL_INF
	   BULK COLLECT INTO CUST_ID, PROD_ID, PROM_ID, DATE_RT, GEO, TRANS_ID, PRICE;
	   CLOSE ALL_INF;
	
	   FOR i IN TRANS_ID.FIRST .. TRANS_ID.LAST LOOP
	      IF ( TRANS_ID ( i ) IS NULL AND PRICE( i ) <= 500) THEN
	         INSERT INTO DW_DATA.DW_TRANSACTION ( TRANSACTION_ID
                                        ,customer_id
                                        ,PRODUCT_id
                                        ,PROMOTION_type_id
                                        ,DATE_TRANSACTION
                                        ,period_id
                                        , PRICE
                                        ,GEO)
	              VALUES ( SEQ_CUSTOMERS.NEXTVAL
	                     , CUST_ID( i )
                         , PROD_ID( i )
                         , PROM_ID( i )
                         , DATE_RT( i )
                         , 2
                         , PRICE( i )
                         , GEO( i ));
	         COMMIT;
	      ELSIF ( TRANS_ID ( i ) IS NULL) THEN
            INSERT INTO dw_data.DW_TRANSACTION ( TRANSACTION_ID
                                        ,customer_id
                                        ,PRODUCT_id
                                        ,PROMOTION_type_id
                                        ,DATE_TRANSACTION
                                        ,period_id
                                        ,price
                                        ,GEO)
	              VALUES ( SEQ_CUSTOMERS.NEXTVAL
	                     , CUST_ID( i )
                         , PROD_ID( i )
                         , PROM_ID( i )
                         , DATE_RT( i )
                         , 1
                         , price( i )
                         , GEO( i ));
	         COMMIT;
            ELSIF( TRANS_ID ( i ) IS NULL AND PRICE(i) <= 500) THEN
	         UPDATE dw_data.DW_TRANSACTION
	            SET customer_id = CUST_ID( i )
                    ,PRODUCT_id = PROD_ID( i )
                    ,PROMOTION_type_id = PROM_ID( i )
                    ,DATE_TRANSACTION = DATE_RT( i )
                    ,period_id = 1
                    ,price = price(i)
                    ,GEO = GEO( i )
	          WHERE dw_data.DW_TRANSACTION.TRANSACTION_ID = TRANS_ID ( i );
	         COMMIT;
            ELSE
	         UPDATE dw_data.DW_TRANSACTION
	            SET customer_id = CUST_ID( i )
                    ,PRODUCT_id = PROD_ID( i )
                    ,PROMOTION_type_id = PROM_ID( i )
                    ,DATE_TRANSACTION = DATE_RT( i )
                    ,period_id = 2
                    ,price = price( i )
                    ,GEO = GEO( i )
	          WHERE dw_data.DW_TRANSACTION.TRANSACTION_ID = TRANS_ID ( i );
	         COMMIT; 
	      END IF;
	   END LOOP;
	END;
   END load_transaction_DW;
   
   
  PROCEDURE load_T_FACT_COUNTRY_DW
   AS
   BEGIN
      DECLARE
	   TYPE CURSOR_INT IS TABLE OF INT;
       TYPE CURSOR_FLOAT IS TABLE OF FLOAT;
       TYPE CURSOR_DATE IS TABLE OF DATE;
	   TYPE BIG_CURSOR IS REF CURSOR ;
	
	   ALL_INF BIG_CURSOR;
	   
       TRANS_ID_SOURCE CURSOR_INT;
	   TRANS_ID_FACT CURSOR_INT;
	   PROD_ID CURSOR_INT;
	   DATE_RT CURSOR_DATE;
       GEO CURSOR_INT;
       price cursor_float;
       
	BEGIN
	   OPEN ALL_INF FOR
	       SELECT  DISTINCT  source_CL.TRANSACTION_ID AS TRANS_SOURCE
                             ,source_CL.PRODUCT_ID
                             ,source_CL.DATE_TRANSACTION
                             ,source_CL.GEO
                             ,source_cl.price
                             ,COUNTRY_sales.TRANSACTION_ID AS TRANS_FACT
	         FROM dw_DATA.DW_TRANSACTION source_CL
                     LEFT JOIN
                        dw_DATA.T_COUNTRY_FACT_SALES_DD COUNTRY_sales
                     ON (COUNTRY_sales.TRANSACTION_ID=source_CL.TRANSACTION_ID);
                     
	
	   FETCH ALL_INF
	   BULK COLLECT INTO TRANS_ID_SOURCE, PROD_ID, DATE_RT, GEO, price, TRANS_ID_FACT;
	   CLOSE ALL_INF;
	
	   FOR i IN TRANS_ID_FACT.FIRST .. TRANS_ID_FACT.LAST LOOP
	      IF ( TRANS_ID_FACT ( i ) IS NULL) THEN
	         INSERT INTO dw_data.t_country_fact_sales_dd ( TRANSACTION_ID
                                                  ,DATE_TRANSACTION
                                                  ,PRODUCT_id
                                                  ,GEO
                                                  ,price
                                                  ,UPDate_date)
	              VALUES ( TRANS_ID_SOURCE( i )
                         , DATE_RT( i )
                         , PROD_ID( i )
                         , GEO( i )
                         , price(i)
                         , NULL);
	         COMMIT;
	      ELSE
	         UPDATE DW_DATA.t_country_fact_sales_dd
	            SET 
                    PRODUCT_id = PROD_ID( i )
                    ,DATE_TRANSACTION = DATE_RT( i )
                    ,GEO = GEO( i )
                    ,price = price(i)
                    ,UPDATE_DATE = SYSDATE
	          WHERE DW_DATA.t_country_fact_sales_dd.TRANSACTION_ID = TRANS_ID_SOURCE( i );
	         COMMIT;
	      END IF;
	   END LOOP;
	END;
   END load_T_FACT_COUNTRY_DW;
   
   
   PROCEDURE load_T_FACT_PROMOTION_DW
   AS
   BEGIN
      DECLARE
	   TYPE CURSOR_INT IS TABLE OF INT;
       TYPE CURSOR_FLOAT IS TABLE OF FLOAT;
       TYPE CURSOR_DATE IS TABLE OF DATE;
	   TYPE BIG_CURSOR IS REF CURSOR ;
	
	   ALL_INF BIG_CURSOR;
	   
       TRANS_ID_SOURCE CURSOR_INT;
	   TRANS_ID_FACT CURSOR_INT;
	   PROD_ID CURSOR_INT;
	   PROM_ID CURSOR_INT;
	   DATE_RT CURSOR_DATE;
       PRICE CURSOR_FLOAT;
	BEGIN
	   OPEN ALL_INF FOR
	       SELECT  DISTINCT  source_CL.TRANSACTION_ID AS TRANS_SOURCE
                             ,source_CL.PRODUCT_ID
                             ,source_CL.PROMOTION_TYPE_ID
                             ,source_CL.DATE_TRANSACTION
                             ,source_cl.price
                             ,COUNTRY_sales.TRANSACTION_ID AS TRANS_FACT
	         FROM dw_DATA.DW_TRANSACTION source_CL
                     LEFT JOIN
                        dw_DATA.T_retail_fact_sales_dd COUNTRY_sales
                     ON (COUNTRY_sales.TRANSACTION_ID=source_CL.TRANSACTION_ID);
                     
	
	   FETCH ALL_INF
	   BULK COLLECT INTO TRANS_ID_SOURCE, PROD_ID, PROM_ID, DATE_RT, price, TRANS_ID_FACT;
	   CLOSE ALL_INF;
	
	   FOR i IN TRANS_ID_FACT.FIRST .. TRANS_ID_FACT.LAST LOOP
	      IF ( TRANS_ID_FACT ( i ) IS NULL) THEN
	         INSERT INTO DW_DATA.T_retail_fact_sales_dd ( TRANSACTION_ID
                                                  ,DATE_TRANSACTION
                                                  ,PRODUCT_id
                                                  ,PROMOTION_type_id
                                                  ,price
                                                  ,UPDATE_DATE)
	              VALUES ( TRANS_ID_SOURCE( i )
                         , DATE_RT( i )
                         , PROD_ID( i )
                         , PROM_ID( i )
                         , price( i )
                         , NULL);
	         COMMIT;
	      ELSE
	         UPDATE DW_DATA.T_retail_fact_sales_dd
	            SET 
                    PRODUCT_id = PROD_ID( i )
                    ,DATE_TRANSACTION = DATE_RT( i )
                    ,PROMOTION_type_id = PROM_ID( i )
                    ,UPDATE_DATE = SYSDATE
                    ,price = price(i)
	          WHERE DW_DATA.T_retail_fact_sales_dd.TRANSACTION_ID = TRANS_ID_SOURCE( i );
	         COMMIT;
	      END IF;
	   END LOOP;
	END;
   END load_T_FACT_PROMOTION_DW;
   
   
   PROCEDURE load_FACT_COUNTRY
   AS
   BEGIN
      DECLARE
	   TYPE CURSOR_INT IS TABLE OF INT;
       TYPE CURSOR_FLOAT IS TABLE OF FLOAT;
       TYPE CURSOR_DATE IS TABLE OF DATE;
	   TYPE BIG_CURSOR IS REF CURSOR ;
	
	   ALL_INF BIG_CURSOR;
	   
	   SALES_ID CURSOR_INT;
	   PROD_ID CURSOR_INT;
	   DATE_ID CURSOR_DATE;
       GEO_ID CURSOR_INT;
       price cursor_float;
       
	BEGIN
	   OPEN ALL_INF FOR
	       SELECT  DISTINCT  COUNTRY_sales.sales_id
                             ,source_DW.DATE_TRANSACTION
                             ,source_DW.PRODUCT_ID
                             ,source_DW.GEO
                             ,source_DW.price
	         FROM dw_DATA.T_COUNTRY_FACT_SALES_DD source_DW
                     LEFT JOIN
                        ALINA.COUNTRY_FACT_SALES_DD COUNTRY_sales
                     ON (COUNTRY_sales.PRODUCT_ID = source_DW.product_id
                     AND COUNTRY_sales.DATE_ID = source_DW.date_transaction
                     AND COUNTRY_SALES.GEO_ID = SOURCE_DW.GEO);
                     
	
	   FETCH ALL_INF
	   BULK COLLECT INTO SALES_ID, DATE_ID, PROD_ID, GEO_ID, price;
	   CLOSE ALL_INF;
	
	   FOR i IN SALES_ID.FIRST .. SALES_ID.LAST LOOP
	      IF (SALES_ID( i ) IS NULL) THEN
	         INSERT INTO ALINA.COUNTRY_FACT_SALES_DD ( SALES_ID
                                                  ,DATE_ID
                                                  ,PRODUCT_id
                                                  ,GEO_ID
                                                  ,SALE_SUM
                                                  ,INSERT_DATE
                                                  ,UPDate_date)
	              VALUES ( SEQ_fact_country.NEXTVAL
                         , DATE_ID( i )
                         , PROD_ID( i )
                         , GEO_ID( i )
                         , price(i)
                         , DATE_ID( i )
                         , NULL);
	         COMMIT;
	      ELSE
	         UPDATE ALINA.COUNTRY_FACT_SALES_DD 
	            SET 
                    sale_sum = sale_sum + price(i)
                    ,UPDATE_DATE = SYSDATE;
	         COMMIT;
	      END IF;
	   END LOOP;
	END;
   END load_FACT_COUNTRY;

    
   PROCEDURE load_FACT_PROMOTION
   AS
   BEGIN
      DECLARE
	   TYPE CURSOR_INT IS TABLE OF INT;
       TYPE CURSOR_FLOAT IS TABLE OF FLOAT;
       TYPE CURSOR_DATE IS TABLE OF DATE;
	   TYPE BIG_CURSOR IS REF CURSOR ;
	
	   ALL_INF BIG_CURSOR;
	   
       sales_id CURSOR_INT;
	   PROD_ID CURSOR_INT;
	   PROM_ID CURSOR_INT;
	   DATE_id CURSOR_DATE;
       PRICE CURSOR_FLOAT;
       PRICE_PERCENT CURSOR_FLOAT;
	BEGIN
	   OPEN ALL_INF FOR
	       SELECT  DISTINCT  PROM_sales.SALES_ID
                             ,source_DW.DATE_TRANSACTION
                             ,source_DW.PRODUCT_ID
                             ,prom_hist.surrogate_key
                             ,source_DW.price
                             ,prom_hist.price_decreasing_percent
	         FROM dw_DATA.T_RETAIL_FACT_SALES_DD source_DW
                     LEFT JOIN
                        ALINA.RETAIL_FACT_SALES_DD PROM_sales
                     ON (PROM_sales.DATE_ID = source_dw.date_transaction
                            AND PROM_sales.PRODUCT_ID = source_dw.product_id
                            AND prom_sales.promotion_id = source_dw.promotion_type_id)
                     LEFT JOIN
                        ALINA.DIM_PROMOTIONS_SCD PROM_HIST
                     ON (PROM_HIST.promotion_id = source_dw.promotion_type_id)
                    WHERE source_dw.date_transaction BETWEEN PROM_HIST.VALID_FROM AND PROM_HIST.VALID_TO;
                     
	
	   FETCH ALL_INF
	   BULK COLLECT INTO SALES_ID, DATE_ID, PROD_ID, PROM_ID, price, PRICE_PERCENT;
	   CLOSE ALL_INF;
	
	   FOR i IN SALES_ID.FIRST .. SALES_ID.LAST LOOP
	      IF ( SALES_ID ( i ) IS NULL) THEN
	         INSERT INTO ALINA.retail_fact_sales_dd ( SALES_ID
                                                  ,DATE_ID
                                                  ,PRODUCT_id
                                                  ,PROMOTION_id
                                                  ,sale_sum
                                                  ,sales_amount
                                                  ,insert_date
                                                  ,UPDATE_DATE)
	              VALUES ( SEQ_fact_promotion.NEXTVAL
                         , DATE_ID( i )
                         , PROD_ID( i )
                         , PROM_ID( i )
                         , price( i )
                         , PRICE(i)*price_percent(i)/100
                         , date_id(i)
                         , NULL);
	         COMMIT;
	      ELSE
	         UPDATE ALINA.retail_fact_sales_dd
	            SET 
                    UPDATE_DATE = SYSDATE
                    ,sale_sum = sale_sum + price(i)
                    ,sales_amount = sales_amount + PRICE(i)*price_percent(i)/100;
	         COMMIT;
	      END IF;
	   END LOOP;
	END;
   END load_FACT_PROMOTION;
   
END pkg__transaction_FACTS;