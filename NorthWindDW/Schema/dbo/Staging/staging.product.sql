CREATE TABLE [staging].[product] (
    [ProductSK]       INT           NOT NULL,
    [ProductID]       INT           NULL,
    [ProductName]     NVARCHAR (80) NULL,
    [QuantityPerUnit] NVARCHAR (40) NULL,
    [Discontinued]    BIT           NULL,
    [CategoryID]      INT           NULL,
    [CategoryName]    NVARCHAR (15) NULL
);
GO