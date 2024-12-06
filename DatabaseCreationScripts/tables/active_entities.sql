USE [master]
GO

/****** Object:  Table [dbo].[active_entities]    Script Date: 12/5/2024 4:57:16 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[active_entities](
	[ENTITY_ID] [uniqueidentifier] NOT NULL,
	[TILE_ID] [uniqueidentifier] NOT NULL,
	[CURRENT_HP] [int] NOT NULL,
	[HAS_MOVED] [bit] NOT NULL,
	[HAS_USED_ABILITY] [bit] NOT NULL,
	[OWNER_ID] [int] NOT NULL,
	[UNIT_TYPE_ID] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ENTITY_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[active_entities] ADD  DEFAULT ((0)) FOR [HAS_MOVED]
GO

ALTER TABLE [dbo].[active_entities] ADD  DEFAULT ((0)) FOR [HAS_USED_ABILITY]
GO

ALTER TABLE [dbo].[active_entities]  WITH CHECK ADD  CONSTRAINT [FK_ActiveEntities_Player] FOREIGN KEY([OWNER_ID])
REFERENCES [dbo].[player] ([PLAYERID])
GO

ALTER TABLE [dbo].[active_entities] CHECK CONSTRAINT [FK_ActiveEntities_Player]
GO

ALTER TABLE [dbo].[active_entities]  WITH CHECK ADD  CONSTRAINT [FK_ActiveEntities_Tile] FOREIGN KEY([TILE_ID])
REFERENCES [dbo].[tile] ([TILE_ID])
GO

ALTER TABLE [dbo].[active_entities] CHECK CONSTRAINT [FK_ActiveEntities_Tile]
GO

ALTER TABLE [dbo].[active_entities]  WITH CHECK ADD  CONSTRAINT [FK_ActiveEntities_UnitType] FOREIGN KEY([UNIT_TYPE_ID])
REFERENCES [dbo].[unit_types] ([UNIT_TYPE_ID])
GO

ALTER TABLE [dbo].[active_entities] CHECK CONSTRAINT [FK_ActiveEntities_UnitType]
GO


