CREATE OR REPLACE PACKAGE pkg_products
AS  
   PROCEDURE load_CLEAN_product;
   PROCEDURE load_PRODUCTS_DW;
   PROCEDURE load_product_dim;
END pkg_products;