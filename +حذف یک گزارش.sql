declare  @userId [nvarchar](150) ,@ReportName [nvarchar](50) ,@GroupName [nvarchar](50)
select @userId='hajjar'
select @GroupName='rpt.VSanadHesabVam',@ReportName='report1'
declare @QueryAndReportName  nvarchar(200),@connection nvarchar(100),
@fldName  [nvarchar](50),@fldFormId bigint ,@btnRefreshReportID bigint,@fldReportID bigint



select @fldName='rptcnfg_'+[dbo].[Fingilish](@GroupName)+'_'+ [dbo].[Fingilish](@ReportName

--پپیدا کردن شناسه فرم مربوطه
SELECT @fldFormId=fldID FROM  [tblForms] WHERE  fldName= @fldName
--حذف کوئری و گزارش قبلی تعریف شده
select @QueryAndReportName=N'rpt_Generated_Form'+CAST(@fldFormId AS VARCHAR) 
delete from [tblQuery] where fldName=@QueryAndReportName
delete from [tblReport] where [fldName]=@QueryAndReportName

--پیدا کردن شناسه دکمه ساخت کوئری گزارش در فرم مربوطه
SELECT @btnRefreshReportID=[fldID]
FROM [dbo].[tblFormFilds]
where fldFormID=@fldFormId and fldFildName= 'rpt_btnBuildQuery'

--پیدا کردن شناسه فیلد نمایش کوئری ساخته شده
SELECT @fldReportID=[fldID]
FROM [dbo].[tblFormFilds]
where fldFormID=@fldFormId and fldFildName=@QueryAndReportName

delete [dbo].[tblFildDependence]
where [fldFildID]=@fldReportID and  [fldFildDepID]=@btnRefreshReportID

delete from [dbo].[tblForms] where fldName= @fldName
delete from tblFormFilds where fldFormID= @fldFormId
 
INSERT INTO [dbo].[tblForms]
           (
		   [fldTitle]
           ,[fldName]
           --,[fldInputCount]
           ,[fldPreQuery]
           --,[fldAfterQuery]
           ,[fldScript]
           ,[fldStyle]
           ,[fldOnCloseCheck]
           ,[fldOnCloseCheckQuery]
           --,[fldProgram]
           ,[fldGroupName]
           ,[fldRefreshByChilds]
           ,[fldAccess]
           ,[fldLog]
           ,[fldOpenLog]
           ,[fldOfferWidth]
           ,[fldOfferHeight]
           --,[fldParentForm]
		   )
     VALUES
           (  N'فرم تنظیمات گزارش'+@ReportName
           ,@fldName
           --,<fldInputCount, int,>
           ,'simple'--,<fldPreQuery, nvarchar(200),>
           --<fldAfterQuery, nvarchar(max),>
           ,''--,<fldScript, nvarchar(max),>
           ,''--,<fldStyle, nvarchar(max),>
           ,0--,<fldOnCloseCheck, bit,>
           ,''--,<fldOnCloseCheckQuery, nvarchar(250),>
           --,<fldProgram, nvarchar(250),>
           ,'گزارش ساز'--,<fldGroupName, nvarchar(200),>
           ,0--,<fldRefreshByChilds, bit,>
           ,0--,<fldAccess, bit,>
           ,0--,<fldLog, bit,>
           ,''--,<fldOpenLog, nvarchar(250),>
           ,'50%'--,<fldOfferWidth, nvarchar(50),>
           ,'70%'--,<fldOfferHeight, nvarchar(50),>
           --,<fldParentForm, nvarchar(350),>
		   )

-- read form ID
SELECT @fldFormId=fldID FROM  [tblForms] WHERE  fldName= @fldName

select @QueryAndReportName=N'rpt_Generated_Form'+CAST(@fldFormId AS VARCHAR) ,@connection='BANK'

--*****************حذف فیلد های گزارش *************
SELECT @fldReportID=[fldID]
FROM [dbo].[tblFormFilds]
where fldFormID=@fldFormId and fldFildName='DynamicReport'

 delete FROM [tblReportFilde]
  where [fldReportID]=@tblReportID 

