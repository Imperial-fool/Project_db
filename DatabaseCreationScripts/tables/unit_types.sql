USE [master]
GO

/****** Object:  Table [dbo].[unit_types]    Script Date: 12/5/2024 4:58:04 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[unit_types](
	[UNIT_TYPE_ID] [int] IDENTITY(1,1) NOT NULL,
	[NAME] [nvarchar](50) NOT NULL,
	[MAX_HP] [int] NOT NULL,
	[ATTACK_DAMAGE] [int] NOT NULL,
	[DEFENSE] [int] NOT NULL,
	[MOVEMENT_SPEED] [int] NOT NULL,
	[ABILITY_PROCEDURE] [nvarchar](128) NULL,
PRIMARY KEY CLUSTERED 
(
	[UNIT_TYPE_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO


