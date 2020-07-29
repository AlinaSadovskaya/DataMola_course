DROP PROCEDURE load_PRODUCTS_DIM;

CREATE PROCEDURE load_PRODUCTS_DIM
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
                        DIM_PRODUCT stage
                     ON (source_DW.PRODUCT_ID = stage.PRODUCT_ID);

	
	   FETCH ALL_INF
	   BULK COLLECT INTO PRODUCT_NAME, LINE_ID, LINE_NAME,COLLECTION_ID
                         ,COLLECTION_NAME, SEASON_ID, SEASON, SIZE_CLOTHES
                         ,COLOR, PRICE , INSERT_DATE, PRODUCT_ID_SOURCE, PRODUCT_ID;
	
	   CLOSE ALL_INF;
	
	   FOR i IN PRODUCT_ID.FIRST .. PRODUCT_ID.LAST LOOP
	      IF ( PRODUCT_ID ( i ) IS NULL AND PRODUCT_ID_SOURCE ( i )IS NOT NULL) THEN
	         INSERT INTO DIM_PRODUCT (   PRODUCT_ID
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
	      ELSE UPDATE DIM_PRODUCT
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
	          WHERE DIM_PRODUCT.PRODUCT_ID = product_ID ( i );
	
	         COMMIT;
	      END IF;
	   END LOOP;
	END;
   END load_productS_DIM;
   EXECUTE load_productS_DIM;
   