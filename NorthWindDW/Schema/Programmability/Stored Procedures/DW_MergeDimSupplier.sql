CREATE PROCEDURE [dbo].[DW_MergeDimSupplier]
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    IF EXISTS (SELECT [SupplierKey] FROM [staging].[supplier] GROUP BY [SupplierKey] HAVING COUNT(*)>1)
        THROW 50002, 'Duplicate staging surrogate keys.', 1;
    UPDATE target
    SET [SupplierName] = s.[SupplierName],
        [SupplierCountry] = s.[SupplierCountry]
    FROM [dbo].[DimSupplier] AS target
    INNER JOIN [staging].[supplier] AS s ON target.[SupplierKey]=s.[SupplierKey];
END;
GO
