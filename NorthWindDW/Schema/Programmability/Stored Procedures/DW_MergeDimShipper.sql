CREATE PROCEDURE [dbo].[DW_MergeDimShipper]
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    IF EXISTS (SELECT [ShipperSK] FROM [staging].[shipper] GROUP BY [ShipperSK] HAVING COUNT(*)>1)
        THROW 50002, 'Duplicate staging surrogate keys.', 1;
    UPDATE target
    SET [CompanyName] = s.[CompanyName]
    FROM [dbo].[DimShipper] AS target
    INNER JOIN [staging].[shipper] AS s ON target.[ShipperSK]=s.[ShipperSK];
END;
GO
