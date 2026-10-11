CREATE PROCEDURE [dbo].[DW_MergeDimDeliveryLocation]
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    IF EXISTS (SELECT [DeliveryLocationSK] FROM [staging].[deliverylocation] GROUP BY [DeliveryLocationSK] HAVING COUNT(*)>1)
        THROW 50002, 'Duplicate staging surrogate keys.', 1;
    UPDATE target
    SET [City] = s.[City],
        [Region] = s.[Region],
        [PostalCode] = s.[PostalCode],
        [Country] = s.[Country]
    FROM [dbo].[DimDeliveryLocation] AS target
    INNER JOIN [staging].[deliverylocation] AS s ON target.[DeliveryLocationSK]=s.[DeliveryLocationSK];
END;
GO
