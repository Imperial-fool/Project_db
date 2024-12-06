USE [master]
GO

/****** Object:  Table [dbo].[city]    Script Date: 12/5/2024 4:57:27 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[city](
	[CITY_ID] [uniqueidentifier] NULL,
	[TILE_ID] [uniqueidentifier] NULL,
	[CITY_NAME] [varchar](50) NULL,
	[PRODUCTION_PER_TURN] [int] NULL,
	[SCIENCE_PER_TURN] [int] NULL,
	[CITY_POP] [int] NULL,
	[CURRENT_BUILD] [int] NULL
) ON [PRIMARY]
GO


