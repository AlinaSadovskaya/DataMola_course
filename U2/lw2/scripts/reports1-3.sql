SELECT DATE_TRANSACTION,PRODUCT_NAME, SUM(PRICE), count(product_name)
FROM sa_transaction
GROUP BY CUBE(DATE_TRANSACTION, PRODUCT_NAME) 
    HAVING date_transaction IS NOT NULL 
    and PRODUCT_NAME is not null;



SELECT DATE_TRANSACTION, PRODUCT_NAME, promotion, SUM(PRICE)
FROM sa_transaction GROUP BY
GROUPING SETS (( DATE_TRANSACTION, PRODUCT_NAME),
(DATE_TRANSACTION,PROMOTION), (promotion, product_name))
    HAVING date_transaction IS NOT NULL 
    and PRODUCT_NAME is not null;


--date report
SELECT /*+ parallel(ff 8 prg 8)*/
        DATE_TRANSACTION AS event_dt
       , DECODE ( GROUPING ( geo ), 1, 'All countries_id', geo ) AS geo_id
       , DECODE ( GROUPING ( product_name ), 1, 'All products', product_name ) AS product
       , SUM ( price ) AS sum
    FROM sa_transaction
    GROUP BY  DATE_TRANSACTION , CUBE (geo, PRODUCT_NAME)
    HAVING GROUPING_ID ( geo ) < 1
    ORDER BY 1,2,3;
    
SELECT /*+ parallel(ff 8 prg 8)*/
        DATE_TRANSACTION AS event_dt
       , DECODE ( GROUPING ( PRODUCT_NAME ), 1, 'All products', PRODUCT_NAME ) AS PRODUCT
       , DECODE ( GROUPING ( promotion ), 1, 'All promotions', promotion ) AS promotion
       , SUM ( price ) AS sum
    FROM sa_transaction
    GROUP BY  DATE_TRANSACTION , CUBE ( PRODUCT_NAME, promotion)
    HAVING GROUPING_ID ( PRODUCT_NAME ) < 1
    ORDER BY 1,2,3;
    
--month report
SELECT /*+ parallel(ff 8 prg 8)*/
        TRUNC ( DATE_TRANSACTION, 'mm' ) AS month_dt
       , DECODE ( GROUPING ( PRODUCT_NAME ), 1, 'All products', PRODUCT_NAME ) AS PRODUCT
       , DECODE ( GROUPING ( promotion ), 1, 'All promotions', promotion ) AS promotion
       , SUM ( price ) AS sum
    FROM sa_transaction
    GROUP BY  TRUNC ( DATE_TRANSACTION, 'mm' ) , CUBE ( PRODUCT_NAME, promotion)
    HAVING GROUPING_ID ( PRODUCT_NAME ) < 1
    ORDER BY 1,2,3;
    
SELECT /*+ parallel(ff 8 prg 8)*/
        TRUNC ( DATE_TRANSACTION, 'mm' ) AS month_dt
       , DECODE ( GROUPING ( geo ), 1, 'All countries_id', geo ) AS geo_id
       , DECODE ( GROUPING ( product_name ), 1, 'All products', product_name ) AS product
       , SUM ( price ) AS sum
    FROM sa_transaction
    GROUP BY  TRUNC ( DATE_TRANSACTION, 'mm' ) , CUBE ( geo, product_name)
    HAVING GROUPING_ID ( geo ) < 1
    ORDER BY 1,2,3;
    
--time report
SELECT DECODE ( GROUPING_ID ( TRUNC ( DATE_TRANSACTION
                                      , 'Year' )
                              , TRUNC ( DATE_TRANSACTION
                                      , 'Q' )
                              , TRUNC ( DATE_TRANSACTION
                                      , 'Month' )
                              , TRUNC ( DATE_TRANSACTION
                                      , 'DDD' ) )
                , 7, 'Total for year'
                , 15, 'GRANT TOTAL'
                , TRUNC ( DATE_TRANSACTION
                        , 'Year' ) )
            AS year
       , DECODE ( GROUPING_ID ( TRUNC ( DATE_TRANSACTION
                                      , 'Year' )
                              , TRUNC ( DATE_TRANSACTION
                                      , 'Q' )
                              , TRUNC ( DATE_TRANSACTION
                                      , 'Month' )
                              , TRUNC ( DATE_TRANSACTION
                                      , 'DDD' ) )
                , 3, 'Total for quarter'
                , TRUNC (DATE_TRANSACTION
                        , 'Q' ) )
            AS quarter
       , DECODE ( GROUPING_ID ( TRUNC ( DATE_TRANSACTION
                                      , 'Year' )
                              , TRUNC ( DATE_TRANSACTION
                                      , 'Q' )
                              , TRUNC ( DATE_TRANSACTION
                                      , 'Month' )
                              , TRUNC ( DATE_TRANSACTION
                                      , 'DDD' ) )
                , 1, 'Total for month'
                , TRUNC ( DATE_TRANSACTION
                        , 'Month' ) )
            AS month
       , DECODE ( GROUPING_ID ( TRUNC ( DATE_TRANSACTION
                                      , 'Year' )
                              , TRUNC ( DATE_TRANSACTION
                                      , 'Q' )
                              , TRUNC ( DATE_TRANSACTION
                                      , 'Month' )
                              , TRUNC ( DATE_TRANSACTION
                                      , 'DDD' ) )
                , 15, ''
                , TRUNC ( DATE_TRANSACTION
                        , 'DDD' ) )
            AS day
       ,  SUM ( price - price_percent*price/100) AS price_with_prom
       , COUNT ( * ) AS quantity
    FROM sa_transaction
    GROUP BY ROLLUP ( TRUNC ( DATE_TRANSACTION
                        , 'Year' ), TRUNC ( DATE_TRANSACTION
                                          , 'Q' ), TRUNC (DATE_TRANSACTION
                                                         , 'Month' ), TRUNC ( DATE_TRANSACTION
                                                                            , 'DDD' ) );

