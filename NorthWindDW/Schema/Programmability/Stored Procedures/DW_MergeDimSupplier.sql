CREATE PROCEDURE [dbo].[DW_MergeDimSupplier]
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    IF EXISTS (SELECT [SupplierSK] FROM [staging].[supplier] GROUP BY [SupplierSK] HAVING COUNT(*)>1)
        THROW 50002, 'Duplicate staging surrogate keys.', 1;
    UPDATE target
    SET [SupplierName] = s.[SupplierName],
        [SupplierCountry] = s.[SupplierCountry]
    FROM [dbo].[DimSupplier] AS target
        INNER JOIN [staging].[supplier] AS s ON target.[SupplierSK]=s.[SupplierSK];
END;
GO
