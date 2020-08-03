CREATE OR REPLACE PACKAGE body pkg_promotions
AS 
 PROCEDURE load_CLEAN_GEN_PROMOTION_DATA 
   AS
      CURSOR c_v
      IS
         SELECT DISTINCT promotion
                       , valid_from
                       , valid_to
                       , price_percent
                       , INSERT_DAy
           FROM SA_CUSTOMERS.sa_gen_promotion_data
           WHERE INSERT_DAY IS NOT NULL ;
   BEGIN
      FOR i IN c_v LOOP
         INSERT INTO DW_CL.dw_cl_gen_promotion_data( 
                        promotion
                       , valid_from
                       , valid_to
                       , price_percent
                       , INSERT_DAy)
              VALUES ( i.promotion
                       , i.valid_from
                       , i.valid_to
                       , i.price_percent
                       , i.INSERT_DAy);

         EXIT WHEN c_v%NOTFOUND;
      END LOOP;

      COMMIT;
   END load_CLEAN_GEN_PROMOTION_DATA;
   
   
   PROCEDURE load_PROMOTION_types
   AS
   BEGIN
      DECLARE
	   TYPE type_prom IS REF CURSOR ;
	
       TYPE INT_DATA IS TABLE OF INT;
	   TYPE FLOAT_DATA IS TABLE OF FLOAT;  
	   TYPE VARCHAR_DATA IS TABLE OF varchar2(150);
       TYPE DATE_DATA IS TABLE OF DATE;
	
	   type_promotion type_prom;
	   
	   promotion_type_id_STAGE INT_DATA;
	   promotion_type_SOURCE VARCHAR_DATA;
       PROMOTION_PRICE_PERCENT_SOURCE FLOAT_DATA;
       PROMOTION_INSERT_DAY DATE_DATA;
	BEGIN
	   OPEN type_promotion FOR
	       SELECT promotion
	             , price_percent
	             , prom_id
	          FROM    (SELECT DISTINCT  t_source.PROMOTION as promotion
                                       ,t_source.PRICE_PERCENT price_percent
                                       ,t_stage.PROMOTION_ID prom_id
	                     FROM (DW_CL.DW_CL_GEN_PROMOTION_DATA t_source
                         
	               LEFT JOIN
	                  DW_DATA.DW_GEN_PROMOTION_TYPE t_stage
	               ON (t_stage.PROMOTION = t_source.PROMOTION 
                       AND t_stage.PRICE_PERCENT = t_source.PRICE_PERCENT)));
       
	   FETCH type_promotion
	   BULK COLLECT INTO promotion_type_SOURCE, PROMOTION_PRICE_PERCENT_SOURCE,  promotion_type_id_STAGE;
	
	   CLOSE type_promotion;
	
	   FOR i IN promotion_type_id_STAGE.FIRST .. promotion_type_id_STAGE.LAST LOOP
	      IF ( promotion_type_id_STAGE ( i ) IS NULL ) THEN
	         INSERT INTO DW_DATA.DW_GEN_PROMOTION_TYPE ( PROMOTION_ID
                                                 ,PROMOTION
                                                 ,PRICE_PERCENT
                                                 ,INSERT_DAY
                                                 ,UPDATE_DAY)
	              VALUES ( SEQ_PROMOTION.NEXTVAL
	                     , promotion_type_SOURCE ( i )
	                     , PROMOTION_PRICE_PERCENT_SOURCE ( i )
	                     , SYSDATE
	                     , NULL );
	
	         COMMIT;
	      ELSE UPDATE DW_DATA.DW_GEN_PROMOTION_TYPE
	            SET UPDATE_DAY = SYSDATE
	          WHERE DW_DATA.DW_GEN_PROMOTION_TYPE.promotion_id = promotion_type_id_STAGE ( i );
	
	         COMMIT;
	      END IF;
	   END LOOP;
	END;
   END load_PROMOTION_types;
   
   
   PROCEDURE load_PROMOTION_hist
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
	         INSERT INTO DW_DATA.DW_GEN_PROMOTION_hist ( PROMOTION_SURROGATE_KEY
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
          ELSE UPDATE DW_DATA.DW_GEN_PROMOTION_hist
	            SET  PRICE_PERCENT = PROMOTION_PRICE_PERCENT_SOURCE ( i )
                    , INSERT_DAY = promotion_insert_day(i)
                    , UPDATE_DAY    = SYSDATE
	          WHERE DW_DATA.DW_GEN_PROMOTION_hist.PROMOTION_ID = promotion_type_id_Stage ( i );
	
	         COMMIT;
	      END IF;
	   END LOOP;
	END;
   END load_PROMOTION_hist;
   
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
	              LEFT JOIN ALINA.DIM_promotions_scd t_stage
	                ON (t_hist.PROMOTION = t_stage.PROMOTION_DESCRIPTION
                        AND t_hist.VALID_FROM = t_stage.VALID_FROM
                        AND t_hist.VALID_TO = t_stage.VALID_TO);
	
	   FETCH promotion
	   BULK COLLECT INTO promotion_sk_HIST, promotion_type_id_HIST, promotion_DESCR_HIST, PRICE_PERCENT_HIST
       ,PROMOTION_VALID_FROM_HIST, PROMOTION_VALID_TO_HIST, promotion_insert_day, promotion_sk_STAGE;
	
	   CLOSE promotion;
	
	   FOR i IN promotion_sk_STAGE.FIRST .. promotion_sk_STAGE.LAST LOOP
	      IF ( promotion_sk_STAGE ( i ) IS NULL ) THEN
	         INSERT INTO ALINA.DIM_promotions_scd ( SURROGATE_KEY
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
          ELSE UPDATE ALINA.DIM_promotions_scd
	            SET  PROMOTION_ID = promotion_sk_HIST(i)
                     ,PROMOTION_DESCRIPTION = promotion_DESCR_HIST( i )
                     ,PRICE_DECREASING_PERCENT = PRICE_PERCENT_HIST ( i )
                     ,VALID_FROM = PROMOTION_VALID_FROM_HIST ( i )
                     ,VALID_TO = PROMOTION_VALID_TO_HIST(I)
                     ,insert_day =  Promotion_insert_day(i)
                     ,UPDATE_DAY    = SYSDATE
	          WHERE ALINA.DIM_promotions_scd.SURROGATE_KEY = promotion_sk_HIST(i);
	
	         COMMIT;
	      END IF;
	   END LOOP;
	END;
   END load_PROMOTION_dim;
   
END pkg_promotions;