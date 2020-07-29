CREATE TABLE sf_customer_geo_dimension (
    address_id    NUMBER(10) NOT NULL,
    postal_code   NUMBER(10),
    address       VARCHAR2(20 BYTE),
    city          VARCHAR2(20 BYTE),
    country       VARCHAR2(20 BYTE),
    region        VARCHAR2(20 BYTE),
    CONSTRAINT address_cg_id_pk PRIMARY KEY ( address_id ) ENABLE
);

CREATE TABLE sf_customer_dimension (
    customer_id   NUMBER(10) NOT NULL,
    first_name    VARCHAR2(40 BYTE),
    last_name     VARCHAR2(40 BYTE),
    email         VARCHAR2(40 BYTE),
    phone         VARCHAR2(40 BYTE),
    address_id    NUMBER(10) NOT NULL,
    CONSTRAINT customer_cd_id_pk PRIMARY KEY ( customer_id ) ENABLE,
    CONSTRAINT address_cg_id_fk FOREIGN KEY ( address_id )
        REFERENCES sf_customer_geo_dimension ( address_id )
);

CREATE TABLE sf_category_dimension (
    category_id     NUMBER(10),
    category_name   VARCHAR2(40 BYTE),
    CONSTRAINT category_cd_id_pk PRIMARY KEY ( category_id ) ENABLE
);

CREATE TABLE sf_product_dimension (
    product_id     NUMBER(10) NOT NULL,
    product_name   VARCHAR2(40 BYTE) NOT NULL,
    category_id    NUMBER(10),
    CONSTRAINT product_pd_id_pk PRIMARY KEY ( product_id ) ENABLE,
    CONSTRAINT category_cd_id_fk FOREIGN KEY ( category_id )
        REFERENCES sf_category_dimension ( category_id )
);

CREATE TABLE sf_store_geo_dimension (
    address_id    NUMBER(10) NOT NULL,
    postal_code   NUMBER(10) NOT NULL,
    address       VARCHAR2(20 BYTE) NOT NULL,
    city          VARCHAR2(20 BYTE) NOT NULL,
    country       VARCHAR2(20 BYTE) NOT NULL,
    region        VARCHAR2(20 BYTE) NOT NULL,
    CONSTRAINT address_sg_id_pk PRIMARY KEY ( address_id ) ENABLE
);

CREATE TABLE sf_employee_dimension (
    employee_id   NUMBER(10) NOT NULL,
    first_name    VARCHAR2(40 BYTE) NOT NULL,
    last_name     VARCHAR2(40 BYTE) NOT NULL,
    email         VARCHAR2(40 BYTE) NOT NULL,
    phone         VARCHAR2(40 BYTE) NOT NULL,
    CONSTRAINT employee_ed_id_pk PRIMARY KEY ( employee_id ) ENABLE
);

CREATE TABLE sf_store_dimension (
    store_id      NUMBER(10) NOT NULL,
    manager_id    NUMBER(10),
    phone         VARCHAR2(40 BYTE) NOT NULL,
    address_id    NUMBER(10) NOT NULL,
    employee_id   NUMBER(10) NOT NULL,
    CONSTRAINT store_sd_id_pk PRIMARY KEY ( store_id ) ENABLE,
    CONSTRAINT address_sd_id_fk FOREIGN KEY ( address_id )
        REFERENCES sf_store_geo_dimension ( address_id ),
    CONSTRAINT employee_sd_id_fk FOREIGN KEY ( employee_id )
        REFERENCES sf_employee_dimension ( employee_id )
);

CREATE TABLE sf_date_dimension (
    date_id             NUMBER(10) NOT NULL,
    fulldate            VARCHAR2(10) NOT NULL,
    dayofmonth          VARCHAR2(2) NOT NULL,
    dayname             VARCHAR2(9) NOT NULL,
    dayofweek           VARCHAR2(1) NOT NULL,
    dayofweekinmonth    VARCHAR2(2) NOT NULL,
    dayofweekinyear     VARCHAR2(2) NOT NULL,
    dayofquarter        VARCHAR2(3) NOT NULL,
    dayofyear           VARCHAR2(3) NOT NULL,
    weekofmonth         VARCHAR2(1) NOT NULL,
    weekofquarter       VARCHAR2(2) NOT NULL,
    weekofyear          VARCHAR2(2) NOT NULL,
    monthnumber         VARCHAR2(2) NOT NULL,
    monthname           VARCHAR2(9) NOT NULL,
    monthofquarter      VARCHAR2(2) NOT NULL,
    quarter             VARCHAR2(1) NOT NULL,
    quartername         VARCHAR2(9) NOT NULL,
    yearnumber          VARCHAR2(4) NOT NULL,
    monthyear           VARCHAR2(10) NOT NULL,
    firstdayofmonth     DATE NOT NULL,
    lastdayofmonth      DATE NOT NULL,
    firstdayofquarter   DATE NOT NULL,
    lastdayofquarter    DATE NOT NULL,
    firstdayofyear      DATE NOT NULL,
    lastdayofyear       DATE NOT NULL,
    CONSTRAINT date_dd_id_pk PRIMARY KEY ( date_id ) ENABLE
);

CREATE TABLE sf_sales_fact (
    sales_id       NUMBER(10) NOT NULL,
    stuff_id       NUMBER(10),
    sales_date     NUMBER(10) NOT NULL,
    product_id     NUMBER(10) NOT NULL,
    customer_id    NUMBER(10),
    store_id       NUMBER(10) NOT NULL,
    sales_amount   NUMBER(10) NOT NULL,
    CONSTRAINT sales_sf_fk FOREIGN KEY ( sales_date )
        REFERENCES sf_date_dimension ( date_id ),
    CONSTRAINT product_sf_id_fk FOREIGN KEY ( product_id )
        REFERENCES sf_product_dimension ( product_id ),
    CONSTRAINT customer_sf_id_fk FOREIGN KEY ( customer_id )
        REFERENCES sf_customer_dimension ( customer_id ),
    CONSTRAINT store_sf_id_fk FOREIGN KEY ( store_id )
        REFERENCES sf_store_dimension ( store_id )
);

drop table sf_sales_fact;
drop table sf_date_dimension;
drop table sf_store_dimension;
drop table sf_employee_dimension;
drop table sf_store_geo_dimension;
drop table sf_product_dimension;
drop table sf_category_dimension;
drop table sf_customer_dimension;
drop table sf_customer_geo_dimension;