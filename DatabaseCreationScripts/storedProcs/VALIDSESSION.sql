USE [master]
GO

/****** Object:  StoredProcedure [dbo].[VALIDATESESSION]    Script Date: 12/5/2024 5:00:56 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[VALIDATESESSION]
	@playerid int,
	@session_token UNIQUEIDENTIFIER
AS
BEGIN
	IF NOT EXISTS (
		SELECT 1 
			FROM PLAYERSESSIONS
			WHERE @playerid = @playerid
				AND SESSIONID = @session_token
				AND EXPIRATION > GETDATE()
			)
	BEGIN
		RETURN 1
	END

	RETURN 0
END
GO


