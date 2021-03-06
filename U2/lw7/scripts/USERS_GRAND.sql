GRANT CREATE   VIEW TO alina;
GRANT CREATE ANY TABLE TO alina;
GRANT CREATE ANY MATERIALIZED VIEW TO alina;
GRANT CREATE DATABASE LINK TO alina;

GRANT ON COMMIT REFRESH on SA_customers.sa_transaction TO alina;
GRANT QUERY REWRITE  TO alina;
GRANT UPDATE ON SA_customers.sa_transaction TO alina;