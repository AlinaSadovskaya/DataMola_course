CREATE OR REPLACE PACKAGE body pkg_products
AS 

PROCEDURE load_CLEAN_product
   AS
      CURSOR c_v
      IS
         SELECT DISTINCT product_NAME
                       , LINE_ID
                       , LINE_NAME
                       , COLLECTION_ID
                       , COLLECTION_NAME
                       , SEASON_ID
                       , SEASON
                       , SIZE_CLOTHES
                       , COLOR
                       , PRICE
                       , INSERT_DATE
           FROM SA_CUSTOMERS.sa_product_data
           WHERE product_NAME IS NOT NULL 
           AND LINE_ID IS NOT NULL
           AND LINE_NAME IS NOT NULL
           AND COLLECTION_ID IS NOT NULL
           AND SEASON_ID IS NOT NULL
           AND SEASON IS NOT NULL
           AND SIZE_CLOTHES IS NOT NULL
           AND COLOR IS NOT NULL
           AND PRICE IS NOT NULL
           AND COLLECTION_NAME IS NOT NULL;
   BEGIN
      FOR i IN c_v LOOP
         INSERT INTO DW_CL.DW_CL_product_DATA( 
                        product_NAME
                       , LINE_ID
                       , LINE_NAME
                       , COLLECTION_ID
                       , COLLECTION_NAME
                       , SEASON_ID
                       , SEASON
                       , SIZE_CLOTHES
                       , COLOR
                       , PRICE
                       , INSERT_DATE)
              VALUES ( i.product_NAME
                       , i.LINE_ID
                       , i.LINE_NAME
                       , i.COLLECTION_ID
                       , i.COLLECTION_NAME
                       , i.SEASON_ID
                       , i.SEASON
                       , i.SIZE_CLOTHES
                       , i.COLOR
                       , i.PRICE
                       , i.INSERT_DATE);

         EXIT WHEN c_v%NOTFOUND;
      END LOOP;

      COMMIT;
   END load_CLEAN_product;
   
   
   
   PROCEDURE load_PRODUCTS_DW
   AS
   BEGIN
      DECLARE
	   TYPE CURSOR_VARCHAR IS TABLE OF varchar2(50);
	   TYPE CURSOR_NUMBER IS TABLE OF number(10);  
       TYPE CURSOR_DATE IS TABLE OF DATE;
       TYPE CURSOR_FLOAT IS TABLE OF FLOAT;
	   TYPE BIG_CURSOR IS REF CURSOR ;
	
	   ALL_INF BIG_CURSOR;
	   
        PRODUCT_NAME_SOURCE      CURSOR_VARCHAR;
        LINE_ID_SOURCE           CURSOR_NUMBER;
        LINE_NAME         CURSOR_VARCHAR;
        COLLECTION_ID_SOURCE     CURSOR_NUMBER;
        COLLECTION_NAME   CURSOR_VARCHAR;
        SEASON_ID         CURSOR_NUMBER;
        SEASON            CURSOR_VARCHAR;
        SIZE_CLOTHES      CURSOR_VARCHAR;
        COLOR             CURSOR_VARCHAR;
        PRICE             CURSOR_FLOAT;
        INSERT_DATE       CURSOR_DATE;
        PRODUCT_NAME      CURSOR_VARCHAR;
        LINE_ID           CURSOR_NUMBER;
        COLLECTION_ID     CURSOR_NUMBER;
        PRODUCT_ID        CURSOR_NUMBER;
        
	BEGIN
	   OPEN ALL_INF FOR
	       SELECT source_CL.PRODUCT_NAME AS PRODUCT_NAME_source_CL
                 , source_CL.LINE_ID AS LINE_ID_source_CL
                 , source_CL.LINE_NAME AS LINE_NAME
	             , source_CL.COLLECTION_ID AS COLLECTION_ID_source_CL
	             , source_CL.COLLECTION_NAME AS COLLECTION_NAME
                 , source_CL.SEASON_ID AS SEASON_ID_source_CL
                 , source_CL.SEASON AS SEASON
	             , source_CL.SIZE_CLOTHES AS SIZE_CLOTHES
	             , source_CL.COLOR AS COLOR
                 , source_CL.PRICE AS PRICE
                 , source_CL.INSERT_DATE AS INSERT_DATE
	             , stage.PRODUCT_NAME AS PRODUCT_NAME_stage
                 , stage.LINE_ID AS LINE_ID_STAGE
                 , stage.COLLECTION_ID AS COLLECTION_ID_STAGE
                 , STAGE.PRODUCT_ID AS PRODUCT_ID
	          FROM (SELECT DISTINCT *
                           FROM dw_CL.DW_CL_PRODUCT_DATA) source_CL
                     LEFT JOIN
                        dw_data.DW_PRODUCT_DATA stage
                     ON (source_CL.PRODUCT_NAME = stage.PRODUCT_NAME AND source_CL.LINE_ID = stage.LINE_ID);

	
	   FETCH ALL_INF
	   BULK COLLECT INTO PRODUCT_NAME_SOURCE
                             ,LINE_ID_SOURCE 
                             ,LINE_NAME 
                             ,COLLECTION_ID_SOURCE
                             ,COLLECTION_NAME
                             ,SEASON_ID
                             ,SEASON
                             ,SIZE_CLOTHES
                             ,COLOR
                             ,PRICE
                             ,INSERT_DATE
                             ,PRODUCT_NAME
                             ,LINE_ID
                             ,COLLECTION_ID
                             ,PRODUCT_ID;
	
	   CLOSE ALL_INF;
	
	   FOR i IN PRODUCT_ID.FIRST .. PRODUCT_ID.LAST LOOP
	      IF ( PRODUCT_ID ( i ) IS NULL ) THEN
	         INSERT INTO dw_data.DW_PRODUCT_DATA (   PRODUCT_ID
                                             ,PRODUCT_NAME
                                             ,LINE_ID 
                                             ,LINE_NAME 
                                             ,COLLECTION_ID
                                             ,COLLECTION_NAME
                                             ,SEASON_ID
                                             ,SEASON
                                             ,SIZE_CLOTHES
                                             ,COLOR
                                             ,PRICE
                                             ,INSERT_DATE
                                             ,UPDATE_DATE)
	              VALUES ( SEQ_PRODUCTS.NEXTVAL
	                      ,PRODUCT_NAME_SOURCE( i )
                          ,LINE_ID_SOURCE ( i )
                          ,LINE_NAME ( i )
                          ,COLLECTION_ID_source ( i )
                          ,COLLECTION_NAME( i )
                          ,SEASON_ID ( i )
                          ,SEASON ( i )
                          ,SIZE_CLOTHES ( i )
                          ,COLOR ( i )
                          ,PRICE ( i )
                          ,INSERT_DATE( i )
	                      , NULL );
	
	         COMMIT;
	      ELSIF ( LINE_ID_SOURCE ( i )<> LINE_ID ( i )) THEN
                 INSERT INTO dw_data.DW_PRODUCT_DATA (   PRODUCT_ID
                                             ,PRODUCT_NAME
                                             ,LINE_ID 
                                             ,LINE_NAME 
                                             ,COLLECTION_ID
                                             ,COLLECTION_NAME
                                             ,SEASON_ID
                                             ,SEASON
                                             ,SIZE_CLOTHES
                                             ,COLOR
                                             ,PRICE
                                             ,INSERT_DATE
                                             ,UPDATE_DATE)
	              VALUES ( SEQ_PRODUCTS.NEXTVAL
	                      ,PRODUCT_NAME_SOURCE( i )
                          ,LINE_ID_SOURCE ( i )
                          ,LINE_NAME ( i )
                          ,COLLECTION_ID_SOURCE ( i )
                          ,COLLECTION_NAME( i )
                          ,SEASON_ID ( i )
                          ,SEASON ( i )
                          ,SIZE_CLOTHES ( i )
                          ,COLOR ( i )
                          ,PRICE ( i )
                          ,INSERT_DATE( i )
	                      , NULL );
                  COMMIT;
           ELSE UPDATE dw_data.DW_PRODUCT_DATA
                    SET PRODUCT_NAME = PRODUCT_NAME_SOURCE( i )
                          ,LINE_ID = LINE_ID_SOURCE( i )
                          ,LINE_NAME = Line_name ( i )
                          ,collection_id = COLLECTION_ID_source ( i )
                          ,COLLECTION_NAME = Collection_name ( i )
                          ,SEASON_ID = SEASON_ID ( i )
                          ,SEASON = SEASON ( i )
                          ,SIZE_CLOTHES = SIZE_CLOTHES ( i )
                          ,COLOR = COLOR ( i )
                          ,PRICE = PRICE ( i )
	                      ,UPDATE_DATE = SYSDATE
                    
	          WHERE dw_data.DW_product_DATA.product_ID = product_ID ( i );
	
	         COMMIT;
	      END IF;
	   END LOOP;
	END;
   END load_productS_DW;
   
   
   PROCEDURE load_product_dim
   AS
   BEGIN
      DECLARE
	   TYPE CURSOR_VARCHAR IS TABLE OF varchar2(50);
	   TYPE CURSOR_NUMBER IS TABLE OF number(10);  
       TYPE CURSOR_DATE IS TABLE OF DATE;
       TYPE CURSOR_FLOAT IS TABLE OF FLOAT;
	   TYPE BIG_CURSOR IS REF CURSOR ;
	
	   ALL_INF BIG_CURSOR;
	   
        PRODUCT_NAME      CURSOR_VARCHAR;
        LINE_ID          CURSOR_NUMBER;
        LINE_NAME         CURSOR_VARCHAR;
        COLLECTION_ID    CURSOR_NUMBER;
        COLLECTION_NAME   CURSOR_VARCHAR;
        SEASON_ID         CURSOR_NUMBER;
        SEASON            CURSOR_VARCHAR;
        SIZE_CLOTHES      CURSOR_VARCHAR;
        COLOR             CURSOR_VARCHAR;
        PRICE             CURSOR_FLOAT;
        INSERT_DATE       CURSOR_DATE;
        PRODUCT_ID_SOURCE        CURSOR_NUMBER;
        PRODUCT_ID        CURSOR_NUMBER;
	BEGIN
	   OPEN ALL_INF FOR
	       SELECT source_DW.PRODUCT_NAME AS PRODUCT_NAME_source
                 , source_DW.LINE_ID AS LINE_ID_source
                 , source_DW.LINE_NAME AS LINE_NAME_SOURCE
	             , source_DW.COLLECTION_ID AS COLLECTION_ID_source
	             , source_DW.COLLECTION_NAME AS COLLECTION_NAME
                 , source_DW.SEASON_ID AS SEASON_ID_source
                 , source_DW.SEASON AS SEASON_SOURCE
	             , source_DW.SIZE_CLOTHES AS SIZE_CLOTHES_SOURCE
	             , source_DW.COLOR AS COLOR_SOURCE
                 , source_DW.PRICE AS PRICE_SOURCE
                 , source_DW.INSERT_DATE AS INSERT_DATE_SOURCE
                 , source_DW.PRODUCT_ID AS PRODUCT_ID_SOURCE
                 , STAGE.PRODUCT_ID AS PRODUCT_ID
	          FROM (SELECT DISTINCT *
                           FROM dw_DATA.DW_PRODUCT_DATA) source_DW
                     LEFT JOIN
                        alina.DIM_PRODUCT stage
                     ON (source_DW.PRODUCT_ID = stage.PRODUCT_ID);

	
	   FETCH ALL_INF
	   BULK COLLECT INTO PRODUCT_NAME, LINE_ID, LINE_NAME,COLLECTION_ID
                         ,COLLECTION_NAME, SEASON_ID, SEASON, SIZE_CLOTHES
                         ,COLOR, PRICE , INSERT_DATE, PRODUCT_ID_SOURCE, PRODUCT_ID;
	
	   CLOSE ALL_INF;
	
	   FOR i IN PRODUCT_ID.FIRST .. PRODUCT_ID.LAST LOOP
	      IF ( PRODUCT_ID ( i ) IS NULL AND PRODUCT_ID_SOURCE ( i )IS NOT NULL) THEN
	         INSERT INTO alina.DIM_PRODUCT (   PRODUCT_ID
                                        ,PRODUCT_NAME
                                        ,LINE_ID
                                        ,LINE_NAME
                                        ,COLLECTION_ID
                                        ,COLLECTION_NAME
                                        ,SEASON_ID
                                        ,SEASON
                                        ,SIZE_CLOTHES
                                        ,COLOR
                                        ,PRICE
                                        ,INSERT_DATE
                                        ,UPDATE_DATE)
	              VALUES ( PRODUCT_ID_SOURCE ( i )
	                      ,PRODUCT_NAME( i )
                          ,LINE_ID ( i )
                          ,LINE_NAME ( i )
                          ,COLLECTION_ID( i )
                          ,COLLECTION_NAME( i )
                          ,SEASON_ID ( i )
                          ,SEASON ( i )
                          ,SIZE_CLOTHES ( i )
                          ,COLOR ( i )
                          ,PRICE ( i )
                          ,INSERT_DATE( i )
	                      , NULL );
	         COMMIT;
	      ELSE UPDATE ALINA.DIM_PRODUCT
                    SET PRODUCT_NAME = PRODUCT_NAME( i )
                          ,LINE_ID = LINE_ID( i )
                          ,LINE_NAME = Line_name ( i )
                          ,collection_id = COLLECTION_ID ( i )
                          ,COLLECTION_NAME = Collection_name ( i )
                          ,SEASON_ID = SEASON_ID ( i )
                          ,SEASON = SEASON ( i )
                          ,SIZE_CLOTHES = SIZE_CLOTHES ( i )
                          ,COLOR = COLOR ( i )
                          ,PRICE = PRICE ( i )
	                      ,UPDATE_DATE = SYSDATE
	          WHERE ALINA.DIM_PRODUCT.PRODUCT_ID = product_ID ( i );
	
	         COMMIT;
	      END IF;
	   END LOOP;
	END;
   END load_product_DIM;
   
END pkg_products;