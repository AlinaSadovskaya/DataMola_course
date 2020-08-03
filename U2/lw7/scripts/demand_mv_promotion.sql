CREATE MATERIALIZED VIEW mv_PRODUCT_PROMOTION_month
BUILD DEFERRED
REFRESH COMPLETE ON DEMAND
AS
SELECT /*+ parallel(ff 8 prg 8)*/
        TRUNC ( DATE_TRANSACTION, 'mm' ) AS month_dt
       , DECODE ( GROUPING ( PRODUCT_NAME ), 1, 'All products', PRODUCT_NAME ) AS PRODUCT
       , DECODE ( GROUPING ( promotion ), 1, 'All promotions', promotion ) AS promotion
       , SUM ( price ) AS sum
    FROM SA_customers.sa_transaction
    GROUP BY  TRUNC ( DATE_TRANSACTION, 'mm' ) , CUBE ( PRODUCT_NAME, promotion)
    HAVING GROUPING_ID ( PRODUCT_NAME ) < 1
    ORDER BY 1,2,3;
    
select * from  mv_PRODUCT_PROMOTION_month;

EXECUTE DBMS_MVIEW.REFRESH('mv_PRODUCT_PROMOTION_month');