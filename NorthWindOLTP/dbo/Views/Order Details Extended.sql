
CREATE VIEW [dbo].[Order Details Extended]
AS
SELECT
    od.OrderID,
    od.ProductID,
    p.ProductName,
    od.UnitPrice,
    od.Quantity,
    od.Discount,
    CONVERT(
        money,
        (od.UnitPrice * od.Quantity * (1 - od.Discount) / 100)
    ) * 100 AS ExtendedPrice
FROM dbo.OrderDetails AS od
INNER JOIN dbo.Products AS p
    ON p.ProductID = od.ProductID;
GO