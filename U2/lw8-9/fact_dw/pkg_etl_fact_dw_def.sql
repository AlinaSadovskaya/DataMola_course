CREATE OR REPLACE PACKAGE pkg_etl_fact_dw
AS  
   PROCEDURE load_T_FACT_COUNTRY_DW;
   PROCEDURE load_T_FACT_PROMOTION_DW;
END pkg_etl_fact_dw;