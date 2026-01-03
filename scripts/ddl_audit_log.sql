/*
===============================================================================
DDL Script: Create Audit_Log Tables
===============================================================================
Script Purpose:
    This script drops existing audit log tables if they already exist and 
    recreates them in both the 'bronze' and 'silver' schemas. 
    Run this script to re-define the DDL structure of the audit log tables 
    used for ETL process tracking and error logging.
===============================================================================
*/

if OBJECT_ID ('bronze.etl_audit_log' , 'U') IS not null 
	drop table bronze.etl_audit_log;

create table bronze.etl_audit_log(
	procedure_name varchar(100),
	schema_name varchar(50),
	table_name varchar(50),
	start_time datetime,
	end_time datetime,
	rows_before int,
	rows_deleted int,
	rows_after int,
	load_duration int,
	status varchar(50),
	error_message varchar(200)
);
go

if OBJECT_ID ('silver.etl_audit_log' , 'U') IS not null 
	drop table silver.etl_audit_log;

create table silver.etl_audit_log(
	procedure_name varchar(100),
	schema_name varchar(50),
	table_name varchar(50),
	start_time datetime,
	end_time datetime,
	rows_before int,
	rows_deleted int,
	rows_after int,
	load_duration int,
	status varchar(50),
	error_message varchar(200)
);
go
