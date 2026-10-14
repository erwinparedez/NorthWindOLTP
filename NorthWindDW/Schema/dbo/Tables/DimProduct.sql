CREATE TABLE [dbo].[DimProduct] (
    [ProductSK]       INT           IDENTITY (0, 1) NOT NULL,
    [ProductID]       INT           NULL,
    [ProductName]     NVARCHAR (80) NULL,
    [QuantityPerUnit] NVARCHAR (40) NULL,
    [Discontinued]    BIT           NULL,
    [CategoryID]      INT           NULL,
    [CategoryName]    NVARCHAR (15) NULL,
    CONSTRAINT [PK_DimProduct] PRIMARY KEY CLUSTERED ([ProductSK] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_DimProduct_ProductID]
    ON [dbo].[DimProduct]([ProductID] ASC) WHERE ([ProductID] IS NOT NULL);

