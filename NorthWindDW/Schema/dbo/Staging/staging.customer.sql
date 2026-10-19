CREATE TABLE [staging].[customer] (
    [CustomerSK]  INT           NOT NULL,
    [CustomerID]  NVARCHAR (10) NULL,
    [CompanyName] NVARCHAR (80) NULL,
    [City]        NVARCHAR (30) NULL,
    [Region]      NVARCHAR (30) NULL,
    [PostalCode]  NVARCHAR (20) NULL,
    [Country]     NVARCHAR (30) NULL
);
GO