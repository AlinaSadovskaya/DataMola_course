CREATE TABLE st_customer_dimension (
    customer_id   NUMBER(10) NOT NULL,
    first_name    VARCHAR2(40 BYTE),
    last_name     VARCHAR2(40 BYTE),
    email         VARCHAR2(40 BYTE),
    phone         VARCHAR2(40 BYTE),
    postal_code   NUMBER(10),
    address       VARCHAR2(20 BYTE),
    city          VARCHAR2(20 BYTE),
    country       VARCHAR2(20 BYTE),
    region        VARCHAR2(20 BYTE),
    CONSTRAINT customer_id_pk PRIMARY KEY ( customer_id ) ENABLE
);

CREATE TABLE st_product_dimension (
    product_id      NUMBER(10) NOT NULL,
    product_name    VARCHAR2(40 BYTE) NOT NULL,
    category_id     NUMBER(10),
    category_name   VARCHAR2(40 BYTE),
    CONSTRAINT product_id_pk PRIMARY KEY ( product_id ) ENABLE
);

CREATE TABLE st_store_dimension (
    store_id      NUMBER(10) NOT NULL,
    manager_id    NUMBER(10),
    phone         VARCHAR2(40 BYTE) NOT NULL,
    postal_code   NUMBER(10) NOT NULL,
    address       VARCHAR2(20 BYTE) NOT NULL,
    city          VARCHAR2(20 BYTE) NOT NULL,
    country       VARCHAR2(20 BYTE) NOT NULL,
    region        VARCHAR2(20 BYTE) NOT NULL,
    CONSTRAINT store_id_pk PRIMARY KEY ( store_id ) ENABLE
);

CREATE TABLE st_employee_dimension (
    employee_id   NUMBER(10) NOT NULL,
    first_name    VARCHAR2(40 BYTE) NOT NULL,
    last_name     VARCHAR2(40 BYTE) NOT NULL,
    email         VARCHAR2(40 BYTE) NOT NULL,
    phone         VARCHAR2(40 BYTE) NOT NULL,
    store_id      NUMBER(10) NOT NULL,
    CONSTRAINT employee_id_pk PRIMARY KEY ( employee_id ) ENABLE
);

CREATE TABLE st_date_dimension (
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
    CONSTRAINT date_id_pk PRIMARY KEY ( date_id ) ENABLE
);

CREATE TABLE st_sales_fact (
    sales_id       NUMBER(10) NOT NULL,
    stuff_id       NUMBER(10),
    sales_date     NUMBER(10) NOT NULL,
    product_id     NUMBER(10) NOT NULL,
    customer_id    NUMBER(10),
    store_id       NUMBER(10) NOT NULL,
    employee_id    NUMBER(10) NOT NULL,
    sales_amount   NUMBER(10) NOT NULL,
    CONSTRAINT sales_date_fk FOREIGN KEY ( sales_date )
        REFERENCES st_date_dimension ( date_id ),
    CONSTRAINT product_id_fk FOREIGN KEY ( product_id )
        REFERENCES st_product_dimension ( product_id ),
    CONSTRAINT customer_id_fk FOREIGN KEY ( customer_id )
        REFERENCES st_customer_dimension ( customer_id ),
    CONSTRAINT store_id_fk FOREIGN KEY ( store_id )
        REFERENCES st_store_dimension ( store_id ),
    CONSTRAINT employee_id_fk FOREIGN KEY ( employee_id )
        REFERENCES st_employee_dimension ( employee_id )
);

drop table st_sales_fact;
drop table st_date_dimension;
drop table st_employee_dimension;
drop table st_store_dimension;
drop table st_product_dimension;
drop table st_customer_dimension;