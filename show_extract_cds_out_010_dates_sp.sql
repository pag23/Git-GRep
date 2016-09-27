USE [CDS_Mart]
GO

/****** Object:  StoredProcedure [dbo].[show_extract_cds_out_010_dates_sp]    Script Date: 09/27/2016 14:00:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[show_extract_cds_out_010_dates_sp]
AS
/******
PAG 24/05/2016 

exec  dbo.[show_extract_cds_out_010_dates_sp]
******/
SELECT DISTINCT CAST(CAST([mod_date] AS DATE) AS DATETIME) AS [Run Date]
 FROM [dbo].[extract_cds_out_history_SSIS]
 ORDER BY CAST(CAST([mod_date] AS DATE) AS DATETIME) desc
 
 
 
 
 
 
 
 
 
 
 
 


GO


