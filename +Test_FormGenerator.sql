declare  @userId [nvarchar](150)
select @userId='hajjar'
EXEC	 [rpt].[FormGenerator]
		@userId = 'hajjar',
		@ReportId = 1
