USE [master]
GO

/****** Object:  StoredProcedure [dbo].[createGame]    Script Date: 12/5/2024 4:59:58 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[createGame] 
	 @player_max_count int,
	 @gametype int,
	 @map_size_x int,
	 @map_size_y int,
	 @session_token UNIQUEIDENTIFIER
AS
DECLARE @validation_status INT;
DECLARE @player_id int
SET @player_id = (SELECT PLAYERID FROM PLAYERSESSIONS WHERE SESSIONID = @session_token)
    EXEC @validation_status = DBO.VALIDATESESSION @player_id, @session_token;

    IF @validation_status != 0
    BEGIN

        RETURN 1; 
    END;
DECLARE @map_id UNIQUEIDENTIFIER
SET @map_id = NEWID()
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
	EXEC AddPlayerToActiveGame @player_id, @game_id, @session_token

SELECT @game_id
GO


