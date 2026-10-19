USE [msdb];
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
	BEGIN TRANSACTION;

	DECLARE @ReturnCode INT;
	DECLARE @JobId UNIQUEIDENTIFIER;
	DECLARE @JobName SYSNAME;
	DECLARE @PackageName SYSNAME;
	DECLARE @Description NVARCHAR(512);
	DECLARE @Command NVARCHAR(MAX);

	IF NOT EXISTS
	(
		SELECT 1
		FROM msdb.dbo.syscategories
		WHERE name = N'[Uncategorized (Local)]'
		  AND category_class = 1
	)
	BEGIN
		EXEC @ReturnCode = msdb.dbo.sp_add_category
			@class = N'JOB',
			@type = N'LOCAL',
			@name = N'[Uncategorized (Local)]';

		IF @ReturnCode <> 0
			THROW 51000, 'Could not create the SQL Agent job category.', 1;
	END;

	SELECT @JobId = job_id
	FROM msdb.dbo.sysjobs
	WHERE name = N'NorthWindJob';

	IF @JobId IS NOT NULL
	BEGIN
		EXEC @ReturnCode = msdb.dbo.sp_update_job
			@job_id = @JobId,
			@enabled = 0;

		IF @ReturnCode <> 0
			THROW 51007, 'Could not disable the previous aggregate NorthWindJob.', 1;
	END;

	DECLARE @Jobs TABLE
	(
		LoadOrder INT NOT NULL,
		JobName SYSNAME NOT NULL,
		PackageName SYSNAME NOT NULL,
		Description NVARCHAR(512) NOT NULL
	);

	INSERT INTO @Jobs (LoadOrder, JobName, PackageName, Description)
	VALUES
		(1, N'NorthWind_ETL_DimCustomer', N'DimCustomer', N'Manual incremental load of DimCustomer.'),
		(2, N'NorthWind_ETL_DimProduct', N'DimProduct', N'Manual incremental load of DimProduct.'),
		(3, N'NorthWind_ETL_DimSupplier', N'DimSupplier', N'Manual incremental load of DimSupplier.'),
		(4, N'NorthWind_ETL_DimEmployee', N'DimEmployee', N'Manual incremental load of DimEmployee.'),
		(5, N'NorthWind_ETL_DimShipper', N'DimShipper', N'Manual incremental load of DimShipper.'),
		(6, N'NorthWind_ETL_DimGeography', N'DimGeography', N'Manual incremental load of DimGeography.'),
		(7, N'NorthWind_ETL_FactSales', N'FactSales', N'Manual incremental load of FactSales. Run after all dimension jobs.');

	DECLARE JobCursor CURSOR LOCAL FAST_FORWARD FOR
		SELECT JobName, PackageName, Description
		FROM @Jobs
		ORDER BY LoadOrder;

	OPEN JobCursor;
	FETCH NEXT FROM JobCursor INTO @JobName, @PackageName, @Description;

	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @JobId = NULL;
		SET @ReturnCode = 0;

		SELECT @JobId = job_id
		FROM msdb.dbo.sysjobs
		WHERE name = @JobName;

		IF @JobId IS NULL
		BEGIN
			EXEC @ReturnCode = msdb.dbo.sp_add_job
				@job_name = @JobName,
				@enabled = 1,
				@description = @Description,
				@category_name = N'[Uncategorized (Local)]',
				@job_id = @JobId OUTPUT;

			IF @ReturnCode <> 0
				THROW 51001, 'Could not create a SQL Agent job.', 1;
		END
		ELSE
		BEGIN
			EXEC @ReturnCode = msdb.dbo.sp_update_job
				@job_id = @JobId,
				@enabled = 1,
				@description = @Description,
				@category_name = N'[Uncategorized (Local)]';

			IF @ReturnCode <> 0
				THROW 51002, 'Could not update a SQL Agent job.', 1;
		END;

		SET @Command = N'/ISSERVER "\"\SSISDB\NorthWind\NorthWindETL2\'
			+ @PackageName
			+ N'.dtsx\"" /SERVER localhost /Par "\"$ServerOption::LOGGING_LEVEL(Int16)\"";1 /Par "\"$ServerOption::SYNCHRONIZED(Boolean)\"";True /CALLERINFO SQLAGENT /REPORTING E';

		SET @ReturnCode = 0;
		IF EXISTS
		(
			SELECT 1
			FROM msdb.dbo.sysjobsteps
			WHERE job_id = @JobId
			  AND step_id = 1
		)
		BEGIN
			EXEC @ReturnCode = msdb.dbo.sp_update_jobstep
				@job_id = @JobId,
				@step_id = 1,
				@step_name = N'Execute SSIS package',
				@subsystem = N'SSIS',
				@command = @Command,
				@database_name = N'master',
				@on_success_action = 1,
				@on_fail_action = 2,
				@retry_attempts = 0,
				@retry_interval = 0;

			IF @ReturnCode <> 0
				THROW 51003, 'Could not update the SSIS job step.', 1;
		END
		ELSE
		BEGIN
			EXEC @ReturnCode = msdb.dbo.sp_add_jobstep
				@job_id = @JobId,
				@step_name = N'Execute SSIS package',
				@step_id = 1,
				@subsystem = N'SSIS',
				@command = @Command,
				@database_name = N'master',
				@on_success_action = 1,
				@on_fail_action = 2,
				@retry_attempts = 0,
				@retry_interval = 0;

			IF @ReturnCode <> 0
				THROW 51004, 'Could not create the SSIS job step.', 1;
		END;

		EXEC @ReturnCode = msdb.dbo.sp_update_job
			@job_id = @JobId,
			@start_step_id = 1;

		IF @ReturnCode <> 0
			THROW 51005, 'Could not set the SQL Agent job start step.', 1;

		IF NOT EXISTS
		(
			SELECT 1
			FROM msdb.dbo.sysjobservers
			WHERE job_id = @JobId
		)
		BEGIN
			EXEC @ReturnCode = msdb.dbo.sp_add_jobserver
				@job_id = @JobId,
				@server_name = N'(local)';

			IF @ReturnCode <> 0
				THROW 51006, 'Could not assign the SQL Agent job to this server.', 1;
		END;

		FETCH NEXT FROM JobCursor INTO @JobName, @PackageName, @Description;
	END;

	CLOSE JobCursor;
	DEALLOCATE JobCursor;

	COMMIT TRANSACTION;
END TRY
BEGIN CATCH
	IF CURSOR_STATUS('local', 'JobCursor') >= 0
		CLOSE JobCursor;
	IF CURSOR_STATUS('local', 'JobCursor') > -3
		DEALLOCATE JobCursor;
	IF XACT_STATE() <> 0
		ROLLBACK TRANSACTION;
	THROW;
END CATCH;
GO