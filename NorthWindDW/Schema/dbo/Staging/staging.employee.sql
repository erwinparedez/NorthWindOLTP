CREATE TABLE [staging].[employee] (
    [EmployeeSK]        INT           NOT NULL,
    [EmployeeID]        INT           NULL,
    [EmployeeName]      NVARCHAR (61) NULL,
    [Title]             NVARCHAR (60) NULL,
    [HireDate]          DATE          NULL,
    [ManagerEmployeeID] INT           NULL,
    [ManagerName]       NVARCHAR (61) NULL,
    [City]              NVARCHAR (30) NULL,
    [Region]            NVARCHAR (30) NULL,
    [Country]           NVARCHAR (30) NULL
);
GO