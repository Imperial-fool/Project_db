USE [master]
GO

/****** Object:  StoredProcedure [dbo].[GeneratePlayer]    Script Date: 12/5/2024 5:00:24 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[GeneratePlayer]
  @password varchar(25),
  @username varchar(25),
  @output int OUTPUT
AS
BEGIN
  -- Default @output to a value for clarity
  SET @output = 1; -- Default to failure unless explicitly set

  IF NOT EXISTS (SELECT 1 FROM player WHERE PLAYERNAME = @username)
  BEGIN
    INSERT INTO dbo.player (ACTIVE_GAME, PLAYERNAME, HASH)
    VALUES (NULL, @username, HASHBYTES('SHA2_256', @password));

    IF @@ROWCOUNT > 0
    BEGIN
      SET @output = 0; -- Success
      SELECT PLAYERID, PLAYERNAME FROM player WHERE PLAYERNAME = @username;
    END
    ELSE
    BEGIN
      SET @output = 2; -- Insert failed for unexpected reasons
    END
  END
  ELSE
  BEGIN
    SET @output = 3; -- User already exists
  END
END;
GO


