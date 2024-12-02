CREATE PROCEDURE dbo.AddPlayerToActiveGame
    @player_id int,
	@game_id int
AS

IF (SELECT CASE 
		WHEN games.PLAYERCOUNT < games.MAX_PLAYER_COUNT THEN 1
		ELSE 0
	END AS canInsert
	FROM dbo.games
	WHERE @game_id = games.GAME_ID) = 1
	BEGIN
		UPDATE player 
		set player.ACTIVE_GAME = @game_id
		WHERE PLAYER_ID = @player_id
	END
