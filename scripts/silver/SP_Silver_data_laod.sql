/*
===============================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
===============================================================================
Script Purpose:
    This stored procedure performs the ETL (Extract, Transform, Load) process to 
    populate the 'silver' schema tables from the 'bronze' schema.
	Actions Performed:
		- Truncates Silver tables.
		- Inserts transformed and cleansed data from Bronze into Silver tables.
		
Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    execute silver.load_data;
===============================================================================
*/

CREATE OR ALTER PROCEDURE silver.load_data
AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME,
            @table_name VARCHAR(50), @schema_name VARCHAR(50), @procedure_name VARCHAR(50),
            @rows_before INT, @rows_deleted INT, @rows_after INT;

    SET @batch_start_time = GETDATE();
    PRINT '==========================';
    PRINT 'Loading Silver layer';
    PRINT '==========================';

    PRINT '---------------------------';
    PRINT 'Loading crm data';
    PRINT '---------------------------';

    BEGIN TRY
        SET @start_time = GETDATE();
        SELECT @rows_before = COUNT(*) FROM silver.crm_cust_info;

        PRINT '>> Truncating silver.crm_cust_info';
        TRUNCATE TABLE silver.crm_cust_info;
        SET @rows_deleted = @rows_before;

        PRINT '>> Inserting data into silver.crm_cust_info';

        INSERT INTO silver.crm_cust_info (
            cst_id, cst_key, cst_firstname, cst_lastname,
            cst_marital_status, cst_gndr, cst_create_date
        )
        SELECT 
            cst_id,
            cst_key,
            TRIM(cst_firstname),
            TRIM(cst_lastname),
            CASE 
                WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
                WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
                ELSE 'n/a'
            END,
            CASE 
                WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
                WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
                ELSE 'n/a'
            END,
            cst_create_date
        FROM (
            SELECT *,
                   ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag
            FROM bronze.crm_cust_info
            WHERE cst_id IS NOT NULL
        ) t
        WHERE flag = 1;

        SET @end_time = GETDATE();
        SELECT @rows_after = COUNT(*) FROM silver.crm_cust_info;

        PRINT '>> Load duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' Seconds';

        INSERT INTO silver.etl_audit_log (
            procedure_name, schema_name, table_name,
            start_time, end_time, rows_before, rows_deleted, rows_after,
            load_duration, status, error_message
        )
        VALUES (
            'silver.load_data', 'silver', 'crm_cust_info',
            @start_time, @end_time, @rows_before, @rows_deleted, @rows_after,
            DATEDIFF(SECOND, @start_time, @end_time),
            'Success',
            NULL
        );
    END TRY
    BEGIN CATCH
        INSERT INTO silver.etl_audit_log (
            procedure_name, schema_name, table_name,
            start_time, end_time, rows_before, rows_deleted, rows_after,
            load_duration, status, error_message
        )
        VALUES (
            'silver.load_data', 'silver', 'crm_cust_info',
            @start_time, GETDATE(), @rows_before, @rows_deleted, @rows_after,
            DATEDIFF(SECOND, @start_time, GETDATE()),
            'Failure',
            ERROR_MESSAGE()
        );
    END CATCH

	BEGIN TRY
        SET @start_time = GETDATE();
        SELECT @rows_before = COUNT(*) FROM silver.crm_prd_info;

        PRINT '>> Truncating silver.crm_prd_info';
        TRUNCATE TABLE silver.crm_prd_info;
        SET @rows_deleted = @rows_before;

        PRINT '>> Inserting data into silver.crm_prd_info';

		insert into silver.crm_prd_info(
			prd_id ,
			cat_id ,
			prd_key ,
			prd_nm ,
			prd_cost ,
			prd_line,
			prd_start_dt ,
			prd_end_dt 
			)
		select 
		prd_id,
		--prd_key,
		replace(substring(prd_key, 1, 5), '-' ,'_') as cat_id,
		substring(prd_key, 7, len(prd_key)) as prd_key,
		prd_nm,
		isnull(prd_cost, '0') as prd_cost,
		case
			when UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
			when UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
			when UPPER(TRIM(prd_line)) = 'S' THEN 'Other'
			when UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
			ELSE 'n/a'
		end as prd_line,
		cast(prd_start_dt as date) as prd_start_dt,
		cast(LEAD(prd_start_dt) over(partition by prd_key order by prd_start_dt)-1as date) as prd_end_dt
		from bronze.crm_prd_info

		SET @end_time = GETDATE();
        SELECT @rows_after = COUNT(*) FROM silver.crm_prd_info;

        PRINT '>> Load duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' Seconds';

        INSERT INTO silver.etl_audit_log (
            procedure_name, schema_name, table_name,
            start_time, end_time, rows_before, rows_deleted, rows_after,
            load_duration, status, error_message
        )
        VALUES (
            'silver.load_data', 'silver', 'crm_prd_info',
            @start_time, @end_time, @rows_before, @rows_deleted, @rows_after,
            DATEDIFF(SECOND, @start_time, @end_time),
            'Success',
            NULL
        );
    END TRY
    BEGIN CATCH
        INSERT INTO bronze.etl_audit_log (
            procedure_name, schema_name, table_name,
            start_time, end_time, rows_before, rows_deleted, rows_after,
            load_duration, status, error_message
        )
        VALUES (
            'silver.load_data', 'silver', 'crm_prd_info',
            @start_time, GETDATE(), @rows_before, @rows_deleted, @rows_after,
            DATEDIFF(SECOND, @start_time, GETDATE()),
            'Failure',
            ERROR_MESSAGE()
        );
    END CATCH



	BEGIN TRY
        SET @start_time = GETDATE();
        SELECT @rows_before = COUNT(*) FROM silver.crm_sales_details;

        PRINT '>> Truncating silver.crm_sales_details';
        TRUNCATE TABLE silver.crm_sales_details;
        SET @rows_deleted = @rows_before;
		print'>> Inserting data into:silver.crm_sales_details'

		insert into silver.crm_sales_details(
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			sls_order_dt,
			sls_ship_dt,
			sls_due_dt,
			sls_sales,
			sls_quantity,
			sls_price
			)
		select 
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			case
				when sls_order_dt = 0 or len(sls_order_dt) !=8 then Null
				else cast(cast(sls_order_dt as varchar(8)) as date) 
			end as sls_order_dt,
			case
				when sls_ship_dt = 0 or len(sls_ship_dt) !=8 then Null
				else cast(cast(sls_ship_dt as varchar(8)) as date) 
			end as sls_ship_dt,
			case
				when sls_due_dt = 0 or len(sls_due_dt) !=8 then Null
				else cast(cast(sls_due_dt as varchar(8)) as date) 
			end as sls_due_dt,
			case 
				when sls_sales is null or sls_sales <=0 or sls_sales != sls_quantity * abs(sls_price)
				then sls_quantity * abs(sls_price)
				else sls_sales
			end as sls_sales,
			sls_quantity,
			case 
				when sls_price is null or sls_price <=0 or sls_price != sls_sales/sls_quantity 
				then sls_sales/ cast(replace(sls_quantity, 'Null' , '0') as int)
				else sls_price
			end as sls_price
		from bronze.crm_sales_details

		SET @end_time = GETDATE();
        SELECT @rows_after = COUNT(*) FROM silver.crm_sales_details;

        PRINT '>> Load duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' Seconds';

        INSERT INTO silver.etl_audit_log (
            procedure_name, schema_name, table_name,
            start_time, end_time, rows_before, rows_deleted, rows_after,
            load_duration, status, error_message
        )
        VALUES (
            'silver.load_data', 'silver', 'crm_sales_details',
            @start_time, @end_time, @rows_before, @rows_deleted, @rows_after,
            DATEDIFF(SECOND, @start_time, @end_time),
            'Success',
            NULL
        );
    END TRY
    BEGIN CATCH
        INSERT INTO silver.etl_audit_log (
            procedure_name, schema_name, table_name,
            start_time, end_time, rows_before, rows_deleted, rows_after,
            load_duration, status, error_message
        )
        VALUES (
            'silver.load_data', 'silver', 'crm_sales_details',
            @start_time, GETDATE(), @rows_before, @rows_deleted, @rows_after,
            DATEDIFF(SECOND, @start_time, GETDATE()),
            'Failure',
            ERROR_MESSAGE()
        );
    END CATCH

		print '---------------------------';
		print 'Loading erp data';
		print '---------------------------';

	BEGIN TRY
        SET @start_time = GETDATE();
        SELECT @rows_before = COUNT(*) FROM silver.erp_cust_az12;

        PRINT '>> Truncating silver.erp_cust_az12';
        TRUNCATE TABLE silver.erp_cust_az12;
        SET @rows_deleted = @rows_before;
		print'>>Inserting data into silver.erp_cust_az12'

		insert into silver.erp_cust_az12(
			cid,
			bdate,
			gen
			)
		select 
			substring(cid,4,len(cid)) as cid,
			case
				when bdate > getdate() then Null
				else bdate
			end as bdate,
			case 
				when upper(trim(gen)) = 'F' then 'Female'
				when upper(trim(gen)) = 'M' then 'Male'
				else 'n/a'
			end as gen
		from bronze.erp_cust_az12

		SET @end_time = GETDATE();
        SELECT @rows_after = COUNT(*) FROM silver.erp_cust_az12;

        PRINT '>> Load duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' Seconds';

        INSERT INTO silver.etl_audit_log (
            procedure_name, schema_name, table_name,
            start_time, end_time, rows_before, rows_deleted, rows_after,
            load_duration, status, error_message
        )
        VALUES (
            'silver.load_data', 'silver', 'erp_cust_az12',
            @start_time, @end_time, @rows_before, @rows_deleted, @rows_after,
            DATEDIFF(SECOND, @start_time, @end_time),
            'Success',
            NULL
        );
    END TRY
    BEGIN CATCH
        INSERT INTO silver.etl_audit_log (
            procedure_name, schema_name, table_name,
            start_time, end_time, rows_before, rows_deleted, rows_after,
            load_duration, status, error_message
        )
        VALUES (
            'silver.load_data', 'silver', 'erp_cust_az12',
            @start_time, GETDATE(), @rows_before, @rows_deleted, @rows_after,
            DATEDIFF(SECOND, @start_time, GETDATE()),
            'Failure',
            ERROR_MESSAGE()
        );
    END CATCH


	BEGIN TRY
        SET @start_time = GETDATE();
        SELECT @rows_before = COUNT(*) FROM silver.erp_loc_a101;

        PRINT '>> Truncating silver.erp_loc_a101';
        TRUNCATE TABLE silver.erp_loc_a101;
        SET @rows_deleted = @rows_before;
		print'>> Inserting data into:silver.erp_loc_a101'

		insert into silver.erp_loc_a101(
			cid,
			cntry
			)
		select 
			replace(cid,'-','') as cid,
			case 
				when upper(trim(cntry)) = 'DE' then 'Germany'
				when upper(trim(cntry)) = 'USA' or upper(trim(cntry)) = 'US' then 'United States'
				when upper(trim(cntry)) is null or upper(trim(cntry)) = '' then 'n/a'
				else trim(cntry)
			end as cntry
		from bronze.erp_loc_a101

		SET @end_time = GETDATE();
        SELECT @rows_after = COUNT(*) FROM silver.erp_loc_a101;

        PRINT '>> Load duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' Seconds';

        INSERT INTO silver.etl_audit_log (
            procedure_name, schema_name, table_name,
            start_time, end_time, rows_before, rows_deleted, rows_after,
            load_duration, status, error_message
        )
        VALUES (
            'silver.load_data', 'silver', 'erp_loc_a101',
            @start_time, @end_time, @rows_before, @rows_deleted, @rows_after,
            DATEDIFF(SECOND, @start_time, @end_time),
            'Success',
            NULL
        );
    END TRY
    BEGIN CATCH
        INSERT INTO silver.etl_audit_log (
            procedure_name, schema_name, table_name,
            start_time, end_time, rows_before, rows_deleted, rows_after,
            load_duration, status, error_message
        )
        VALUES (
            'silver.load_data', 'silver', 'erp_loc_a101',
            @start_time, GETDATE(), @rows_before, @rows_deleted, @rows_after,
            DATEDIFF(SECOND, @start_time, GETDATE()),
            'Failure',
            ERROR_MESSAGE()
        );
    END CATCH


	BEGIN TRY
        SET @start_time = GETDATE();
        SELECT @rows_before = COUNT(*) FROM silver.erp_px_cat_g1v2;

        PRINT '>> Truncating silver.erp_px_cat_g1v2';
        TRUNCATE TABLE silver.erp_px_cat_g1v2;
        SET @rows_deleted = @rows_before;
		print'>> Inserting data into:silver.erp_px_cat_g1v2'

		insert silver.erp_px_cat_g1v2(
			id,
			cat,
			subcat,
			maintenance
		)
		select 
		id,
		cat,
		subcat,
		maintenance
		from bronze.erp_px_cat_g1v2

		SET @end_time = GETDATE();
        SELECT @rows_after = COUNT(*) FROM silver.erp_px_cat_g1v2;

        PRINT '>> Load duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' Seconds';

        INSERT INTO silver.etl_audit_log (
            procedure_name, schema_name, table_name,
            start_time, end_time, rows_before, rows_deleted, rows_after,
            load_duration, status, error_message
        )
        VALUES (
            'silver.load_data', 'silver', 'erp_px_cat_g1v2',
            @start_time, @end_time, @rows_before, @rows_deleted, @rows_after,
            DATEDIFF(SECOND, @start_time, @end_time),
            'Success',
            NULL
        );
    END TRY
    BEGIN CATCH
        INSERT INTO silver.etl_audit_log (
            procedure_name, schema_name, table_name,
            start_time, end_time, rows_before, rows_deleted, rows_after,
            load_duration, status, error_message
        )
        VALUES (
            'silver.load_data', 'silver', 'erp_px_cat_g1v2',
            @start_time, GETDATE(), @rows_before, @rows_deleted, @rows_after,
            DATEDIFF(SECOND, @start_time, GETDATE()),
            'Failure',
            ERROR_MESSAGE()
        );
    END CATCH
end
