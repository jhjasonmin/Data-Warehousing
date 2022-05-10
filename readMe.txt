Pre-requisite:
DATASTREAM and MASTERDATA datas should arleady be loaded into the database. 
To do this run sql file 'DataStream_MasterData_Creator v1.sql'.

Step 1: Create a star-schema designed data warehouse into the database
1) Open SQL Developer and connect to Oracle SQL.
2) Run the sql file 'createDW.sql' to create six tables including one fact table (sales) and five dimension tables (customer, product, warehouse, supplier and dates).
	*The star-schema has changed from assignment 1*
3) The script should also drop any pre-existing tables with the same names and replace with the new tables that are blank.

You should now have 6 tables

Step 2: Fill the tables using INLJ algorithm
In order to store the data in the Data warehouse, a join operator called Index Nested Loop Join (INLJ) was used to implement the enrichment feature in the transformation phase of ETL.
1) In SQL Developer, run the 'Enrichment.sql' PL/SQL file which will run the INLJ algorithm.
2) The algorithm will create a cursor 'datastreamcursor' and read 100 tuples from DATASTREAM table at a time. The number of tuples in a batch to read at a time can be changed.
3) Cursor will be read tuple by tuple using PRODUCT__ID as index.
3) The algorithm will check for replicates and avoid replicate entries for dimension tables using various all variables.
4) Once run, all 6 tables should now be filled with data from DATASTREAM and MASTERDATA and also have calculated 'TOTAL_SALES' from multiplying 'QUANTITY_SOLD' and 'PRICE'.

Data Warehouse should be ready at this point for OLAP queries.

Step 3: Data analysis by using OLAP queries
Relevent piece of code will need to be run by highlighting the code and running the statement(s).
1) In SQL Developer, open queriesDW.sql
2) Highlight all and press 'Ctrl + Enter' to run statement. 
3) This should return 5 query results and also a script output to say that you have successfully dropped any previous materialized view with the name 'warehouse_analysis_mv