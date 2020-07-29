DROP PROCEDURE load_STORES_DW;
CREATE PROCEDURE load_STORES_DW
   AS
   BEGIN
      DECLARE
	   
       TYPE BIG_CURSOR IS REF CURSOR;
       TYPE T_REC_STORES IS RECORD
       (
         STORE_PHONE varchar2(50)
         ,STORE_NAME varchar2(50)
         ,STORE_INSERT_DATE varchar2(50)
         ,STORE_NAME_STAGE varchar2(50)
         ,STORE_ID number(10)
         
       );
       TYPE t_STORES IS TABLE OF T_REC_STORES ;
       ALL_INF BIG_CURSOR;
	   record_STORES t_STORES;
	   curid NUMBER ( 25 );
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
	   BULK COLLECT INTO record_STORES;
	   
	
       curid := dbms_sql.to_cursor_number (  ALL_INF );
	   dbms_sql.close_cursor ( curid );
       
	   FOR i IN record_STORES.FIRST .. record_STORES.LAST LOOP
	      IF ( record_STORES(i).STORE_ID IS NULL ) THEN
	         INSERT INTO DW_STORE_DATA ( STORE_ID
                                         , STORE_PHONE 
                                         , STORE_NAME
                                         , INSERT_DATE
                                         , UPDATE_DATE)
	              VALUES ( SEQ_STORES.NEXTVAL
	                     , record_STORES(i).STORE_PHONE
                         , record_STORES(i).STORE_NAME
                         , record_STORES(i).STORE_INSERT_DATE
	                     , NULL );
	
	         COMMIT;
	      ELSE  UPDATE DW_STORE_DATA
	            SET STORE_PHONE = record_STORES(i).STORE_PHONE
                   ,STORE_NAME = record_STORES(i).STORE_NAME
                   ,UPDATE_DATE = SYSDATE
	          WHERE DW_STORE_DATA.STORE_ID = record_STORES(i).STORE_ID;
	
	         COMMIT;
	      END IF;
	   END LOOP;
	END;
   END load_STORES_DW;

Execute load_STORES_DW;