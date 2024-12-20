USE [master]
GO

/****** Object:  Table [dbo].[games]    Script Date: 12/5/2024 4:57:42 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[games](
	[GAME_ID] [int] IDENTITY(1,1) NOT NULL,
	[MAP_ID] [uniqueidentifier] NOT NULL,
	[PLAYERCOUNT] [int] NULL,
	[GAMETYPE] [int] NULL,
	[MAX_PLAYER_COUNT] [int] NULL,
	[TURN] [int] NULL,
	[CURRENT_PLAYER_TURN] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[GAME_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO


