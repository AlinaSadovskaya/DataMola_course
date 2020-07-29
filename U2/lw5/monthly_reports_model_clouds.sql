--monthly report on the products and promotions
SELECT /*+ parallel(ff 8 prg 8)*/
       DISTINCT PRODUCT_NAME AS PRODUCT
       , NVL(PROMOTION, 'ALL SALES') AS PROMOTION
       , price
    FROM DW_CL.dw_cl_transaction
    WHERE TRUNC ( DATE_TRANSACTION, 'mm' ) = TO_DATE ( '06.01.20'
                                   , 'MM.DD.YY' )
    group by CUBE(PRODUCT_NAME, promotion) 
    HAVING PRODUCT_NAME IS NOT NULL 
    MODEL
      DIMENSION BY ( PRODUCT_NAME, PROMOTION)
      MEASURES ( SUM(price) PRICE)
       RULES
            (  PRICE [NULL, 
                FOR promotion IN (SELECT promotion FROM DW_CL.dw_cl_transaction group by promotion)] = 
                SUM ( PRICE )[any, cv(promotion)]
                )
    ORDER BY PRODUCT_NAME, price desc;


--monthly report on the products and countries
SELECT /*+ parallel(ff 8 prg 8)*/
       DISTINCT PRODUCT_NAME AS PRODUCT
       , NVL(GEO, 0) AS GEO
       , PRICE
    FROM DW_CL.dw_cl_transaction
    WHERE TRUNC ( DATE_TRANSACTION, 'mm' ) = TO_DATE ( '06.01.20'
                                   , 'MM.DD.YY' )
    group by CUBE(PRODUCT_NAME, GEO) 
    HAVING PRODUCT_NAME IS NOT NULL 
    MODEL
      DIMENSION BY ( PRODUCT_NAME, GEO)
      MEASURES ( SUM(price) PRICE)
       RULES
            (  PRICE [NULL, 
                FOR GEO IN (SELECT GEO FROM DW_CL.dw_cl_transaction group by GEO)] = 
                SUM ( PRICE )[any, cv(GEO)]
                )
    ORDER BY PRODUCT_NAME, price desc;
    
    
--monthly report on the countries
SELECT /*+ parallel(ff 8 prg 8)*/
       DISTINCT 
       GEO
       ,PRODUCT_NAME AS PRODUCT 
       ,PRICE
    FROM DW_CL.dw_cl_transaction
    WHERE TRUNC ( DATE_TRANSACTION, 'mm' ) = TO_DATE ( '06.01.20'
                                   , 'MM.DD.YY' )
    group by CUBE( GEO, PRODUCT_NAME) 
    HAVING PRODUCT_NAME IS NOT NULL
    and GEO IS NOT NULL
    MODEL
      DIMENSION BY ( PRODUCT_NAME, GEO)
      MEASURES ( SUM(price) PRICE)
       RULES
            (  PRICE [NULL, 
                FOR GEO IN (SELECT GEO FROM DW_CL.dw_cl_transaction group by GEO)] = 
                SUM ( PRICE )[any, cv(GEO)]
                )
    ORDER BY GEO, PRICE desc;
    
    
--monthly report on the price with discount
SELECT /*+ parallel(ff 8 prg 8)*/
       DISTINCT PRODUCT_NAME AS PRODUCT
       , NVL(PROMOTION, 'ALL SALES') AS PROMOTION
       , price
       , price_percent
    FROM DW_CL.dw_cl_transaction
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