declare @filter nvarchar(max)		,@filters rpt.FilterType;
INSERT INTO @filters ([fldFieldName],[fldFieldType],[fldOperator],[fldOprand])
  VALUES
   ( 'Name1', 'STRING','in'  ,'vdfhbte')
  ,( 'Name2', 'NUMBER','x>=a','frye')
 
	set @filter=' ';
    -- Insert statements for procedure here
	SELECT
	--@filter=  @filter+ rpt.criteriaBuilder(fldFieldName,'STRING',fldOperator,fldOprand) + 'AND'
	@filter=CASE  
			WHEN rpt.criteriaBuilder(fldFieldName,[fldFieldType],fldOperator,fldOprand) IS NULL THEN  @filter 
			ELSE   @filter + rpt.criteriaBuilder(fldFieldName,[fldFieldType],fldOperator,fldOprand) + 'AND'
		END
		--select *
	    From  @filters as f
	set @filter=SUBSTRING(@filter,0,Len(@filter)-3);


select @filter