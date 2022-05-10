-----------------  -Assignment1 CREATE DW---------------------


DROP TABLE customer CASCADE CONSTRAINTS;
DROP TABLE warehouse CASCADE CONSTRAINTS;
DROP TABLE product CASCADE CONSTRAINTS;
DROP TABLE supplier CASCADE CONSTRAINTS;
DROP TABLE dates CASCADE CONSTRAINTS;
DROP TABLE sales CASCADE CONSTRAINTS;

CREATE TABLE customer(
customer_id VARCHAR2(4) NOT NULL,
customer_name VARCHAR2(28) NOT NULL,
CONSTRAINT customers_pk PRIMARY KEY (customer_id)
);

CREATE TABLE warehouse(
warehouse_id VARCHAR2(4)NOT NULL,
warehouse_name VARCHAR2(20) NOT NULL,
CONSTRAINT warehouses_pk PRIMARY KEY (warehouse_id)
);

CREATE TABLE product(
product_id VARCHAR2(6) NOT NULL,
product_name VARCHAR2(30) NOT NULL,
price NUMBER(5,2) DEFAULT 0.0 NOT NULL,
CONSTRAINT products_pk PRIMARY KEY (product_id)
);

CREATE TABLE supplier(
supplier_id VARCHAR2(5) NOT NULL,
supplier_name VARCHAR2(30) NOT NULL,
CONSTRAINT suppliers_pk PRIMARY KEY (supplier_id)
);

CREATE TABLE dates(
t_date DATE NOT NULL,
t_month VARCHAR2(9) NOT NULL,
t_quarter VARCHAR2(1) NOT NULL,
t_year VARCHAR2 (4) NOT NULL,
CONSTRAINT dates_pk PRIMARY KEY(t_date)
);



CREATE TABLE sales(
datastream_id NUMBER(8,0) NOT NULL,
product_id VARCHAR2(6) NOT NULL,
warehouse_id VARCHAR2(4)NOT NULL,
customer_id VARCHAR2(4) NOT NULL,
supplier_id VARCHAR2(5) NOT NULL,
t_date DATE NOT NULL,
quantity_sold NUMBER(3,0) NOT NULL,
total_sales NUMBER(8,2),
CONSTRAINT sales_pk PRIMARY KEY (datastream_id) 
);
ALTER TABLE sales ADD CONSTRAINT sales_products_fk FOREIGN KEY (product_id) REFERENCES product (product_id);
ALTER TABLE sales ADD CONSTRAINT sales_warehouses_fk FOREIGN KEY (warehouse_id) REFERENCES warehouse (warehouse_id);
ALTER TABLE sales ADD CONSTRAINT sales_customers_fk FOREIGN KEY (customer_id) REFERENCES customer (customer_id);
ALTER TABLE sales ADD CONSTRAINT sales_suppliers_fk FOREIGN KEY (supplier_id) REFERENCES supplier (supplier_id);
ALTER TABLE sales ADD CONSTRAINT sales_dates_fk FOREIGN KEY (t_date) REFERENCES dates (t_date);


