/*
===============================================================================
DDL Script: Create Silver Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'silver' schema, dropping existing tables 
    if they already exist.
	  Run this script to re-define the DDL structure of 'bronze' Tables
===============================================================================
*/

--create DDL for CRM
if OBJECT_ID ('silver.crm_cust_info' , 'U') IS not null 
	drop table silver.crm_cust_info;

create table silver.crm_cust_info(
	cst_id int,
	cst_key varchar(50),
	cst_firstname varchar(50),
	cst_lastname varchar(50),
	cst_marital_status varchar(50),
	cst_gndr varchar(50),
	cst_create_date date,
	dwh_create_date date default getdate()
);
go

if OBJECT_ID ('silver.crm_prd_info' , 'U') IS not null 
	drop table silver.crm_prd_info;

create table silver.crm_prd_info(
	prd_id int,
	cat_id varchar(50),
	prd_key varchar(50),
	prd_nm varchar(50),
	prd_cost int,
	prd_line varchar(50),
	prd_start_dt date,
	prd_end_dt date,
	dwh_create_date date default getdate()
);
go



if OBJECT_ID ('silver.crm_sales_details' , 'U') IS not null 
	drop table silver.crm_sales_details;

create table silver.crm_sales_details(
	sls_ord_num varchar(50),
	sls_prd_key varchar(50),
	sls_cust_id int,
	sls_order_dt date,
	sls_ship_dt date,
	sls_due_dt date,
	sls_sales int,
	sls_quantity int,
	sls_price int,
	dwh_create_date date default getdate()
);
go



-- create DDL for ERP
if OBJECT_ID ('silver.erp_cust_az12' , 'U') IS not null 
	drop table silver.erp_cust_az12;

create table silver.erp_cust_az12(
	CID varchar(50),
	BDATE date,
	GEN varchar(50),
	dwh_create_date date default getdate()
);
go



if OBJECT_ID ('silver.erp_loc_a101' , 'U') IS not null 
	drop table silver.erp_loc_a101;

create table silver.erp_loc_a101(
	CID varchar(50),
	CNTRY varchar(50),
	dwh_create_date date default getdate()
);
go


if OBJECT_ID ('silver.erp_px_cat_g1v2' , 'U') IS not null 
	drop table silver.erp_px_cat_g1v2;

create table silver.erp_px_cat_g1v2(
	ID varchar(50),
	CAT varchar(50),
	SUBCAT varchar(50),
	MAINTENANCE varchar(50),
	dwh_create_date date default getdate()
);
go
