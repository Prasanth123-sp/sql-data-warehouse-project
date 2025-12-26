--create DDL for CRM
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


create table bronze.crm_prd_info(
	prd_id int,
	prd_key varchar(50),
	prd_nm varchar(50),
	prd_cost int,
	prd_line varchar(50),
	prd_start_dt date,
	prd_end_dt date
);
go


create table bronze.crm_sales_details(
	sls_ord_num varchar(50),
	sls_prd_key varchar(50),
	sls_cust_id int,
	sls_order_dt date,
	sls_ship_dt date,
	sls_due_dt date,
	sls_sales int,
	sls_quantity int,
	sls_price int
);
go


  
-- create DDL for ERP
create table bronze.erm_cust_az12(
	CID varchar(50),
	BDATE date,
	GEN varchar(50)
);
go



create table bronze.erm_loc_a101(
	CID varchar(50),
	CNTRY varchar(50)
);
go



create table bronze.erm_px_cat_g1v2(
	ID varchar(50),
	CAT varchar(50),
	SUBCAT varchar(50),
	MAINTENANCE varchar(50)
);
go
