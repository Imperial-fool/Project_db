USE [master]
GO

/****** Object:  StoredProcedure [dbo].[getCurrentMapInfo]    Script Date: 12/5/2024 5:00:34 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[getCurrentMapInfo]
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

	SELECT DISTINCT tile.*,map.x,map.y
FROM map
JOIN tile ON map.TILE_ID = tile.TILE_ID
WHERE map.MAP_ID = (
    SELECT MAP_ID
    FROM games
    WHERE GAME_ID = COALESCE(
        (SELECT ACTIVE_GAME
         FROM player
         WHERE PLAYERID = @player_id),
        NULL)
);


END;
GO


