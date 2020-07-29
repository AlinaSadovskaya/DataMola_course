drop PROCEDURE load_PROMOTION_types;
CREATE PROCEDURE load_PROMOTION_types
   AS
   BEGIN
      DECLARE
	   TYPE type_prom IS REF CURSOR ;
		
	   
	   TYPE type_rec IS RECORD
	   (
	      promotion_type_id_STAGE  INT
	    , promotion_type_SOURCE  VARCHAR2 ( 100 )
	    , PROMOTION_PRICE_PERCENT_SOURCE FLOAT
	   );
	   type_promotion type_prom;
       RECORD_1 type_rec;
       
       curid          NUMBER ( 25 );
	   query_cur      VARCHAR2 ( 2000 );
	   ret            NUMBER ( 25 );
	BEGIN
        
        query_cur := 'SELECT promotion
	             , price_percent
	             , prom_id
	          FROM    (SELECT DISTINCT  t_source.PROMOTION as promotion
                                       ,t_source.PRICE_PERCENT price_percent
                                       ,t_stage.PROMOTION_ID prom_id
	                     FROM (DW_CL.DW_CL_GEN_PROMOTION_DATA t_source
                         
	               LEFT JOIN
	                  DW_DATA.DW_GEN_PROMOTION_TYPE t_stage
	               ON (t_stage.PROMOTION = t_source.PROMOTION 
                       AND t_stage.PRICE_PERCENT = t_source.PRICE_PERCENT)))';
	   
       curid:= dbms_sql.open_cursor;
	   dbms_sql.parse ( curid
	                  , query_cur
	                  , dbms_sql.native );    
       ret         := dbms_sql.execute ( curid );
	
	   type_promotion     := dbms_sql.to_refcursor ( curid );
        LOOP
	      FETCH type_promotion
	      INTO record_1;
          EXIT WHEN type_promotion%NOTFOUND;
	   
	
	   IF ( record_1.promotion_type_id_STAGE IS NULL ) THEN
	         INSERT INTO DW_GEN_PROMOTION_TYPE ( PROMOTION_ID
                                                 ,PROMOTION
                                                 ,PRICE_PERCENT
                                                 ,INSERT_DAY
                                                 ,UPDATE_DAY)
	              VALUES ( SEQ_PROMOTION.NEXTVAL
	                     ,  record_1.promotion_type_SOURCE
	                     ,  record_1.PROMOTION_PRICE_PERCENT_SOURCE
	                     , SYSDATE
	                     , NULL );
	
	         COMMIT;
	      ELSE UPDATE DW_GEN_PROMOTION_TYPE
	            SET UPDATE_DAY = SYSDATE
	          WHERE DW_GEN_PROMOTION_TYPE.promotion_id =  record_1.promotion_type_id_STAGE;
	
	         COMMIT;
	      END IF;
	   END LOOP;
	END;
   END load_PROMOTION_types;
   
execute load_PROMOTION_types;