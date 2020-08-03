CREATE OR REPLACE PACKAGE BODY pkg_period
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
   
   PROCEDURE load_period_DATA 
   AS
       CURSOR cur_1
         IS
            (SELECT     source_period.START_PERIOD
                        ,source_period.END_PERIOD
                        ,source_period.INSERT_DAY
            FROM dw_cl.DW_cl_period_DATA source_period);
       BEGIN
         execute immediate 'truncate table dw_data.DW_period_DATA';
         FOR i IN cur_1 LOOP
          INSERT INTO dw_data.DW_period_DATA ( PERIOD_ID
                                                 ,START_PERIOD
                                                 ,END_PERIOD
                                                 ,INSERT_DAY)
                    VALUES ( SEQ_PERIOD.NEXTVAL
                           , i.START_PERIOD
                           , i.END_PERIOD
                           , i.INSERT_DAY);

         EXIT WHEN cur_1%NOTFOUND;
       END LOOP;
        COMMIT;
   END load_period_DATA ;
END pkg_period;