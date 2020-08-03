CREATE OR REPLACE PACKAGE body pkg_customers
AS  
  PROCEDURE load_CLEAN_CUSTOMER
   AS
      CURSOR c_v
      IS
         SELECT DISTINCT FIRST_NAME
                       , LAST_NAME
                       , EMAIL
                       , PHONE
                       , AGE
                       , INSERT_DATE
           FROM SA_CUSTOMERS.sa_customers_data
           WHERE FIRST_NAME IS NOT NULL 
           AND EMAIL IS NOT NULL
           AND PHONE IS NOT NULL
           AND AGE IS NOT NULL
           AND INSERT_DATE IS NOT NULL;
   BEGIN
      FOR i IN c_v LOOP
         INSERT INTO DW_CL.DW_CL_CUSTOMERS_DATA( 
                        FIRST_NAME
                       , LAST_NAME
                       , EMAIL
                       , PHONE
                       , AGE
                       , INSERT_DATE)
              VALUES ( i.FIRST_NAME
                     , i.LAST_NAME
                     , i.EMAIL
                     , i.PHONE
                     , i.age
                     , i.insert_date);

         EXIT WHEN c_v%NOTFOUND;
      END LOOP;

      COMMIT;
   END load_CLEAN_CUSTOMER;
   
   
   PROCEDURE load_CUSTOMERS_DW
AS
   BEGIN
      DECLARE
	   TYPE CURSOR_VARCHAR IS TABLE OF varchar2(50);
	   TYPE CURSOR_NUMBER IS TABLE OF number(10);  
       TYPE CURSOR_DATE IS TABLE OF DATE;
	   TYPE BIG_CURSOR IS REF CURSOR ;
	
	   ALL_INF BIG_CURSOR;
	   
	   CUSTOMER_FIRST_NAME CURSOR_VARCHAR;
	   CUSTOMER_LAST_NAME CURSOR_VARCHAR;
	   CUSTOMER_EMAIL CURSOR_VARCHAR;
	   CUSTOMER_PHONE CURSOR_VARCHAR;
       CUSTOMER_AGE CURSOR_NUMBER;
       CUSTOMER_INSERT_DATE CURSOR_DATE;
       CUSTOMER_FIRST_NAME_STAGE CURSOR_VARCHAR;
	   CUSTOMER_LAST_NAME_STAGE CURSOR_VARCHAR;
       CUSTOMER_ID CURSOR_NUMBER;
	BEGIN
	   OPEN ALL_INF FOR
	       SELECT source_CL.FIRST_NAME AS FIRST_NAME_source_CL
                 , source_CL.LAST_NAME AS LAST_NAME_source_CL
                 , source_CL.EMAIL AS EMAIL
	             , source_CL.PHONE AS PHONE
	             , source_CL.AGE AS AGE
                 , source_CL.INSERT_DATE AS INSERT_DATE
	             , stage.FIRST_NAME AS FIRST_NAME_stage
                 , stage.LAST_NAME AS LAST_NAME_STAGE
                 , STAGE.CUSTOMER_ID AS CUSTOMER_ID
	          FROM (SELECT DISTINCT *
                           FROM dw_CL.DW_CL_CUSTOMERS_DATA) source_CL
                     LEFT JOIN
                        DW_DATA.DW_CUSTOMERS_DATA stage
                     ON (source_CL.FIRST_NAME = stage.FIRST_NAME AND source_CL.LAST_NAME = stage.LAST_NAME );

	
	   FETCH ALL_INF
	   BULK COLLECT INTO CUSTOMER_FIRST_NAME, CUSTOMER_LAST_NAME, CUSTOMER_EMAIL, 
       CUSTOMER_PHONE, CUSTOMER_AGE, CUSTOMER_INSERT_DATE, CUSTOMER_FIRST_NAME_STAGE, 
       CUSTOMER_LAST_NAME_STAGE, CUSTOMER_ID;
	
	   CLOSE ALL_INF;
	
	   FOR i IN CUSTOMER_ID.FIRST .. CUSTOMER_ID.LAST LOOP
	      IF ( CUSTOMER_ID ( i ) IS NULL ) THEN
	         INSERT INTO DW_DATA.DW_CUSTOMERS_DATA ( CUSTOMER_ID
                                             ,first_name
                                             ,last_name
                                             ,email
                                             ,phone
                                             ,age 
                                             ,INSERT_DATE
                                             ,UPDATE_DATE)
	              VALUES ( SEQ_CUSTOMERS.NEXTVAL
	                     , CUSTOMER_FIRST_NAME( i )
                         , CUSTOMER_LAST_NAME( i )
                         , CUSTOMER_EMAIL( i )
                         , CUSTOMER_PHONE( i )
                         , CUSTOMER_AGE( i )
                         , CUSTOMER_INSERT_DATE( i )
	                     , NULL );
	
	         COMMIT;
	      ELSIF ( CUSTOMER_PHONE ( i )<> CUSTOMER_PHONE ( i )) THEN
	         UPDATE DW_DATA.DW_CUSTOMERS_DATA
	            SET EMAIL = CUSTOMER_EMAIL ( i )
                   ,PHONE = CUSTOMER_PHONE( i )
                   ,AGE = CUSTOMER_AGE( i )
                   ,UPDATE_DATE = SYSDATE
	          WHERE DW_CUSTOMERS_DATA.CUSTOMER_ID = CUSTOMER_ID ( i );
	
	         COMMIT;
	      END IF;
	   END LOOP;
	END;
   END load_CUSTOMERS_DW;
END pkg_customers;