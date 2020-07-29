CREATE OR REPLACE PACKAGE body pkg_etl_promotion_dim
AS  
   PROCEDURE load_PROMOTION_dim
   AS
   BEGIN
      DECLARE
	   TYPE prom IS REF CURSOR ;
	
       TYPE INT_DATA IS TABLE OF INT;
	   TYPE FLOAT_DATA IS TABLE OF FLOAT;  
	   TYPE VARCHAR_DATA IS TABLE OF varchar2(150);
       TYPE DATE_DATA IS TABLE OF DATE;
	
	   promotion prom;
       
	   promotion_sk_HIST int_DATA;
       promotion_type_id_HIST INT_DATA;
       promotion_DESCR_HIST VARCHAR_DATA;
       PRICE_PERCENT_HIST FLOAT_DATA;
       PROMOTION_VALID_FROM_HIST DATE_DATA;
       PROMOTION_VALID_TO_HIST DATE_DATA;
       promotion_insert_day DATE_DATA;
       promotion_sk_STAGE int_DATA;
	BEGIN
	   OPEN promotion FOR
	       SELECT DISTINCT  t_hist.PROMOTION_SURROGATE_KEY surr_key_HIST
                                        , t_hist.promotion_id promotion_type_id_HIST
                                        , t_hist.promotion promotion_DESCR_HIST
                                        , t_hist.price_percent price_perc_HIST
                                        , t_hist.valid_from vf_HIST
                                        , t_hist.valid_to vt_HIST
                                        , t_hist.insert_day insert_day
                                        , T_STAGE.SURROGATE_KEY SURR_KEY_STAGE
	                     FROM DW_DATA.DW_GEN_PROMOTION_hist t_hist
	              LEFT JOIN DIM_promotions_scd t_stage
	                ON (t_hist.PROMOTION = t_stage.PROMOTION_DESCRIPTION
                        AND t_hist.VALID_FROM = t_stage.VALID_FROM
                        AND t_hist.VALID_TO = t_stage.VALID_TO);
	
	   FETCH promotion
	   BULK COLLECT INTO promotion_sk_HIST, promotion_type_id_HIST, promotion_DESCR_HIST, PRICE_PERCENT_HIST
       ,PROMOTION_VALID_FROM_HIST, PROMOTION_VALID_TO_HIST, promotion_insert_day, promotion_sk_STAGE;
	
	   CLOSE promotion;
	
	   FOR i IN promotion_sk_STAGE.FIRST .. promotion_sk_STAGE.LAST LOOP
	      IF ( promotion_sk_STAGE ( i ) IS NULL ) THEN
	         INSERT INTO DIM_promotions_scd ( SURROGATE_KEY
                                              ,PROMOTION_ID
                                              ,PROMOTION_DESCRIPTION
                                              ,PRICE_DECREASING_PERCENT
                                              ,VALID_FROM
                                              ,VALID_TO
                                              ,insert_day
                                              ,UPDATE_DAY )
	              VALUES ( promotion_sk_HIST(i)
	                     , promotion_type_id_HIST( i )
                         , promotion_DESCR_HIST( i )
	                     , PRICE_PERCENT_HIST ( i )
	                     , PROMOTION_VALID_FROM_HIST ( i )
                         , PROMOTION_VALID_TO_HIST ( i )
                         , Promotion_insert_day(i)
	                     , NULL );
	
	         COMMIT;
          ELSE UPDATE DIM_promotions_scd
	            SET  PROMOTION_ID = promotion_sk_HIST(i)
                     ,PROMOTION_DESCRIPTION = promotion_DESCR_HIST( i )
                     ,PRICE_DECREASING_PERCENT = PRICE_PERCENT_HIST ( i )
                     ,VALID_FROM = PROMOTION_VALID_FROM_HIST ( i )
                     ,VALID_TO = PROMOTION_VALID_TO_HIST(I)
                     ,insert_day =  Promotion_insert_day(i)
                     ,UPDATE_DAY    = SYSDATE
	          WHERE DIM_promotions_scd.SURROGATE_KEY = promotion_sk_HIST(i);
	
	         COMMIT;
	      END IF;
	   END LOOP;
	END;
   END load_PROMOTION_dim;
END pkg_etl_promotion_dim;