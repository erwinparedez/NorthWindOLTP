CREATE TABLE dbo.PackageConfig (
    TableName VARCHAR(50) NOT NULL,
    LastRowVersion BIGINT NOT NULL CONSTRAINT DF_PackageConfig_LastRowVersion DEFAULT (0),
    CONSTRAINT PK_PackageConfig PRIMARY KEY (TableName),
    CONSTRAINT CK_PackageConfig_LastRowVersion CHECK (LastRowVersion >= 0)
);
GO
