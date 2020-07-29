CREATE PROCEDURE load_CLEAN_product
   AS
      CURSOR c_v
      IS
         SELECT DISTINCT product_NAME
                       , LINE_ID
                       , LINE_NAME
                       , COLLECTION_ID
                       , COLLECTION_NAME
                       , SEASON_ID
                       , SEASON
                       , SIZE_CLOTHES
                       , COLOR
                       , PRICE
                       , INSERT_DATE
           FROM SA_CUSTOMERS.sa_product_data
           WHERE product_NAME IS NOT NULL 
           AND LINE_ID IS NOT NULL
           AND LINE_NAME IS NOT NULL
           AND COLLECTION_ID IS NOT NULL
           AND SEASON_ID IS NOT NULL
           AND SEASON IS NOT NULL
           AND SIZE_CLOTHES IS NOT NULL
           AND COLOR IS NOT NULL
           AND PRICE IS NOT NULL
           AND COLLECTION_NAME IS NOT NULL;
   BEGIN
      FOR i IN c_v LOOP
         INSERT INTO DW_CL.DW_CL_product_DATA( 
                        product_NAME
                       , LINE_ID
                       , LINE_NAME
                       , COLLECTION_ID
                       , COLLECTION_NAME
                       , SEASON_ID
                       , SEASON
                       , SIZE_CLOTHES
                       , COLOR
                       , PRICE
                       , INSERT_DATE)
              VALUES ( i.product_NAME
                       , i.LINE_ID
                       , i.LINE_NAME
                       , i.COLLECTION_ID
                       , i.COLLECTION_NAME
                       , i.SEASON_ID
                       , i.SEASON
                       , i.SIZE_CLOTHES
                       , i.COLOR
                       , i.PRICE
                       , i.INSERT_DATE);

         EXIT WHEN c_v%NOTFOUND;
      END LOOP;

      COMMIT;
   END load_CLEAN_product;

Execute load_CLEAN_product;
 