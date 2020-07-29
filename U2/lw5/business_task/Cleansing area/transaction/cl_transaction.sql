CREATE PROCEDURE load_CLEAN_transaction
   AS
      CURSOR c_v
      IS
         SELECT DISTINCT FIRST_NAME
                       , LAST_NAME
                       , PRODUCT_NAME
                       , LINE_NAME
                       , COLLECTION_NAME
                       , SIZE_CLOTHES
                       , PRICE
                       , PROMOTION
                       , VALID_FROM
                       , VALID_TO
                       , PRICE_PERCENT
                       , DATE_TRANSACTION
                       , GEO
           FROM SA_CUSTOMERS.sa_transaction
           WHERE FIRST_NAME IS NOT NULL 
           AND LAST_NAME IS NOT NULL
           AND LINE_NAME IS NOT NULL
           AND PRODUCT_NAME IS NOT NULL
           AND PROMOTION IS NOT NULL
           AND VALID_FROM IS NOT NULL
           AND SIZE_CLOTHES IS NOT NULL
           AND VALID_TO IS NOT NULL
           AND PRICE IS NOT NULL
           AND COLLECTION_NAME IS NOT NULL
           AND PRICE_PERCENT IS NOT NULL
           AND DATE_TRANSACTION IS NOT NULL
           AND GEO IS NOT NULL;
   BEGIN
      FOR i IN c_v LOOP
         INSERT INTO DW_CL.dw_cl_transaction( 
                        FIRST_NAME
                       , LAST_NAME
                       , PRODUCT_NAME
                       , LINE_NAME
                       , COLLECTION_NAME
                       , SIZE_CLOTHES
                       , PRICE
                       , PROMOTION
                       , VALID_FROM
                       , VALID_TO
                       , PRICE_PERCENT
                       , DATE_TRANSACTION
                       , GEO)
              VALUES ( i.FIRST_NAME
                       , i.LAST_NAME
                       , i.PRODUCT_NAME
                       , i.LINE_NAME
                       , i.COLLECTION_NAME
                       , i.SIZE_CLOTHES
                       , i.PRICE
                       , i.PROMOTION
                       , i.VALID_FROM
                       , i.VALID_TO
                       , i.PRICE_PERCENT
                       , i.DATE_TRANSACTION
                       , i.GEO);

         EXIT WHEN c_v%NOTFOUND;
      END LOOP;

      COMMIT;
   END load_CLEAN_transaction;

Execute load_CLEAN_transaction;
 