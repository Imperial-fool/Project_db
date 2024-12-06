USE [master]
GO

/****** Object:  StoredProcedure [dbo].[getAllGames]    Script Date: 12/5/2024 5:00:27 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[getAllGames] 
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

	SELECT * FROM games

GO


