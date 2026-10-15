USE [msdb]
GO

/****** Objeto:  Job [NorthWindETL_Job]    Fecha: 2026-10-14 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0

-- 1. Categoría del Trabajo
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
    EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
    IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

-- 2. Eliminar el Job si ya existía previamente para recrearlo limpiamente
IF EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'NorthWindETL_Job')
BEGIN
    EXEC msdb.dbo.sp_delete_job @job_name=N'NorthWindETL_Job', @delete_unused_schedule=1
END

-- 3. Crear el Job Principal
DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'NorthWindETL_Job', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Job de ejecucion secuencial para ETL NorthWind (Dimensiones y Hechos con control de errores).', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', 
		@job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

/* ==============================================================================
   PASO 1: Cargar DimShipper
   - Si éxito (on_success_action = 3): Ir al paso siguiente (Paso 2)
   - Si error (on_fail_action = 2): Salir del trabajo indicando fallo
================================================================================= */
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'1. Cargar DimShipper', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, -- Ir al paso siguiente
		@on_success_step_id=0, 
		@on_fail_action=2,    -- Salir indicando error
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'SSIS', 
		@command=N'/ISSERVER "\"\SSISDB\NorthWind\NorthWindETL2\DimShipper.dtsx\"" /SERVER localhost /Par "\"$ServerOption::LOGGING_LEVEL(Int16)\"";1 /Par "\"$ServerOption::SYNCHRONIZED(Boolean)\"";True /CALLERINFO SQLAGENT /REPORTING E', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

/* ==============================================================================
   PASO 2: Cargar DimProduct
   - Si éxito: Ir al paso siguiente (Paso 3)
   - Si error: Salir indicando fallo
================================================================================= */
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'2. Cargar DimProduct', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, -- Ir al paso siguiente
		@on_success_step_id=0, 
		@on_fail_action=2,    -- Salir indicando error
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'SSIS', 
		@command=N'/ISSERVER "\"\SSISDB\NorthWind\NorthWindETL2\DimProduct.dtsx\"" /SERVER localhost /Par "\"$ServerOption::LOGGING_LEVEL(Int16)\"";1 /Par "\"$ServerOption::SYNCHRONIZED(Boolean)\"";True /CALLERINFO SQLAGENT /REPORTING E', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

/* ==============================================================================
   PASO 3: Cargar DimCustomer
   - Si éxito: Ir al paso siguiente (Paso 4)
   - Si error: Salir indicando fallo
================================================================================= */
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'3. Cargar DimCustomer', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=3, -- Ir al paso siguiente
		@on_success_step_id=0, 
		@on_fail_action=2,    -- Salir indicando error
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'SSIS', 
		@command=N'/ISSERVER "\"\SSISDB\NorthWind\NorthWindETL2\DimCustomer.dtsx\"" /SERVER localhost /Par "\"$ServerOption::LOGGING_LEVEL(Int16)\"";1 /Par "\"$ServerOption::SYNCHRONIZED(Boolean)\"";True /CALLERINFO SQLAGENT /REPORTING E', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

/* ==============================================================================
   PASO 4: Cargar DimEmployee
   - Si éxito: Ir al paso siguiente (Paso 5)
   - Si error: Salir indicando fallo
================================================================================= */
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'4. Cargar DimEmployee', 
		@step_id=4, 
		@cmdexec_success_code=0, 
		@on_success_action=3, -- Ir al paso siguiente
		@on_success_step_id=0, 
		@on_fail_action=2,    -- Salir indicando error
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'SSIS', 
		@command=N'/ISSERVER "\"\SSISDB\NorthWind\NorthWindETL2\DimEmployee.dtsx\"" /SERVER localhost /Par "\"$ServerOption::LOGGING_LEVEL(Int16)\"";1 /Par "\"$ServerOption::SYNCHRONIZED(Boolean)\"";True /CALLERINFO SQLAGENT /REPORTING E', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

/* ==============================================================================
   PASO 5: Cargar DimGeography
   - Si éxito: Ir al paso siguiente (Paso 6)
   - Si error: Salir indicando fallo
================================================================================= */
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'5. Cargar DimGeography', 
		@step_id=5, 
		@cmdexec_success_code=0, 
		@on_success_action=3, -- Ir al paso siguiente
		@on_success_step_id=0, 
		@on_fail_action=2,    -- Salir indicando error
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'SSIS', 
		@command=N'/ISSERVER "\"\SSISDB\NorthWind\NorthWindETL2\DimGeography.dtsx\"" /SERVER localhost /Par "\"$ServerOption::LOGGING_LEVEL(Int16)\"";1 /Par "\"$ServerOption::SYNCHRONIZED(Boolean)\"";True /CALLERINFO SQLAGENT /REPORTING E', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

/* ==============================================================================
   PASO 6: Cargar FactSales (Paso Final)
   - Si éxito (on_success_action = 1): Salir del trabajo indicando éxito
   - Si error (on_fail_action = 2): Salir del trabajo indicando fallo
================================================================================= */
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'6. Cargar FactSales', 
		@step_id=6, 
		@cmdexec_success_code=0, 
		@on_success_action=1, -- Salir del trabajo reportando ÉXITO
		@on_success_step_id=0, 
		@on_fail_action=2,    -- Salir indicando error
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'SSIS', 
		@command=N'/ISSERVER "\"\SSISDB\NorthWind\NorthWindETL2\FactSales.dtsx\"" /SERVER localhost /Par "\"$ServerOption::LOGGING_LEVEL(Int16)\"";1 /Par "\"$ServerOption::SYNCHRONIZED(Boolean)\"";True /CALLERINFO SQLAGENT /REPORTING E', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

-- Definir el paso inicial (Paso 1)
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

/* ==============================================================================
   PROGRAMACIÓN (SCHEDULE): Ejecución automática diaria a las 02:00:00 AM
================================================================================= */
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Diario a las 02:00 AM', 
		@enabled=1, 
		@freq_type=4,                  -- Diario
		@freq_interval=1,              -- Cada 1 día
		@freq_subday_type=1,           -- A una hora fija
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20261014, 
		@active_end_date=99991231, 
		@active_start_time=20000,      -- 02:00:00 AM
		@active_end_time=235959
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

-- Asignar el servidor local al Job
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

COMMIT TRANSACTION
PRINT '>> El Job [NorthWindETL_Job] ha sido creado exitosamente con sus 6 pasos y programacion.'
GOTO EndSave

QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
    PRINT '>> ERROR: Ocurrió un error al crear el Job. Transacción revertida.'
EndSave:
GO
