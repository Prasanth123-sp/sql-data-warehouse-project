create or alter procedure bronze.load_data as 
begin
	declare @start_time datetime, @end_time datetime, @batch_start_time datetime, @batch_end_time datetime
	begin try
		set @batch_start_time = GETDATE();
		print '==========================';
		print 'Loading Bronze layer';
		print '==========================';

		print '---------------------------';
		print 'Loading crm data';
		print '---------------------------';

		set @start_time = GETDATE();
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
		print '>> Load duration: ' + cast(datediff(second,@start_time, @end_time)as varchar) + 'Seconds';
		print '---------------------------';

		set @start_time = GETDATE();
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
		print '>> Load duration: ' + cast(datediff(second,@start_time, @end_time)as varchar) + 'Seconds';
		print '---------------------------';


		set @start_time = GETDATE();
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
		print '>> Load duration: ' + cast(datediff(second,@start_time, @end_time)as varchar) + 'Seconds';
		print '---------------------------';


		print '---------------------------';
		print 'Loading erp data';
		print '---------------------------';

		set @start_time = GETDATE();
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
		print '>> Load duration: ' + cast(datediff(second,@start_time, @end_time)as varchar) + 'Seconds';
		print '---------------------------';

		set @start_time = GETDATE();
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
		print '>> Load duration: ' + cast(datediff(second,@start_time, @end_time)as varchar) + 'Seconds';
		print '---------------------------';


		set @start_time = GETDATE();
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
		print '>> Load duration: ' + cast(datediff(second,@start_time, @end_time)as varchar) + 'Seconds';
		print '---------------------------';

		print '==========================';
		print 'Bronze Layer loaded successfully';
		print '==========================';
		set @batch_end_time = GETDATE();
		print '>> Bronze data Load duration: ' + cast(datediff(second,@batch_start_time, @batch_end_time)as varchar) + 'Seconds';
		print '---------------------------';
	end try
	begin catch
		print 'Error during load';
		print 'Error meesage: '+cast(error_message() as varchar);
		print 'Error meesage: '+ cast(error_number() as varchar);
	end catch

end
