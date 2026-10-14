CREATE TABLE [dbo].[FactSales] (
    [OrderLineSK]        BIGINT          IDENTITY (1, 1) NOT NULL,
    [OrderID]            INT             NOT NULL,
    [OrderDateSK]        INT             NOT NULL,
    [RequiredDateSK]     INT             NOT NULL,
    [ShippedDateSK]      INT             NOT NULL,
    [CustomerSK]         INT             NOT NULL,
    [ProductSK]          INT             NOT NULL,
    [EmployeeSK]         INT             NOT NULL,
    [ShipperSK]          INT             NOT NULL,
    [GeographySK]        INT             NOT NULL,
    [SupplierSK]         INT             NOT NULL,
    [Quantity]           SMALLINT        NOT NULL,
    [UnitPrice]          DECIMAL (19, 4) NOT NULL,
    [Discount]           DECIMAL (9, 6)  NOT NULL,
    [GrossSalesAmount]   DECIMAL (19, 4) NOT NULL,
    [DiscountAmount]     DECIMAL (19, 4) NOT NULL,
    [NetSalesAmount]     DECIMAL (19, 4) NOT NULL,
    [FreightAllocated]   DECIMAL (19, 4) NOT NULL,
    CONSTRAINT [PK_FactSales] PRIMARY KEY CLUSTERED ([OrderLineSK] ASC),
    CONSTRAINT [FK_DimCustomer] FOREIGN KEY ([CustomerSK]) REFERENCES [dbo].[DimCustomer] ([CustomerSK]),
    CONSTRAINT [FK_DimDate_OrderDate] FOREIGN KEY ([OrderDateSK]) REFERENCES [dbo].[DimDate] ([DateSK]),
    CONSTRAINT [FK_DimDate_RequiredDate] FOREIGN KEY ([RequiredDateSK]) REFERENCES [dbo].[DimDate] ([DateSK]),
    CONSTRAINT [FK_DimDate_ShippedDate] FOREIGN KEY ([ShippedDateSK]) REFERENCES [dbo].[DimDate] ([DateSK]),
    CONSTRAINT [FK_DimGeography] FOREIGN KEY ([GeographySK]) REFERENCES [dbo].[DimGeography] ([GeographySK]),
    CONSTRAINT [FK_DimEmployee] FOREIGN KEY ([EmployeeSK]) REFERENCES [dbo].[DimEmployee] ([EmployeeSK]),
    CONSTRAINT [FK_DimProduct] FOREIGN KEY ([ProductSK]) REFERENCES [dbo].[DimProduct] ([ProductSK]),
    CONSTRAINT [FK_DimShipper] FOREIGN KEY ([ShipperSK]) REFERENCES [dbo].[DimShipper] ([ShipperSK]),
    CONSTRAINT [FK_DimSupplier] FOREIGN KEY ([SupplierSK]) REFERENCES [dbo].[DimSupplier] ([SupplierSK]),
    CONSTRAINT [UQ_FactSales_Order_Product] UNIQUE NONCLUSTERED ([OrderID] ASC, [ProductSK] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_FactSales_CustomerSK]
    ON [dbo].[FactSales]([CustomerSK] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_FactSales_ProductSK]
    ON [dbo].[FactSales]([ProductSK] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_FactSales_EmployeeSK]
    ON [dbo].[FactSales]([EmployeeSK] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_FactSales_ShipperSK]
    ON [dbo].[FactSales]([ShipperSK] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_FactSales_GeographySK]
    ON [dbo].[FactSales]([GeographySK] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_FactSales_SupplierSK]
    ON [dbo].[FactSales]([SupplierSK] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_FactSales_OrderDateSK]
    ON [dbo].[FactSales]([OrderDateSK] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_FactSales_RequiredDateSK]
    ON [dbo].[FactSales]([RequiredDateSK] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_FactSales_ShippedDateSK]
    ON [dbo].[FactSales]([ShippedDateSK] ASC);

