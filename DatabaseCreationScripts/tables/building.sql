USE [master]
GO

/****** Object:  Table [dbo].[building]    Script Date: 12/5/2024 4:57:22 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[building](
	[BUILDING_ID] [int] IDENTITY(1,1) NOT NULL,
	[BUILDING_NAME] [varchar](50) NULL,
	[CITY_ID] [int] NULL,
	[MODIFIER_TYPE] [bit] NULL,
	[MODIFIER] [varchar](10) NULL,
	[MODIFIER_AMOUNT] [int] NULL,
	[WOOD_COST] [int] NULL,
	[IRON_COST] [int] NULL,
	[STONE_COST] [int] NULL,
	[PRODUCTION_COST] [int] NULL
) ON [PRIMARY]
GO


