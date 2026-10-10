
CREATE VIEW [dbo].[Order Subtotals]
AS
SELECT
    od.OrderID,
    SUM(
        CONVERT(
            money,
            (od.UnitPrice * od.Quantity * (1 - od.Discount) / 100)
        ) * 100
    ) AS Subtotal
FROM dbo.OrderDetails AS od
GROUP BY od.OrderID;
GO