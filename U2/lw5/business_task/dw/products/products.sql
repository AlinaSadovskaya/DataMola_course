drop PROCEDURE load_PRODUCTS_DW;
CREATE PROCEDURE load_PRODUCTS_DW
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
                        DW_PRODUCT_DATA stage
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
	         INSERT INTO DW_PRODUCT_DATA (   PRODUCT_ID
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
                 INSERT INTO DW_PRODUCT_DATA (   PRODUCT_ID
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
           ELSE UPDATE DW_PRODUCT_DATA
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
                    
	          WHERE DW_product_DATA.product_ID = product_ID ( i );
	
	         COMMIT;
	      END IF;
	   END LOOP;
	END;
   END load_productS_DW;

Execute load_productS_DW;