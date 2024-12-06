USE [master]
GO

/****** Object:  StoredProcedure [dbo].[playerlogin]    Script Date: 12/5/2024 5:00:49 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[playerlogin]
	@username varchar(25),
	@password varchar(25),
	@session_token UNIQUEIDENTIFIER OUTPUT,
	@player_id INT OUTPUT
AS
BEGIN
	DECLARE @hashed_password varchar(255)
	
	SET @hashed_password = 
	(SELECT player.HASH
	FROM dbo.player
	WHERE @username = PLAYERNAME)
	SET @player_id = (SELECT PLAYERID FROM player WHERE @username = PLAYERNAME)

	IF @hashed_password = HASHBYTES('SHA2_256', @password)
	BEGIN 
		SET @session_token = NEWID()
		IF EXISTS (SELECT 1 FROM PLAYERSESSIONS WHERE PLAYERID = @player_id)
		BEGIN
		UPDATE PLAYERSESSIONS
		SET SESSIONID = @session_token, EXPIRATION =  DATEADD(DAY,1,GETDATE())
		WHERE PLAYERID = (SELECT PLAYERID FROM player WHERE @username = PLAYERNAME)
		END
		ELSE
		BEGIN
			INSERT INTO PLAYERSESSIONS (PLAYERID,SESSIONID,EXPIRATION)
			VALUES(@player_id,@session_token,DATEADD(DAY,1,GETDATE()))
		END
		RETURN 0;
	END
	SET @session_token = 0X0
	RETURN 1;
END
GO


