
CREATE PROCEDURE [dbo].[SalesByCategory]
    @CategoryName NVARCHAR(15),
    @OrdYear NVARCHAR(4) = '1998'
AS
BEGIN
    IF @OrdYear NOT IN ('1996', '1997', '1998')
    BEGIN
        SET @OrdYear = '1998';
    END;

    SELECT
        p.ProductName,
        TotalPurchase = ROUND(
            SUM(
                CONVERT(
                    DECIMAL(14, 2),
                    od.Quantity * (1 - od.Discount) * od.UnitPrice
                )
            ),
            0
        )
    FROM dbo.OrderDetails AS od
    INNER JOIN dbo.Orders AS o
        ON od.OrderID = o.OrderID
    INNER JOIN dbo.Products AS p
        ON od.ProductID = p.ProductID
    INNER JOIN dbo.Categories AS c
        ON p.CategoryID = c.CategoryID
    WHERE c.CategoryName = @CategoryName
      AND SUBSTRING(
            CONVERT(NVARCHAR(22), o.OrderDate, 111),
            1,
            4
          ) = @OrdYear
    GROUP BY p.ProductName
    ORDER BY p.ProductName;
END;