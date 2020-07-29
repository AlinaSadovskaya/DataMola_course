DROP PROCEDURE load_STORES_DW;
CREATE PROCEDURE load_STORES_DW
   AS
   BEGIN
      DECLARE
	   TYPE CURSOR_VARCHAR IS TABLE OF varchar2(50);
	   TYPE CURSOR_NUMBER IS TABLE OF number(10);  
       TYPE CURSOR_DATE IS TABLE OF DATE;
       TYPE BIG_CURSOR IS REF CURSOR;
       
       STORE_PHONE CURSOR_VARCHAR;
       STORE_NAME CURSOR_VARCHAR;
       STORE_INSERT_DATE CURSOR_DATE;
       STORE_NAME_STAGE CURSOR_VARCHAR;
       STORE_ID CURSOR_NUMBER;
       ALL_INF BIG_CURSOR;
	BEGIN
	   OPEN ALL_INF FOR
	       SELECT source_CL.STORE_NAME AS STORE_NAME_source_CL
                 , source_CL.STORE_PHONE AS STORE_PHONE_source_CL
                 , source_CL.INSERT_DATE AS INSERT_DATE
	             , stage.STORE_NAME AS STORE_NAME_stage
                 , STAGE.STORE_ID AS STORE_ID
	          FROM (SELECT DISTINCT *
                           FROM dw_CL.DW_CL_STORE_DATA) source_CL
                     LEFT JOIN
                        DW_STORE_DATA stage
                     ON (source_CL.STORE_NAME = stage.STORE_NAME);

	
	   FETCH ALL_INF
	   BULK COLLECT INTO STORE_NAME, STORE_PHONE, STORE_INSERT_DATE, STORE_NAME_STAGE, STORE_ID;
	
	   CLOSE ALL_INF;
	
	   FOR i IN STORE_ID.FIRST .. STORE_ID.LAST LOOP
	      IF ( STORE_ID ( i ) IS NULL ) THEN
	         INSERT INTO DW_STORE_DATA ( STORE_ID
                                         , STORE_PHONE 
                                         , STORE_NAME
                                         , INSERT_DATE
                                         , UPDATE_DATE)
	              VALUES ( SEQ_STORES.NEXTVAL
	                     , STORE_PHONE( i )
                         , STORE_NAME( i )
                         , STORE_INSERT_DATE( i )
	                     , NULL );
	
	         COMMIT;
	      ELSE  UPDATE DW_STORE_DATA
	            SET STORE_PHONE = STORE_PHONE( i )
                   ,STORE_NAME = STORE_NAME( i )
                   ,UPDATE_DATE = SYSDATE
	          WHERE DW_STORE_DATA.STORE_ID = STORE_ID ( i );
	
	         COMMIT;
	      END IF;
	   END LOOP;
	END;
   END load_STORES_DW;

Execute load_STORES_DW;