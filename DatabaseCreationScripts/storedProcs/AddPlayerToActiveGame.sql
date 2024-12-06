USE [master]
GO

/****** Object:  StoredProcedure [dbo].[AddPlayerToActiveGame]    Script Date: 12/5/2024 4:59:55 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[AddPlayerToActiveGame]
    @player_id INT,
    @game_id INT,
	@session_token UNIQUEIDENTIFIER
AS
BEGIN

    BEGIN TRY
		DECLARE @validation_status INT;
		EXEC @validation_status = DBO.VALIDATESESSION @player_id, @session_token

		IF @validation_status != 0
		BEGIN
		 RETURN 1
		END
		IF 1 = (SELECT 1 FROM player WHERE @player_id = PLAYERID AND ACTIVE_GAME IS NOT NULL)
		BEGIN
			RETURN 2
		END
        -- Check if the player count is less than the max player count
        IF (SELECT CASE 
                    WHEN PLAYERCOUNT < MAX_PLAYER_COUNT THEN 1
                    ELSE 0
                  END
            FROM dbo.games
            WHERE GAME_ID = @game_id) = 1
        BEGIN
            -- Update the player to assign them to the active game
            UPDATE dbo.player 
            SET ACTIVE_GAME = @game_id
            WHERE PLAYERID = @player_id

            -- Set turn order
            DECLARE @turn_order INT;
            SET @turn_order = COALESCE(
                (SELECT MAX(TURN_ORDER) + 1 FROM dbo.GAME_TURNS WHERE GAME_ID = @game_id),
                1
            )

            -- If turn order is 1, set the current player turn
            IF (@turn_order = 1)
            BEGIN
                UPDATE dbo.games
                SET CURRENT_PLAYER_TURN = @player_id, PLAYERCOUNT = PLAYERCOUNT + 1
                WHERE GAME_ID = @game_id
            END

            -- Insert into GAME_TURNS table
            INSERT INTO dbo.GAME_TURNS (GAME_ID, PLAYER_ID, TURN_ORDER)
            VALUES (@game_id, @player_id, @turn_order)
        END
    END TRY
    BEGIN CATCH
        PRINT ERROR_MESSAGE();
        THROW;
    END CATCH
END;
GO


