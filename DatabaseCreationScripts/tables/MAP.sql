USE [master]
GO

/****** Object:  Table [dbo].[map]    Script Date: 12/5/2024 4:57:45 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[map](
	[MAP_ID] [uniqueidentifier] NOT NULL,
	[TILE_ID] [uniqueidentifier] NULL,
	[X] [int] NULL,
	[Y] [int] NULL
) ON [PRIMARY]
GO


