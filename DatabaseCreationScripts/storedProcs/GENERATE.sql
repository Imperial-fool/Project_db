USE [master]
GO

/****** Object:  StoredProcedure [dbo].[GENERATE]    Script Date: 12/5/2024 5:00:20 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[GENERATE](
	@game_id INT,
	@map_id UNIQUEIDENTIFIER,
	@map_size_x int,
	@map_size_y int
)
AS
DECLARE @x INT
DECLARE @y INT
DECLARE @count INT
DECLARE @randval FLOAT
DECLARE @tileTYPEID INT
DECLARE @tile_type_count INT
DECLARE @Prev_type INT

SET @tile_type_count = (SELECT COUNT(*) FROM tile_type)
SET @Prev_type = 1
SET @count = 0

WHILE @count < (@map_size_x * @map_size_y)
BEGIN
	
	SET @x = @count / @map_size_x
	SET @y = @count % @map_size_x
	SET @randval = RAND(CHECKSUM(NEWID()))
	Insert into dbo.DebugVal (RandVal) Values (@randval)
	IF @randval > 0.5
		BEGIN
			SET @tileTYPEID = (FLOOR(CONVERT(int, CURRENT_TIMESTAMP) / CONVERT(int,@randval*1000)) % @tile_type_count) + 1
			SET @Prev_type = @tileTYPEID
		END
	ELSE
		BEGIN
			SET @tileTYPEID = @Prev_type
		END
	DECLARE @newtileid UNIQUEIDENTIFIER = NEWID()
	INSERT INTO [dbo].[tile]
          (TILE_ID
		  ,[PLAYER_CONTROL_ID]
           ,[OCCUPIED]
           ,[TILE_TYPE]
           ,[is_CITY]
           ,[CITY_ID])
			VALUES (
			@newtileid,
			0,
			null,
			@tileTYPEID,
			0,
			0
			)

	INSERT INTO [dbo].[map]
           ([MAP_ID]
           ,[TILE_ID]
           ,[X]
           ,[Y])
		VALUES(
			@map_id,
			@newtileid,
			@x,
			@y
			)
	SET @count = @count + 1
END
GO


