CREATE TABLE [staging].[sales] (
    [OrderID]          INT             NOT NULL,
    [OrderDateSK]      INT             NOT NULL,
    [RequiredDateSK]   INT             NOT NULL,
    [ShippedDateSK]    INT             NOT NULL,
    [CustomerSK]       INT             NOT NULL,
    [ProductSK]        INT             NOT NULL,
    [EmployeeSK]       INT             NOT NULL,
    [ShipperSK]        INT             NOT NULL,
    [GeographyKey]     INT             NOT NULL,
    [SupplierKey]      INT             NOT NULL,
    [Quantity]         SMALLINT        NOT NULL,
    [UnitPrice]        DECIMAL (19, 4) NOT NULL,
    [Discount]         DECIMAL (9, 6)  NOT NULL,
    [GrossSalesAmount] DECIMAL (19, 4) NOT NULL,
    [DiscountAmount]   DECIMAL (19, 4) NOT NULL,
    [NetSalesAmount]   DECIMAL (19, 4) NOT NULL,
    [FreightAllocated] DECIMAL (19, 4) NOT NULL,
    CONSTRAINT [PK_staging_sales] PRIMARY KEY ([OrderID], [ProductSK])
);
GO
