declare @query nvarchar(max);
	set @query=' ';
    -- Insert statements for procedure here
	SELECT
	--@query=  @query+ rpt.criteriaBuilder(fldFieldName,'STRING',fldOperator,fldOprand) + 'AND'
	@query=CASE  
			WHEN rpt.criteriaBuilder(fldFieldName,'STRING',fldOperator,fldOprand) IS NULL THEN  @query 
			ELSE   @query + rpt.criteriaBuilder(fldFieldName,'STRING',fldOperator,fldOprand) + 'AND'
		END
		--select *
	    From  rpt.tblFilter as f
	set @query=SUBSTRING(@query,0,Len(@query)-3);


select @query