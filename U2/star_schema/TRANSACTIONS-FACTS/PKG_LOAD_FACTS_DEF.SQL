CREATE OR REPLACE PACKAGE pkg__transaction_FACTS
AS  
   PROCEDURE load_CLEAN_transaction;
   PROCEDURE load_transaction_DW;  
   PROCEDURE load_T_FACT_COUNTRY_DW;
   PROCEDURE load_T_FACT_PROMOTION_DW;
   PROCEDURE load_FACT_COUNTRY;
   PROCEDURE load_FACT_PROMOTION;
END pkg__transaction_FACTS;