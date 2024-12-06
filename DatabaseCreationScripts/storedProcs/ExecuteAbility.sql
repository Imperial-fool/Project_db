USE [master]
GO

/****** Object:  StoredProcedure [dbo].[ExecuteAbility]    Script Date: 12/5/2024 5:00:06 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[ExecuteAbility]
    @x int,
    @y int,
    @map_id UNIQUEIDENTIFIER,
    @session_token UNIQUEIDENTIFIER
AS
    DECLARE @player_id INT;
    SET @player_id = (SELECT PLAYERID FROM PLAYERSESSIONS WHERE SESSIONID = @session_token);
    
    DECLARE @game_id INT = (SELECT ACTIVE_GAME FROM player WHERE PLAYERID = @player_id);

    DECLARE @validation_status INT;
    EXEC @validation_status = VALIDATESESSION @player_id, @session_token
    
    IF @validation_status = 0
    BEGIN
        DECLARE @tile_id_old UNIQUEIDENTIFIER = (SELECT TILE_ID FROM map WHERE @x = X AND @y = Y and @map_id = MAP_ID);
        DECLARE @ENTITYREF UNIQUEIDENTIFIER = (SELECT OCCUPIED FROM tile WHERE TILE_ID = @tile_id_old);
        DECLARE @UNIT_TYPE INT = (SELECT UNIT_TYPE_ID FROM active_entities WHERE ENTITY_ID = @ENTITYREF);

        IF EXISTS (
            SELECT 1
            FROM active_entities
            WHERE ENTITY_ID = @ENTITYREF AND HAS_USED_ABILITY = 0
        )
        BEGIN
            RETURN 2; -- Ability has already been used
        END
        
        IF NOT EXISTS (
            SELECT 1
            FROM unit_types
            WHERE UNIT_TYPE_ID = @UNIT_TYPE AND ABILITY_PROCEDURE = ''
        )
        BEGIN
            RETURN @UNIT_TYPE; -- No ability procedure defined
        END

        DECLARE @PROCEDURE NVARCHAR(100) = (SELECT ABILITY_PROCEDURE FROM unit_types WHERE UNIT_TYPE_ID = @UNIT_TYPE AND ABILITY_PROCEDURE != '');

        DECLARE @SQL NVARCHAR(MAX);
        SET @SQL = N'EXEC ' + QUOTENAME(@PROCEDURE) + ' @map_id, @ENTITYREF, @x, @y';
        
        DECLARE @RETURN INT;
        
        -- Execute the dynamic SQL and capture the return value as an INT
        EXEC @RETURN = sp_executesql @SQL, N'@map_id UNIQUEIDENTIFIER, @ENTITYREF UNIQUEIDENTIFIER, @x INT, @y INT', @map_id, @ENTITYREF, @x, @y;
		PRINT @SQL;
        -- Return the result from the dynamic SQL procedure execution
        RETURN 5; -- This should be an integer (0 or another status code)
    END
    ELSE
    BEGIN
        RETURN 0; -- Return 0 if validation fails
    END
GO


