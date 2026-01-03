/*
===============================================================================
DDL Script: Create Bronze Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'bronze' schema, dropping existing tables 
    if they already exist.
	  Run this script to re-define the DDL structure of 'bronze' Tables
===============================================================================
*/
--create DDL for CRM
if OBJECT_ID ('bronze.crm_cust_info' , 'U') IS not null 
	drop table bronze.crm_cust_info;

create table bronze.crm_cust_info(
	cst_id int,
	cst_key varchar(50),
	cst_firstname varchar(50),
	cst_lastname varchar(50),
	cst_marital_status varchar(50),
	cst_gndr varchar(50),
	cst_create_date date
);
go

if OBJECT_ID ('bronze.crm_prd_info' , 'U') IS not null 
	drop table bronze.crm_prd_info;

create table bronze.crm_prd_info(
	prd_id int,
	prd_key varchar(50),
	prd_nm varchar(50),
	prd_cost int,
	prd_line varchar(50),
	prd_start_dt DATETIME,
	prd_end_dt DATETIME
);
go


if OBJECT_ID ('bronze.crm_sales_details' , 'U') IS not null 
	drop table bronze.crm_sales_details;

create table bronze.crm_sales_details(
	sls_ord_num varchar(50),
	sls_prd_key varchar(50),
	sls_cust_id int,
	sls_order_dt int,
	sls_ship_dt int,
	sls_due_dt int,
	sls_sales int,
	sls_quantity int,
	sls_price int
);
go



-- create DDL for ERP
if OBJECT_ID ('bronze.erp_cust_az12' , 'U') IS not null 
	drop table bronze.erp_cust_az12;

create table bronze.erp_cust_az12(
	CID varchar(50),
	BDATE date,
	GEN varchar(50)
);
go



if OBJECT_ID ('bronze.erp_loc_a101' , 'U') IS not null 
	drop table bronze.erp_loc_a101;

create table bronze.erp_loc_a101(
	CID varchar(50),
	CNTRY varchar(50)
);
go


if OBJECT_ID ('bronze.erp_px_cat_g1v2' , 'U') IS not null 
	drop table bronze.erp_px_cat_g1v2;

create table bronze.erp_px_cat_g1v2(
	ID varchar(50),
	CAT varchar(50),
	SUBCAT varchar(50),
	MAINTENANCE varchar(50)
);
go
if OBJECT_ID ('bronze.erp_px_cat_g1v2' , 'U') IS not null 
	drop table bronze.erp_px_cat_g1v2;

create table bronze.erp_px_cat_g1v2(
	ID varchar(50),
	CAT varchar(50),
	SUBCAT varchar(50),
	MAINTENANCE varchar(50)
);
go
