CREATE PROCEDURE [dbo].[GetShipperChangesByRowVersion]
    @startRow BIGINT,
    @endRow BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    IF @startRow < 0 OR @endRow < @startRow
        THROW 50001, 'Invalid rowversion interval.', 1;
    SELECT s.ShipperID, s.CompanyName
    FROM dbo.Shippers AS s
    WHERE (s.[rowversion] > CONVERT(BINARY(8), @startRow) AND s.[rowversion] <= CONVERT(BINARY(8), @endRow));
END;
GO
