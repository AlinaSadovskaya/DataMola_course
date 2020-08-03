 DROP  MATERIALIZED VIEW mv_sales_geo_daily;
 
 CREATE MATERIALIZED VIEW mv_sales_geo_daily
 BUILD IMMEDIATE
 REFRESH FAST ON COMMIT
 ENABLE QUERY REWRITE
 AS
 SELECT DATE_TRANSACTION AS event_dt
       , geo
       , product_name
       , SUM ( price ) AS sum
    FROM sa_customers.sa_transaction
    WHERE TRUNC ( DATE_TRANSACTION
                       , 'DD' ) = TO_DATE ( '06.06.2020'
                                          , 'DD.MM.YYYY' )
    GROUP BY  DATE_TRANSACTION ,geo, PRODUCT_NAME
    order by geo, sum;
    
SELECT * FROM mv_sales_geo_daily;

UPDATE sa_customers.sa_transaction
    SET PRICE = PRICE*2
    WHERE TRUNC ( DATE_TRANSACTION
                       , 'DD' ) = TO_DATE ( '06.06.2020'
                                          , 'DD.MM.YYYY' );
COMMIT;                                      