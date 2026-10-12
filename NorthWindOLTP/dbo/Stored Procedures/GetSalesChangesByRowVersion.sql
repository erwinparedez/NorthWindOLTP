CREATE PROCEDURE [dbo].[GetSalesChangesByRowVersion]
    @startRow BIGINT,
    @endRow BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    IF @startRow < 0 OR @endRow < @startRow
        THROW 50001, 'Invalid rowversion interval.', 1;
    SELECT o.OrderID, d.ProductID, o.CustomerID, o.EmployeeID, o.ShipVia AS ShipperID,
        CONVERT(INT, CONVERT(VARCHAR(8), o.OrderDate, 112)) AS OrderDateSK,
        CASE WHEN o.RequiredDate IS NULL THEN 0 ELSE CONVERT(INT, CONVERT(VARCHAR(8), o.RequiredDate, 112)) END AS RequiredDateSK,
        CASE WHEN o.ShippedDate IS NULL THEN 0 ELSE CONVERT(INT, CONVERT(VARCHAR(8), o.ShippedDate, 112)) END AS ShippedDateSK,
        CONVERT(DATE,o.OrderDate) AS OrderDate,
        CONVERT(DATE,o.RequiredDate) AS RequiredDate,
        CONVERT(DATE,o.ShippedDate) AS ShippedDate,
        o.ShipCity AS City, o.ShipRegion AS Region,
        o.ShipPostalCode AS PostalCode, o.ShipCountry AS Country,
        d.Quantity, CONVERT(DECIMAL(19,4),d.UnitPrice) AS UnitPrice,
        amounts.Discount,
        amounts.GrossSalesAmount,
        CONVERT(DECIMAL(19,4),amounts.GrossSalesAmount*amounts.Discount) AS DiscountAmount,
        CONVERT(DECIMAL(19,4),amounts.GrossSalesAmount*(1-amounts.Discount)) AS NetSalesAmount,
        CONVERT(DECIMAL(19,4),COALESCE(o.Freight,0)/NULLIF(totals.LineCount,0)) AS FreightAllocated
    FROM dbo.Orders AS o
    INNER JOIN dbo.OrderDetails AS d ON d.OrderID=o.OrderID
    CROSS APPLY (SELECT COUNT(*) AS LineCount FROM dbo.OrderDetails AS allLines WHERE allLines.OrderID=o.OrderID) AS totals
    CROSS APPLY (SELECT CONVERT(DECIMAL(9,6),d.Discount) AS Discount,
        CONVERT(DECIMAL(19,4),d.UnitPrice*d.Quantity) AS GrossSalesAmount) AS amounts
    WHERE (o.[rowversion] > CONVERT(BINARY(8), @startRow) AND o.[rowversion] <= CONVERT(BINARY(8), @endRow)) OR EXISTS (SELECT 1 FROM dbo.OrderDetails AS changed WHERE changed.OrderID=o.OrderID AND (changed.[rowversion] > CONVERT(BINARY(8), @startRow) AND changed.[rowversion] <= CONVERT(BINARY(8), @endRow)));
END;
GO
