BEGIN
    pkg_products.load_CLEAN_product;
    pkg_products.load_PRODUCTS_DW;
    pkg_products.load_product_dim;
END;