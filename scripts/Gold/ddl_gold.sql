/*
===============================================================================
DDL Script: Create Gold Views
===============================================================================
Script Purpose:
    This script creates views for the Gold layer in the data warehouse. 
    The Gold layer represents the final dimension and fact tables (Star Schema)

    Each view performs transformations and combines data from the Silver layer 
    to produce a clean, enriched, and business-ready dataset.

Usage:
    - These views can be queried directly for analytics and reporting.
===============================================================================
*/

-- =============================================================================
-- Create Dimension: gold.dim_customers
-- =============================================================================

IF OBJECT_ID('gold.dim_customers', 'V') IS NOT NULL
    DROP VIEW gold.dim_customers;
GO

create view gold.dim_customers as
select 
	ROW_NUMBER() over(order by c.cst_id) as customer_key,
	c.cst_id as customer_id ,
	c.cst_key as customer_number ,
	c.cst_firstname as first_name ,
	c.cst_lastname as last_name ,
	e.CNTRY as country ,
	c.cst_marital_status as marital_status ,
	case
		when c.cst_gndr != 'n/a' then  c.cst_gndr
		else COALESCE(ec.gen, 'n/a')
	end as gender,
	ec.bdate as birthdate ,
	c.cst_create_date as create_date 
from silver.crm_cust_info c
left join silver.erp_loc_a101 e
	on c.cst_key = e.cid
left join silver.erp_cust_az12 ec
	on c.cst_key = ec.CID;
go
  
-- =============================================================================
-- Create Dimension: gold.dim_products
-- =============================================================================

IF OBJECT_ID('gold.dim_products', 'V') IS NOT NULL
    DROP VIEW gold.dim_products;
GO

create view gold.dim_products as
select 
	row_number() over(order by p.prd_id) as product_key,
	p.prd_id as product_id,
	p.prd_key as product_number,
	p.prd_nm as product_name,
	p.cat_id as category_id,
	case
		when ep.cat is null then 'n/a'
		else ep.cat
	end as category,
	case
		when ep.subcat is null then 'n/a'
		else ep.subcat
	end as subcategory,
	case
		when ep.maintenance is null then 'n/a'
		else ep.maintenance
	end as maintenance,
	p.prd_cost as cost,
	p.prd_line as product_line,
	p.prd_start_dt as start_date
from silver.crm_prd_info p
left join silver.erp_px_cat_g1v2 ep
	on p.cat_id = ep.id
WHERE p.prd_end_dt IS NULL;
go

-- =============================================================================
-- Create Fact Table: gold.fact_sales
-- =============================================================================

IF OBJECT_ID('gold.fact_sales', 'V') IS NOT NULL
    DROP VIEW gold.fact_sales;
GO

create view gold.fact_sales as 
select 
	s.sls_ord_num as order_number,
	dp.product_key as product_key,
	dc.customer_key as customer_key,
	s.sls_order_dt as order_dt,
	s.sls_ship_dt as shipping_date,
	s.sls_due_dt as due_dt,
	s.sls_sales as sales_amount,
	s.sls_quantity as quantity,
	s.sls_price as price
from silver.crm_sales_details s
left join gold.dim_products dp
	on s.sls_prd_key = dp.product_number
left join gold.dim_customers dc
	on s.sls_cust_id = dc.customer_id;
go
