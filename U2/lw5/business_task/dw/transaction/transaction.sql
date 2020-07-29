DROP PROCEDURE load_transaction_DW;
CREATE PROCEDURE load_transaction_DW
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
                        DW_CUSTOMERS_DATA CUSTOMERS
                     ON (CUSTOMERS.first_name=source_CL.FIRST_NAME AND
                            source_CL.LAST_NAME = CUSTOMERS.LAST_NAME )
                     LEFT JOIN
                        DW_PRODUCT_DATA PRODUCTS
                     ON (PRODUCTS.PRODUCT_NAME = source_CL.PRODUCT_NAME AND
                        PRODUCTS.LINE_NAME = source_CL.LINE_NAME  AND 
                        PRODUCTS.COLLECTION_NAME =source_CL.COLLECTION_NAME  AND
                        PRODUCTS.SIZE_CLOTHES  =source_CL.SIZE_CLOTHES  AND
                        PRODUCTS.PRICE =source_CL.PRICE)
                     LEFT JOIN
                        DW_GEN_PROMOTION_TYPE PROMOTION
                     ON (PROMOTION.PROMOTION= source_CL.PROMOTION AND
                         PROMOTION.PRICE_PERCENT = source_CL.PRICE_PERCENT)
                     LEFT JOIN
                        DW_TRANSACTION TRANSACTIONS
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
	         INSERT INTO DW_TRANSACTION ( TRANSACTION_ID
                                        ,customer_id
                                        ,PRODUCT_id
                                        ,PROMOTION_type_id
                                        ,DATE_TRANSACTION
                                        ,period_id
                                        ,GEO)
	              VALUES ( SEQ_CUSTOMERS.NEXTVAL
	                     , CUST_ID( i )
                         , PROD_ID( i )
                         , PROM_ID( i )
                         , DATE_RT( i )
                         , 2
                         , GEO( i ));
	         COMMIT;
	      ELSIF ( TRANS_ID ( i ) IS NULL) THEN
            INSERT INTO DW_TRANSACTION ( TRANSACTION_ID
                                        ,customer_id
                                        ,PRODUCT_id
                                        ,PROMOTION_type_id
                                        ,DATE_TRANSACTION
                                        ,period_id
                                        ,GEO)
	              VALUES ( SEQ_CUSTOMERS.NEXTVAL
	                     , CUST_ID( i )
                         , PROD_ID( i )
                         , PROM_ID( i )
                         , DATE_RT( i )
                         , 1
                         , GEO( i ));
	         COMMIT;
            ELSIF( TRANS_ID ( i ) IS NULL AND PRICE(i) <= 500) THEN
	         UPDATE DW_TRANSACTION
	            SET customer_id = CUST_ID( i )
                    ,PRODUCT_id = PROD_ID( i )
                    ,PROMOTION_type_id = PROM_ID( i )
                    ,DATE_TRANSACTION = DATE_RT( i )
                    ,period_id = 1
                    ,GEO = GEO( i )
	          WHERE DW_TRANSACTION.TRANSACTION_ID = TRANS_ID ( i );
	         COMMIT;
            ELSE
	         UPDATE DW_TRANSACTION
	            SET customer_id = CUST_ID( i )
                    ,PRODUCT_id = PROD_ID( i )
                    ,PROMOTION_type_id = PROM_ID( i )
                    ,DATE_TRANSACTION = DATE_RT( i )
                    ,period_id = 2
                    ,GEO = GEO( i )
	          WHERE DW_TRANSACTION.TRANSACTION_ID = TRANS_ID ( i );
	         COMMIT; 
	      END IF;
	   END LOOP;
	END;
   END load_transaction_DW;
   
   execute load_transaction_DW;