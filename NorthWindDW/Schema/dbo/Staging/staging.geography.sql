CREATE TABLE [staging].[geography] (
    [GeographyKey] INT           NOT NULL,
    [City]         NVARCHAR (30) NULL,
    [Region]       NVARCHAR (30) NULL,
    [PostalCode]   NVARCHAR (20) NULL,
    [Country]      NVARCHAR (30) NULL
);
GO