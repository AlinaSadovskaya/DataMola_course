BEGIN
    Pkg_etl_customers_cl.load_CLEAN_CUSTOMER;
    pkg_etl_products_cl.load_CLEAN_product;
    pkg_etl_period_cl.load_CLEAN_period_DATA;
    pkg_etl_promotions_cl.load_CLEAN_GEN_PROMOTION_DATA;
    pkg_etl_store_cl.load_CLEAN_store;
    pkg_etl_transaction_def.load_CLEAN_transaction;
END;