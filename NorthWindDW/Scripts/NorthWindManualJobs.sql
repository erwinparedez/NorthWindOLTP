USE [msdb];
GO

SET XACT_ABORT ON;

BEGIN TRY
	BEGIN TRANSACTION;

	DECLARE @ReturnCode INT = 0;
	DECLARE @jobId BINARY(16);

	IF NOT EXISTS (SELECT 1 FROM msdb.dbo.syscategories WHERE name = N'[Uncategorized (Local)]' AND category_class = 1)
	BEGIN
		EXEC @ReturnCode = msdb.dbo.sp_add_category @class = N'JOB', @type = N'LOCAL', @name = N'[Uncategorized (Local)]';
		IF @ReturnCode <> 0 THROW 50011, 'Could not create SQL Agent job category.', 1;
	END;

	IF EXISTS (SELECT 1 FROM msdb.dbo.sysjobs WHERE name = N'NorthWindDatabaseHealthCheck')
	BEGIN
		EXEC @ReturnCode = msdb.dbo.sp_delete_job @job_name = N'NorthWindDatabaseHealthCheck', @delete_unused_schedule = 1;
		IF @ReturnCode <> 0 THROW 50012, 'Could not replace NorthWindDatabaseHealthCheck.', 1;
	END;

	EXEC @ReturnCode = msdb.dbo.sp_add_job
		@job_name = N'NorthWindDatabaseHealthCheck',
		@enabled = 1,
		@description = N'Manually checks that NorthWindOLTP2 and NorthWindDW2 are online.',
		@category_name = N'[Uncategorized (Local)]',
		@owner_login_name = N'sa',
		@job_id = @jobId OUTPUT;
	IF @ReturnCode <> 0 THROW 50013, 'Could not create NorthWindDatabaseHealthCheck.', 1;

	EXEC @ReturnCode = msdb.dbo.sp_add_jobstep
		@job_id = @jobId,
		@step_name = N'Check NorthWind databases are online',
		@step_id = 1,
		@on_success_action = 1,
		@on_fail_action = 2,
		@subsystem = N'TSQL',
		@database_name = N'master',
		@command = N'IF NOT EXISTS (SELECT 1 FROM sys.databases WHERE name = N''NorthWindOLTP2'' AND state = 0) THROW 50021, ''NorthWindOLTP2 is missing or not online.'', 1;
IF NOT EXISTS (SELECT 1 FROM sys.databases WHERE name = N''NorthWindDW2'' AND state = 0) THROW 50022, ''NorthWindDW2 is missing or not online.'', 1;
PRINT N''NorthWindOLTP2 and NorthWindDW2 are online.'';';
	IF @ReturnCode <> 0 THROW 50014, 'Could not add the NorthWindDatabaseHealthCheck step.', 1;

	EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)';
	IF @ReturnCode <> 0 THROW 50015, 'Could not assign NorthWindDatabaseHealthCheck to the local server.', 1;

	SET @jobId = NULL;

	IF EXISTS (SELECT 1 FROM msdb.dbo.sysjobs WHERE name = N'NorthWindDatabaseLatencyCheck')
	BEGIN
		EXEC @ReturnCode = msdb.dbo.sp_delete_job @job_name = N'NorthWindDatabaseLatencyCheck', @delete_unused_schedule = 1;
		IF @ReturnCode <> 0 THROW 50016, 'Could not replace NorthWindDatabaseLatencyCheck.', 1;
	END;

	EXEC @ReturnCode = msdb.dbo.sp_add_job
		@job_name = N'NorthWindDatabaseLatencyCheck',
		@enabled = 1,
		@description = N'Manually measures the elapsed time of a minimal SQL probe in NorthWindDW2.',
		@category_name = N'[Uncategorized (Local)]',
		@owner_login_name = N'sa',
		@job_id = @jobId OUTPUT;
	IF @ReturnCode <> 0 THROW 50017, 'Could not create NorthWindDatabaseLatencyCheck.', 1;

	EXEC @ReturnCode = msdb.dbo.sp_add_jobstep
		@job_id = @jobId,
		@step_name = N'Time a minimal database query',
		@step_id = 1,
		@on_success_action = 1,
		@on_fail_action = 2,
		@subsystem = N'TSQL',
		@database_name = N'NorthWindDW2',
		@command = N'DECLARE @startedAt datetime2(7) = SYSUTCDATETIME();
DECLARE @probe int;
SELECT @probe = 1;
DECLARE @elapsedMs decimal(18, 3) = DATEDIFF_BIG(NANOSECOND, @startedAt, SYSUTCDATETIME()) / 1000000.0;
PRINT CONCAT(N''SQL server-side probe elapsed time (ms): '', @elapsedMs);';
	IF @ReturnCode <> 0 THROW 50018, 'Could not add the NorthWindDatabaseLatencyCheck step.', 1;

	EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)';
	IF @ReturnCode <> 0 THROW 50019, 'Could not assign NorthWindDatabaseLatencyCheck to the local server.', 1;

	COMMIT TRANSACTION;
END TRY
BEGIN CATCH
	IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
	THROW;
END CATCH;
GO