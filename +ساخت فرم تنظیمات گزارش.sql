use KosarWebDBBank;
declare  @userId [nvarchar](150) ,@ReportName [nvarchar](50) ,@GroupName [nvarchar](50)
select @userId='hajjar'
select @GroupName='rpt.VSanadHesabVam',@ReportName='report1'
declare @QueryAndReportName  nvarchar(200),@connection nvarchar(100),
@fldName  [nvarchar](50),@fldFormId bigint ,@btnRefreshReportID bigint,@fldReportID bigint,@tblReportID bigint



select @fldName='rptcnfg_'+@GroupName+'_'+ @ReportName

--پپیدا کردن شناسه فرم مربوطه
SELECT @fldFormId=fldID FROM  [tblForms] WHERE  fldName= @fldName
--حذف کوئری و گزارش قبلی تعریف شده
select @QueryAndReportName=N'rpt_Generated_Form'+CAST(@fldFormId AS VARCHAR) 
delete from [tblQuery] where fldName=@QueryAndReportName
--******************** کویری های اتوکمپلت و لیست ************************
delete from [tblQuery] where fldName in (
SELECT  
'autoQuery_'+CAST(@fldFormId AS VARCHAR)+'_'+f.[fldFieldName]
   FROM [rpt].[tblFilter] as f
  outer APPLY 
   ( 
SELECT g.fldType ,g.fldFieldName,g.fldQuery  from  [rpt].[tblGroups]as g
		 where g.fldFieldName=f.fldFieldName and  g.fldGroupName=@GroupName 
	) S 
where  f.fldReportName=@ReportName  and f.fldFieldName=S.fldFieldName
and S.fldQuery<>'' and (S.fldType='STRING' or S.fldType='LIST')
)
--******************
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



DECLARE  @filters rpt.FilterType
INSERT INTO @filters ([fldFieldName],[fldFieldType],[fldOperator],[fldOprand])
SELECT   
       f.[fldFieldName]+'_'+CAST(f.fldID as varchar(max))
	  ,S.fldType
      ,f.[fldOperator]
      ,f.[fldFieldName]--,f.[fldOprand]
   FROM [rpt].[tblFilter] as f
  outer APPLY 
   ( 
SELECT g.fldType ,g.fldFieldName  from  [rpt].[tblGroups]as g
		 where g.fldFieldName=f.fldFieldName and  g.fldGroupName=@GroupName 
	) S 
where  f.fldReportName=@ReportName  and f.fldFieldName=S.fldFieldName

INSERT INTO [dbo].[tblFormFilds]
           ([fldName]
           ,[fldFildName]
           ,[fldFormID]
           ,[fldOrder]
           ,[fldStyle]
           ,[fldFildLabelTdStyle]
           ,[fldFildDivStyle]
           ,[fldFildTdStyle]
           ,[flDModal]
           ,[fldTypeCode]
           ,[fldDisable]
           ,[fldVisible]
           ,[fldRegularExp]
           ,[fldAutoCompelete]
           ,[fldDefault]
           ,[fldTypeName]
           ,[fldNewLine]
           ,[fldSize]
           ,[fldSubmitName]
           ,[fldSubmitQuery]
           ,[fldSubmitRedirect]
           ,[fldLabelText]
           ,[fldListQuery]
           ,[fldListTitle]
           ,[fldframeURL]
           ,[fldframeHeight]
           ,[fldIsComputedFilde]
           ,[fldComputedQuery]
           ,[fldComputedDependenceFilde]
           ,[fldLabel]
           ,[fldFrameWith]
           ,[fldButtonOnClick]
           ,[fldTextAreaRows]
           ,[fldTextAreaColumns]
           ,[fldSubmitConfirm]
           ,[fldSubmitConfirmMessage]
           ,[fldIsPassWord]
           ,[fldEncrypt]
           ,[fldencryptionKey]
           ,[fldSplit]
           ,[fldDate]
           ,[fldFixDate]
           ,[fldWaitOnSubmit]
           ,[fldDisableAfterDone]
           ,[fldDate10]
           ,[fldFileAccept]
           ,[fldFileMaxSize]
           ,[fldRequired]
           ,[fldSubmitPreControl]
           ,[fldFileMultiple]
           ,[fldDirectScan]
           ,[fldEnClient]
           ,[fldReportName]
           ,[fldAutoSplitChar]
           ,[fldPlaceHolder]
           ,[fldProgram]
           ,[fldLazyReport]
           ,[fldAccess]
           ,[fldLog]
           ,[fldSubmitLog]
           ,[fldSync]
           ,[fldSubmitSuccessfullMessage]
           ,[fldGroupName])
     
SELECT 
		--'     ('+f.fldOprand+')         '+ isnull(D.fldValue,[fldName]) 
		'     ('+ isnull(D.fldValue,f.fldOprand) +')         '+ [fldName]
      ,f.fldFieldName
      ,@fldFormId
      ,[fldOrder]
      ,[fldStyle]
      ,[fldFildLabelTdStyle]
      ,[fldFildDivStyle]
      ,[fldFildTdStyle]
      ,[flDModal]
      ,[fldTypeCode]
      ,[fldDisable]
      ,[fldVisible]
      ,[fldRegularExp]
      ,'autoQuery_'+ CAST(@fldFormId AS VARCHAR)+'_'+f.[fldFieldName]--[fldAutoCompelete]
      ,[fldDefault]
      ,[fldTypeName]
      ,[fldNewLine]
      ,[fldSize]
      ,[fldSubmitName]
      ,[fldSubmitQuery]
      ,[fldSubmitRedirect]
      ,[fldLabelText]
      ,'autoQuery_'+ CAST(@fldFormId AS VARCHAR)+'_'+f.[fldFieldName]--[fldListQuery]
      ,[fldListTitle]
      ,[fldframeURL]
      ,[fldframeHeight]
      ,[fldIsComputedFilde]
      ,[fldComputedQuery]
      ,[fldComputedDependenceFilde]
      ,[fldLabel]
      ,[fldFrameWith]
      ,[fldButtonOnClick]
      ,[fldTextAreaRows]
      ,[fldTextAreaColumns]
      ,[fldSubmitConfirm]
      ,[fldSubmitConfirmMessage]
      ,[fldIsPassWord]
      ,[fldEncrypt]
      ,[fldencryptionKey]
      ,[fldSplit]
      ,[fldDate]
      ,[fldFixDate]
      ,[fldWaitOnSubmit]
      ,[fldDisableAfterDone]
      ,[fldDate10]
      ,[fldFileAccept]
      ,[fldFileMaxSize]
      ,[fldRequired]
      ,[fldSubmitPreControl]
      ,[fldFileMultiple]
      ,[fldDirectScan]
      ,[fldEnClient]
      ,[fldReportName]
      ,[fldAutoSplitChar]
      ,[fldPlaceHolder]
      ,[fldProgram]
      ,[fldLazyReport]
      ,[fldAccess]
      ,[fldLog]
      ,[fldSubmitLog]
      ,[fldSync]
      ,[fldSubmitSuccessfullMessage]
       ,'گزارش ساز'--,[fldGroupName]
	   from @filters AS f
 outer APPLY 
   ( 
   SELECT * FROM [rpt].[tblFilds] AS g
	 where f.fldFieldType=g.fldFieldType  and g.fldFieldType <>'DEFAULT'  and g.fldOperator= f.fldOperator
   ) G 
  outer apply(SELECT Top 1 [fldValue]   FROM [dbo].[tblDictionary] D 
  where D.fldKey=f.fldOprand
	) d
   /* افزودن فیلد های پیش فرض*/
INSERT INTO [dbo].[tblFormFilds]
           ([fldName]
           ,[fldFildName]
           ,[fldFormID]
           ,[fldOrder]
           ,[fldStyle]
           ,[fldFildLabelTdStyle]
           ,[fldFildDivStyle]
           ,[fldFildTdStyle]
           ,[flDModal]
           ,[fldTypeCode]
           ,[fldDisable]
           ,[fldVisible]
           ,[fldRegularExp]
           ,[fldAutoCompelete]
           ,[fldDefault]
           ,[fldTypeName]
           ,[fldNewLine]
           ,[fldSize]
           ,[fldSubmitName]
           ,[fldSubmitQuery]
           ,[fldSubmitRedirect]
           ,[fldLabelText]
           ,[fldListQuery]
           ,[fldListTitle]
           ,[fldframeURL]
           ,[fldframeHeight]
           ,[fldIsComputedFilde]
           ,[fldComputedQuery]
           ,[fldComputedDependenceFilde]
           ,[fldLabel]
           ,[fldFrameWith]
           ,[fldButtonOnClick]
           ,[fldTextAreaRows]
           ,[fldTextAreaColumns]
           ,[fldSubmitConfirm]
           ,[fldSubmitConfirmMessage]
           ,[fldIsPassWord]
           ,[fldEncrypt]
           ,[fldencryptionKey]
           ,[fldSplit]
           ,[fldDate]
           ,[fldFixDate]
           ,[fldWaitOnSubmit]
           ,[fldDisableAfterDone]
           ,[fldDate10]
           ,[fldFileAccept]
           ,[fldFileMaxSize]
           ,[fldRequired]
           ,[fldSubmitPreControl]
           ,[fldFileMultiple]
           ,[fldDirectScan]
           ,[fldEnClient]
           ,[fldReportName]
           ,[fldAutoSplitChar]
           ,[fldPlaceHolder]
           ,[fldProgram]
           ,[fldLazyReport]
           ,[fldAccess]
           ,[fldLog]
           ,[fldSubmitLog]
           ,[fldSync]
           ,[fldSubmitSuccessfullMessage]
           ,[fldGroupName])
     SELECT TOP (1000) 
	   [fldName]
      ,[fldFildName]
      ,@fldFormId
      ,[fldOrder]
      ,[fldStyle]
      ,[fldFildLabelTdStyle]
      ,[fldFildDivStyle]
      ,[fldFildTdStyle]
      ,[flDModal]
      ,[fldTypeCode]
      ,[fldDisable]
      ,[fldVisible]
      ,[fldRegularExp]
      ,[fldAutoCompelete]
      ,[fldDefault]
      ,[fldTypeName]
      ,[fldNewLine]
      ,[fldSize]
      ,[fldSubmitName]
      ,[fldSubmitQuery]
      ,[fldSubmitRedirect]
      ,[fldLabelText]
      ,[fldListQuery]
      ,[fldListTitle]
      ,[fldframeURL]
      ,[fldframeHeight]
      ,[fldIsComputedFilde]
      ,[fldComputedQuery]
      ,[fldComputedDependenceFilde]
      ,[fldLabel]
      ,[fldFrameWith]
      ,[fldButtonOnClick]
      ,[fldTextAreaRows]
      ,[fldTextAreaColumns]
      ,[fldSubmitConfirm]
      ,[fldSubmitConfirmMessage]
      ,[fldIsPassWord]
      ,[fldEncrypt]
      ,[fldencryptionKey]
      ,[fldSplit]
      ,[fldDate]
      ,[fldFixDate]
      ,[fldWaitOnSubmit]
      ,[fldDisableAfterDone]
      ,[fldDate10]
      ,[fldFileAccept]
      ,[fldFileMaxSize]
      ,[fldRequired]
      ,[fldSubmitPreControl]
      ,[fldFileMultiple]
      ,[fldDirectScan]
      ,[fldEnClient]
      ,[fldReportName]
      ,[fldAutoSplitChar]
      ,[fldPlaceHolder]
      ,[fldProgram]
      ,[fldLazyReport]
      ,[fldAccess]
      ,[fldLog]
      ,[fldSubmitLog]
      ,[fldSync]
      ,[fldSubmitSuccessfullMessage]
       ,'گزارش ساز'--,[fldGroupName]
  FROM [rpt].[tblFilds]
  where fldFieldType ='DEFAULT'
  /*افزودن فیلد گزارش*/
INSERT INTO [dbo].[tblFormFilds]
           ([fldName]
           ,[fldFildName]
           ,[fldFormID]
           ,[fldOrder]
           ,[fldStyle]
           ,[fldFildLabelTdStyle]
           ,[fldFildDivStyle]
           ,[fldFildTdStyle]
           ,[flDModal]
           ,[fldTypeCode]
           ,[fldDisable]
           ,[fldVisible]
           ,[fldRegularExp]
           ,[fldAutoCompelete]
           ,[fldDefault]
           ,[fldTypeName]
           ,[fldNewLine]
           ,[fldSize]
           ,[fldSubmitName]
           ,[fldSubmitQuery]
           ,[fldSubmitRedirect]
           ,[fldLabelText]
           ,[fldListQuery]
           ,[fldListTitle]
           ,[fldframeURL]
           ,[fldframeHeight]
           ,[fldIsComputedFilde]
           ,[fldComputedQuery]
           ,[fldComputedDependenceFilde]
           ,[fldLabel]
           ,[fldFrameWith]
           ,[fldButtonOnClick]
           ,[fldTextAreaRows]
           ,[fldTextAreaColumns]
           ,[fldSubmitConfirm]
           ,[fldSubmitConfirmMessage]
           ,[fldIsPassWord]
           ,[fldEncrypt]
           ,[fldencryptionKey]
           ,[fldSplit]
           ,[fldDate]
           ,[fldFixDate]
           ,[fldWaitOnSubmit]
           ,[fldDisableAfterDone]
           ,[fldDate10]
           ,[fldFileAccept]
           ,[fldFileMaxSize]
           ,[fldRequired]
           ,[fldSubmitPreControl]
           ,[fldFileMultiple]
           ,[fldDirectScan]
           ,[fldEnClient]
           ,[fldReportName]
           ,[fldAutoSplitChar]
           ,[fldPlaceHolder]
           ,[fldProgram]
           ,[fldLazyReport]
           ,[fldAccess]
           ,[fldLog]
           ,[fldSubmitLog]
           ,[fldSync]
           ,[fldSubmitSuccessfullMessage]
           ,[fldGroupName])VALUES
  (N'گزارش پویا', N'DynamicReport',@fldFormId, 1000,
N'z-index: 10; height: 100%; width: 100%; font-size: 1.5vw; ',
N'width: 50%; height: 10%; z-index: 10; font-size: 1.5vw; text-align: right; direction: rtl; display: inline; align-items: center; position: absolute; left: 10%; top: 10%; overflow: scroll;',
N'width: 100%;  z-index: 10; font-size: 1.5vw; text-align: right; direction: rtl;  align-items: center;left: 10%; top: 10%; overflow: scroll;',
N'', N'', N'REPORT', 0, 1, NULL, N'', N'', NULL, 1, NULL, N'', N'', N'', N'', N'', N'', N'', NULL, NULL, NULL, NULL, 0, NULL, N'', 0, 0, 0, N'', 0, 0, N'', 0, 0, 0, 0, 0, 0, N'', 0, NULL, NULL, 0, 0, NULL,@QueryAndReportName, N'', N'', NULL, 1, 0, 0, N'', 0, N'', N'')

--***********************ساخت کویری*********************
DECLARE  @setting rpt.SettingType
		,@command nvarchar(max)
delete @filters
INSERT INTO @filters ([fldFieldName],[fldFieldType],[fldOperator],[fldOprand])
SELECT   
       f.[fldFieldName]
	  ,S.fldType
      ,f.[fldOperator]
     -- , f.[fldOprand]
	  ,'#'+f.[fldFieldName]+'_'+CAST(f.fldID as varchar(max))+'#'
  FROM [rpt].[tblFilter] as f
  outer APPLY 
   ( 
	SELECT g.fldType ,s.FieldName,g.fldFieldName, s.fldReportName  from   [rpt].[tblSetting] as s
     outer APPLY 
   ( 
   SELECT g.fldType ,g.fldFieldName  from  [rpt].[tblGroups]as g
	 where g.fldFieldName=S.FieldName and  g.fldGroupName=@GroupName 
   ) G 
	 where   fldGroupName=@GroupName and s.fldReportName=@ReportName and s.fldUserId=@userId
	 ) S 
  where  f.fldReportName=@ReportName  and f.fldFieldName=s.FieldName

INSERT INTO @setting (FieldName, AggreegateFunc,IsGrouped)
select FieldName,AggreegateFunc ,IsGrouped
from rpt.tblSetting
where fldGroupName=@GroupName and fldReportName=@ReportName and fldUserId=@userId


EXEC	 [rpt].[QueryGenerator]
		@Setting = @setting,
		@Filters = @filters,
		@ReportName = @GroupName,
		@index =1,
		@pageSize =50,
		@Query = @command OUTPUT

--******************** کویری های اتوکمپلت و لیست ************************
INSERT INTO [dbo].[tblQuery]
           ([fldName]
           ,[fldCommand]
           ,[fldConnectionName]
           ,[fldProgram]
           ,[fldGroupName])
	 SELECT  
	'autoQuery_'+ CAST(@fldFormId AS VARCHAR)+'_'+f.[fldFieldName]
     ,S.fldQuery
     ,@connection
     ,NULL
     ,'گزارش ساز '
   FROM [rpt].[tblFilter] as f
  outer APPLY 
   ( 
SELECT g.fldType ,g.fldFieldName,g.fldQuery  from  [rpt].[tblGroups]as g
		 where g.fldFieldName=f.fldFieldName and  g.fldGroupName=@GroupName 
	) S 
where  f.fldReportName=@ReportName  and f.fldFieldName=S.fldFieldName
and S.fldQuery<>'' and (S.fldType='STRING' or S.fldType='LIST')
--********************افزودن کویری************************


--set @command='SELECT TOP (100) [fldID]
--      ,[fldBedBesFlag]
--      ,[fldDate]
--      ,[fldTime]
--      ,[fldHesabType]
--      ,[fldHesabID]
--      ,[fldBed]
--      ,[fldBes]
--      ,[fldSanadID]
    
--  FROM [VsanadCustomer]'
INSERT INTO [dbo].[tblQuery]
           ([fldName]
           ,[fldCommand]
           ,[fldConnectionName]
           ,[fldProgram]
           ,[fldGroupName])
     VALUES
           (@QueryAndReportName
           ,@command
           ,@connection
           ,NULL
           ,'گزارش ساز ')
--*******************افزودن گزارش*****************
INSERT [tblReport] ( [fldName], [fldTitle], [fldHeadTitle], [fldQuery], [fldGroupName], [fldIntialize], [fldPerLineIntialize], [fldShowAllColumns], [fldDesignID], [fldSpecial], [fldSpecialPattern], [fldFootTitle], [fldQueryTitle], [fldBorder], [fldTableCSSClass], [fldStyle], [fldTokenEncrypt], [fldScript], [fldShowSQLError], [fldUserReorder], [fldTrStyle], [fldSelectRow], [fldMulitpleSelect], [fldKeyField], [fldPrintHeadTitle], [fldPrintFootTitle], [fldSettingHidden], [fldProgram], [fldPrintUseHeader], [fldEndLinePage], [fldEndLine], [fldExportEnable], [fldRightClick], [fldExportDefault]) 
VALUES 
( @QueryAndReportName, N'گزارش اتومات' +@ReportName, N'', @QueryAndReportName, N'گزارش ساز', NULL, NULL, 1, NULL, 0, N'', N'', N'simple', 1, N'', N'', NULL, NULL, NULL, 1, NULL, 1, 0, N'', N'', N'', 1, NULL, NULL, NULL, NULL, 1, NULL, NULL)

select @tblReportID=fldId From [tblReport]
where [fldName]=@QueryAndReportName

--**********Set Dependencies**************
SELECT @btnRefreshReportID=[fldID]
FROM [KosarWebDBBank].[dbo].[tblFormFilds]
where fldFormID=@fldFormId and fldFildName= 'rpt_btnBuildQuery'

SELECT @fldReportID=[fldID]
FROM [dbo].[tblFormFilds]
where fldFormID=@fldFormId and fldFildName='DynamicReport'
INSERT INTO [dbo].[tblFildDependence]
           (
		   [fldFildID]
           ,[fldFildDepName]
           ,[fldQuery]
           ,[fldReportReSelect]
           ,[fldProgram]
           ,[fldFildDepID])
		   values(@fldReportID,'rpt_btnBuildQuery','simple',null,null, @btnRefreshReportID)


--*****************افزودن فیلد های گزارش *************


 delete FROM [tblReportFilde]
  where [fldReportID]=@tblReportID 
INSERT INTO [dbo].[tblReportFilde]
           (
		[fldReportID]
      ,[fldTitle]
      ,[fldName]
      ,[fldOrder]
      --,[fldLink]
      ,[fldLinkShow]
      ,[fldButton]
      ,[fldButtonFunction]
      ,[fldStyle]
      ,[fldShowType]
      ,[fldSplit]
     -- ,[fldCalcExperssion]
      ,[fldSum]
      --,[fldEncrypt]
      --,[fldEncKey]
      --,[fldTdStyle]
      --,[fldWidth]
      --,[fldNoWrap]
      --,[fldPrint]
      --,[fldForeColor]
      --,[fldBackColor]
      --,[fldFont]
      --,[fldFontSize]
      --,[fldEditable]
      --,[fldIsReport]
      --,[fldProgram]
      ,[fldDiv])
SELECT @tblReportID ,N'ردیف' ,'rowNumber',1,'',0,'','',2,0,0,0 union all
SELECT TOP (1000) @tblReportID,
CASE
	WHEN IsGrouped<1 and AggreegateFunc!=''  THEN   ISNULL(D.fldValue,[FieldName])+'_'+ AggreegateFunc
    WHEN IsGrouped<1 and AggreegateFunc=''  THEN   ISNULL(D.fldValue,[FieldName])+'_COUNT'  
    ELSE   ISNULL(D.fldValue,[FieldName])
END 
,CASE
	WHEN IsGrouped<1 and AggreegateFunc!=''  THEN  [FieldName]+'_'+ AggreegateFunc
    WHEN IsGrouped<1 and AggreegateFunc=''  THEN  [FieldName]+'_COUNT'  
    ELSE   [FieldName]
END 
,1,'',0,'','',2,0,0,0
  FROM [rpt].[tblSetting] s
    outer apply(SELECT Top 1 [fldValue]   FROM [dbo].[tblDictionary] D 
  where D.fldKey=s.[FieldName]
	) d
  where fldGroupName=@GroupName and fldReportName=@ReportName and fldUserId=@userId 





  --******************************************************


/****** Object:  StoredProcedure [rpt].[DeletReport]    Script Date: 13/03/1400 12:50:13 ب.ظ ******/
SET ANSI_NULLS ON
