CREATE OR REPLACE PACKAGE body pkg_etl_fact_dw
AS  
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
       
	BEGIN
	   OPEN ALL_INF FOR
	       SELECT  DISTINCT  source_CL.TRANSACTION_ID AS TRANS_SOURCE
                             ,source_CL.PRODUCT_ID
                             ,source_CL.DATE_TRANSACTION
                             ,source_CL.GEO
                             ,COUNTRY_sales.TRANSACTION_ID AS TRANS_FACT
	         FROM dw_DATA.DW_TRANSACTION source_CL
                     LEFT JOIN
                        dw_DATA.T_COUNTRY_FACT_SALES_DD COUNTRY_sales
                     ON (COUNTRY_sales.TRANSACTION_ID=source_CL.TRANSACTION_ID);
                     
	
	   FETCH ALL_INF
	   BULK COLLECT INTO TRANS_ID_SOURCE, PROD_ID, DATE_RT, GEO, TRANS_ID_FACT;
	   CLOSE ALL_INF;
	
	   FOR i IN TRANS_ID_FACT.FIRST .. TRANS_ID_FACT.LAST LOOP
	      IF ( TRANS_ID_FACT ( i ) IS NULL) THEN
	         INSERT INTO t_country_fact_sales_dd ( TRANSACTION_ID
                                                  ,DATE_TRANSACTION
                                                  ,PRODUCT_id
                                                  ,GEO
                                                  ,UPDate_date)
	              VALUES ( TRANS_ID_SOURCE( i )
                         , DATE_RT( i )
                         , PROD_ID( i )
                         , GEO( i )
                         , NULL);
	         COMMIT;
	      ELSE
	         UPDATE DW_DATA.t_country_fact_sales_dd
	            SET 
                    PRODUCT_id = PROD_ID( i )
                    ,DATE_TRANSACTION = DATE_RT( i )
                    ,GEO = GEO( i )
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
       
	BEGIN
	   OPEN ALL_INF FOR
	       SELECT  DISTINCT  source_CL.TRANSACTION_ID AS TRANS_SOURCE
                             ,source_CL.PRODUCT_ID
                             ,source_CL.PROMOTION_TYPE_ID
                             ,source_CL.DATE_TRANSACTION
                             ,COUNTRY_sales.TRANSACTION_ID AS TRANS_FACT
	         FROM dw_DATA.DW_TRANSACTION source_CL
                     LEFT JOIN
                        dw_DATA.T_retail_fact_sales_dd COUNTRY_sales
                     ON (COUNTRY_sales.TRANSACTION_ID=source_CL.TRANSACTION_ID);
                     
	
	   FETCH ALL_INF
	   BULK COLLECT INTO TRANS_ID_SOURCE, PROD_ID, PROM_ID, DATE_RT, TRANS_ID_FACT;
	   CLOSE ALL_INF;
	
	   FOR i IN TRANS_ID_FACT.FIRST .. TRANS_ID_FACT.LAST LOOP
	      IF ( TRANS_ID_FACT ( i ) IS NULL) THEN
	         INSERT INTO DW_DATA.T_retail_fact_sales_dd ( TRANSACTION_ID
                                                  ,DATE_TRANSACTION
                                                  ,PRODUCT_id
                                                  ,PROMOTION_type_id
                                                  ,UPDATE_DATE)
	              VALUES ( TRANS_ID_SOURCE( i )
                         , DATE_RT( i )
                         , PROD_ID( i )
                         , PROM_ID( i )
                         , NULL);
	         COMMIT;
	      ELSE
	         UPDATE DW_DATA.T_retail_fact_sales_dd
	            SET 
                    PRODUCT_id = PROD_ID( i )
                    ,DATE_TRANSACTION = DATE_RT( i )
                    ,PROMOTION_type_id = PROM_ID( i )
                    ,UPDATE_DATE = SYSDATE
	          WHERE DW_DATA.T_retail_fact_sales_dd.TRANSACTION_ID = TRANS_ID_SOURCE( i );
	         COMMIT;
	      END IF;
	   END LOOP;
	END;
   END load_T_FACT_PROMOTION_DW;
END pkg_etl_fact_dw;