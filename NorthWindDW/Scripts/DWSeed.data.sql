SET NOCOUNT ON;

IF NOT EXISTS (SELECT 1 FROM dbo.DimDate WHERE DateSK = 0)
BEGIN
	INSERT INTO dbo.DimDate
		(DateSK, FullDate, CalendarYear, CalendarQuarter, MonthNumberOfYear, MonthName,
		 DayNumberOfMonth, DayNumberOfWeek, IsWeekend, DayNameOfWeek, DayNumberOfYear,
		 WeekNumberOfYear, CalendarSemester)
	VALUES
		(0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
END;

DECLARE @StartDate DATE = '19900101';
DECLARE @EndDate DATE = '20501231';

;WITH DateRange AS
(
	SELECT @StartDate AS FullDate
	UNION ALL
	SELECT DATEADD(DAY, 1, FullDate)
	FROM DateRange
	WHERE FullDate < @EndDate
)
INSERT INTO dbo.DimDate
	(DateSK, FullDate, CalendarYear, CalendarQuarter, MonthNumberOfYear, MonthName,
	 DayNumberOfMonth, DayNumberOfWeek, IsWeekend, DayNameOfWeek, DayNumberOfYear,
	 WeekNumberOfYear, CalendarSemester)
SELECT CONVERT(INT, CONVERT(CHAR(8), d.FullDate, 112)),
	   d.FullDate,
	   YEAR(d.FullDate),
	   DATEPART(QUARTER, d.FullDate),
	   MONTH(d.FullDate),
	   CASE MONTH(d.FullDate)
		   WHEN 1 THEN N'January' WHEN 2 THEN N'February' WHEN 3 THEN N'March'
		   WHEN 4 THEN N'April' WHEN 5 THEN N'May' WHEN 6 THEN N'June'
		   WHEN 7 THEN N'July' WHEN 8 THEN N'August' WHEN 9 THEN N'September'
		   WHEN 10 THEN N'October' WHEN 11 THEN N'November' WHEN 12 THEN N'December'
	   END,
	   DAY(d.FullDate),
	   v.DayNumberOfWeek,
	   CASE WHEN v.DayNumberOfWeek IN (6, 7) THEN 1 ELSE 0 END,
	   CASE v.DayNumberOfWeek
		   WHEN 1 THEN N'Monday' WHEN 2 THEN N'Tuesday' WHEN 3 THEN N'Wednesday'
		   WHEN 4 THEN N'Thursday' WHEN 5 THEN N'Friday' WHEN 6 THEN N'Saturday'
		   WHEN 7 THEN N'Sunday'
	   END,
	   DATEPART(DAYOFYEAR, d.FullDate),
	   DATEPART(ISO_WEEK, d.FullDate),
	   CASE WHEN MONTH(d.FullDate) <= 6 THEN 1 ELSE 2 END
FROM DateRange AS d
CROSS APPLY (SELECT (DATEDIFF(DAY, CONVERT(DATE, '19000101', 112), d.FullDate) % 7) + 1 AS DayNumberOfWeek) AS v
WHERE NOT EXISTS (SELECT 1 FROM dbo.DimDate AS existing WHERE existing.DateSK = CONVERT(INT, CONVERT(CHAR(8), d.FullDate, 112)))
OPTION (MAXRECURSION 0);

IF NOT EXISTS (SELECT 1 FROM dbo.DimCustomer WHERE CustomerSK = 0)
BEGIN
	SET IDENTITY_INSERT dbo.DimCustomer ON;
	INSERT INTO dbo.DimCustomer (CustomerSK, CustomerID, CompanyName, City, Region, PostalCode, Country)
	VALUES (0, NULL, NULL, NULL, NULL, NULL, NULL);
	SET IDENTITY_INSERT dbo.DimCustomer OFF;
END;

IF NOT EXISTS (SELECT 1 FROM dbo.DimDeliveryLocation WHERE DeliveryLocationSK = 0)
BEGIN
	SET IDENTITY_INSERT dbo.DimDeliveryLocation ON;
	INSERT INTO dbo.DimDeliveryLocation (DeliveryLocationSK, City, Region, PostalCode, Country)
	VALUES (0, NULL, NULL, NULL, NULL);
	SET IDENTITY_INSERT dbo.DimDeliveryLocation OFF;
END;

IF NOT EXISTS (SELECT 1 FROM dbo.DimEmployee WHERE EmployeeSK = 0)
BEGIN
	SET IDENTITY_INSERT dbo.DimEmployee ON;
	INSERT INTO dbo.DimEmployee
		(EmployeeSK, EmployeeID, EmployeeName, Title, HireDate, ManagerEmployeeID, ManagerName, City, Region, Country)
	VALUES (0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
	SET IDENTITY_INSERT dbo.DimEmployee OFF;
END;

IF NOT EXISTS (SELECT 1 FROM dbo.DimProduct WHERE ProductSK = 0)
BEGIN
	SET IDENTITY_INSERT dbo.DimProduct ON;
	INSERT INTO dbo.DimProduct
		(ProductSK, ProductID, ProductName, QuantityPerUnit, Discontinued, CategoryID, CategoryName, SupplierID, SupplierName, SupplierCountry)
	VALUES (0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
	SET IDENTITY_INSERT dbo.DimProduct OFF;
END;

IF NOT EXISTS (SELECT 1 FROM dbo.DimShipper WHERE ShipperSK = 0)
BEGIN
	SET IDENTITY_INSERT dbo.DimShipper ON;
	INSERT INTO dbo.DimShipper (ShipperSK, ShipperID, CompanyName)
	VALUES (0, NULL, NULL);
	SET IDENTITY_INSERT dbo.DimShipper OFF;
END;
GO
