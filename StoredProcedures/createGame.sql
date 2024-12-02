ALTER PROCEDURE dbo.createGame 
	 @player_max_count int,
	 @gametype int,
	 @map_size_x int,
	 @map_size_y int
AS
DECLARE @map_id int
SET @map_id = FLOOR(RAND() * 2147483647)
	INSERT INTO [dbo].[games]
           ([MAP_ID]
           ,[PLAYERCOUNT]
           ,[GAMETYPE]
           ,[MAX_PLAYER_COUNT])
     VALUES(
		@map_id,
		0,
		@gametype,
		@player_max_count
	 )
DECLARE @game_id INT
SET @game_id = SCOPE_IDENTITY()

    EXEC dbo.generate @game_id,@map_id, @map_size_x,@map_size_y

