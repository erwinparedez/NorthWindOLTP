CREATE PROCEDURE [dbo].[DW_MergeDimEmployee]
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    IF EXISTS (SELECT [EmployeeSK] FROM [staging].[employee] GROUP BY [EmployeeSK] HAVING COUNT(*)>1)
        THROW 50002, 'Duplicate staging surrogate keys.', 1;
    UPDATE target
    SET [EmployeeName] = s.[EmployeeName],
        [Title] = s.[Title],
        [HireDate] = s.[HireDate],
        [ManagerEmployeeID] = s.[ManagerEmployeeID],
        [ManagerName] = s.[ManagerName],
        [City] = s.[City],
        [Region] = s.[Region],
        [Country] = s.[Country]
    FROM [dbo].[DimEmployee] AS target
    INNER JOIN [staging].[employee] AS s ON target.[EmployeeSK]=s.[EmployeeSK];
END;
GO
