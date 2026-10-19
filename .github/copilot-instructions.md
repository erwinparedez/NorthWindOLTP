# Copilot Instructions

## Directrices del proyecto
- El diseño dimensional objetivo del proyecto NorthWind debe ajustarse exactamente al diagrama proporcionado: una tabla central FactSales relacionada con DimGeography, DimEmployee, DimCustomer, DimSupplier, DimProduct, DimShipper y DimDate. FactSales contiene OrderLineSK, OrderID, OrderDateSK, RequiredDateSK, ShippedDateSK, CustomerSK, ProductSK, EmployeeSK, ShipperSK, GeographySK, SupplierSK, Quantity, UnitPrice, Discount, GrossSalesAmount, DiscountAmount, NetSalesAmount y FreightAllocated. No deben conservarse dimensiones o columnas heredadas que no aparezcan en este modelo.
- Para el ETL de NorthWind, se prefieren trabajos de SQL Server Agent separados y ejecutables manualmente, sin programaciones automáticas por defecto.