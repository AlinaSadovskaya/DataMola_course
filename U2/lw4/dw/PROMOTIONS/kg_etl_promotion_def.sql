CREATE OR REPLACE PACKAGE pkg_etl_dw_promotion_def
AS  
   PROCEDURE load_PROMOTION_types;
   PROCEDURE load_PROMOTION_hist;
END pkg_etl_dw_promotion_def;