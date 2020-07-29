create tablespace ts_sa_customers_data_01
datafile '/oracle/u01/app/oracle/oradata/DCORCL/pdb_asadovskaya/ts_sa_customers_data_01.dat'
size 150M
 autoextend on next 50M
logging
segment space management auto
extent management local autoallocate;

create user SA_CUSTOMERS 
  identified by "%PWD%"
    default tablespace ts_sa_customers_data_01;

grant CONNECT,RESOURCE to SA_CUSTOMERS;

create tablespace ts_sa_employees_data_01
datafile '/oracle/u01/app/oracle/oradata/DCORCL/pdb_asadovskaya/ts_sa_employees_data_01.dat'
size 150M
 autoextend on next 50M
logging
segment space management auto
extent management local autoallocate;

create user SA_EMPLOYEES
  identified by "%PWD%"
    default tablespace ts_sa_employees_data_01;

grant CONNECT,RESOURCE to SA_EMPLOYEES;

create tablespace ts_DW_CL
datafile '/oracle/u01/app/oracle/oradata/DCORCL/pdb_asadovskaya/ts_DW_CL.dat'
size 100M
 autoextend on next 50M
nologging
segment space management auto;

create user DW_CL 
  identified by "%PWD%"
    default tablespace ts_DW_CL;

grant CONNECT,CREATE VIEW,RESOURCE to DW_CL;

DROP TABLESPACE ts_dw_data_01 INCLUDING CONTENTS AND DATAFILES CASCADE CONSTRAINTS;

create tablespace ts_DW_DATA_01
datafile '/oracle/u01/app/oracle/oradata/DCORCL/pdb_asadovskaya/db_qpt_dw_data_01.dat'
size 150M
 autoextend on next 50M
logging
segment space management auto;

create user dw_data
  identified by "%PWD%"
    default tablespace TS_DW_DATA_01;

grant CONNECT,RESOURCE to dw_data;

create tablespace ts_DW_STR_CLS
datafile '/oracle/u01/app/oracle/oradata/DCORCL/pdb_asadovskaya/ts_DW_STR_CLS.dat'
size 150M
 autoextend on next 50
nologging
segment space management auto;

create user SAL_DW_CL 
  identified by "%PWD%"
    default tablespace ts_DW_STR_CLS;

grant CONNECT,CREATE VIEW,RESOURCE to SAL_DW_CL;

create tablespace ts_SAL_CL
datafile '/oracle/u01/app/oracle/oradata/DCORCL/pdb_asadovskaya/ts_SAL_CL.dat'
size 150M
 autoextend on next 50
nologging
segment space management auto;

create user SAL_CL 
  identified by "%PWD%"
    default tablespace ts_SAL_CL;

grant CONNECT,CREATE VIEW,RESOURCE to SAL_CL;

create tablespace ts_SA_FCT_BALANCES_01
datafile '/oracle/u01/app/oracle/oradata/DCORCL/pdb_asadovskaya/ts_SA_FCT_BALANCES_01.dat'
size 150M
 autoextend on next 50
nologging
segment space management auto;

create user DM_PRODUCT_BALANCES 
  identified by "%PWD%"
    default tablespace ts_SA_FCT_BALANCES_01;

grant CONNECT,CREATE VIEW,RESOURCE to DM_PRODUCT_BALANCES;

create tablespace ts_SA_FCT_SALES_01
datafile '/oracle/u01/app/oracle/oradata/DCORCL/pdb_asadovskaya/ts_SA_FCT_SALES_01.dat'
size 150M
 autoextend on next 50
nologging
segment space management auto;

create user DM_RETAIL_SALES 
  identified by "%PWD%"
    default tablespace ts_SA_FCT_SALES_01;

grant CONNECT,CREATE VIEW,RESOURCE to DM_RETAIL_SALES;

create tablespace ts_SA_DIM_CUST_01
datafile '/oracle/u01/app/oracle/oradata/DCORCL/pdb_asadovskaya/ts_SA_DIM_CUST_01.dat'
size 150M
 autoextend on next 50
nologging
segment space management auto;

create user DM_CUSTOMERS 
  identified by "%PWD%"
    default tablespace ts_SA_DIM_CUST_01;

grant CONNECT,CREATE VIEW,RESOURCE to DM_CUSTOMERS;

create tablespace ts_SA_DIM_PROD_01
datafile '/oracle/u01/app/oracle/oradata/DCORCL/pdb_asadovskaya/ts_SA_DIM_PROD_01.dat'
size 150M
 autoextend on next 50
nologging
segment space management auto;

create user DM_PRODUCTS 
  identified by "%PWD%"
    default tablespace ts_SA_DIM_PROD_01;

grant CONNECT,CREATE VIEW,RESOURCE to DM_PRODUCTS;

create tablespace ts_SA_DIM_PROM_01
datafile '/oracle/u01/app/oracle/oradata/DCORCL/pdb_asadovskaya/ts_SA_DIM_PROM_01.dat'
size 150M
 autoextend on next 50
nologging
segment space management auto;

create user DM_PROMOTION 
  identified by "%PWD%"
    default tablespace ts_SA_DIM_PROM_01;

grant CONNECT,CREATE VIEW,RESOURCE to DM_PROMOTION;