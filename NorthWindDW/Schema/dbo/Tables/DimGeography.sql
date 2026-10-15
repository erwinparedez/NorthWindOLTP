CREATE TABLE [dbo].[DimGeography] (
    [GeographySK]        INT           IDENTITY (0, 1) NOT NULL,
    [City]               NVARCHAR (30) NULL,
    [Region]             NVARCHAR (30) NULL,
    [PostalCode]         NVARCHAR (20) NULL,
    [Country]            NVARCHAR (30) NULL,
    CONSTRAINT [PK_DimGeography] PRIMARY KEY CLUSTERED ([GeographySK] ASC)
);
