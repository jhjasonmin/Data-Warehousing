/* First, set cursors and create prodcut table for Datastream data */
DECLARE
  CURSOR DATASTREAMCURSOR  IS  SELECT * FROM DATASTREAM;
  /*Create the type T_DATASTREAM as table type;*/
  TYPE T_DATASTREAM IS TABLE OF DATASTREAMCURSOR%ROWTYPE;
  T_ID T_DATASTREAM;
  /* Create variables to store the masterdata data */
  TPRODCUT_ID    MASTERDATA.PRODUCT_ID%TYPE;
  TPRODUCT_NAME  MASTERDATA.PRODUCT_NAME%TYPE;
  TSUPPLIER_ID   MASTERDATA.SUPPLIER_ID%TYPE;
  TSUPPLIER_NAME MASTERDATA.SUPPLIER_NAME%TYPE;
  TPRICE         MASTERDATA.SALE_PRICE%TYPE;

/* Record Counter */
REC int;
  
/* Begin data extraction from Datastream and Masterdata */
BEGIN
OPEN DATASTREAMCURSOR;
LOOP /* LOOP over extracting data from Datastream into cursor table, 100 tupules at a time until non is left */
  FETCH DATASTREAMSCURSOR BULK COLLECT INTO T_ID LIMIT 100;
  EXIT WHEN DATASTREAMSCURSOR%NOTFOUND;
  /* Divide reading each tupule, one ata a time */
  FOR i IN T_ID.FIRST .. T_ID.LAST
    LOOP 
    /* Second loop inside the first loop to match and extract data between Datastream and Masterdata */

    /* Store data into the variables table from Masterdata */
      SELECT  PRODUCT_ID, PRODUCT_NAME, SUPPLIER_ID, SUPPLIER_NAME, SALE_PRICE
        INTO  TPRODCUT_ID, TPRODUCT_NAME, 
              TSUPPLIER_ID, TSUPPLIER_NAME, 
              TPRICE
        FROM  MASTERDATA WHERE PRODUCT_ID = T_ID(i).PRODUCT_ID;

    /* Use IF statement to store the data into respective dimension tables only if there isn't already the same data in the table 
    Do this by using int that was defined previously */
    
    -- customer dimension table
      SELECT COUNT(0) INTO REC FROM customer 
        WHERE CUSTOMER_ID = T_ID(i).CUSTOMER_ID;
      IF REC = 0 THEN
        INSERT INTO CUSTOMER(CUSTOMER_ID, CUSTOMER_NAME)
          VALUES (T_ID(i).CUSTOMER_ID, T_ID(i).CUSTOMER_NAME);
      END IF;
      
    -- product dimension table
      SELECT COUNT(0) INTO REC FROM product 
        WHERE PRODUCT_ID = T_ID(i).PRODUCT_ID;
      IF REC = 0 THEN
        INSERT INTO PRODUCT(PRODUCT_ID, PRODUCT_NAME,SUPPLIER_ID, SUPPLIER_NAME)
          VALUES (T_ID(i).PRODUCT_ID, TPRODUCT_NAME,TSUPPLIER_ID, TSUPPLIER_NAME);
      END IF;
      
    -- warehouse dimension table
      SELECT COUNT(0) INTO REC FROM warehouse 
        WHERE WAREHOUSE_ID = T_ID(i).WAREHOUSE_ID;
      IF REC = 0 THEN
        INSERT INTO WAREHOUSE(WAREHOUSE_ID, WAREHOUSE_NAME)
          VALUES (T_ID(i).WAREHOUSE_ID, T_ID(i).WAREHOUSE_NAME);
      END IF;
      
    -- date_id dimension table
      SELECT COUNT(0) INTO REC FROM DATE_ID 
		WHERE t_date = T_ID(i).T_DATE;
      IF REC = 0 THEN
        INSERT INTO DATE_ID(DATE_KEY,T_DATE, date_day, date_month, date_quarter, date_year)
          VALUES (T_ID(i).T_DATE,T_ID(i).T_DATE, EXTRACT(DAY FROM T_ID(i).T_DATE), TO_CHAR(T_ID(i).T_DATE,'MON'),
                TO_CHAR(T_ID(i).T_DATE,'Q'), EXTRACT(YEAR FROM T_ID(i).T_DATE));
        END IF;

    -- sales fact table
    /* TOTAL_SALE is calculated by multiplying QUANTITY_SOLD and PRICE */
      SELECT COUNT(0) INTO REC FROM sales 
        WHERE DATASTREAM_ID = T_ID(i).DATASTREAM_ID;
      IF REC = 0 THEN
        INSERT INTO SALES(DATASTREAM_ID, CUSTOMER_ID, PRODUCT_ID, WAREHOUSE_ID, 
                            DATE_KEY, QUANTITY_SOLD, PRICE, TOTAL_SALE)
          VALUES (T_ID(i).DATASTREAM_ID, T_ID(i).CUSTOMER_ID, T_ID(i).PRODUCT_ID, T_ID(i).WAREHOUSE_ID, T_ID(i).T_DATE, 
                  t_ID(i).Quantity_sold,tprice,T_ID(i).QUANTITY_SOLD*TPRICE);
      END IF; 
      commit; /* End and store the data by commit; */
      
    END LOOP; /* End second LOOP for the 100 tuples */
    commit;

END LOOP; /* End first LOOP */
CLOSE DATASTREAMCURSOR;
END;
