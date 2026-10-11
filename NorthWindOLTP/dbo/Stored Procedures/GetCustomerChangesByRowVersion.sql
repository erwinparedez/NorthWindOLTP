CREATE PROCEDURE [dbo].[GetCustomerChangesByRowVersion]
    @startRow BIGINT,
    @endRow BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    IF @startRow < 0 OR @endRow < @startRow
        THROW 50001, 'Invalid rowversion interval.', 1;
    SELECT c.CustomerID, c.CompanyName, c.City, c.Region, c.PostalCode, c.Country
    FROM dbo.Customers AS c
    WHERE (c.[rowversion] > CONVERT(BINARY(8), @startRow) AND c.[rowversion] <= CONVERT(BINARY(8), @endRow));
END;
GO
