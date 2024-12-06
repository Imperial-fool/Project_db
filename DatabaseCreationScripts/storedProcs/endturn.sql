USE [master]
GO

/****** Object:  StoredProcedure [dbo].[endturn]    Script Date: 12/5/2024 5:00:02 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[endturn]
	@session_token UNIQUEIDENTIFIER
AS
BEGIN
	DECLARE @player_id int
	SET @player_id = (SELECT PLAYERID FROM PLAYERSESSIONS WHERE SESSIONID = @session_token)
	DECLARE @game_id INT = (SELECT ACTIVE_GAME FROM player WHERE PLAYERID = @player_id)

	DECLARE @validation_status INT;

    EXEC @validation_status = VALIDATESESSIONANDTURN @game_id, @player_id, @session_token;

    IF @validation_status != 0
    BEGIN
        RETURN
    END
	UPDATE games
	SET TURN = TURN +1 
	WHERE GAME_ID = @game_id

	EXEC NextPlayerTurn @game_id

END
GO


