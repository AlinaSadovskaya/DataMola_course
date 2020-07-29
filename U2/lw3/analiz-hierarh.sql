 SELECT LINE_name, collection_name
    FROM ( 
        SELECT LEVEL lev
             , SYS_CONNECT_BY_PATH ( LINE_ID, '->' ) PATH_line_collection
             , LINE_NAME
             , COLLECTION_NAME
             , CONNECT_BY_ROOT LINE_ID LINE_ID
              FROM SA_PRODUCT_DATA
        CONNECT BY NOCYCLE PRIOR LINE_ID = COLLECTION_ID) 
    where lev = 2;