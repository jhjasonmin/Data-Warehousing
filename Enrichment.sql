--DIFFERENT STAR-SCHEMA USED, PLEASE RERUN createDW.sql--

/* First, set cursors and create prodcut table for Datastream data */
DECLARE
  CURSOR DATASTREAMCURSOR  IS  SELECT * FROM DATASTREAM;
  /*Create the type T_DATASTREAM as table type;*/
  TYPE T_DATASTREAM IS TABLE OF DATASTREAMCURSOR%ROWTYPE;
  T_DS T_DATASTREAM;
  /* Create variables to store the masterdata data */
  TPRODUCT_ID    MASTERDATA.PRODUCT_ID%TYPE;
  TPRODUCT_NAME  MASTERDATA.PRODUCT_NAME%TYPE;
  TSUPPLIER_ID   MASTERDATA.SUPPLIER_ID%TYPE;
  TSUPPLIER_NAME MASTERDATA.SUPPLIER_NAME%TYPE;
  TPRICE         MASTERDATA.SALE_PRICE%TYPE;

/* Make a counting variable 'CNT' and make it an interger */
CNT int;
  
/* Begin data extraction from Datastream and Masterdata */
BEGIN
OPEN DATASTREAMCURSOR;
LOOP /* LOOP over extracting data from Datastream into cursor table, a batch of 100 tupules at a time until non is left */
  FETCH DATASTREAMCURSOR BULK COLLECT INTO T_DS LIMIT 100;
  EXIT WHEN DATASTREAMCURSOR%NOTFOUND; /* When no more data is present, the FETCH will end */
  
  /* Divide reading each tupule, one row at a time */
  FOR i IN T_DS.FIRST .. T_DS.LAST
    LOOP 
    /* Second loop inside the first loop to match and extract data between Datastream and Masterdata */

    /* Store data into the temporary variable tables from Masterdata */
      SELECT  PRODUCT_ID, PRODUCT_NAME, SUPPLIER_ID, SUPPLIER_NAME, SALE_PRICE
        INTO  TPRODUCT_ID, TPRODUCT_NAME, 
              TSUPPLIER_ID, TSUPPLIER_NAME, 
              TPRICE
        FROM  MASTERDATA WHERE PRODUCT_ID = T_DS(i).PRODUCT_ID; /* Use PRODUCT_ID as index */

    /* Use IF statement to store the data into respective dimension tables only if there isn't already the same data in the table 
    Do this by using CNT that was defined previously */
    
    -- customer dimension table
      SELECT COUNT(0) INTO CNT FROM customer /* Start counting for any replicates from 0 using 'CNT' */
        WHERE CUSTOMER_ID = T_DS(i).CUSTOMER_ID;
      IF CNT = 0 THEN /* only insert if no duplicates i.e. CNT is 0 */
        INSERT INTO CUSTOMER(CUSTOMER_ID, CUSTOMER_NAME)
          VALUES (T_DS(i).CUSTOMER_ID, T_DS(i).CUSTOMER_NAME); /* both set of data from Datastream */
      END IF;
   
   /* Repeat above for all other dimension tables and fact table */
    -- product dimension table
      SELECT COUNT(0) INTO CNT FROM product 
        WHERE PRODUCT_ID = T_DS(i).PRODUCT_ID;
      IF CNT = 0 THEN
        INSERT INTO PRODUCT(PRODUCT_ID, PRODUCT_NAME, PRICE)
          VALUES (T_DS(i).PRODUCT_ID, TPRODUCT_NAME, TPRICE); /* Product_ID from Datastream and Product_name, Price is from Masterdata (i.e. TPRODUCT_NAME + TPRICE) */
      END IF;
      
    -- warehouse dimension table
      SELECT COUNT(0) INTO CNT FROM warehouse 
        WHERE WAREHOUSE_ID = T_DS(i).WAREHOUSE_ID;
      IF CNT = 0 THEN
        INSERT INTO WAREHOUSE(WAREHOUSE_ID, WAREHOUSE_NAME)
          VALUES (T_DS(i).WAREHOUSE_ID, T_DS(i).WAREHOUSE_NAME);
      END IF;

	 -- supplier dimension table
      SELECT COUNT(0) INTO CNT FROM supplier 
        WHERE SUPPLIER_ID = TSUPPLIER_ID;
      IF CNT = 0 THEN
        INSERT INTO SUPPLIER(SUPPLIER_ID, SUPPLIER_NAME)
          VALUES (TSUPPLIER_ID, TSUPPLIER_NAME);
      END IF;
      
    -- date_id dimension table
      SELECT COUNT(0) INTO CNT FROM DATES 
		WHERE t_date = T_DS(i).T_DATE;
      IF CNT = 0 THEN
        INSERT INTO DATES(T_DATE, T_MONTH, T_QUARTER, T_YEAR)
          VALUES (T_DS(i).T_DATE, TO_CHAR(T_DS(i).T_DATE,'MON'), /* 'MON' refers to only extracting the MONTH data from T_DATE */
                TO_CHAR(T_DS(i).T_DATE,'Q'), EXTRACT(YEAR FROM T_DS(i).T_DATE)); /* 'Q' refers to only extracting the QUARTERLY data from T_DATE */
        END IF;

    -- sales fact table
    /* TOTAL_SALE is calculated by multiplying QUANTITY_SOLD and PRICE */
      SELECT COUNT(0) INTO CNT FROM sales 
        WHERE DATASTREAM_ID = T_DS(i).DATASTREAM_ID;
      IF CNT = 0 THEN
        INSERT INTO SALES(DATASTREAM_ID, CUSTOMER_ID, PRODUCT_ID, WAREHOUSE_ID, SUPPLIER_ID, 
                            T_DATE, QUANTITY_SOLD, TOTAL_SALES)
          VALUES (T_DS(i).DATASTREAM_ID, T_DS(i).CUSTOMER_ID, T_DS(i).PRODUCT_ID, T_DS(i).WAREHOUSE_ID, TSUPPLIER_ID, T_DS(i).T_DATE, 
                  T_DS(i).Quantity_sold,T_DS(i).QUANTITY_SOLD*TPRICE);
      END IF; 
      commit; /* store the batch of 100 rows of data by commit; */
      
    END LOOP; /* End second LOOP for extracting and matching of 100 tuples, one row at a time */
    commit;

END LOOP; /* End first LOOP of creating batches of 100 tuples each */
CLOSE DATASTREAMCURSOR;
END;
