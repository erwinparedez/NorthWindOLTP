CREATE TABLE [dbo].[DimCustomer] (
    [CustomerSK]  INT           IDENTITY (0, 1) NOT NULL,
    [CustomerID]  NVARCHAR (10) NULL,
    [CompanyName] NVARCHAR (80) NULL,
    [City]        NVARCHAR (30) NULL,
    [Region]      NVARCHAR (30) NULL,
    [PostalCode]  NVARCHAR (20) NULL,
    [Country]     NVARCHAR (30) NULL,
    CONSTRAINT [PK_DimCustomer] PRIMARY KEY CLUSTERED ([CustomerSK] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_DimCustomer_CustomerID]
    ON [dbo].[DimCustomer]([CustomerID] ASC) WHERE ([CustomerID] IS NOT NULL);

