DROP TABLE T_retail_fact_sales_dd;
CREATE TABLE T_retail_fact_sales_dd (
    TRANSACTION_ID  INT ,
    DATE_TRANSACTION DATE NOT NULL,
    PRODUCT_id      int NOT NULL,
    PROMOTION_type_id    int not null,
    price float not null,
    UPDATE_DATE     DATE,
    CONSTRAINT sales_TRANSACTION_ID PRIMARY KEY ( TRANSACTION_ID ) ENABLE
);

DROP TABLE t_COUNTRY_fact_sales_dd;
CREATE TABLE t_COUNTRY_fact_sales_dd (
    TRANSACTION_ID  INT ,
    DATE_TRANSACTION DATE NOT NULL,
    PRODUCT_id      int NOT NULL,
    GEO INT NOT NULL,
    UPDATE_DATE     DATE,
    price float not null,
    CONSTRAINT t_COUNTRY_TRANSACTION_ID PRIMARY KEY ( TRANSACTION_ID ) ENABLE
);