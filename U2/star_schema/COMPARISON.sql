SET AUTOTRACE ON;    
--date report
SELECT /*+ parallel(ff 8 prg 8)*/
        SOURCE_TABLE.DATE_ID AS event_dt
       , DECODE ( GROUPING ( SOURCE_TABLE.geo_ID ), 1, 'All countries_id', geo_ID ) AS geo_id
       , DECODE ( GROUPING ( PRODUCT.product_name ), 1, 'All products', product_name ) AS product
       , SUM (SOURCE_TABLE.SALE_SUM) AS sum
    FROM COUNTRY_FACT_SALES_DD SOURCE_TABLE
    LEFT JOIN DIM_PRODUCT PRODUCT
    ON(SOURCE_TABLE.PRODUCT_ID = PRODUCT.PRODUCT_ID)
    GROUP BY  source_table.date_id , CUBE (SOURCE_TABLE.geo_ID, PRODUCT.product_name)
    HAVING GROUPING_ID ( SOURCE_TABLE.geo_ID ) < 1
    ORDER BY 1,2,3;
    
    
SET AUTOTRACE ON;  
SELECT /*+ parallel */
       DISTINCT 
       PRODUCT_NAME AS PRODUCT
       , NVL(GEO, 0) AS GEO
       , PRICE
    FROM DW_CL.dw_cl_transaction
    WHERE DATE_TRANSACTION = TO_DATE ( '06.02.20'
                                   , 'MM.DD.YY' )
   
    group by ROLLUP(PRODUCT_NAME, GEO) 
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