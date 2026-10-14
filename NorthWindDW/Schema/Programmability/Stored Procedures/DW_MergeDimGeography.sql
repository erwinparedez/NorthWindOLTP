CREATE PROCEDURE [dbo].[DW_MergeDimGeography]
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    IF EXISTS (SELECT [GeographySK] FROM [staging].[geography] GROUP BY [GeographySK] HAVING COUNT(*)>1)
        THROW 50002, 'Duplicate staging surrogate keys.', 1;
    UPDATE target
    SET [City] = s.[City],
        [Region] = s.[Region],
        [PostalCode] = s.[PostalCode],
        [Country] = s.[Country]
    FROM [dbo].[DimGeography] AS target
    INNER JOIN [staging].[geography] AS s ON target.[GeographySK]=s.[GeographySK];
END;
GO
