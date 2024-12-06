USE [master]
GO

/****** Object:  StoredProcedure [dbo].[startGame]    Script Date: 12/5/2024 5:00:53 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[startGame] 
    @session_token UNIQUEIDENTIFIER
AS
    DECLARE @PLAYER_ID INT = (SELECT PLAYERID FROM PLAYERSESSIONS WHERE @session_token = SESSIONID)
    DECLARE @GAME_ID INT = (SELECT ACTIVE_GAME FROM player WHERE @PLAYER_ID = PLAYERID)
    DECLARE @HAS_START INT = (SELECT 1 FROM games WHERE @GAME_ID = GAME_ID AND TURN IS NOT NULL)

    IF (SELECT 1 FROM GAME_TURNS WHERE @PLAYER_ID = PLAYER_ID AND TURN_ORDER = 1 AND @GAME_ID = GAME_ID) = 1
    BEGIN
        DECLARE @X INT = 0
        DECLARE @PLAYERCOUNT INT = (SELECT PLAYERCOUNT FROM games WHERE @GAME_ID = GAME_ID)
        DECLARE @TILE_IDS TABLE (TILE_ID UNIQUEIDENTIFIER)

        -- Select random tiles based on player count
        INSERT INTO @TILE_IDS (TILE_ID)
        SELECT TOP(@PLAYERCOUNT) TILE_ID
        FROM map
        WHERE MAP_ID = (SELECT MAP_ID FROM games WHERE GAME_ID = @GAME_ID)
        ORDER BY NEWID()

        -- Insert into active_entities for each player
        WHILE @X < @PLAYERCOUNT
        BEGIN
            IF EXISTS (SELECT 1 FROM @TILE_IDS)
            BEGIN
                DECLARE @TILE_ID UNIQUEIDENTIFIER = (SELECT TOP 1 TILE_ID FROM @TILE_IDS)
                DELETE TOP(1) FROM @TILE_IDS
				DECLARE @ENTITYID UNIQUEIDENTIFIER = NEWID()
                -- Insert entity for the player
                INSERT INTO [dbo].[active_entities]
                       ([ENTITY_ID], [TILE_ID], [CURRENT_HP], [HAS_MOVED], [HAS_USED_ABILITY], [OWNER_ID], [UNIT_TYPE_ID])
                VALUES (@ENTITYID, @TILE_ID, 2, 0, 0, @PLAYER_ID, 1)
				UPDATE tile 
				SET OCCUPIED = @ENTITYID
				WHERE @TILE_ID = TILE_ID
            END

            -- Increment X to move to the next player
            SET @X = @X + 1
        END

        -- Update game state to reflect game has started
        UPDATE games
        SET TURN = 1
        WHERE @GAME_ID = GAME_ID
		RETURN 0
    END
	RETURN 1
GO


