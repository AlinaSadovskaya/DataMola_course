BEGIN
    pkg_promotions.load_CLEAN_GEN_PROMOTION_DATA ;
    pkg_promotions.load_PROMOTION_types;
    pkg_promotions.load_PROMOTION_hist;
    pkg_promotions.load_PROMOTION_dim;
END;