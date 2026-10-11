INSERT INTO dbo.PackageConfig (TableName,LastRowVersion)
SELECT names.TableName,0
FROM (VALUES ('Customer'),('Product'),('Employee'),('Shipper'),('DeliveryLocation'),('Sales')) AS names(TableName)
WHERE NOT EXISTS (SELECT 1 FROM dbo.PackageConfig AS c WHERE c.TableName=names.TableName);
GO
