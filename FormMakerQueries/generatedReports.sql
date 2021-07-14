declare @userId nvarchar(50)
--select @userId=#user:userName#
select @userId='hajjar'
/****** Script for SelectTopNRows command from SSMS  ******/
SELECT  DENSE_RANK() OVER (ORDER BY  R.fldName) AS Row_Number
		,G.fldTitle fldGroupName
		,G.fldName fldGroupName_en
		,R.fldName fldReportName
		,[fldID] ReportID
		
  FROM [KosarWebDBBank].[rpt].[tblReports] R
  outer apply(
  SELECT TOP (1000) [fldTitle]
      ,[fldName]
      ,[fldViewName]
      ,[fldConnectionName]
  FROM [KosarWebDBBank].[rpt].[tblGroups] g 
  where g.fldName=R.fk_fldGroupTitle
  )G
    where [fldUserId]=@userId
    order by fldReportName