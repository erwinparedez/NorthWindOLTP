CREATE TABLE [staging].[date_1]
(
    [DateSK]            [int]           NOT NULL,
    [FullDate]          [date]          NULL,
    [CalendarYear]      [smallint]      NULL,
    [CalendarQuarter]   [tinyint]       NULL,
    [MonthNumberOfYear] [tinyint]       NULL,
    [MonthName]         [nvarchar](20)  NULL,
    [DayNumberOfMonth]  [tinyint]       NULL,
    [DayNumberOfWeek]   [tinyint]       NULL,
    [IsWeekend]         [bit]           NULL,
    [DayNameOfWeek]     [nvarchar](20)  NULL,
    [DayNumberOfYear]   [smallint]      NULL,
    [WeekNumberOfYear]  [tinyint]       NULL,
    [CalendarSemester]  [tinyint]       NULL
);
GO