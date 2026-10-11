CREATE TABLE [dbo].[DimShipper] (
    [ShipperSK]   INT           IDENTITY (0, 1) NOT NULL,
    [ShipperID]   INT           NULL,
    [CompanyName] NVARCHAR (80) NULL,
    CONSTRAINT [PK_DimShipper] PRIMARY KEY CLUSTERED ([ShipperSK] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_DimShipper_ShipperID]
    ON [dbo].[DimShipper]([ShipperID] ASC) WHERE ([ShipperID] IS NOT NULL);

