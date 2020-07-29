CREATE OR REPLACE PACKAGE body pkg_etl_store_cl
AS  
   PROCEDURE load_CLEAN_store
   AS
      CURSOR c_v
      IS
         SELECT DISTINCT store_phone
                       , STORE_NAME
                       , INSERT_DATE
           FROM SA_CUSTOMERS.sa_store_data
           WHERE store_phone IS NOT NULL 
           AND STORE_NAME IS NOT NULL
           AND INSERT_DATE IS NOT NULL;
   BEGIN
      FOR i IN c_v LOOP
         INSERT INTO DW_CL.DW_CL_store_DATA( 
                        store_phone
                       , STORE_NAME
                       , INSERT_DATE)
              VALUES ( i.store_phone
                     , i.store_NAME
                     , i.insert_date);

         EXIT WHEN c_v%NOTFOUND;
      END LOOP;

      COMMIT;
END load_CLEAN_store;
END pkg_etl_store_cl;