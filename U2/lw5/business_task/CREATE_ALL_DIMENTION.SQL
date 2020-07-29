drop table DIM_product;
CREATE TABLE DIM_product (
    product_id        INTEGER NOT NULL,
    PRODUCT_NAME      VARCHAR2(40 BYTE) NOT NULL,
    LINE_ID           INT NOT NULL,
    LINE_NAME         VARCHAR2(40 BYTE) NOT NULL,
    COLLECTION_ID     INT NOT NULL,
    COLLECTION_NAME   VARCHAR2(40 BYTE) NOT NULL,
    SEASON_ID         INT NOT NULL,
    SEASON            VARCHAR2(40 BYTE) NOT NULL,
    SIZE_CLOTHES      VARCHAR2(10 BYTE) NOT NULL,
    COLOR             VARCHAR2(40 BYTE) NOT NULL,
    PRICE             FLOAT NOT NULL,
    INSERT_DATE       DATE NOT NULL,
    UPDATE_DATE       DATE,
    CONSTRAINT product_id_pk PRIMARY KEY ( product_id ) ENABLE
);

DROP TABLE DIM_geo_locations;
create table DIM_geo_locations 
as SELECT country_geo_id
     , cntr.country_id
     , cntr.country_code_a2
     , cntr.country_code_a3
     , cntr.region_desc AS country_desc
     --region
     , NVL ( g_region_id, -99 ) AS region_geo_id
     , NVL ( reg.src_continent_id, -99 ) AS region_id
     , NVL ( reg.region_code, 'n.d.' ) AS region_code
     , NVL ( reg.region_desc, 'n.d.' ) AS region_desc
     -- part
     , NVL ( g_part_id, -99 ) AS part_geo_id
     , NVL ( part.part_id, -99 ) AS part_id
     , NVL ( part.part_code, 'n.d.' ) AS part_code
     , NVL ( part.part_desc, 'n.d.' ) AS part_desc
     -- geo_systems
     , NVL ( g_system_id, -99 ) AS geo_system_geo_id
     , NVL ( g_sys.src_geo_system_id, -99 ) AS geo_system_id
     , NVL ( g_sys.geo_system_code, 'n.d.' ) AS geo_system_code
     , NVL ( g_sys.geo_system_desc, 'n.d.' ) AS geo_system_desc
     -- group_items
     , NVL ( grp_sub_gr, -99 ) AS sub_group_geo_id
     , NVL ( sub_grp.sub_group_id, -99 ) AS sub_group_id
     , NVL ( sub_grp.sub_group_code, 'n.d.' ) AS sub_group_code
     , NVL ( sub_grp.sub_group_desc, 'n.d.' ) AS sub_group_desc
     -- groups
     , NVL ( grp_group, -99 ) AS group_geo_id
     , NVL ( grp.GROUP_ID, -99 ) AS GROUP_ID
     , NVL ( grp.group_code, 'n.d.' ) AS group_code
     , NVL ( grp.group_desc, 'n.d.' ) AS group_desc
     -- group system
     , NVL ( grp_sys, -99 ) AS grp_system_geo_id
     , NVL ( grp_sys.grp_system_id, -99 ) AS grp_system_id
     , NVL ( grp_sys.grp_system_code, 'n.d.' ) AS grp_system_code
     , NVL ( grp_sys.grp_system_desc, 'n.d.' ) AS grp_system_desc
  FROM (    SELECT CONNECT_BY_ROOT child_geo_id AS country_geo_id
                 , parent_geo_id
                 , link_type_id
              FROM u_dw_references.t_geo_object_links
        START WITH child_geo_id IN (SELECT geo_id
                                      FROM u_dw_references.cu_countries)
        CONNECT BY PRIOR parent_geo_id = child_geo_id) PIVOT (SUM ( parent_geo_id )
                                                       FOR link_type_id
                                                       IN  (1 AS g_system_id
                                                         , 2 AS g_part_id
                                                         , 3 AS g_region_id
                                                         , 4 AS grp_sys
                                                         , 5 AS grp_group
                                                         , 6 AS grp_sub_gr)) src
     , u_dw_references.cu_countries cntr
     , u_dw_references.cu_geo_regions reg
     , u_dw_references.cu_geo_parts part
     , u_dw_references.cu_geo_systems g_sys
     , u_dw_references.cu_cntr_group_systems grp_sys
     , u_dw_references.cu_cntr_groups grp
     , u_dw_references.cu_cntr_sub_groups sub_grp
 WHERE cntr.geo_id(+) = src.country_geo_id
   AND reg.geo_id(+) = src.g_region_id
   AND part.geo_id(+) = src.g_part_id
   AND g_sys.geo_id(+) = src.g_system_id
   AND grp_sys.geo_id(+) = src.grp_sys
   AND grp.geo_id(+) = src.grp_group
   AND sub_grp.geo_id(+) = src.grp_sub_gr;

ALTER TABLE DIM_geo_locations
 ADD CONSTRAINT pk_DIM_geo_locations
 PRIMARY KEY (country_geo_id);
 
drop table DIM_promotions_scd;
CREATE TABLE DIM_promotions_scd(
    SURROGATE_KEY           INT UNIQUE NOT NULL,
    PROMOTION_ID	        NUMBER(10) NOT NULL,	
    PROMOTION_DESCRIPTION	VARCHAR2(40 BYTE) NOT NULL,
    PRICE_DECREASING_PERCENT	NUMBER(10) NOT NULL,
    VALID_FROM              DATE NOT NULL,
    VALID_TO                DATE NOT NULL,
    insert_day              DATE NOT NULL,
    UPDATE_DAY              DATE,
    CONSTRAINT PROMOTION_id_Pk PRIMARY KEY ( PROMOTION_ID, VALID_FROM,VALID_TO) ENABLE
);

drop table DIM_date;

CREATE TABLE dim_DATE
    AS
        ( SELECT
            t_days.time_id                        time_id,
            t_days.day_name                       day_name,
            t_days.day_number_in_week             day_number_in_week_iso,
            t_days.day_number_in_month            day_number_in_month_iso,
            t_days.day_number_in_year             day_number_in_year_iso,
            t_weeks.week_id                       week_id,
            t_weeks.week_beg_date                 week_beg_date,
            t_weeks.week_ending_date              week_ending_date,
            t_months.month_id                     month_id_iso,
            t_months.calendar_month_number        calendar_month_number_iso,
            t_months.days_in_cal_month            days_in_cal_month_iso,
            t_months.beg_of_cal_month             beg_of_cal_month_iso,
            t_months.end_of_cal_month             end_of_cal_month_iso,
            t_months.calendar_month_name          calendar_month_name_iso,
            m.month_id                            month_id_fin,
            m.calendar_month_number               calendar_month_number_fin,
            m.days_in_cal_month                   days_in_cal_month_fin,
            m.beg_of_cal_month                    beg_of_cal_month_fin,
            m.end_of_cal_month                    end_of_cal_month_fin,
            m.calendar_month_name                 calendar_month_name_fin,
            t_quarters.quarter_id                 quarter_id_iso,
            t_quarters.days_in_cal_quarter        days_in_cal_quarter_iso,
            t_quarters.beg_of_cal_quarter         beg_of_cal_quarter_iso,
            t_quarters.end_of_cal_quarter         end_of_cal_quarter_iso,
            t_quarters.calendar_quarter_number    calendar_quarter_number_iso,
            q.quarter_id                          quarter_id_fin,
            q.days_in_cal_quarter                 days_in_cal_quarter_fin,
            q.beg_of_cal_quarter                  beg_of_cal_quarter_fin,
            q.end_of_cal_quarter                  end_of_cal_quarter_fin,
            q.calendar_quarter_number             calendar_quarter_number_fin,
            t_years.year_id                       year_id_iso,
            t_years.calendar_year                 calendar_year_iso,
            t_years.days_in_cal_year              days_in_cal_year_iso,
            t_years.beg_of_cal_year               beg_of_cal_year_iso,
            t_years.end_of_cal_year               end_of_cal_year_iso,
            y.year_id                             year_id_fin,
            y.calendar_year                       calendar_year_fin,
            y.days_in_cal_year                    days_in_cal_year_fin,
            y.beg_of_cal_year                     beg_of_cal_year_fin,
            y.end_of_cal_year                     end_of_cal_year_fin
        FROM
                 t_days
            INNER JOIN t_weeks ON t_days.time_id BETWEEN week_beg_date AND week_ending_date
            INNER JOIN t_months ON t_days.time_id BETWEEN beg_of_cal_month AND end_of_cal_month
                                   AND type = 'iso'
            INNER JOIN t_months    m ON t_days.time_id BETWEEN m.beg_of_cal_month AND m.end_of_cal_month
                                     AND m.type = 'fin'
            INNER JOIN t_quarters ON t_days.time_id BETWEEN t_quarters.beg_of_cal_quarter AND t_quarters.end_of_cal_quarter
                                     AND t_quarters.type = 'iso'
            INNER JOIN t_quarters  q ON t_days.time_id BETWEEN q.beg_of_cal_quarter AND q.end_of_cal_quarter
                                       AND q.type = 'fin'
            INNER JOIN t_years ON t_days.time_id BETWEEN t_years.beg_of_cal_year AND t_years.end_of_cal_year
                                  AND t_years.type = 'iso'
            INNER JOIN t_years     y ON t_days.time_id BETWEEN y.beg_of_cal_year AND y.end_of_cal_year
                                    AND y.type = 'fin'
        );

        
ALTER TABLE DIM_DATE
 ADD CONSTRAINT DIM_ID_PK
 PRIMARY KEY (TIME_ID);
 
drop table retail_fact_sales_DD ;
CREATE TABLE retail_fact_sales_dd (
    sales_id       NUMBER(10),
    date_id        DATE NOT NULL,
    PRODUCT_ID	   NUMBER(10) NOT NULL,
    PROMOTION_ID   NUMBER(10) NOT NULL,
    SALE_SUM	   NUMBER(10) NOT NULL,
    sales_amount   NUMBER(10) NOT NULL,
    CONSTRAINT date_id_fk FOREIGN KEY ( date_id )
        REFERENCES dim_date ( TIME_id ),
    CONSTRAINT PRODUCT_ID_fk FOREIGN KEY ( PRODUCT_ID )
        REFERENCES dim_product ( product_id ),
    CONSTRAINT PROMOTION_ID_fk FOREIGN KEY ( PROMOTION_ID )
        REFERENCES dim_PROMOTIONs_SCD ( SURROGATE_KEY ),
    CONSTRAINT sales_id_pk PRIMARY KEY ( sales_id ) ENABLE
);

DROP TABLE COUNTRY_fact_sales_dd;
CREATE TABLE COUNTRY_fact_sales_dd (
    date_id        DATE NOT NULL,
    PRODUCT_ID	   NUMBER(10) NOT NULL,
    GEO_ID         NUMBER(10) NOT NULL,
    SALE_SUM	   NUMBER(10) NOT NULL,
    sales_amount   NUMBER(10) NOT NULL,
    CONSTRAINT date_id_fC FOREIGN KEY ( date_id )
        REFERENCES dim_date ( TIME_id ),
    CONSTRAINT PRODUCT_ID_fC FOREIGN KEY ( PRODUCT_ID )
        REFERENCES dim_product ( product_id ),
    CONSTRAINT Geo_id_fC FOREIGN KEY ( GEO_ID)
        REFERENCES dim_geo_locations(country_geo_id)
);

commit;