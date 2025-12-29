create or alter procedure bronze.load_data as 
begin
	declare @start_time datetime, @end_time datetime, @batch_start_time datetime, @batch_end_time datetime, 
	@table_name varchar(50), @schema_name varchar(50),@procedure_name varchar(50), @rows_before int,
	@rows_deleted int, @rows_after int

	set @batch_start_time = GETDATE();
	print '==========================';
	print 'Loading Bronze layer';
	print '==========================';

	print '---------------------------';
	print 'Loading crm data';
	print '---------------------------';
	begin try
		set @start_time = GETDATE();
		SELECT @rows_before = COUNT(*) FROM bronze.crm_cust_info;
	
		print '>> Truncating table:crm_cust_info';
		--load data for crm_cust_info
		truncate table bronze.crm_cust_info;

		print '>> Inserting table:crm_cust_info'
		bulk insert bronze.crm_cust_info
		from 'C:\Users\2327866\OneDrive - Cognizant\Data Engineering\datasets\source_crm\cust_info.csv'
		with (
			firstrow = 2,
			fieldterminator =',',
			tablock
		);  
		set @end_time = GETDATE();
		SELECT @rows_after = COUNT(*) FROM bronze.crm_cust_info;
		print '>> Load duration: ' + cast(datediff(second,@start_time, @end_time)as varchar) + 'Seconds';
		print '---------------------------';
		INSERT INTO bronze.etl_audit_log (
        procedure_name, schema_name, table_name,
        start_time, end_time, rows_before, rows_deleted, rows_after,
        load_duration, status, error_message
		)
		VALUES (
			'sp_bronze_load_data', 'bronze', 'crm_cust_info',
			@start_time, @end_time, @rows_before, @rows_before, @rows_after,
			DATEDIFF(SECOND,@start_time,@end_time),
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
			'sp_bronze_load_data', 'bronze', 'crm_cust_info',
			@start_time, GETDATE(), @rows_before, @rows_before, NULL,
			DATEDIFF(SECOND,@start_time,GETDATE()),
			'Failure',
			ERROR_MESSAGE()
		);
	END CATCH;
		
	begin try
		set @start_time = GETDATE();
		SELECT @rows_before = COUNT(*) FROM bronze.crm_prd_info;

		print '>> Truncating table:crm_prd_info';
		--load data for prd_info
		truncate table bronze.crm_prd_info;
		print '>> Inserting table:crm_prd_info';
		bulk insert bronze.crm_prd_info
		from 'C:\Users\2327866\OneDrive - Cognizant\Data Engineering\datasets\source_crm\prd_info.csv'
		with (
			firstrow = 2,
			fieldterminator =',',
			tablock
		);  
		set @end_time = GETDATE();
		SELECT @rows_after = COUNT(*) FROM bronze.crm_prd_info;
		print '>> Load duration: ' + cast(datediff(second,@start_time, @end_time)as varchar) + 'Seconds';
		print '---------------------------';

		INSERT INTO bronze.etl_audit_log (
        procedure_name, schema_name, table_name,
        start_time, end_time, rows_before, rows_deleted, rows_after,
        load_duration, status, error_message
		)
		VALUES (
			'sp_bronze_load_data', 'bronze', 'crm_prd_info',
			@start_time, @end_time, @rows_before, @rows_before, @rows_after,
			DATEDIFF(SECOND,@start_time,@end_time),
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
			'sp_bronze_load_data', 'bronze', 'crm_prd_info',
			@start_time, GETDATE(), @rows_before, @rows_before, NULL,
			DATEDIFF(SECOND,@start_time,GETDATE()),
			'Failure',
			ERROR_MESSAGE()
		);
	END CATCH;

	begin try
		set @start_time = GETDATE();
		SELECT @rows_before = COUNT(*) FROM bronze.crm_sales_details;
		print '>> Truncating table:crm_sales_details';
		--load data for sales_details
		truncate table bronze.crm_sales_details;

		print '>> Inserting table:crm_sales_details';
		bulk insert bronze.crm_sales_details
		from 'C:\Users\2327866\OneDrive - Cognizant\Data Engineering\datasets\source_crm\sales_details.csv'
		with (
			firstrow = 2,
			fieldterminator =',',
			tablock
		);  
		set @end_time = GETDATE();
		SELECT @rows_after = COUNT(*) FROM bronze.crm_sales_details;
		print '>> Load duration: ' + cast(datediff(second,@start_time, @end_time)as varchar) + 'Seconds';
		print '---------------------------';

		INSERT INTO bronze.etl_audit_log (
        procedure_name, schema_name, table_name,
        start_time, end_time, rows_before, rows_deleted, rows_after,
        load_duration, status, error_message
		)
		VALUES (
			'sp_bronze_load_data', 'bronze', 'crm_sales_details',
			@start_time, @end_time, @rows_before, @rows_before, @rows_after,
			DATEDIFF(SECOND,@start_time,@end_time),
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
			'sp_bronze_load_data', 'bronze', 'crm_sales_details',
			@start_time, GETDATE(), @rows_before, @rows_before, NULL,
			DATEDIFF(SECOND,@start_time,GETDATE()),
			'Failure',
			ERROR_MESSAGE()
		);
	END CATCH;


		print '---------------------------';
		print 'Loading erp data';
		print '---------------------------';


	begin try
		set @start_time = GETDATE();
		SELECT @rows_before = COUNT(*) FROM bronze.erp_CUST_AZ12;
		print '>> Truncating table:erp_CUST_AZ12';
		--load data for erp_CUST_AZ12
		truncate table bronze.erp_CUST_AZ12;

		print '>> Inserting table:erp_CUST_AZ12';
		bulk insert bronze.erp_CUST_AZ12
		from 'C:\Users\2327866\OneDrive - Cognizant\Data Engineering\datasets\source_erp\CUST_AZ12.csv'
		with (
			firstrow = 2,
			fieldterminator =',',
			tablock
		);  
		set @end_time = GETDATE();
		SELECT @rows_after = COUNT(*) FROM bronze.erp_CUST_AZ12;
		print '>> Load duration: ' + cast(datediff(second,@start_time, @end_time)as varchar) + 'Seconds';
		print '---------------------------';

		INSERT INTO bronze.etl_audit_log (
        procedure_name, schema_name, table_name,
        start_time, end_time, rows_before, rows_deleted, rows_after,
        load_duration, status, error_message
		)
		VALUES (
			'sp_bronze_load_data', 'bronze', 'erp_cust_az12',
			@start_time, @end_time, @rows_before, @rows_before, @rows_after,
			DATEDIFF(SECOND,@start_time,@end_time),
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
			'sp_bronze_load_data', 'bronze', 'erp_cust_az12',
			@start_time, GETDATE(), @rows_before, @rows_before, NULL,
			DATEDIFF(SECOND,@start_time,GETDATE()),
			'Failure',
			ERROR_MESSAGE()
		);
	END CATCH;


	begin try
		set @start_time = GETDATE();
		SELECT @rows_before = COUNT(*) FROM bronze.erp_LOC_A101;
		print '>> Truncating table:erp_LOC_A101';
		--load data for erp_LOC_A101
		truncate table bronze.erp_LOC_A101;

		print '>> Inserting table:erp_LOC_A101';
		bulk insert bronze.erp_LOC_A101
		from 'C:\Users\2327866\OneDrive - Cognizant\Data Engineering\datasets\source_erp\LOC_A101.csv'
		with (
			firstrow = 2,
			fieldterminator =',',
			tablock
		);  
		set @end_time = GETDATE();
		SELECT @rows_after = COUNT(*) FROM bronze.erp_LOC_A101;
		print '>> Load duration: ' + cast(datediff(second,@start_time, @end_time)as varchar) + 'Seconds';
		print '---------------------------';

		INSERT INTO bronze.etl_audit_log (
        procedure_name, schema_name, table_name,
        start_time, end_time, rows_before, rows_deleted, rows_after,
        load_duration, status, error_message
		)
		VALUES (
			'sp_bronze_load_data', 'bronze', 'erp_loc_a101',
			@start_time, @end_time, @rows_before, @rows_before, @rows_after,
			DATEDIFF(SECOND,@start_time,@end_time),
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
			'sp_bronze_load_data', 'bronze', 'erp_loc_a101',
			@start_time, GETDATE(), @rows_before, @rows_before, NULL,
			DATEDIFF(SECOND,@start_time,GETDATE()),
			'Failure',
			ERROR_MESSAGE()
		);
	END CATCH;

	begin try
		set @start_time = GETDATE();
		SELECT @rows_before = COUNT(*) FROM bronze.erp_PX_CAT_G1V2;
		
		print '>> Truncating table:erp_PX_CAT_G1V2';
		--load data for sales_details
		truncate table bronze.erp_PX_CAT_G1V2;

		print '>> Inserting table:erp_PX_CAT_G1V2';
		bulk insert bronze.erp_PX_CAT_G1V2
		from 'C:\Users\2327866\OneDrive - Cognizant\Data Engineering\datasets\source_erp\PX_CAT_G1V2.csv'
		with (
			firstrow = 2,
			fieldterminator =',',
			tablock
		);  
	    set @end_time = GETDATE();
		SELECT @rows_after = COUNT(*) FROM bronze.erp_PX_CAT_G1V2;
		print '>> Load duration: ' + cast(datediff(second,@start_time, @end_time)as varchar) + 'Seconds';
		print '---------------------------';

		INSERT INTO bronze.etl_audit_log (
        procedure_name, schema_name, table_name,
        start_time, end_time, rows_before, rows_deleted, rows_after,
        load_duration, status, error_message
		)
		VALUES (
			'sp_bronze_load_data', 'bronze', 'erp_PX_CAT_G1V2',
			@start_time, @end_time, @rows_before, @rows_before, @rows_after,
			DATEDIFF(SECOND,@start_time,@end_time),
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
			'sp_bronze_load_data', 'bronze', 'erp_PX_CAT_G1V2',
			@start_time, GETDATE(), @rows_before, @rows_before, NULL,
			DATEDIFF(SECOND,@start_time,GETDATE()),
			'Failure',
			ERROR_MESSAGE()
		);
	END CATCH;

		print '==========================';
		print 'Bronze Layer loaded successfully';
		print '==========================';
		set @batch_end_time = GETDATE();
		print '>> Bronze data Load duration: ' + cast(datediff(second,@batch_start_time, @batch_end_time)as varchar) + 'Seconds';
		print '---------------------------';
end
