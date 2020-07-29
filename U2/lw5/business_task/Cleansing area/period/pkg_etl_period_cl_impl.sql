CREATE OR REPLACE PACKAGE BODY pkg_etl_period_cl
AS PROCEDURE load_CLEAN_period_DATA
   AS
      CURSOR c_v
      IS
         SELECT DISTINCT START_PERIOD
                     ,END_PERIOD
                     ,INSERT_DAY
                     ,update_day
           FROM SA_CUSTOMERS.sa_period_data
           WHERE START_PERIOD IS NOT NULL 
           AND INSERT_DAY IS NOT NULL;
   BEGIN
      FOR i IN c_v LOOP
         INSERT INTO DW_CL.DW_CL_period_DATA( 
                         START_PERIOD
                         ,END_PERIOD
                         ,INSERT_DAY
                         ,update_day)
              VALUES ( i.start_period
                       , i.END_PERIOD
                       , i.INSERT_DAY
                       , i.update_day);

         EXIT WHEN c_v%NOTFOUND;
      END LOOP;

      COMMIT;
   END load_CLEAN_period_DATA;
END pkg_etl_period_cl;