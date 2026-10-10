
CREATE PROCEDURE [dbo].[CustOrderHist]
    @CustomerID NCHAR(5)
AS
BEGIN
    SELECT
        p.ProductName,
        Total = SUM(od.Quantity)
    FROM dbo.Products AS p
    INNER JOIN dbo.OrderDetails AS od
        ON od.ProductID = p.ProductID
    INNER JOIN dbo.Orders AS o
        ON o.OrderID = od.OrderID
    INNER JOIN dbo.Customers AS c
        ON c.CustomerID = o.CustomerID
    WHERE c.CustomerID = @CustomerID
    GROUP BY p.ProductName;
END;
GO