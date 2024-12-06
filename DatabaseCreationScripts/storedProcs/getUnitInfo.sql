USE [master]
GO

/****** Object:  StoredProcedure [dbo].[getUnitInfo]    Script Date: 12/5/2024 5:00:38 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[getUnitInfo] 
	@TILE_ID UNIQUEIDENTIFIER,
	@session_token UNIQUEIDENTIFIER
AS
	DECLARE @player_id int = (SELECT PLAYERID FROM PLAYERSESSIONS WHERE @session_token = SESSIONID)

	DECLARE @RET INT
	EXEC @RET = VALIDATESESSION @player_id, @session_token
	
	IF @RET = 1
	BEGIN
		RETURN 'NOT VALID SESSION TOKEN'
	END
	SELECT * FROM active_entities as t1, unit_types as t2 WHERE t1.TILE_ID = @TILE_ID and t1.UNIT_TYPE_ID = t2.UNIT_TYPE_ID



GO


