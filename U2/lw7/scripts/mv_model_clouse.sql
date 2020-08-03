DROP MATERIALIZED VIEW mv_PRICE_SALES_MONTHLY;
CREATE MATERIALIZED VIEW mv_PRICE_SALES_MONTHLY
BUILD IMMEDIATE
REFRESH COMPLETE ON DEMAND  START WITH SYSDATE NEXT (SYSDATE + 1/1440)
AS
SELECT /*+ parallel(ff 8 prg 8)*/
       DISTINCT PRODUCT_NAME AS PRODUCT
       , NVL(PROMOTION, 'ALL SALES') AS PROMOTION
       , price
       , price_percent
    FROM SA_CUSTOMERS.sa_transaction
    WHERE TRUNC ( DATE_TRANSACTION, 'mm' ) = TO_DATE ( '06.01.20'
                                   , 'MM.DD.YY' )
    group by CUBE(PRODUCT_NAME, promotion) 
    HAVING PRODUCT_NAME IS NOT NULL 
    MODEL
      DIMENSION BY ( PRODUCT_NAME, PROMOTION)
      MEASURES ( SUM(price) PRICE, SUM ( price_percent*price/100) price_percent)
       RULES
            (  PRICE [NULL, 
                    FOR promotion IN (SELECT promotion FROM DW_CL.dw_cl_transaction group by promotion)] = 
                    SUM ( PRICE )[any, cv(promotion)],
               price_percent [NULL, 
                    FOR promotion IN (SELECT promotion FROM DW_CL.dw_cl_transaction group by promotion)] = 
                    SUM ( price_percent )[any, cv(promotion)]
                )
    ORDER BY PRODUCT_NAME, price_percent desc;
    
SELECT * FROM MV_PRICE_SALES_MONTHLY;


UPDATE SA_CUSTOMERS.sa_transaction
set PRICE=PRICE/2
where PRODUCT_NAME = 'Andrew Marc'
AND PROMOTION = 'sale 8%';
COMMIT;