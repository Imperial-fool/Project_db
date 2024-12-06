USE [master]
GO

/****** Object:  StoredProcedure [dbo].[NextPlayerTurn]    Script Date: 12/5/2024 5:00:46 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[NextPlayerTurn]
	@game_id int
AS
DECLARE @next_turn int

SET @next_turn = (SELECT turn_order +1 
	FROM game_turns
	WHERE player_id = (SELECT CURRENT_PLAYER_TURN FROM games WHERE GAME_ID = @game_id))

	IF @next_turn > (SELECT MAX(turn_order) FROM GAME_TURNS WHERE GAME_ID = @game_id)
	BEGIN
		SET @next_turn = 1;
	END 
	
	UPDATE games
	SET CURRENT_PLAYER_TURN = (SELECT PLAYER_ID FROM GAME_TURNS WHERE TURN_ORDER = @next_turn AND GAME_ID = @game_id)
	WHERE GAME_ID = @game_id
	

GO


