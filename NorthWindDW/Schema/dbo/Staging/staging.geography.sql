CREATE TABLE [staging].[deliverylocation] (
    [DeliveryLocationSK] INT           NOT NULL,
    [City]               NVARCHAR (30) NULL,
    [Region]             NVARCHAR (30) NULL,
    [PostalCode]         NVARCHAR (20) NULL,
    [Country]            NVARCHAR (30) NULL
);
GO