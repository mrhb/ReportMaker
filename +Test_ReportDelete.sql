declare  @userId [nvarchar](150) ,@ReportName [nvarchar](50) ,@GroupName [nvarchar](50)
select @userId='hajjar'
select @GroupName='rpt.VSanadHesabVam',@ReportName='report1'

EXEC	 [rpt].[DeleteReport]
		@userId = 'hajjar',
		@ReportName = 'report1',
		@GroupName = 'rpt.VSanadHesabVam'
