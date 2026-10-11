CREATE PROCEDURE [dbo].[GetDeliveryLocationChangesByRowVersion]
    @startRow BIGINT,
    @endRow BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    IF @startRow < 0 OR @endRow < @startRow
        THROW 50001, 'Invalid rowversion interval.', 1;
    SELECT DISTINCT o.ShipCity AS City, o.ShipRegion AS Region, o.ShipPostalCode AS PostalCode, o.ShipCountry AS Country
    FROM dbo.Orders AS o
    WHERE (o.[rowversion] > CONVERT(BINARY(8), @startRow) AND o.[rowversion] <= CONVERT(BINARY(8), @endRow));
END;
GO
