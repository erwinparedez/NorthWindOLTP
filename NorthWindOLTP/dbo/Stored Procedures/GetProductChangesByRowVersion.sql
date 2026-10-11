CREATE PROCEDURE [dbo].[GetProductChangesByRowVersion]
    @startRow BIGINT,
    @endRow BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    IF @startRow < 0 OR @endRow < @startRow
        THROW 50001, 'Invalid rowversion interval.', 1;
    SELECT p.ProductID, p.ProductName, p.QuantityPerUnit, p.Discontinued,
        p.CategoryID, c.CategoryName, p.SupplierID,
        s.CompanyName AS SupplierName, s.Country AS SupplierCountry
    FROM dbo.Products AS p LEFT JOIN dbo.Categories AS c ON c.CategoryID=p.CategoryID LEFT JOIN dbo.Suppliers AS s ON s.SupplierID=p.SupplierID
    WHERE (p.[rowversion] > CONVERT(BINARY(8), @startRow) AND p.[rowversion] <= CONVERT(BINARY(8), @endRow)) OR (c.[rowversion] > CONVERT(BINARY(8), @startRow) AND c.[rowversion] <= CONVERT(BINARY(8), @endRow)) OR (s.[rowversion] > CONVERT(BINARY(8), @startRow) AND s.[rowversion] <= CONVERT(BINARY(8), @endRow));
END;
GO
