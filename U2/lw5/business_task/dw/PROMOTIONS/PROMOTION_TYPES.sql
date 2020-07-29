drop PROCEDURE load_PROMOTION_types;
CREATE PROCEDURE load_PROMOTION_types
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
	         INSERT INTO DW_GEN_PROMOTION_TYPE ( PROMOTION_ID
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
	      ELSE UPDATE DW_GEN_PROMOTION_TYPE
	            SET UPDATE_DAY = SYSDATE
	          WHERE DW_GEN_PROMOTION_TYPE.promotion_id = promotion_type_id_STAGE ( i );
	
	         COMMIT;
	      END IF;
	   END LOOP;
	END;
   END load_PROMOTION_types;
   
execute load_PROMOTION_types;