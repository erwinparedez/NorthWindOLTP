CREATE PROCEDURE dbo.GetLastPackageRowVersion
    @tableName VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM dbo.PackageConfig WHERE TableName=@tableName)
        THROW 50003, 'Unknown load configuration.', 1;
    SELECT LastRowVersion FROM dbo.PackageConfig WHERE TableName=@tableName;
END;
GO
