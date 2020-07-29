drop table DIM_customer;
CREATE TABLE DIM_customer (
    customer_id   NUMBER(10) NOT NULL,
    first_name    VARCHAR2(40 BYTE) NOT NULL,
    last_name     VARCHAR2(40 BYTE) NOT NULL,
    email         VARCHAR2(40 BYTE) NOT NULL,
    phone         VARCHAR2(40 BYTE) NOT NULL,
    YEAR_OF_BIRTH DATA NOT NULL,
    address       VARCHAR2(20 BYTE) NOT NULL,
    city          VARCHAR2(20 BYTE) NOT NULL,
    country       VARCHAR2(20 BYTE) NOT NULL,
    region        VARCHAR2(20 BYTE) NOT NULL,
    CONSTRAINT customer_id_pk PRIMARY KEY ( customer_id ) ENABLE
);
drop table DIM_product;
CREATE TABLE DIM_product (
    PRODUCT_ID	            NUMBER(10) NOT NULL,
    PRODUCT_NAME	        VARCHAR2(10 BYTE) NOT NULL,
    PRODUCT_DESCRIPTION	    VARCHAR2(40 BYTE) NOT NULL,	
    LINE_ID	                NUMBER(10) NOT NULL,
    LINE_NAME	            VARCHAR2(10 BYTE) NOT NULL,	
    LINE_DESCRIPTION	    VARCHAR2(40 BYTE) NOT NULL,	
    COLLECTION_ID	        NUMBER(10) NOT NULL,
    SEASON_ID	            NUMBER(10) NOT NULL,	
    SEASON	                VARCHAR2(10 BYTE) NOT NULL,
    COLLECTION_DESCRIPTION	VARCHAR2(40 BYTE) NOT NULL,
    COLLECTION_DATE	        DATE  NOT NULL,	
    PRODUCT_TYPE_ID	        NUMBER(10),	
    PRODUCT_TYPE 	        VARCHAR2(10 BYTE) NOT NULL,
    HEIGHT	                VARCHAR2(10 BYTE) NOT NULL,	
    HIP_GIRTH	            NUMBER(10) NOT NULL,
    COLOR	                VARCHAR2(40 BYTE) NOT NULL,	
    PRICE	                NUMBER(10) NOT NULL,
    CONSTRAINT product_id_pk PRIMARY KEY ( product_id ) ENABLE
);
drop table DIM_store;
CREATE TABLE DIM_store (
    store_id      NUMBER(10) NOT NULL,
    manager_id    NUMBER(10) NOT NULL,
    phone         VARCHAR2(40 BYTE) NOT NULL,
    address       VARCHAR2(20 BYTE) NOT NULL,
    city          VARCHAR2(20 BYTE) NOT NULL,
    country       VARCHAR2(20 BYTE) NOT NULL,
    region        VARCHAR2(20 BYTE) NOT NULL,
    CONSTRAINT store_id_pk PRIMARY KEY ( store_id ) ENABLE
);
drop table DIM_gen_period;
CREATE TABLE DIM_gen_period (
    period_id      NUMBER(10) NOT NULL,
    VALID_FROM     NUMBER(10) NOT NULL,
    VALID_TO       NUMBER(10) NOT NULL,
    promotions_id  NUMBER(10) NOT NULL,
    decription    VARCHAR2(20 BYTE) NOT NULL,
    CONSTRAINT period_id_pk PRIMARY KEY ( period_id) ENABLE
);

DROP TABLE DIM_payment_method;
CREATE TABLE DIM_payment_method(
    PAYMENT_METHOD_ID	NUMBER(10,0) NOT NULL,
    PAYMENT_METHOD_NAME	VARCHAR2(40 BYTE) NOT NULL,
    BANK_NAME	VARCHAR2(40 BYTE) NOT NULL,
    CONSTRAINT  PAYMENT_METHOD_ID_pk PRIMARY KEY (  PAYMENT_METHOD_ID ) ENABLE
);
DROP TABLE DIM_geo_locations;
create table DIM_geo_locations 
(
   Geo_id             NUMBER(10,0) NOT NULL,
   Geo_group_id       NUMBER(10) NOT NULL,
   Geo_group_desc     VARCHAR2(200) NOT NULL,
   Geo_sub_group_id   NUMBER(10) NOT NULL,
   Geo_dub_group_desc VARCHAR2(200) NOT NULL,
   Geo_system_code    NUMBER(10) NOT NULL,
   Geo_system_desc    VARCHAR2(200) NOT NULL,
   Geo_region_id      NUMBER(10) NOT NULL,
   Geo_region_desc    VARCHAR2(200) NOT NULL,
   Geo_country_code_a2 VARCHAR2(200) NOT NULL,
   Geo_country_code_a3 VARCHAR2(200) NOT NULL,
   Geo_country_id     NUMBER(10) NOT NULL,
   Geo_country_desc   VARCHAR2(200) NOT NULL,
   constraint geo_locations_dimension_PK primary key (Geo_id) ENABLE
);
drop table DIM_employee;
CREATE TABLE DIM_employee (
    employee_id     NUMBER(10) NOT NULL,
    first_name      VARCHAR2(40 BYTE) NOT NULL,
    last_name       VARCHAR2(40 BYTE) NOT NULL,
    email           VARCHAR2(40 BYTE) NOT NULL,
    phone           VARCHAR2(40 BYTE) NOT NULL,
    store_id        NUMBER(10) NOT NULL,
    POSITION_NAME   VARCHAR2(40 BYTE) NOT NULL,
    POSITION_GRADE	VARCHAR2(40 BYTE) NOT NULL,
    HIRE_DATE	    DATE NOT NULL,	
    FIRE_DATE	    DATE NOT NULL,
    MANAGER_ID	    NUMBER(10) NOT NULL,	
    M_FIRST_NAME	VARCHAR2(40 BYTE) NOT NULL,	
    M_LAST_NAME	    VARCHAR2(40 BYTE) NOT NULL,	
    M_POSITION_NAME	VARCHAR2(40 BYTE) NOT NULL,	
    CONSTRAINT employee_id_pk PRIMARY KEY ( employee_id) ENABLE
);
drop table DIM_promotions;
CREATE TABLE DIM_promotions(
    PROMOTION_ID	        NUMBER(10) NOT NULL,
    PROMOTION_TYPE_ID	    NUMBER(10) NOT NULL,	
    PROMOTION_TYPE	        VARCHAR2(40 BYTE) NOT NULL,	
    PROMOTION_DESCRIPTION	VARCHAR2(40 BYTE) NOT NULL,
    PROMOTION_PRICE	        NUMBER(10) NOT NULL,	
    PRICE_DECREASING_PERCENT	NUMBER(10) NOT NULL,	
    FREE_UNIT_AMOUNT	    NUMBER(10) NOT NULL,		
    CONSTRAINT PROMOTION_id_pk PRIMARY KEY ( PROMOTION_ID ) ENABLE
);
drop table DIM_date;
CREATE TABLE DIM_date(
    date_id             DATE NOT NULL,
    full_date           VARCHAR2(10) NOT NULL,
    day_name            VARCHAR2(9) NOT NULL,
    day_of_month        VARCHAR2(2) NOT NULL,
    day_of_week         VARCHAR2(1) NOT NULL,
    day_of_quarter      VARCHAR2(3) NOT NULL,
    day_of_year         VARCHAR2(3) NOT NULL,
    week_of_month       VARCHAR2(1) NOT NULL,
    week_of_quarter     VARCHAR2(2) NOT NULL,
    week_of_year        VARCHAR2(2) NOT NULL,
    month_number         VARCHAR2(2) NOT NULL,
    month_name          VARCHAR2(9) NOT NULL,
    month_of_quarter    VARCHAR2(2) NOT NULL,
    month_of_year       VARCHAR2(2) NOT NULL,
    quarter             VARCHAR2(1) NOT NULL,
    quarter_name         VARCHAR2(9) NOT NULL,
    quarter_of_year       VARCHAR2(2) NOT NULL,
    year_number          VARCHAR2(4) NOT NULL,
    firstday_of_month     DATE NOT NULL,
    lastday_of_month      DATE NOT NULL,
    firstday_of_quarter   DATE NOT NULL,
    lastday_of_quarter    DATE NOT NULL,
    firstday_of_year      DATE NOT NULL,
    lastday_of_year       DATE NOT NULL,
    CONSTRAINT date_id_pk PRIMARY KEY ( date_id ) ENABLE
);
drop table retail_fact_sales ;

CREATE TABLE retail_fact_sales (
    sales_id       NUMBER(10) NOT NULL,
    date_id        DATE NOT NULL,
    PRODUCT_ID	   NUMBER(10) NOT NULL,
    EMPLOYEE_ID	   NUMBER(10) NOT NULL,
    CUSTOMER_ID	   NUMBER(10) NOT NULL,
    GEO_ID         NUMBER(10) NOT NULL,
    STORE_ID	   NUMBER(10) NOT NULL,
    PAYMENT_METHOD_ID	NUMBER(10) NOT NULL,
    PROMOTION_ID   NUMBER(10) NOT NULL,
    period_id      NUMBER(10) NOT NULL,
    SALE_SUM	   NUMBER(10) NOT NULL,
    sales_amount   NUMBER(10) NOT NULL,
    CONSTRAINT date_id_fk FOREIGN KEY ( date_id )
        REFERENCES dim_date ( date_id ),
    CONSTRAINT PRODUCT_ID_fk FOREIGN KEY ( PRODUCT_ID )
        REFERENCES dim_product ( product_id ),
    CONSTRAINT employee_id_fk FOREIGN KEY ( employee_id )
        REFERENCES dim_employee ( employee_id ),
    CONSTRAINT customer_id_fk FOREIGN KEY ( customer_id )
        REFERENCES dim_customer ( customer_id ),
    CONSTRAINT store_id_fk FOREIGN KEY ( store_id )
        REFERENCES dim_store ( store_id ),
    CONSTRAINT PAYMENT_METHOD_ID_fk FOREIGN KEY ( PAYMENT_METHOD_ID )
        REFERENCES dim_PAYMENT_METHOD ( PAYMENT_METHOD_ID ),
    CONSTRAINT PROMOTION_ID_fk FOREIGN KEY ( PROMOTION_ID )
        REFERENCES dim_PROMOTIONs ( PROMOTION_ID ),
    CONSTRAINT Geo_id_fk FOREIGN KEY ( GEO_ID)
        REFERENCES dim_geo_locations(GEO_ID),
    CONSTRAINT period_id_fk FOREIGN KEY ( period_ID)
        REFERENCES dim_gen_period(period_id),
    CONSTRAINT sales_id_pk PRIMARY KEY ( sales_id ) ENABLE
)
PARTITION BY RANGE (month(date_id))
    subpartition by hash(PRODUCT_DETAILS_ID) subpartitions 4
(
    PARTITION QUARTER_1 VALUES LESS THAN('04')
    (
      subpartition QUARTER_1_sub_1,
      subpartition QUARTER_1_sub_2,
      subpartition QUARTER_1_sub_3,
      subpartition QUARTER_1_sub_4
    ),
    PARTITION QUARTER_2 VALUES LESS THAN('07')
    (
      subpartition QUARTER_2_sub_1,
      subpartition QUARTER_2_sub_2,
      subpartition QUARTER_2_sub_3,
      subpartition QUARTER_2_sub_4
     ),
     PARTITION QUARTER_3 VALUES LESS THAN('10')
    (
       subpartition QUARTER_3_sub_1,
      subpartition QUARTER_3_sub_2,
      subpartition QUARTER_3_sub_3,
      subpartition QUARTER_3_sub_4
    ),
     PARTITION QUARTER_4 VALUES LESS THAN('13')
    (
      subpartition QUARTER_4_sub_1,
      subpartition QUARTER_4_sub_2,
      subpartition QUARTER_4_sub_3,
      subpartition QUARTER_4_sub_4
    )
);

        
CREATE TABLE product_fact_balances(
        DATE_ID	    DATE NOT NULL,
        PRODUCT_ID	NUMBER(10) NOT NULL,
        STORE_ID	NUMBER(10) NOT NULL,
        STOCK_VALUE	NUMBER(10) NOT NULL,
        TOTAL_PRODUCT_BALANCE NUMBER(10) NOT NULL,
    CONSTRAINT date_id_fb FOREIGN KEY ( date_id )
        REFERENCES dim_date ( date_id ),
    CONSTRAINT PRODUCT_ID_fb FOREIGN KEY ( PRODUCT_ID )
        REFERENCES dim_product ( product_id ),
    CONSTRAINT store_id_fb FOREIGN KEY ( store_id )
        REFERENCES dim_store ( store_id ),
    CONSTRAINT product_balance_id_pk PRIMARY KEY ( date_id, product_id, store_id) ENABLE
);
drop table product_fact_balances;
commit;