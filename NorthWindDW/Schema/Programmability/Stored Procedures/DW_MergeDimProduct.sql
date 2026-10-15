CREATE PROCEDURE [dbo].[DW_MergeDimProduct]
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    IF EXISTS (SELECT [ProductSK] FROM [staging].[product] GROUP BY [ProductSK] HAVING COUNT(*)>1)
        THROW 50002, 'Duplicate staging surrogate keys.', 1;
    UPDATE target
    SET [ProductName] = s.[ProductName],
        [QuantityPerUnit] = s.[QuantityPerUnit],
        [Discontinued] = s.[Discontinued],
        [CategoryID] = s.[CategoryID],
        [CategoryName] = s.[CategoryName]
    FROM [dbo].[DimProduct] AS target
    INNER JOIN [staging].[product] AS s ON target.[ProductSK]=s.[ProductSK];
END;
GO
