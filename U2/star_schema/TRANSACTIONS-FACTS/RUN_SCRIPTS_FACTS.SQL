BEGIN
   -- pkg__transaction_FACTS.load_CLEAN_transaction;
   -- pkg__transaction_FACTS.load_transaction_DW;
   pkg__transaction_FACTS.load_T_FACT_COUNTRY_DW;
   pkg__transaction_FACTS.load_T_FACT_PROMOTION_DW;
   pkg__transaction_FACTS.load_FACT_COUNTRY;
   pkg__transaction_FACTS.load_FACT_PROMOTION;
END;