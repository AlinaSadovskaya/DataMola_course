CREATE OR REPLACE PACKAGE body pkg_etl_customers_cl
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
END pkg_etl_customers_cl;