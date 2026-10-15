CREATE TABLE [dbo].[DimGeography] (
    [GeographyKey]       INT           IDENTITY (0, 1) NOT NULL,
    [City]               NVARCHAR (30) NULL,
    [Region]             NVARCHAR (30) NULL,
    [PostalCode]         NVARCHAR (20) NULL,
    [Country]            NVARCHAR (30) NULL,
    [GeographySK]        AS [GeographyKey],
    [DeliveryLocationSK] AS [GeographyKey],
    CONSTRAINT [PK_DimGeography] PRIMARY KEY CLUSTERED ([GeographyKey] ASC)
);
