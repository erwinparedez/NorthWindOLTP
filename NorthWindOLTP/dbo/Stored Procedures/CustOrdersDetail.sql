
CREATE PROCEDURE [dbo].[CustOrdersDetail]
    @OrderID INT
AS
BEGIN
    SELECT
        p.ProductName,
        UnitPrice = ROUND(od.UnitPrice, 2),
        od.Quantity,
        Discount = CONVERT(INT, od.Discount * 100),
        ExtendedPrice = ROUND(
            CONVERT(
                MONEY,
                od.Quantity * (1 - od.Discount) * od.UnitPrice
            ),
            2
        )
    FROM dbo.OrderDetails AS od
    INNER JOIN dbo.Products AS p
        ON od.ProductID = p.ProductID
    WHERE od.OrderID = @OrderID;
END;