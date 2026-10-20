USE [msdb]
GO

SET XACT_ABORT ON;

BEGIN TRY
	BEGIN TRANSACTION;

	DECLARE @ReturnCode INT = 0;
	DECLARE @jobId BINARY(16);

	IF NOT EXISTS (SELECT 1 FROM msdb.dbo.syscategories WHERE name = N'[Uncategorized (Local)]' AND category_class = 1)
	BEGIN
		EXEC @ReturnCode = msdb.dbo.sp_add_category @class = N'JOB', @type = N'LOCAL', @name = N'[Uncategorized (Local)]';
		IF @ReturnCode <> 0 THROW 50001, 'Could not create SQL Agent job category.', 1;
	END;

	IF EXISTS (SELECT 1 FROM msdb.dbo.sysjobs WHERE name = N'NorthWindJob')
	BEGIN
		EXEC @ReturnCode = msdb.dbo.sp_delete_job @job_name = N'NorthWindJob', @delete_unused_schedule = 1;
		IF @ReturnCode <> 0 THROW 50002, 'Could not replace existing NorthWindJob.', 1;
	END;

	EXEC @ReturnCode = msdb.dbo.sp_add_job
		@job_name = N'NorthWindJob',
		@enabled = 1,
		@notify_level_eventlog = 0,
		@notify_level_email = 0,
		@notify_level_netsend = 0,
		@notify_level_page = 0,
		@delete_level = 0,
		@description = N'Loads the NorthWind dimensional model by running the SSIS orchestration package.',
		@category_name = N'[Uncategorized (Local)]',
		@owner_login_name = N'sa',
		@job_id = @jobId OUTPUT;
	IF @ReturnCode <> 0 THROW 50003, 'Could not create NorthWindJob.', 1;

	EXEC @ReturnCode = msdb.dbo.sp_add_jobstep
		@job_id = @jobId,
		@step_name = N'Load NorthWind dimensional model',
		@step_id = 1,
		@cmdexec_success_code = 0,
		@on_success_action = 1,
		@on_fail_action = 2,
		@retry_attempts = 0,
		@retry_interval = 0,
		@subsystem = N'SSIS',
		@command = N'/ISSERVER "\"\SSISDB\NorthWind\NorthWindETL2\Package.dtsx\"" /SERVER localhost /Par "\"$ServerOption::LOGGING_LEVEL(Int16)\"";1 /Par "\"$ServerOption::SYNCHRONIZED(Boolean)\"";True /CALLERINFO SQLAGENT /REPORTING E',
		@database_name = N'master',
		@flags = 0;
	IF @ReturnCode <> 0 THROW 50004, 'Could not create NorthWindJob SSIS step.', 1;

	EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1;
	IF @ReturnCode <> 0 THROW 50005, 'Could not set NorthWindJob start step.', 1;

	EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)';
	IF @ReturnCode <> 0 THROW 50007, 'Could not assign NorthWindJob to the local server.', 1;

	COMMIT TRANSACTION;
END TRY
BEGIN CATCH
	IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
	THROW;
END CATCH;
GO
