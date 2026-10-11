CREATE PROCEDURE [dbo].[DW_MergeFactSales]
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    UPDATE target
    SET [OrderDateSK] = s.[OrderDateSK],
        [RequiredDateSK] = s.[RequiredDateSK],
        [ShippedDateSK] = s.[ShippedDateSK],
        [CustomerSK] = s.[CustomerSK],
        [EmployeeSK] = s.[EmployeeSK],
        [ShipperSK] = s.[ShipperSK],
        [DeliveryLocationSK] = s.[DeliveryLocationSK],
        [Quantity] = s.[Quantity],
        [UnitPrice] = s.[UnitPrice],
        [Discount] = s.[Discount],
        [GrossSalesAmount] = s.[GrossSalesAmount],
        [DiscountAmount] = s.[DiscountAmount],
        [NetSalesAmount] = s.[NetSalesAmount],
        [FreightAllocated] = s.[FreightAllocated]
    FROM dbo.FactSales AS target
    INNER JOIN staging.sales AS s ON target.OrderID=s.OrderID AND target.ProductSK=s.ProductSK;
END;
GO
