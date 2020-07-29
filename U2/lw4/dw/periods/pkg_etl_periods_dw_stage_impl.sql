CREATE OR REPLACE PACKAGE BODY pkg_etl_periods_dw_stage
AS PROCEDURE load_period_DATA 
   AS
       CURSOR cur_1
         IS
            (SELECT     source_period.START_PERIOD
                        ,source_period.END_PERIOD
                        ,source_period.INSERT_DAY
            FROM dw_cl.DW_cl_period_DATA source_period);
       BEGIN
         execute immediate 'truncate table DW_period_DATA';
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
END pkg_etl_periods_dw_stage;