SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER PROCEDURE dbo.RunNorthWindETL
	@tableName VARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	IF @tableName NOT IN ('Customer', 'Product', 'Employee', 'Shipper', 'Geography', 'Supplier', 'Sales')
		THROW 50014, 'Unknown NorthWind ETL package name.', 1;

	DECLARE @dbts TABLE (DBTS BIGINT NOT NULL);
	INSERT INTO @dbts EXEC [NorthWindOLTP].[dbo].[GetDatabaseRowVersion];

	DECLARE @highWater BIGINT;
	SELECT @highWater = MAX(DBTS) FROM @dbts;
	IF @highWater IS NULL OR @highWater < 0
		THROW 50010, 'Could not read the NorthWindOLTP rowversion watermark.', 1;

	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

	BEGIN TRY
		BEGIN TRANSACTION;

		IF EXISTS
		(
			SELECT required.TableName
			FROM (VALUES ('Customer'), ('Product'), ('Employee'), ('Shipper'), ('Geography'), ('Supplier'), ('Sales')) AS required(TableName)
			LEFT JOIN dbo.PackageConfig AS config ON config.TableName = required.TableName
			WHERE config.TableName IS NULL
		)
			THROW 50011, 'NorthWindDW PackageConfig is incomplete.', 1;

		DECLARE @startRow BIGINT;
		DECLARE @endRow BIGINT;

		SELECT @highWater = CASE WHEN MAX(LastRowVersion) > @highWater THEN MAX(LastRowVersion) ELSE @highWater END
		FROM dbo.PackageConfig;

		IF @tableName = 'Customer'
		BEGIN
		SELECT @startRow = LastRowVersion FROM dbo.PackageConfig WHERE TableName = 'Customer';
		SET @endRow = CASE WHEN @highWater < @startRow THEN @startRow ELSE @highWater END;
		DECLARE @customers TABLE
		(
			CustomerID NCHAR(5) NOT NULL, CompanyName NVARCHAR(40) NOT NULL,
			City NVARCHAR(15) NULL, Region NVARCHAR(15) NULL,
			PostalCode NVARCHAR(10) NULL, Country NVARCHAR(15) NULL
		);
		INSERT INTO @customers EXEC [NorthWindOLTP].[dbo].[GetCustomerChangesByRowVersion] @startRow, @endRow;
		TRUNCATE TABLE staging.customer;
		INSERT INTO dbo.DimCustomer (CustomerID, CompanyName, City, Region, PostalCode, Country)
		SELECT changes.CustomerID, changes.CompanyName, changes.City, changes.Region, changes.PostalCode, changes.Country
		FROM @customers AS changes
		WHERE NOT EXISTS (SELECT 1 FROM dbo.DimCustomer AS target WHERE target.CustomerID = changes.CustomerID);
		INSERT INTO staging.customer (CustomerSK, CustomerID, CompanyName, City, Region, PostalCode, Country)
		SELECT target.CustomerSK, changes.CustomerID, changes.CompanyName, changes.City, changes.Region, changes.PostalCode, changes.Country
		FROM @customers AS changes
		INNER JOIN dbo.DimCustomer AS target ON target.CustomerID = changes.CustomerID
		WHERE target.CustomerSK <> 0;
		EXEC dbo.DW_MergeDimCustomer;
		EXEC dbo.UpdateLastPackageRowVersion @tableName = 'Customer', @lastRowVersion = @endRow;
		END;

		IF @tableName = 'Product'
		BEGIN
		SELECT @startRow = LastRowVersion FROM dbo.PackageConfig WHERE TableName = 'Product';
		SET @endRow = CASE WHEN @highWater < @startRow THEN @startRow ELSE @highWater END;
		DECLARE @products TABLE
		(
			ProductID INT NOT NULL, ProductName NVARCHAR(40) NOT NULL,
			QuantityPerUnit NVARCHAR(20) NULL, Discontinued BIT NOT NULL,
			CategoryID INT NULL, CategoryName NVARCHAR(15) NULL,
			SupplierID INT NULL, SupplierName NVARCHAR(40) NULL, SupplierCountry NVARCHAR(15) NULL
		);
		INSERT INTO @products EXEC [NorthWindOLTP].[dbo].[GetProductChangesByRowVersion] @startRow, @endRow;
		TRUNCATE TABLE staging.product;
		INSERT INTO dbo.DimProduct
			(ProductID, ProductName, QuantityPerUnit, Discontinued, CategoryID, CategoryName)
		SELECT changes.ProductID, changes.ProductName, changes.QuantityPerUnit, changes.Discontinued,
			   changes.CategoryID, changes.CategoryName
		FROM @products AS changes
		WHERE NOT EXISTS (SELECT 1 FROM dbo.DimProduct AS target WHERE target.ProductID = changes.ProductID);
		INSERT INTO staging.product
			(ProductSK, ProductID, ProductName, QuantityPerUnit, Discontinued, CategoryID, CategoryName)
		SELECT target.ProductSK, changes.ProductID, changes.ProductName, changes.QuantityPerUnit, changes.Discontinued,
			   changes.CategoryID, changes.CategoryName
		FROM @products AS changes
		INNER JOIN dbo.DimProduct AS target ON target.ProductID = changes.ProductID
		WHERE target.ProductSK <> 0;
		EXEC dbo.DW_MergeDimProduct;
		EXEC dbo.UpdateLastPackageRowVersion @tableName = 'Product', @lastRowVersion = @endRow;
		END;

		IF @tableName = 'Supplier'
		BEGIN
		SELECT @startRow = LastRowVersion FROM dbo.PackageConfig WHERE TableName = 'Supplier';
		IF @startRow IS NULL SET @startRow = 0;
		SET @endRow = CASE WHEN @highWater < @startRow THEN @startRow ELSE @highWater END;
		DECLARE @suppliers TABLE
		(
			SupplierID INT NOT NULL, SupplierName NVARCHAR(40) NOT NULL, SupplierCountry NVARCHAR(15) NULL
		);
		INSERT INTO @suppliers
		SELECT s.SupplierID, s.CompanyName, s.Country
		FROM [NorthWindOLTP].[dbo].[Suppliers] AS s
		WHERE (s.[rowversion] > CONVERT(BINARY(8), @startRow) AND s.[rowversion] <= CONVERT(BINARY(8), @endRow));

		TRUNCATE TABLE staging.supplier;

		INSERT INTO dbo.DimSupplier (SupplierID, SupplierName, SupplierCountry)
		SELECT changes.SupplierID, changes.SupplierName, changes.SupplierCountry
		FROM @suppliers AS changes
		WHERE NOT EXISTS (SELECT 1 FROM dbo.DimSupplier AS target WHERE target.SupplierID = changes.SupplierID);

		INSERT INTO staging.supplier (SupplierSK, SupplierID, SupplierName, SupplierCountry)
		SELECT target.SupplierSK, changes.SupplierID, changes.SupplierName, changes.SupplierCountry
		FROM @suppliers AS changes
		INNER JOIN dbo.DimSupplier AS target ON target.SupplierID = changes.SupplierID
		WHERE target.SupplierSK <> 0;

		EXEC dbo.DW_MergeDimSupplier;
		EXEC dbo.UpdateLastPackageRowVersion @tableName = 'Supplier', @lastRowVersion = @endRow;
		END;

		IF @tableName = 'Employee'
		BEGIN
		SELECT @startRow = LastRowVersion FROM dbo.PackageConfig WHERE TableName = 'Employee';
		SET @endRow = CASE WHEN @highWater < @startRow THEN @startRow ELSE @highWater END;
		DECLARE @employees TABLE
		(
			EmployeeID INT NOT NULL, EmployeeName NVARCHAR(61) NOT NULL,
			Title NVARCHAR(30) NULL, HireDate DATE NULL, ManagerEmployeeID INT NULL,
			ManagerName NVARCHAR(61) NULL, City NVARCHAR(15) NULL,
			Region NVARCHAR(15) NULL, Country NVARCHAR(15) NULL
		);
		INSERT INTO @employees EXEC [NorthWindOLTP].[dbo].[GetEmployeeChangesByRowVersion] @startRow, @endRow;
		TRUNCATE TABLE staging.employee;
		INSERT INTO dbo.DimEmployee
			(EmployeeID, EmployeeName, Title, HireDate, ManagerEmployeeID, ManagerName, City, Region, Country)
		SELECT changes.EmployeeID, changes.EmployeeName, changes.Title, changes.HireDate,
			   changes.ManagerEmployeeID, changes.ManagerName, changes.City, changes.Region, changes.Country
		FROM @employees AS changes
		WHERE NOT EXISTS (SELECT 1 FROM dbo.DimEmployee AS target WHERE target.EmployeeID = changes.EmployeeID);
		INSERT INTO staging.employee
			(EmployeeSK, EmployeeID, EmployeeName, Title, HireDate, ManagerEmployeeID, ManagerName, City, Region, Country)
		SELECT target.EmployeeSK, changes.EmployeeID, changes.EmployeeName, changes.Title, changes.HireDate,
			   changes.ManagerEmployeeID, changes.ManagerName, changes.City, changes.Region, changes.Country
		FROM @employees AS changes
		INNER JOIN dbo.DimEmployee AS target ON target.EmployeeID = changes.EmployeeID
		WHERE target.EmployeeSK <> 0;
		EXEC dbo.DW_MergeDimEmployee;
		EXEC dbo.UpdateLastPackageRowVersion @tableName = 'Employee', @lastRowVersion = @endRow;
		END;

		IF @tableName = 'Shipper'
		BEGIN
		SELECT @startRow = LastRowVersion FROM dbo.PackageConfig WHERE TableName = 'Shipper';
		SET @endRow = CASE WHEN @highWater < @startRow THEN @startRow ELSE @highWater END;
		DECLARE @shippers TABLE (ShipperID INT NOT NULL, CompanyName NVARCHAR(40) NOT NULL);
		INSERT INTO @shippers EXEC [NorthWindOLTP].[dbo].[GetShipperChangesByRowVersion] @startRow, @endRow;
		TRUNCATE TABLE staging.shipper;
		INSERT INTO dbo.DimShipper (ShipperID, CompanyName)
		SELECT changes.ShipperID, changes.CompanyName
		FROM @shippers AS changes
		WHERE NOT EXISTS (SELECT 1 FROM dbo.DimShipper AS target WHERE target.ShipperID = changes.ShipperID);
		INSERT INTO staging.shipper (ShipperSK, ShipperID, CompanyName)
		SELECT target.ShipperSK, changes.ShipperID, changes.CompanyName
		FROM @shippers AS changes
		INNER JOIN dbo.DimShipper AS target ON target.ShipperID = changes.ShipperID
		WHERE target.ShipperSK <> 0;
		EXEC dbo.DW_MergeDimShipper;
		EXEC dbo.UpdateLastPackageRowVersion @tableName = 'Shipper', @lastRowVersion = @endRow;
		END;

		IF @tableName = 'Geography'
		BEGIN
		SELECT @startRow = LastRowVersion FROM dbo.PackageConfig WHERE TableName = 'Geography';
		SET @endRow = CASE WHEN @highWater < @startRow THEN @startRow ELSE @highWater END;
		DECLARE @locations TABLE
		(
			City NVARCHAR(15) NULL, Region NVARCHAR(15) NULL,
			PostalCode NVARCHAR(10) NULL, Country NVARCHAR(15) NULL
		);
		INSERT INTO @locations EXEC [NorthWindOLTP].[dbo].[GetGeographyChangesByRowVersion] @startRow, @endRow;
		TRUNCATE TABLE staging.geography;
		INSERT INTO dbo.DimGeography (City, Region, PostalCode, Country)
		SELECT DISTINCT changes.City, changes.Region, changes.PostalCode, changes.Country
		FROM @locations AS changes
		WHERE NOT EXISTS
		(
			SELECT 1 FROM dbo.DimGeography AS target
			WHERE (target.City = changes.City OR (target.City IS NULL AND changes.City IS NULL))
			  AND (target.Region = changes.Region OR (target.Region IS NULL AND changes.Region IS NULL))
			  AND (target.PostalCode = changes.PostalCode OR (target.PostalCode IS NULL AND changes.PostalCode IS NULL))
			  AND (target.Country = changes.Country OR (target.Country IS NULL AND changes.Country IS NULL))
		);
		INSERT INTO staging.geography (GeographySK, City, Region, PostalCode, Country)
		SELECT target.GeographySK, changes.City, changes.Region, changes.PostalCode, changes.Country
		FROM @locations AS changes
		INNER JOIN dbo.DimGeography AS target
			ON (target.City = changes.City OR (target.City IS NULL AND changes.City IS NULL))
		   AND (target.Region = changes.Region OR (target.Region IS NULL AND changes.Region IS NULL))
		   AND (target.PostalCode = changes.PostalCode OR (target.PostalCode IS NULL AND changes.PostalCode IS NULL))
		   AND (target.Country = changes.Country OR (target.Country IS NULL AND changes.Country IS NULL))
		WHERE target.GeographySK <> 0;
		EXEC dbo.DW_MergeDimGeography;
		EXEC dbo.UpdateLastPackageRowVersion @tableName = @tableName, @lastRowVersion = @endRow;
		END;

		IF @tableName = 'Sales'
		BEGIN
		SELECT @startRow = LastRowVersion FROM dbo.PackageConfig WHERE TableName = 'Sales';
		SET @endRow = CASE WHEN @highWater < @startRow THEN @startRow ELSE @highWater END;
		DECLARE @sales TABLE
		(
			OrderID INT NOT NULL, ProductID INT NOT NULL,
			CustomerID NCHAR(5) NULL, EmployeeID INT NULL, ShipperID INT NULL,
			OrderDateSK INT NOT NULL, RequiredDateSK INT NOT NULL, ShippedDateSK INT NOT NULL,
			OrderDate DATE NULL, RequiredDate DATE NULL, ShippedDate DATE NULL,
			City NVARCHAR(15) NULL, Region NVARCHAR(15) NULL,
			PostalCode NVARCHAR(10) NULL, Country NVARCHAR(15) NULL,
			Quantity SMALLINT NOT NULL, UnitPrice DECIMAL(19,4) NOT NULL,
			Discount DECIMAL(9,6) NOT NULL, GrossSalesAmount DECIMAL(19,4) NOT NULL,
			DiscountAmount DECIMAL(19,4) NOT NULL, NetSalesAmount DECIMAL(19,4) NOT NULL,
			FreightAllocated DECIMAL(19,4) NOT NULL
		);
		INSERT INTO @sales EXEC [NorthWindOLTP].[dbo].[GetSalesChangesByRowVersion] @startRow, @endRow;
		TRUNCATE TABLE staging.sales;

		IF EXISTS
		(
			SELECT 1 FROM @sales AS changes
			LEFT JOIN dbo.DimProduct AS product ON product.ProductID = changes.ProductID
			WHERE product.ProductSK IS NULL
		)
			THROW 50012, 'A sales row references a product that is not loaded in DimProduct.', 1;

		IF EXISTS
		(
			SELECT 1 FROM @sales AS changes
			WHERE (changes.OrderDate IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.DimDate AS d WHERE d.FullDate = changes.OrderDate))
			   OR (changes.RequiredDate IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.DimDate AS d WHERE d.FullDate = changes.RequiredDate))
			   OR (changes.ShippedDate IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.DimDate AS d WHERE d.FullDate = changes.ShippedDate))
		)
			THROW 50013, 'A sales date is outside the seeded DimDate range.', 1;

		INSERT INTO staging.sales
			(OrderID, OrderDateSK, RequiredDateSK, ShippedDateSK, CustomerSK, ProductSK,
				 EmployeeSK, ShipperSK, GeographySK, SupplierSK, Quantity, UnitPrice, Discount,
			 GrossSalesAmount, DiscountAmount, NetSalesAmount, FreightAllocated)
		SELECT changes.OrderID,
			   COALESCE(changes.OrderDateSK, orderDate.DateSK, 0),
			   COALESCE(changes.RequiredDateSK, requiredDate.DateSK, 0),
			   COALESCE(changes.ShippedDateSK, shippedDate.DateSK, 0),
			   COALESCE(customer.CustomerSK, 0), product.ProductSK,
			   COALESCE(employee.EmployeeSK, 0), COALESCE(shipper.ShipperSK, 0),
			   COALESCE(location.GeographySK, 0), COALESCE(supplier.SupplierSK, 0),
			   changes.Quantity, changes.UnitPrice, changes.Discount, changes.GrossSalesAmount,
			   changes.DiscountAmount, changes.NetSalesAmount, changes.FreightAllocated
		FROM @sales AS changes
		LEFT JOIN dbo.DimCustomer AS customer ON customer.CustomerID = changes.CustomerID
		INNER JOIN dbo.DimProduct AS product ON product.ProductID = changes.ProductID
		LEFT JOIN [NorthWindOLTP].[dbo].[Products] AS oltpProduct ON oltpProduct.ProductID = changes.ProductID
		LEFT JOIN dbo.DimSupplier AS supplier ON supplier.SupplierID = oltpProduct.SupplierID
		LEFT JOIN dbo.DimEmployee AS employee ON employee.EmployeeID = changes.EmployeeID
		LEFT JOIN dbo.DimShipper AS shipper ON shipper.ShipperID = changes.ShipperID
		LEFT JOIN dbo.DimDate AS orderDate ON orderDate.FullDate = changes.OrderDate
		LEFT JOIN dbo.DimDate AS requiredDate ON requiredDate.FullDate = changes.RequiredDate
		LEFT JOIN dbo.DimDate AS shippedDate ON shippedDate.FullDate = changes.ShippedDate
		OUTER APPLY
		(
			SELECT TOP (1) target.GeographySK
			FROM dbo.DimGeography AS target
			WHERE (target.City = changes.City OR (target.City IS NULL AND changes.City IS NULL))
			  AND (target.Region = changes.Region OR (target.Region IS NULL AND changes.Region IS NULL))
			  AND (target.PostalCode = changes.PostalCode OR (target.PostalCode IS NULL AND changes.PostalCode IS NULL))
			  AND (target.Country = changes.Country OR (target.Country IS NULL AND changes.Country IS NULL))
			ORDER BY target.GeographySK
		) AS location;

		INSERT INTO dbo.FactSales
			(OrderID, OrderDateSK, RequiredDateSK, ShippedDateSK, CustomerSK, ProductSK,
				 EmployeeSK, ShipperSK, GeographySK, SupplierSK, Quantity, UnitPrice, Discount,
			 GrossSalesAmount, DiscountAmount, NetSalesAmount, FreightAllocated)
		SELECT staging.OrderID, staging.OrderDateSK, staging.RequiredDateSK, staging.ShippedDateSK,
			   staging.CustomerSK, staging.ProductSK, staging.EmployeeSK, staging.ShipperSK,
			   staging.GeographySK, staging.SupplierSK, staging.Quantity, staging.UnitPrice, staging.Discount,
			   staging.GrossSalesAmount, staging.DiscountAmount, staging.NetSalesAmount, staging.FreightAllocated
		FROM staging.sales AS staging
		WHERE NOT EXISTS
		(
			SELECT 1 FROM dbo.FactSales AS target
			WHERE target.OrderID = staging.OrderID AND target.ProductSK = staging.ProductSK
		);
		EXEC dbo.DW_MergeFactSales;
		EXEC dbo.UpdateLastPackageRowVersion @tableName = 'Sales', @lastRowVersion = @endRow;
		END;

		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
		THROW;
	END CATCH;
END;
GO
