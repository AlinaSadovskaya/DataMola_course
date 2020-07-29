CREATE OR REPLACE PACKAGE pkg_etl_products_dw_stage
-- Package Reload Data From Source Tables to DataBase - stores
AS  
   -- Load All stores Types
   PROCEDURE load_PRODUCTS_DW;
END pkg_etl_products_dw_stage;