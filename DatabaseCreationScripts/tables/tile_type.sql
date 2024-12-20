USE [master]
GO

/****** Object:  Table [dbo].[tile_type]    Script Date: 12/5/2024 4:58:00 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[tile_type](
	[TILE_TYPE_ID] [int] IDENTITY(1,1) NOT NULL,
	[TILE_NAME] [varchar](50) NULL,
	[TILE_DIFF] [int] NULL,
	[WOOD_PER_TURN] [int] NULL,
	[FOOD_PER_TURN] [int] NULL,
	[STONE_PER_TURN] [int] NULL,
	[IRON_PER_TURN] [int] NULL,
	[is_CITY] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[TILE_TYPE_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO


