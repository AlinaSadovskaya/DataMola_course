CREATE PROCEDURE load_CLEAN_GEN_PROMOTION_DATA 
   AS
      CURSOR c_v
      IS
         SELECT DISTINCT promotion
                       , valid_from
                       , valid_to
                       , price_percent
                       , INSERT_DAy
           FROM SA_CUSTOMERS.sa_gen_promotion_data
           WHERE INSERT_DAY IS NOT NULL ;
   BEGIN
      FOR i IN c_v LOOP
         INSERT INTO DW_CL.dw_cl_gen_promotion_data( 
                        promotion
                       , valid_from
                       , valid_to
                       , price_percent
                       , INSERT_DAy)
              VALUES ( i.promotion
                       , i.valid_from
                       , i.valid_to
                       , i.price_percent
                       , i.INSERT_DAy);

         EXIT WHEN c_v%NOTFOUND;
      END LOOP;

      COMMIT;
   END load_CLEAN_GEN_PROMOTION_DATA;

Execute load_CLEAN_GEN_PROMOTION_DATA;
 