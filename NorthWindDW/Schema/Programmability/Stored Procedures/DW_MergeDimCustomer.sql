CREATE PROCEDURE [dbo].[DW_MergeDimCustomer]
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    IF EXISTS (SELECT [CustomerSK] FROM [staging].[customer] GROUP BY [CustomerSK] HAVING COUNT(*)>1)
        THROW 50002, 'Duplicate staging surrogate keys.', 1;
    UPDATE target
    SET [CompanyName] = s.[CompanyName],
        [City] = s.[City],
        [Region] = s.[Region],
        [PostalCode] = s.[PostalCode],
        [Country] = s.[Country]
    FROM [dbo].[DimCustomer] AS target
    INNER JOIN [staging].[customer] AS s ON target.[CustomerSK]=s.[CustomerSK];
END;
GO
