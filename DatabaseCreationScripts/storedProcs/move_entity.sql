USE [master]
GO

/****** Object:  StoredProcedure [dbo].[move_entity]    Script Date: 12/5/2024 5:00:41 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[move_entity]
	@origin_x int,
	@origin_y int,
	@target_x int,
	@target_y int,
	@map_id uniqueidentifier,
	@session_token uniqueidentifier
AS
BEGIN
	DECLARE @player_id int
	SET @player_id = (SELECT PLAYERID FROM PLAYERSESSIONS WHERE SESSIONID = @session_token)
	IF @player_id IS NULL
	BEGIN
		RAISERROR (N'No game found for player', -- Message text.
		10, -- Severity,
		1, -- State,
		N'number', -- First argument.
		5);
		RETURN 5;  -- You can use an appropriate return code
	END
	DECLARE @game_id INT = (SELECT ACTIVE_GAME FROM player WHERE PLAYERID = @player_id)
	IF @game_id IS NULL
	BEGIN
		RAISERROR (N'No player found for session token', -- Message text.
		10, -- Severity,
		1, -- State,
		N'number', -- First argument.
		5);
		RETURN 6;  -- You can use an appropriate return code
	END
	DECLARE @validation_status INT;

    EXEC @validation_status = VALIDATESESSIONANDTURN @game_id, @player_id, @session_token;
	
	IF @validation_status = 0
	BEGIN

		DECLARE @tile_id_old UNIQUEIDENTIFIER = (SELECT TILE_ID FROM map WHERE @origin_x = X AND @origin_y = Y and MAP_ID = @map_id)
		DECLARE @tile_id_NEW UNIQUEIDENTIFIER = (SELECT TILE_ID FROM map WHERE @target_x = X AND @target_y = Y  and MAP_ID = @map_id)
		DECLARE @entityREF UNIQUEIDENTIFIER = (SELECT OCCUPIED FROM tile WHERE TILE_ID = @tile_id_old)


		 IF EXISTS (
        SELECT 1
        FROM active_entities
		WHERE ENTITY_ID = @entityREF AND HAS_MOVED = 1)
			BEGIN
				RETURN 1;
			END
		IF NOT EXISTS (
        SELECT 1
        FROM active_entities
		WHERE ENTITY_ID = @entityREF AND @player_id = OWNER_ID)
			BEGIN
				RETURN 2;
			END

		DECLARE @distance int = (SELECT MOVEMENT_SPEED FROM unit_types WHERE UNIT_TYPE_ID = (SELECT UNIT_TYPE_ID FROM active_entities WHERE ENTITY_ID = @entityREF))

		DECLARE @traveldistance int = abs(@origin_x - @target_x) + abs(@origin_y - @target_y)
		
		IF @traveldistance <= @distance
		BEGIN

			UPDATE tile 
			SET tile.OCCUPIED = null
			WHERE TILE_ID = @tile_id_old
			UPDATE tile
			set tile.OCCUPIED = @entityREF
			WHERE TILE_ID = @tile_id_NEW
		END
		ELSE
		 BEGIN
         RETURN 3;
		 END
	END
	RAISERROR (N'validation failed', -- Message text.
		10, -- Severity,
		1, -- State,
		N'number', -- First argument.
		5);
	RETURN 4
END

GO


