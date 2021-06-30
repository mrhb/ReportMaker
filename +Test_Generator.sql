DECLARE  @setting rpt.SettingType
		,@filters rpt.FilterType
		,@query nvarchar(max)

INSERT INTO @setting (FieldName, AggreegateFunc,IsGrouped)
  VALUES
  ('fldName', 'Avg', 'TRUE'), 
  ('fldVamType', 'Count', 'TRUE'), 
  ('fldVamGroup','Min','False');
INSERT INTO @filters ([fldFieldName],[fldFieldType],[fldOperator],[fldOprand])
  VALUES
   ( 'fldName1', 'STRING','in'  ,'#fldName1#')
  ,( 'fldqwme2', 'STRING','like','fte5cdesrt')
  ,( 'fldName2', 'NUMBER','x>=a','fte56')
  ,( 'fldqwme2', 'NUMBER','b<x<=a','fte56#srt');

EXEC	 [rpt].[QueryGenerator]
		@Setting = @setting,
		@Filters = @filters,
		@ReportName = 'rpt.vsanadVam',
		@index =1,
		@pageSize =50,
		@Query = @query OUTPUT
SELECT	@query as N'Result Query'
