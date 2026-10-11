CREATE TABLE [dbo].[DimEmployee] (
    [EmployeeSK]        INT           IDENTITY (0, 1) NOT NULL,
    [EmployeeID]        INT           NULL,
    [EmployeeName]      NVARCHAR (61) NULL,
    [Title]             NVARCHAR (60) NULL,
    [HireDate]          DATE          NULL,
    [ManagerEmployeeID] INT           NULL,
    [ManagerName]       NVARCHAR (61) NULL,
    [City]              NVARCHAR (30) NULL,
    [Region]            NVARCHAR (30) NULL,
    [Country]           NVARCHAR (30) NULL,
    CONSTRAINT [PK_DimEmployee] PRIMARY KEY CLUSTERED ([EmployeeSK] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_DimEmployee_EmployeeID]
    ON [dbo].[DimEmployee]([EmployeeID] ASC) WHERE ([EmployeeID] IS NOT NULL);

