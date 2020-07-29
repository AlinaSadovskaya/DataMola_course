drop PROCEDURE load_PROMOTION_hist;
CREATE PROCEDURE load_PROMOTION_hist
   AS
   BEGIN
      DECLARE
	   TYPE prom IS REF CURSOR ;
	
       TYPE INT_DATA IS TABLE OF INT;
	   TYPE FLOAT_DATA IS TABLE OF FLOAT;  
	   TYPE VARCHAR_DATA IS TABLE OF varchar2(150);
       TYPE DATE_DATA IS TABLE OF DATE;
	
	   promotion prom;
	   
       promotion_sk_STAGE int_DATA;
       
	   promotion_type_id_STAGE INT_DATA;
       promotion_type_id_SOURCE INT_DATA;
       
	   promotion_type_SOURCE VARCHAR_DATA;
       promotion_type_STAGE VARCHAR_DATA;
       
       PROMOTION_PRICE_PERCENT_SOURCE FLOAT_DATA;
       PROMOTION_PRICE_PERCENT_STAGE FLOAT_DATA;
       
       PROMOTION_VALID_FROM_SOURCE DATE_DATA;
       PROMOTION_VALID_FROM_Stage DATE_DATA;
       PROMOTION_VALID_TO_STAGE DATE_DATA;
       PROMOTION_VALID_TO_Source DATE_DATA;
       promotion_insert_day DATE_DATA;
	BEGIN
	   OPEN promotion FOR
	       SELECT surr_key
	             , promotion_type_id_Source
	             , promotion_type_id_STAGE
                 , promotion_source
                 , promotion_stage
                 , price_perc_source
                 , price_perc_stage
                 , vf_source
                 , vf_stage
                 , vt_source
                 , vt_stage
                 , insert_day
	          FROM    (SELECT DISTINCT  t_stage.PROMOTION_SURROGATE_KEY surr_key
                                        , t_TYPE.promotion_id promotion_type_id_Source
                                        , t_stage.promotion_id promotion_type_id_STAGE
                                        , t_source.promotion promotion_source
                                        , t_stage.promotion promotion_stage
                                        , t_source.price_percent price_perc_source
                                        , t_stage.price_percent price_perc_stage
                                        , t_source.valid_from vf_source
                                        , t_stage.valid_from vf_stage
                                        , t_source.valid_to vt_source
                                        , t_stage.valid_to vt_stage
                                        , t_source.insert_day insert_day
	                     FROM DW_CL.DW_CL_GEN_PROMOTION_DATA t_source
	               LEFT JOIN
	                  DW_DATA.DW_GEN_PROMOTION_TYPE t_TYPE
	               ON (t_source.PROMOTION = t_TYPE.PROMOTION)
	              LEFT JOIN DW_DATA.DW_GEN_PROMOTION_HIST t_stage
	                ON (t_source.PROMOTION = t_stage.PROMOTION
                        AND t_source.VALID_FROM = t_stage.VALID_FROM
                        AND t_source.VALID_TO = t_stage.VALID_TO));
	
	   FETCH promotion
	   BULK COLLECT INTO promotion_sk_STAGE, promotion_type_id_SOURCE, promotion_type_id_STAGE, promotion_type_SOURCE,  promotion_type_STAGE, 
        PROMOTION_PRICE_PERCENT_SOURCE, PROMOTION_PRICE_PERCENT_STAGE, PROMOTION_VALID_FROM_SOURCE, PROMOTION_VALID_FROM_Stage ,  
        PROMOTION_VALID_TO_Source, PROMOTION_VALID_TO_STAGE, promotion_insert_day;
	
	   CLOSE promotion;
	
	   FOR i IN promotion_sk_STAGE.FIRST .. promotion_sk_STAGE.LAST LOOP
	      IF ( promotion_sk_STAGE ( i ) IS NULL ) THEN
	         INSERT INTO DW_GEN_PROMOTION_hist ( PROMOTION_SURROGATE_KEY
                                                 , PROMOTION_ID
                                                 , PROMOTION
                                                 , PRICE_PERCENT
                                                 , VALID_FROM
                                                 , VALID_TO
                                                 , INSERT_DAY
                                                 , UPDATE_DAY )
	              VALUES ( SEQ_PROMOTION_HIST.nextval
	                     , promotion_type_id_SOURCE ( i )
                         , promotion_type_SOURCE( i )
	                     , PROMOTION_PRICE_PERCENT_SOURCE ( i )
	                     , PROMOTION_VALID_FROM_SOURCE ( i )
                         , PROMOTION_VALID_TO_Source ( i )
                         , promotion_insert_day(i)
	                     , NULL );
	
	         COMMIT;
          ELSE UPDATE DW_GEN_PROMOTION_hist
	            SET  PRICE_PERCENT = PROMOTION_PRICE_PERCENT_SOURCE ( i )
                    , INSERT_DAY = promotion_insert_day(i)
                    , UPDATE_DAY    = SYSDATE
	          WHERE DW_GEN_PROMOTION_hist.PROMOTION_ID = promotion_type_id_Stage ( i );
	
	         COMMIT;
	      END IF;
	   END LOOP;
	END;
   END load_PROMOTION_hist;
   
execute load_PROMOTION_hist;