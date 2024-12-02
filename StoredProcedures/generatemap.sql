ALTER PROCEDURE generate(
	@game_id int,
	@map_id int,
	@map_size_x int,
	@map_size_y int
)
AS
DECLARE @x INT
DECLARE @y INT
DECLARE @count INT
DECLARE @randval FLOAT
DECLARE @tileID INT
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
			SET @tileID = (FLOOR(CONVERT(int, CURRENT_TIMESTAMP) / CONVERT(int,@randval*1000)) % @tile_type_count) + 1
			SET @Prev_type = @tileID
		END
	ELSE
		BEGIN
			SET @tileID = @Prev_type
		END

	INSERT INTO [dbo].[tile]
          ([PLAYER_CONTROL_ID]
           ,[OCCUPIED]
           ,[TILE_TYPE]
           ,[is_CITY]
           ,[CITY_ID])
			VALUES (
			0,
			0,
			@tileID,
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
			SCOPE_IDENTITY(),
			@x,
			@y
			)
	SET @count = @count + 1
END
