USE [master]
GO

/****** Object:  StoredProcedure [dbo].[FOUNDCITY]    Script Date: 12/5/2024 5:00:09 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[FOUNDCITY]
    @game_id INT,
    @entityref UNIQUEIDENTIFIER,
    @X INT,
    @Y INT
AS
BEGIN TRAN FOUNDCITY
    -- Get TILE_ID from active_entities
    DECLARE @TILEREF UNIQUEIDENTIFIER = (SELECT TILE_ID FROM active_entities WHERE @entityref = ENTITY_ID);

    -- Validate if the tile is available for city creation
    DECLARE @VALID INT = (SELECT 1 FROM tile WHERE @TILEREF = TILE_ID AND PLAYER_CONTROL_ID = 0);

    IF @VALID = 1
    BEGIN
        -- Get the player control ID
        DECLARE @PLAYERCONTROLID INT = (SELECT current_player_turn FROM games WHERE @game_id = GAME_ID);

        -- Get the map ID
        DECLARE @MAP_ID UNIQUEIDENTIFIER = (SELECT MAP_ID FROM games WHERE GAME_ID = @game_id);

        -- Initialize tile coordinates
        DECLARE @TILE_X INT = @X;
        DECLARE @TILE_Y INT = @Y;
        DECLARE @DISTANCE INT = 1;

        -- Start iterating over the nearby tiles
        DECLARE @DX INT = -@DISTANCE;
        WHILE @DX <= @DISTANCE
        BEGIN
            DECLARE @DY INT = -@DISTANCE;
            WHILE @DY <= @DISTANCE
            BEGIN
                -- Calculate the position of the neighboring tile
                DECLARE @CHECK_X INT = @TILE_X + @DX;
                DECLARE @CHECK_Y INT = @TILE_Y + @DY;

                -- Check if the tile exists in the map
                IF EXISTS (SELECT 1 FROM map WHERE @MAP_ID = MAP_ID AND @CHECK_X = X AND @CHECK_Y = Y)
                BEGIN
                    -- Get the tile ID for the neighboring tile
                    DECLARE @TILEID UNIQUEIDENTIFIER = (SELECT TILE_ID FROM map WHERE @MAP_ID = MAP_ID AND @CHECK_X = X AND @CHECK_Y = Y);

                    -- If the tile is available for player control (no current player control)
                    IF EXISTS (SELECT 1 FROM tile WHERE TILE_ID = @TILEID AND PLAYER_CONTROL_ID = 0)
                    BEGIN
                        -- If the tile is the target tile, set it as a city
                        IF EXISTS (SELECT 1 FROM map WHERE TILE_ID = @TILEID AND X = @X AND Y = @Y)
                        BEGIN
                            UPDATE tile
                            SET PLAYER_CONTROL_ID = @PLAYERCONTROLID, is_CITY = 1
                            WHERE TILE_ID = @TILEID AND PLAYER_CONTROL_ID = 0;

                            -- Insert the city into the city table
                            INSERT INTO [dbo].[city] 
                                (CITY_ID, TILE_ID, CITY_NAME, PRODUCTION_PER_TURN, SCIENCE_PER_TURN, CITY_POP, CURRENT_BUILD)
                            VALUES
                                (NEWID(), @TILEID, 'City Name Placeholder', 0, 0, 1, 0);
                        END
                        ELSE
                        BEGIN
                            -- Set the player control on the tile without marking it as a city
                            UPDATE tile
                            SET PLAYER_CONTROL_ID = @PLAYERCONTROLID
                            WHERE TILE_ID = @TILEID AND PLAYER_CONTROL_ID = 0;
                        END
                    END
                END

                SET @DY = @DY + 1;
            END
            SET @DX = @DX + 1;
			
        END
		  -- Remove the entity from active_entities
        DELETE FROM active_entities WHERE @entityref = ENTITY_ID;
		COMMIT TRANSACTION 
    END
    RETURN 0
ROLLBACK
GO


