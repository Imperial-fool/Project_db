USE [master]
GO

/****** Object:  StoredProcedure [dbo].[getCurrentGameInfo]    Script Date: 12/5/2024 5:00:30 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[getCurrentGameInfo]
	@session_token UNIQUEIDENTIFIER
AS 
BEGIN
    DECLARE @validation_status INT
	DECLARE @player_id int

	SET @player_id = (SELECT PLAYERID FROM PLAYERSESSIONS WHERE SESSIONID = @session_token)
    EXEC @validation_status = DBO.VALIDATESESSION @player_id, @session_token;

    IF @validation_status != 0
    BEGIN

        RETURN;
    END;

	SELECT * FROM games WHERE GAME_ID = (SELECT ACTIVE_GAME FROM player WHERE @player_id = PLAYERID)


END
GO


