CREATE PROCEDURE [dbo].[DW_MergeDimDeliveryLocation]
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    EXEC [dbo].[DW_MergeDimGeography];
END;
GO
