﻿USE [dbo]
GO
/****** Object:  UserDefinedFunction [dbo].[InitCap]    Script Date: 20/12/2019 18:43:46 // savva.lukhnev // ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[InitCap] ( @InputString Nvarchar(128) )
RETURNS NVARCHAR(128)
AS
BEGIN
DECLARE @Index          INT
DECLARE @Char           NVARCHAR(1)
DECLARE @PrevChar       NVARCHAR(1)
DECLARE @OutputString   NVARCHAR(128)
SET @OutputString = LOWER(@InputString)
SET @Index = 1
WHILE @Index <= LEN(@InputString)
BEGIN
    SET @Char     = SUBSTRING(@InputString, @Index, 1)
    SET @PrevChar = CASE WHEN @Index = 1 THEN ' '
                         ELSE SUBSTRING(@InputString, @Index - 1, 1)
                    END
    IF @PrevChar IN (' ', ';', ':', '!', ',', '.', '_', '-', '/', '&', '''', '(')
    BEGIN
        IF @PrevChar != '''' OR UPPER(@Char) != 'S'
            SET @OutputString = STUFF(@OutputString, @Index, 1, UPPER(@Char))
    END
    SET @Index = @Index + 1
END
RETURN @OutputString
END
