USE [master]
GO

/****** Object:  Table [dbo].[player]    Script Date: 12/5/2024 4:57:49 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[player](
	[PLAYERID] [int] IDENTITY(1,1) NOT NULL,
	[PLAYERNAME] [varchar](25) NOT NULL,
	[ACTIVE_GAME] [int] NULL,
	[HASH] [binary](32) NOT NULL,
 CONSTRAINT [PK_player] PRIMARY KEY CLUSTERED 
(
	[PLAYERID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO


