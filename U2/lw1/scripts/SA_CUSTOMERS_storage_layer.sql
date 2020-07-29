--DROP TABLE SA_CUSTOMERS_DATA;
CREATE TABLE SA_CUSTOMERS_DATA 
(
    first_name    VARCHAR2(40 BYTE),
    last_name     VARCHAR2(40 BYTE),
    email         VARCHAR2(50 BYTE) NOT NULL,
    phone         VARCHAR2(40 BYTE) NOT NULL,
    age           NUMBER(3) NOT NULL,
    INSERT_DATE   DATE NOT NULL)
TABLESPACE ts_sa_customers_data_01;

WHILE (SELECT COUNT(*) FROM SA_CUSTOMERS_DATA) < 100001
LOOP
     SELECT first_name AS FIRST_NAME_S FROM
          (SELECT first_name FROM SA_CUSTOMERS_DATA
                ORDER BY dbms_random.value )
                    WHERE rownum = 1;
     SELECT last_name AS LAST_NAME_S FROM
        ( SELECT last_name FROM SA_CUSTOMERS_DATA
                ORDER BY dbms_random.value )
                    WHERE rownum = 1;
     SELECT email AS EMAIL_S FROM
            ( SELECT email FROM SA_CUSTOMERS_DATA
                            ORDER BY dbms_random.value )
                            WHERE rownum = 1;
     SELECT phone AS PHONE_S FROM
            ( SELECT phone FROM SA_CUSTOMERS_DATA
                            ORDER BY dbms_random.value )
                            WHERE rownum = 1;
     SELECT age AS AGE_S FROM
            ( SELECT age FROM SA_CUSTOMERS_DATA
                            ORDER BY dbms_random.value )
                            WHERE rownum = 1;
     SELECT address AS ADDRESS_S FROM
            ( SELECT address FROM SA_CUSTOMERS_DATA
                            ORDER BY dbms_random.value )
                            WHERE rownum = 1;
     SELECT city AS CITY_S FROM
            ( SELECT city FROM SA_CUSTOMERS_DATA
                            ORDER BY dbms_random.value )
                            WHERE rownum = 1;
     SELECT country AS COUNTRY_S FROM
            ( SELECT country FROM SA_CUSTOMERS_DATA
                            ORDER BY dbms_random.value )
                            WHERE rownum = 1;
     SELECT region AS REGION_S FROM
            ( SELECT region FROM SA_CUSTOMERS_DATA
                            ORDER BY dbms_random.value )
                            WHERE rownum = 1;
     EXECUTE IMMEDIATE 'INSERT INTO SA_CUSTOMERS_DATA values (:first_name, :last_name, :email, :phone, :age, :address , :city ,:country, :region)' using first_name_S,last_name_S, email_S,phone_S,age_S,address_S,city_S,country_S,region_S;
END LOOP;

--DROP TABLE SA_STORE_DATA;
CREATE TABLE SA_STORE_DATA 
(
    STORE_PHONE       VARCHAR2(40 BYTE) NOT NULL,
    STORE_NAME        VARCHAR2(50 BYTE) NOT NULL,
    INSERT_DATE       DATE NOT NULL)
TABLESPACE ts_sa_customers_data_01;

--DROP TABLE SA_PRODUCT_DATA;
CREATE TABLE SA_PRODUCT_DATA 
(
    PRODUCT_NAME        VARCHAR2(40 BYTE) NOT NULL,
    LINE_ID           INT NOT NULL,
    LINE_NAME         VARCHAR2(40 BYTE) NOT NULL,
    COLLECTION_ID     INT NOT NULL,
    COLLECTION_NAME   VARCHAR2(40 BYTE) NOT NULL,
    SEASON_ID         INT NOT NULL,
    SEASON            VARCHAR2(40 BYTE) NOT NULL,
    SIZE_CLOTHES      VARCHAR2(10 BYTE) NOT NULL,
    COLOR             VARCHAR2(40 BYTE) NOT NULL,
    PRICE             FLOAT NOT NULL,
    INSERT_DATE       DATE NOT NULL)
TABLESPACE ts_sa_customers_data_01;

DROP TABLE SA_PR_DATA;
CREATE TABLE SA_PR_DATA 
(
    PRODUCT_NAME      VARCHAR2(40 BYTE) NOT NULL,
    LINE_ID           INT NOT NULL,
    LINE_NAME         VARCHAR2(40 BYTE) NOT NULL,
    SIZE_CLOTHES      VARCHAR2(10 BYTE) NOT NULL,
    COLOR             VARCHAR2(40 BYTE) NOT NULL,
    PRICE             NUMBER(10) NOT NULL,
    INSERT_DATE       DATE NOT NULL)
TABLESPACE ts_sa_customers_data_01;

DROP TABLE SA_PR2_DATA;
CREATE TABLE SA_PR2_DATA 
(
    SEASON_ID           INT NOT NULL,
    SEASON_NAME         VARCHAR2(40 BYTE) NOT NULL,
    COLLECTION_ID           INT NOT NULL,
    COLLECTION_NAME         VARCHAR2(40 BYTE) NOT NULL)
TABLESPACE ts_sa_customers_data_01;

INSERT INTO SA_PRODUCT_DATA(PRODUCT_NAME, LINE_ID, LINE_NAME, COLLECTION_ID, COLLECTION_NAME, SEASON_ID, SEASON, SIZE_CLOTHES, COLOR, PRICE, INSERT_DATE)
SELECT 
    SA_PR_DATA.PRODUCT_NAME
    ,SA_PR_DATA.LINE_ID
    ,SA_PR_DATA.LINE_NAME
    ,SA_PR2_DATA.COLLECTION_ID
    ,SA_PR2_DATA.COLLECTION_NAME
    ,SA_PR2_DATA.SEASON_ID
    ,SA_PR2_DATA.SEASON_NAME
    ,SA_PR_DATA.SIZE_CLOTHES
    ,SA_PR_DATA.COLOR
    ,SA_PR_DATA.PRICE
    ,SA_PR_DATA.INSERT_DATE 
    FROM SA_PR_DATA, SA_PR2_DATA ;
  
--DROP TABLE  SA_GEN_PROMOTION_DATA; 
CREATE TABLE SA_GEN_PROMOTION_DATA 
(
    PROMOTION     VARCHAR2(40 BYTE),
    VALID_FROM    date not null,
    VALID_TO      date NOT NULL,
    INSERT_DAY    date NOT NULL,
    PRICE_PERCENT float NOT NULL)
TABLESPACE ts_sa_customers_data_01;

drop table SA_GEN_PROMOTION_DATA;

drop table sa_period_data;
CREATE TABLE SA_period_DATA 
(
    START_PERIOD  INT NOT NULL,
    END_PERIOD    INT,
    INSERT_DAY    date NOT NULL,
    update_day    date)
TABLESPACE ts_sa_customers_data_01;

DROP TABLE DATE_GEO;
CREATE TABLE DATE_GEO
(
        DATE_TRANSACTION DATE NOT NULL,
        GEO INT NOT NULL
)
TABLESPACE ts_sa_customers_data_01;


CREATE TABLE SA_TRANSACTION_data
(
    first_name    VARCHAR2(40 BYTE),
    last_name     VARCHAR2(40 BYTE),
    PRODUCT_NAME        VARCHAR2(40 BYTE) NOT NULL,
    LINE_NAME         VARCHAR2(40 BYTE) NOT NULL,
    COLLECTION_NAME   VARCHAR2(40 BYTE) NOT NULL,
    SIZE_CLOTHES      VARCHAR2(10 BYTE) NOT NULL,
    PRICE             FLOAT NOT NULL,
    PROMOTION     VARCHAR2(40 BYTE),
    VALID_FROM    date not null,
    VALID_TO      date NOT NULL,
    PRICE_PERCENT float NOT NULL
);

DROP TABLE SA_TRANSACTION;
CREATE TABLE SA_TRANSACTION
(
    first_name    VARCHAR2(40 BYTE),
    last_name     VARCHAR2(40 BYTE),
    PRODUCT_NAME        VARCHAR2(40 BYTE) NOT NULL,
    LINE_NAME         VARCHAR2(40 BYTE) NOT NULL,
    COLLECTION_NAME   VARCHAR2(40 BYTE) NOT NULL,
    SIZE_CLOTHES      VARCHAR2(10 BYTE) NOT NULL,
    PRICE             FLOAT NOT NULL,
    PROMOTION     VARCHAR2(40 BYTE),
    VALID_FROM    date not null,
    VALID_TO      date NOT NULL,
    PRICE_PERCENT float NOT NULL,
    DATE_TRANSACTION DATE NOT NULL,
    GEO INT NOT NULL
);

drop table SA_TRANSACTION_DATA;
INSERT INTO SA_TRANSACTION_DATA(first_name,last_name,PRODUCT_NAME,LINE_NAME,COLLECTION_NAME,SIZE_CLOTHES,PRICE,PROMOTION,VALID_FROM,VALID_TO,PRICE_PERCENT)
SELECT 
    SA_TRANSACTION1_DATA.first_name
    ,SA_TRANSACTION1_DATA.last_name
    ,SA_TRANSACTION1_DATA.PRODUCT_NAME
    ,SA_TRANSACTION1_DATA.LINE_NAME
    ,SA_TRANSACTION1_DATA.COLLECTION_NAME
    ,SA_TRANSACTION1_DATA.SIZE_CLOTHES
    ,SA_TRANSACTION1_DATA.PRICE
    ,SA_GEN_PROMOTION_DATA.PROMOTION
    ,SA_GEN_PROMOTION_DATA.VALID_FROM
    ,SA_GEN_PROMOTION_DATA.VALID_TO
    ,SA_GEN_PROMOTION_DATA.PRICE_PERCENT
    FROM SA_TRANSACTION1_DATA, SA_GEN_PROMOTION_DATA;
    
    
INSERT INTO SA_TRANSACTION(first_name,last_name,PRODUCT_NAME,LINE_NAME,COLLECTION_NAME,SIZE_CLOTHES,PRICE,PROMOTION,VALID_FROM,VALID_TO,PRICE_PERCENT,DATE_TRANSACTION, GEO)
SELECT 
    SA_TRANSACTION_DATA.first_name
    ,SA_TRANSACTION_DATA.last_name
    ,SA_TRANSACTION_DATA.PRODUCT_NAME
    ,SA_TRANSACTION_DATA.LINE_NAME
    ,SA_TRANSACTION_DATA.COLLECTION_NAME
    ,SA_TRANSACTION_DATA.SIZE_CLOTHES
    ,SA_TRANSACTION_DATA.PRICE
    ,SA_TRANSACTION_DATA.PROMOTION
    ,SA_TRANSACTION_DATA.VALID_FROM
    ,SA_TRANSACTION_DATA.VALID_TO
    ,SA_TRANSACTION_DATA.PRICE_PERCENT
    ,DATE_GEO.DATE_TRANSACTION
    ,DATE_GEO.GEO
    FROM SA_TRANSACTION_DATA, DATE_GEO;

    
drop table SA_TRANSACTION1_DATA;
CREATE TABLE SA_TRANSACTION1_DATA 
(
    first_name    VARCHAR2(40 BYTE),
    last_name     VARCHAR2(40 BYTE),
    PRODUCT_NAME        VARCHAR2(40 BYTE) NOT NULL,
    LINE_NAME         VARCHAR2(40 BYTE) NOT NULL,
    COLLECTION_NAME   VARCHAR2(40 BYTE) NOT NULL,
    SIZE_CLOTHES      VARCHAR2(10 BYTE) NOT NULL,
    PRICE             FLOAT NOT NULL
)
TABLESPACE ts_sa_customers_data_01;

SELECT COUNT(*) FROM SA_CUSTOMERS_DATA;
SELECT COUNT(*) FROM SA_PRODUCT_DATA;
SELECT COUNT(*) FROM SA_GEN_PROMOTION_DATA;
SELECT COUNT(*) FROM DATE_GEO;
SELECT COUNT(*) FROM SA_TRANSACTION;