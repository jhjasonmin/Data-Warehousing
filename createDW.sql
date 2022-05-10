CREATE TABLE product (
PRODUCT_ID varchar2(6) not null,
PRODUCT_NAME varchar2(30) not null,
SUPPLIER_ID varchar2(50) not null,
SUPPLIER_NAME varchar2(30) not null,
constraint product_pk primary key (PRODUCT_ID));

CREATE TABLE customer (
CUSTOMER_ID varchar2(4) not null, 
CUSTOMER_NAME varchar2(28) not null, 
constraint customer_pk primary key (CUSTOMER_ID));

CREATE TABLE warehouse (
WAREHOUSE_ID varchar2(4) not null, 
WAREHOUSE_NAME varchar2(20) not null, 
CONSTRAINT warehouse_pk primary key (WAREHOUSE_ID));

CREATE TABLE date_id (
DATE_KEY varchar2 (8) not null,
T_DATE DATE not null, 
Date_year number(4,0) not null,
Date_month varchar2 (3) not null,
Date_day number (2,0) not null,
Date_Quarter number (1,0),
CONSTRAINT date_pk primary key (DATE_KEY));

CREATE TABLE sales (
DATASTREAM_ID number(8,0) not null,
PRODUCT_ID varchar2(6) not null, 
CUSTOMER_ID varchar2(4) not null,  
WAREHOUSE_ID varchar2(4) not null,  
DATE_KEY varchar2(8) not null, 
QUANTITY_SOLD number(3,0) not null,
PRICE number (5,2) not null,
TOTAL_SALE number(3,0) not null,
CONSTRAINT sales_pk primary key ("DATASTREAM_ID"));

     
ALTER TABLE sales ADD CONSTRAINT product_fk FOREIGN KEY (PRODUCT_ID) REFERENCES product (PRODUCT_ID) ;
ALTER TABLE sales ADD CONSTRAINT customer_fk FOREIGN KEY (CUSTOMER_ID) REFERENCES customer (CUSTOMER_ID) ;
ALTER TABLE sales ADD CONSTRAINT warehouse_fk FOREIGN KEY (WAREHOUSE_ID) REFERENCES warehouse (WAREHOUSE_ID) ;
ALTER TABLE sales ADD CONSTRAINT date_fk FOREIGN KEY (DATE_KEY) REFERENCES date_id (DATE_KEY) ;

