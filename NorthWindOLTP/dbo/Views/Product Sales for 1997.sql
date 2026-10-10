
CREATE VIEW [dbo].[Product Sales for 1997]
AS
SELECT
    c.CategoryName,
    p.ProductName,
    SUM(
        CONVERT(
            money,
            (od.UnitPrice * od.Quantity * (1 - od.Discount) / 100)
        ) * 100
    ) AS ProductSales
FROM dbo.Categories AS c
INNER JOIN dbo.Products AS p
    ON p.CategoryID = c.CategoryID
INNER JOIN dbo.Orders AS o
    ON o.OrderID IN (
        SELECT od2.OrderID
        FROM dbo.OrderDetails AS od2
        WHERE od2.ProductID = p.ProductID
    )
INNER JOIN dbo.OrderDetails AS od
    ON od.OrderID = o.OrderID
    AND od.ProductID = p.ProductID
WHERE o.ShippedDate >= '19970101'
  AND o.ShippedDate < '19980101'
GROUP BY
    c.CategoryName,
    p.ProductName;
GO