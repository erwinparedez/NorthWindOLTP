CREATE PROCEDURE [dbo].[GetEmployeeChangesByRowVersion]
    @startRow BIGINT,
    @endRow BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    IF @startRow < 0 OR @endRow < @startRow
        THROW 50001, 'Invalid rowversion interval.', 1;
    SELECT e.EmployeeID, CONCAT(e.FirstName, N' ', e.LastName) AS EmployeeName,
        e.Title, CONVERT(DATE,e.HireDate) AS HireDate,
        e.ReportsTo AS ManagerEmployeeID,
        CASE WHEN m.EmployeeID IS NULL THEN NULL ELSE CONCAT(m.FirstName,N' ',m.LastName) END AS ManagerName,
        e.City, e.Region, e.Country
    FROM dbo.Employees AS e LEFT JOIN dbo.Employees AS m ON m.EmployeeID=e.ReportsTo
    WHERE (e.[rowversion] > CONVERT(BINARY(8), @startRow) AND e.[rowversion] <= CONVERT(BINARY(8), @endRow)) OR (m.[rowversion] > CONVERT(BINARY(8), @startRow) AND m.[rowversion] <= CONVERT(BINARY(8), @endRow));
END;
GO
