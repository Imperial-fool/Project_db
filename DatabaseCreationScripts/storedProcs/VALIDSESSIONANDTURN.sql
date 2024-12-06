USE [master]
GO

/****** Object:  StoredProcedure [dbo].[VALIDATESESSIONANDTURN]    Script Date: 12/5/2024 5:01:00 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[VALIDATESESSIONANDTURN]
	@gameid int,
	@playerid int,
	@session_token UNIQUEIDENTIFIER
AS
BEGIN
	IF NOT EXISTS (
		SELECT 1 
			FROM PLAYERSESSIONS
			WHERE @playerid = @playerid
				AND SESSIONID = @session_token
				AND EXPIRATION > GETDATE()
			)
	BEGIN
		PRINT('PLAYER SESSION TOKEN DOES NOT EXIST')
		RETURN 1
	END
	IF NOT EXISTS (
		SELECT 1
			FROM games
			WHERE GAME_ID = @gameid
				AND CURRENT_PLAYER_TURN = @playerid
	)
	BEGIN
		PRINT('NOT PLAYERS TURN')
		RETURN 2
	END

	RETURN 0
END
GO


