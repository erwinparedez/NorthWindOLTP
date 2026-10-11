CREATE TABLE [dbo].[DimDate] (
    [DateSK]            INT           NOT NULL,
    [FullDate]          DATE          NULL,
    [CalendarYear]      SMALLINT      NULL,
    [CalendarQuarter]   TINYINT       NULL,
    [MonthNumberOfYear] TINYINT       NULL,
    [MonthName]         NVARCHAR (20) NULL,
    [DayNumberOfMonth]  TINYINT       NULL,
    [DayNumberOfWeek]   TINYINT       NULL,
    [IsWeekend]         BIT           NULL,
    [DayNameOfWeek]     NVARCHAR (20) NULL,
    [DayNumberOfYear]   SMALLINT      NULL,
    [WeekNumberOfYear]  TINYINT       NULL,
    [CalendarSemester]  TINYINT       NULL,
    CONSTRAINT [PK_DimDate] PRIMARY KEY CLUSTERED ([DateSK] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_DimDate_FullDate]
    ON [dbo].[DimDate]([FullDate] ASC) WHERE ([FullDate] IS NOT NULL);

