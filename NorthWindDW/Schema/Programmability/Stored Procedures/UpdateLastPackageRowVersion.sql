CREATE PROCEDURE dbo.UpdateLastPackageRowVersion
    @tableName VARCHAR(50),
    @lastRowVersion BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    IF @lastRowVersion IS NULL OR @lastRowVersion < 0
        THROW 50004, 'Invalid rowversion.', 1;
    UPDATE dbo.PackageConfig SET LastRowVersion=@lastRowVersion
    WHERE TableName=@tableName AND LastRowVersion<=@lastRowVersion;
    IF @@ROWCOUNT=0
        THROW 50005, 'Unknown configuration or decreasing rowversion.', 1;
END;
GO
