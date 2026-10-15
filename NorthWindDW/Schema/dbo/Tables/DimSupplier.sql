CREATE TABLE [dbo].[DimSupplier] (
    [SupplierKey]     INT           IDENTITY (0, 1) NOT NULL,
    [SupplierID]      INT           NULL,
    [SupplierName]    NVARCHAR (80) NULL,
    [SupplierCountry] NVARCHAR (30) NULL,
    [SupplierSK]      AS [SupplierKey],
    CONSTRAINT [PK_DimSupplier] PRIMARY KEY CLUSTERED ([SupplierKey] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_DimSupplier_SupplierID]
    ON [dbo].[DimSupplier]([SupplierID] ASC) WHERE ([SupplierID] IS NOT NULL);
