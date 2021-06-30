use KosarWebDBBank;
declare  @userId [nvarchar](150) ,@ReportName [nvarchar](50)  ,@GroupName [nvarchar](50)
select @userId='hajjar'
select @GroupName='rpt.VSanadHesabVam',@ReportName='report1'

   declare @isChart bit, @chartType  [nvarchar](10) ,@QueryAndReportName  nvarchar(200) ,@ChartReportName nvarchar(200),@connection nvarchar(100),
@fldName  [nvarchar](50),@fldFormId bigint  ,@fldLevelID bigint ,@btnRefreshReportID bigint,@fldReportID bigint,@tblReportID bigint


    select @isChart=fldIsChart ,@chartType =fldChartType
    From [rpt].tblReports as r
    where r.fldname=@ReportName


    select @GroupName=[dbo].[Fingilish](@GroupName), @ReportName=[dbo].[Fingilish](@ReportName)

    select @fldName='rptcnfg_'+@GroupName+'_'+ @ReportName

    --پیدا کردن شناسه فرم مربوطه
    SELECT @fldFormId=fldID
    FROM [tblForms]
    WHERE  fldName= @fldName
    --حذف کوئری و گزارش قبلی تعریف شده
    select @QueryAndReportName=N'rpt_Form'+CAST(@fldFormId AS VARCHAR) 
, @ChartReportName=N'chartReport_Form'+CAST(@fldFormId AS VARCHAR)
    delete from [tblQuery] where [fldName]=@QueryAndReportName
    delete from [tblQuery] where fldName=@QueryAndReportName+N'_title'
    delete from [tblReport] where [fldName]=@QueryAndReportName or [fldName]=@ChartReportName
    delete from [tblAPI] where [fldName]=@QueryAndReportName

    SELECT @fldLevelID=[fldID]
    from [dbo].[tblFormAccessLevels]
    where fldName='NULL' and fldFormID=@fldFormId
    delete from [dbo].[tblFormAccessDetail] where   fldLevelID=@fldLevelID and fldFildName='API:'+@QueryAndReportName
    delete from [dbo].[tblFormAccessLevels] where fldName='NULL' and fldFormID=@fldFormId
    --******************** کویری های اتوکمپلت و لیست ************************
    delete from [tblQuery] where fldName in (
SELECT
        'autoQuery_'+CAST(@fldFormId AS VARCHAR)+'_'+f.[fldFieldName]+'_'+CAST(f.fldID as varchar(max))
    FROM [rpt].[tblFilter] as f
  outer APPLY 
   ( 
SELECT g.fldType , g.fldFieldName, g.fldQuery
        from [rpt].[tblGroupColumns]as g
        where g.fldFieldName=f.fldFieldName and g.fldGroupName=@GroupName 
	) S
    where  f.fldReportName=@ReportName and f.fldFieldName=S.fldFieldName
        and S.fldQuery<>'' and (S.fldType='STRING' or S.fldType='LIST')
)

    --******************


    --پیدا کردن شناسه دکمه ساخت کوئری گزارش در فرم مربوطه
    SELECT @btnRefreshReportID=[fldID]
    FROM [dbo].[tblFormFilds]
    where fldFormID=@fldFormId and fldFildName= 'rpt_btnBuildQuery'

    --پیدا کردن شناسه فیلد نمایش کوئری ساخته شده
    SELECT @fldReportID=[fldID]
    FROM [dbo].[tblFormFilds]
    where fldFormID=@fldFormId and fldFildName=@QueryAndReportName

    delete [dbo].[tblFildDependence]
where [fldFildID]=@fldReportID and [fldFildDepID]=@btnRefreshReportID
    
   select @tblReportID=fldId
    From [tblReport]
    where [fldName]=@QueryAndReportName

    delete FROM [tblReportFilde]
    where [fldReportID]=@tblReportID

    delete from [dbo].[tblForms] where fldName= @fldName
    delete from [dbo].[tblFormAccessLevels] where fldFormID= @fldFormId and fldName='NULL'

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
        ( N'فرم تنظیمات گزارش'+@ReportName
           , @fldName
           --,<fldInputCount, int,>
           , 'simple'--,<fldPreQuery, nvarchar(200),>
           --<fldAfterQuery, nvarchar(max),>
           , N''--,<fldScript, nvarchar(max),>
           , ''--,<fldStyle, nvarchar(max),>
           , 0--,<fldOnCloseCheck, bit,>
           , ''--,<fldOnCloseCheckQuery, nvarchar(250),>
           --,<fldProgram, nvarchar(250),>
           , 'اتوگزارش'--,<fldGroupName, nvarchar(200),>
           , 0--,<fldRefreshByChilds, bit,>
           , 0--,<fldAccess, bit,>
           , 0--,<fldLog, bit,>
           , ''--,<fldOpenLog, nvarchar(250),>
           , '50%'--,<fldOfferWidth, nvarchar(50),>
           , '70%'--,<fldOfferHeight, nvarchar(50),>
           --,<fldParentForm, nvarchar(350),>
		   )

    -- read form ID
    SELECT @fldFormId=fldID
    FROM [tblForms]
    WHERE  fldName= @fldName

    select @QueryAndReportName=N'rpt_Form'+CAST(@fldFormId AS VARCHAR) 
, @ChartReportName=N'chartReport_Form'+CAST(@fldFormId AS VARCHAR) 
, @connection='BANK'


    UPDATE [dbo].[tblForms]
   SET [fldScript] = cast('
//*********Coloring********** */
// Some random pastel backgrounds with saturation in range 25-95% and lightness in range 85-95%:
    const hues=[266,111,70,288,187,17,45,2555,100,60,207,160,9,30];
    const backgrounds=[];
    const borders=[];
    for (let  f = 0; f < hues.length; f++){
        var h=hues[f];
        var s=95;//saturation  
        var l=68; //lightness    

        var a=0.8
        backgrounds[f]="hsl(" +(h) + '','' + s + ''%,'' +l + ''%, 0.6)'' ;
        borders[f]="hsl(" +(h) + '','' + s + ''%,'' +l + ''%)'';
    }
  let getColor=function getColor(i){ 
        // Define desired object
     var obj = {
       background: backgrounds[i%backgrounds.length],
       border: borders[i%backgrounds.length],
     };
     // Return it
     return obj;
    }
//*********Coloring End********** */

//*********LabelsAndSeriess********** */
 function getLabelsAndSeriess(apiData,type=''line''){ 
      var fields = Object.keys(apiData[0]);
      var serieslabels=fields.slice(1,fields.length);
      let series=[];
      let labels=[];

      serieslabels.forEach((item, index)=>
          {
          if(type==''pie'')
              series.push({
              data:[],
              label:item,
              backgroundColor:[],
              borderColor: [],
              borderWidth: 1,

              fill: ''origin''      // 0: fill to ''origin''
              });
          else
              series.push({
              data:[],
              label:item,
              backgroundColor: getColor(index).background,
              borderColor: getColor(index).background.border,
              borderWidth: 3,

              fill: ''origin''      // 0: fill to ''origin''
              });
          
          }
      )

      apiData.reduce((acc,value)=>{
          serieslabels.forEach(item=>{
              var seri= series.find(element=>element.label==item);
              seri.data.push(value[item]);
              if(type==''pie'')
              {
               seri.backgroundColor.push(getColor(seri.data.length).background);
               seri.borderColor.push(getColor(seri.data.length).background);
              }
          })
              labels.push(value[fields[0]]);

          return acc
      },[]);    
    
    // Define desired object
     var obj = {
       series: series,
       labels: labels,
     };
     // Return it
     return obj;
}
//*********LabelsAndSeriess End********** */
Chart.defaults.font.family = ''IRANSans'';
/*var operatorSanadsData = api(''operatorSanadsChart'');*/
var ctx = ''ReportChart'';
var temp=12;

function refreshChart(){
temp=temp+100;
console.log(temp);
operatorSanadsData = api(''' as nvarchar(max))+cast(@QueryAndReportName as nvarchar(max))
+cast(N''');
var operatorSanads_LabelsAndSeries = getLabelsAndSeriess(operatorSanadsData.ExData);

if (typeof(myChart) != "undefined")
myChart.destroy();

myChart = new Chart(ctx, {
    type: ''' as nvarchar(max))+@chartType
+cast(N''',
    data: {
        labels: operatorSanads_LabelsAndSeries.labels,
        datasets:operatorSanads_LabelsAndSeries.series
    },
    options: {
        scales: {
            y: {
                beginAtZero: true,
                stacked: false
            }
    }
        }
});
		   } //refreshChart          
$(''#rpt_btnBuildQuery'').click(function() {
  refreshChart();
});
   ' as nvarchar(max))
 WHERE fldID=@fldFormId

    DECLARE  @filters rpt.FilterType
    INSERT INTO @filters
        ([fldFieldName],[fldFieldType],[fldOperator],[fldOprand])
    SELECT
        f.[fldFieldName]+'_'+CAST(f.fldID as varchar(max))
	  , S.fldType
      , f.[fldOperator]
      , f.[fldFieldName]--,f.[fldOprand]
    FROM [rpt].[tblFilter] as f
  outer APPLY 
   ( 
SELECT g.fldType , g.fldFieldName
        from [rpt].[tblGroupColumns]as g
        where g.fldFieldName=f.fldFieldName and g.fldGroupName=@GroupName 
	) S
    where  f.fldReportName=@ReportName and f.fldFieldName=S.fldFieldName

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
      , f.fldFieldName
      , @fldFormId
      , [fldOrder]
      , [fldStyle]
      , [fldFildLabelTdStyle]
      , [fldFildDivStyle]
      , [fldFildTdStyle]
      , [flDModal]
      , [fldTypeCode]
      , [fldDisable]
      , [fldVisible]
      , [fldRegularExp]
      , 'autoQuery_'+ CAST(@fldFormId AS VARCHAR)+'_'+f.[fldFieldName]--[fldAutoCompelete]
      , [fldDefault]
      , [fldTypeName]
      , [fldNewLine]
      , [fldSize]
      , [fldSubmitName]
      , [fldSubmitQuery]
      , [fldSubmitRedirect]
      , [fldLabelText]
      , 'autoQuery_'+ CAST(@fldFormId AS VARCHAR)+'_'+f.[fldFieldName]--,[fldListQuery]
      , [fldListTitle]
      , [fldframeURL]
      , [fldframeHeight]
      , [fldIsComputedFilde]
      , [fldComputedQuery]
      , [fldComputedDependenceFilde]
      , [fldLabel]
      , [fldFrameWith]
      , [fldButtonOnClick]
      , [fldTextAreaRows]
      , [fldTextAreaColumns]
      , [fldSubmitConfirm]
      , [fldSubmitConfirmMessage]
      , [fldIsPassWord]
      , [fldEncrypt]
      , [fldencryptionKey]
      , [fldSplit]
      , [fldDate]
      , [fldFixDate]
      , [fldWaitOnSubmit]
      , [fldDisableAfterDone]
      , [fldDate10]
      , [fldFileAccept]
      , [fldFileMaxSize]
      , [fldRequired]
      , [fldSubmitPreControl]
      , [fldFileMultiple]
      , [fldDirectScan]
      , [fldEnClient]
      , [fldReportName]
      , [fldAutoSplitChar]
      , [fldPlaceHolder]
      , [fldProgram]
      , [fldLazyReport]
      , [fldAccess]
      , [fldLog]
      , [fldSubmitLog]
      , [fldSync]
      , [fldSubmitSuccessfullMessage]
       , 'اتوگزارش'--,[fldGroupName]
    from @filters AS f
 outer APPLY 
   ( 
   SELECT *
        FROM [rpt].[tblFilds] AS g
        where f.fldFieldType=g.fldFieldType and g.fldFieldType <>'DEFAULT' and g.fldOperator= f.fldOperator
   ) G 
  outer apply(SELECT Top 1
            [fldValue]
        FROM [dbo].[tblDictionary] D
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
      , [fldFildName]
      , @fldFormId
      , [fldOrder]
      , [fldStyle]
      , [fldFildLabelTdStyle]
      , [fldFildDivStyle]
      , [fldFildTdStyle]
      , [flDModal]
      , [fldTypeCode]
      , [fldDisable]
      , [fldVisible]
      , [fldRegularExp]
      , [fldAutoCompelete]
      , [fldDefault]
      , [fldTypeName]
      , [fldNewLine]
      , [fldSize]
      , [fldSubmitName]
      , [fldSubmitQuery]
      , [fldSubmitRedirect]
      , [fldLabelText]
      , [fldListQuery]
      , [fldListTitle]
      , [fldframeURL]
      , [fldframeHeight]
      , [fldIsComputedFilde]
      , [fldComputedQuery]
      , [fldComputedDependenceFilde]
      , [fldLabel]
      , [fldFrameWith]
      , [fldButtonOnClick]
      , [fldTextAreaRows]
      , [fldTextAreaColumns]
      , [fldSubmitConfirm]
      , [fldSubmitConfirmMessage]
      , [fldIsPassWord]
      , [fldEncrypt]
      , [fldencryptionKey]
      , [fldSplit]
      , [fldDate]
      , [fldFixDate]
      , [fldWaitOnSubmit]
      , [fldDisableAfterDone]
      , [fldDate10]
      , [fldFileAccept]
      , [fldFileMaxSize]
      , [fldRequired]
      , [fldSubmitPreControl]
      , [fldFileMultiple]
      , [fldDirectScan]
      , [fldEnClient]
      , [fldReportName]
      , [fldAutoSplitChar]
      , [fldPlaceHolder]
      , [fldProgram]
      , [fldLazyReport]
      , [fldAccess]
      , [fldLog]
      , [fldSubmitLog]
      , [fldSync]
      , [fldSubmitSuccessfullMessage]
       , 'اتوگزارش'--,[fldGroupName]
    FROM [rpt].[tblFilds]
    where fldFieldType ='DEFAULT'
    /*افزودن فیلد گزارش جدولی و نموداری*/
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
    VALUES
        (N'گزارش جدولی', N'TableReport', @fldFormId, 1000,
            N'z-index: 10; height: 100%; width: 100%; font-size: 1.5vw; ',
            N'width: 50%; height: 10%; z-index: 10; font-size: 1.5vw; text-align: right; direction: rtl; display: inline; align-items: center; position: absolute; left: 10%; top: 10%; overflow: scroll;',
            N'width: 100%;  z-index: 10; font-size: 1.5vw; text-align: right; direction: rtl;  align-items: center;left: 10%; top: 10%; overflow: scroll;',
            N'', N'', N'REPORT', 0,~@isChart, NULL, N'', N'', NULL, 1, NULL, N'', N'', N'', N'', N'', N'', N'', NULL, NULL, NULL, NULL, 0, NULL, N'', 0, 0, 0, N'', 0, 0, N'', 0, 0, 0, 0, 0, 0, N'', 0, NULL, NULL, 0, 0, NULL, @QueryAndReportName, N'', N'', NULL, 1, 0, 0, N'', 0, N'', N'')
,
        (N'گزارش نموداری', N'ChartReport', @fldFormId, 1000,
            N'z-index: 10; height: 100%; width: 100%; font-size: 1.5vw; ',
            N'width: 50%; height: 10%; z-index: 10; font-size: 1.5vw; text-align: right; direction: rtl; display: inline; align-items: center; position: absolute; left: 10%; top: 10%; overflow: scroll;',
            N'width: 100%;  z-index: 10; font-size: 1.5vw; text-align: right; direction: rtl;  align-items: center;left: 10%; top: 10%; overflow: scroll;',
            N'', N'', N'REPORT', 0, @isChart, NULL, N'', N'', NULL, 1, NULL, N'', N'', N'', N'', N'', N'', N'', NULL, NULL, NULL, NULL, 0, NULL, N'', 0, 0, 0, N'', 0, 0, N'', 0, 0, 0, 0, 0, 0, N'', 0, NULL, NULL, 0, 0, NULL, @ChartReportName, N'', N'', NULL, 0, 0, 0, N'', 0, N'', N'')




    --***********************ساخت کویری*********************
    DECLARE  @setting rpt.SettingType
		,@command nvarchar(max)
		,@command_title nvarchar(max)
    delete @filters
    INSERT INTO @filters
        ([fldFieldName],[fldFieldType],[fldOperator],[fldOprand])
    SELECT
        f.[fldFieldName]
	  , S.fldType
      , f.[fldOperator]
     -- , f.[fldOprand]
	  , '#'+f.[fldFieldName]+'_'+CAST(f.fldID as varchar(max))+'#'
    FROM [rpt].[tblFilter] as f
  outer APPLY 
   ( 
	SELECT g.fldType , s.FieldName, g.fldFieldName, s.fldReportName
        from [rpt].[tblReportColumns] as s
     outer APPLY 
   ( 
   SELECT g.fldType , g.fldFieldName
            from [rpt].[tblGroupColumns]as g
            where g.fldFieldName=S.FieldName and g.fldGroupName=@GroupName 
   ) G
        where   fldGroupName=@GroupName and s.fldReportName=@ReportName and s.fldUserId=@userId
	 ) S
    where  f.fldReportName=@ReportName and f.fldFieldName=s.FieldName

    INSERT INTO @setting
        (FieldName, AggreegateFunc,IsGrouped)
    select FieldName, AggreegateFunc , IsGrouped
    from rpt.tblReportColumns
    where fldGroupName=@GroupName and fldReportName=@ReportName and fldUserId=@userId


    EXEC	 [rpt].[QueryGenerator]
		@Setting = @setting,
		@Filters = @filters,
		@ReportName = @GroupName,
		@index =1,
		@pageSize =50,
		@Query = @command OUTPUT

    EXEC	 [rpt].[QueryGenerator_title]
		@Setting = @setting,
		@Filters = @filters,
		@ReportName = @GroupName,
		@index =1,
		@pageSize =50,
		@Query = @command_title OUTPUT

    --******************** کویری های اتوکمپلت و لیست ************************
    INSERT INTO [dbo].[tblQuery]
        ([fldName]
        ,[fldCommand]
        ,[fldConnectionName]
        ,[fldProgram]
        ,[fldGroupName])
    SELECT
        'autoQuery_'+ CAST(@fldFormId AS VARCHAR)+'_'+f.[fldFieldName]+'_'+CAST(f.fldID as varchar(max))
     , S.fldQuery
     , @connection
     , NULL
     , 'اتوگزارش'
    FROM [rpt].[tblFilter] as f
  outer APPLY 
   ( 
SELECT g.fldType , g.fldFieldName, g.fldQuery
        from [rpt].[tblGroupColumns]as g
        where g.fldFieldName=f.fldFieldName and g.fldGroupName=@GroupName 
	) S
    where  f.fldReportName=@ReportName and f.fldFieldName=S.fldFieldName
        and S.fldQuery<>'' and (S.fldType='STRING' or S.fldType='LIST')
    --********************افزودن کویری************************
    INSERT INTO [dbo].[tblQuery]
        ([fldName]
        ,[fldCommand]
        ,[fldConnectionName]
        ,[fldProgram]
        ,[fldGroupName])
    VALUES
        (@QueryAndReportName
           , @command
           , @connection
           , NULL
           , 'اتوگزارش')

--********************افزودن کویری عنوان گزارش ************************
    INSERT INTO [dbo].[tblQuery]
        ([fldName]
        ,[fldCommand]
        ,[fldConnectionName]
        ,[fldProgram]
        ,[fldGroupName])
    VALUES
        (@QueryAndReportName+N'_title'
           ,N'  select round(count(*) / #lstPageSize#,1 )+1  as fldName From('+@command_title+')  q'
           , @connection
           , NULL
           , 'اتوگزارش')
    --*******************افزودن گزارش جدولی و نموداری و ای پی آی*****************
    declare @style nvarchar(max);
    declare @headTitle nvarchar(max);

    select @headTitle= cast(N'
      <style>
.pagination {
}

.pagination a span {
  color: black;
  float: right;
  padding: 8px 16px;
  text-decoration: none;
}

.pagination a.active {
  background-color: #4CAF50;
  color: white;
}

.pagination a:hover:not(.active) {background-color: #ddd;}
</style>

<div class="pagination">
  <a id="next" href="#"><<</a>
 صفحه <span id="index"></span> از <span id="count"></span>
 <a id="prev" href="#">>></a> 
 
</div>

 <script>
 var count = #Q:fldName#
 var pageIndex = 1
 if( $( "#txtPageIndex " ).val()){
  pageIndex = $( "#txtPageIndex " ).val();
  }
  
   $( "#count" ).text(count);
  document.getElementById(''index'').innerHTML =String( pageIndex)   ; 

 $( "#prev" ).click(function() {
   pageIndex=parseInt(pageIndex)-1;
    if(pageIndex<1){pageIndex=count;}

            document.getElementById(''index'').innerHTML =String( pageIndex)   ; 
           $( "#txtPageIndex" ).val(pageIndex);
         $(''#rpt_btnBuildQuery'').click();
  });

   $( "#next" ).click(function() {
   pageIndex=parseInt(pageIndex)+1;
   if(pageIndex>count){pageIndex=1;}
 
    document.getElementById(''index'').innerHTML = String(pageIndex);
           $( "#txtPageIndex" ).val(pageIndex);
      $(''#rpt_btnBuildQuery'').click();
     
  }); 
   </script>

      ' as nvarchar(max));
    select @style=fldStyle
    From [rpt].tblReports as r
outer apply (
 select *
        From [rpt].tblTables as f
        where r.fldTableType=f.fldName 
 ) ff
    where r.fldname=@ReportName

    INSERT [tblReport]
        ( [fldName], [fldTitle], [fldHeadTitle], [fldQuery], [fldGroupName], [fldIntialize], [fldPerLineIntialize], [fldShowAllColumns], [fldDesignID], [fldSpecial], [fldSpecialPattern], [fldFootTitle], [fldQueryTitle], [fldBorder], [fldTableCSSClass], [fldStyle], [fldTokenEncrypt], [fldScript], [fldShowSQLError], [fldUserReorder], [fldTrStyle], [fldSelectRow], [fldMulitpleSelect], [fldKeyField], [fldPrintHeadTitle], [fldPrintFootTitle], [fldSettingHidden], [fldProgram], [fldPrintUseHeader], [fldEndLinePage], [fldEndLine], [fldExportEnable], [fldRightClick], [fldExportDefault])
    VALUES
        ( @QueryAndReportName, N'گزارش جدولی' +@ReportName, @headTitle, @QueryAndReportName, N'اتوگزارش', NULL, NULL, 1, NULL, 0, N'', N'',  @QueryAndReportName+N'_title', 1, N'table'
 --fldStyle
 ,@style, NULL, NULL, NULL, 1, NULL, 1, 0, N'', N'', N'', 1, NULL, NULL, NULL, NULL, 1, NULL, NULL)
,
        ( @ChartReportName, N'گزارش نموداری' +@ReportName
--[fldHeadTitle]
, N'<script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/3.2.0/chart.min.js" integrity="sha512-VMsZqo0ar06BMtg0tPsdgRADvl0kDHpTbugCBBrL55KmucH6hP9zWdLIWY//OTfMnzz6xWQRxQqsUFefwHuHyg==" crossorigin="anonymous">
 </script>
  <div id="convas"> <canvas id="ReportChart"></canvas></div>'
, N'simple', N'اتوگزارش', NULL, NULL, 0, NULL, 1, N''
, N''--[fldFootTitle]
, N'simple', 0, N'', N'', NULL, NULL, NULL, 0, NULL, 1, 0, N'', N'', N'', 1, NULL, NULL, NULL, NULL, 0, NULL, NULL)

    INSERT INTO [dbo].[tblAPI]
        ([fldName]
        ,[fldQuery]
        ,[fldResualt]
        ,[fldProgram]
        ,[fldGroupName])
    VALUES
        (@QueryAndReportName--<fldName, nvarchar(50),>
           , @QueryAndReportName--<fldQuery, nvarchar(150),>
           , 1--<fldResualt, bit,>
           , NULL--<fldProgram, nvarchar(250),>
           , N'اتوگزارش'--<fldGroupName, nvarchar(200),>
		   )
    INSERT INTO [dbo].[tblFormAccessLevels]
        ([fldName]
        ,[fldFormID]
        ,[fldProgram])
    VALUES
        ('NULL'
           , @fldFormId
           , NULL)



    SELECT @fldLevelID=[fldID]
    FROM [dbo].[tblFormAccessLevels]
    where fldName='NULL' and fldFormID=@fldFormId
    INSERT INTO [dbo].[tblFormAccessDetail]
        ([fldLevelID]
        ,[fldFildName]
        ,[fldVisible]
        ,[fldDisable]
        ,[fldProgram]
        ,[fldFildID])
    VALUES
        (@fldLevelID
           , 'API:'+@QueryAndReportName
           , 1
           , 0
           , NULL
           , NULL)


    select @tblReportID=fldId
    From [tblReport]
    where [fldName]=@QueryAndReportName

    --**********Set Dependencies**************
    SELECT @btnRefreshReportID=[fldID]
    FROM [dbo].[tblFormFilds]
    where fldFormID=@fldFormId and fldFildName= 'rpt_btnBuildQuery'

    SELECT @fldReportID=[fldID]
    FROM [dbo].[tblFormFilds]
    where fldFormID=@fldFormId and fldFildName='TableReport'
    INSERT INTO [dbo].[tblFildDependence]
        (
        [fldFildID]
        ,[fldFildDepName]
        ,[fldQuery]
        ,[fldReportReSelect]
        ,[fldProgram]
        ,[fldFildDepID])
    values(@fldReportID, 'rpt_btnBuildQuery', 'simple', null, null, @btnRefreshReportID)

    --[FormGenerator]*****************افزودن فیلد های گزارش *************
	declare @hasGroupBy bit;
	SELECT @hasGroupBy= CASE
		WHEN SUM(CASE WHEN IsGrouped = 1 THEN 1 ELSE 0 END)<1  THEN 'FALSE'
		ELSE 'TRUE'
	END
    From @Setting

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
            SELECT @tblReportID , N'ردیف' , 'rowNumber', 1, '', 0, '', '', 2, 0, 0, 0
    union all
        SELECT TOP (1000)
            @tblReportID,
            CASE
				WHEN @hasGroupBy>0 and IsGrouped<1 and AggreegateFunc!=''  THEN   ISNULL(D.fldValue,[FieldName])+'_'+ AggreegateFunc
				WHEN @hasGroupBy>0 and IsGrouped<1 and AggreegateFunc=''  THEN   ISNULL(D.fldValue,[FieldName])+'_COUNT'  
				ELSE   ISNULL(D.fldValue,[FieldName])
			END 
			, CASE
				WHEN @hasGroupBy>0 and IsGrouped<1 and AggreegateFunc!=''  THEN  [FieldName]+'_'+ AggreegateFunc
				WHEN @hasGroupBy>0 and IsGrouped<1 and AggreegateFunc=''  THEN  [FieldName]+'_COUNT'  
				ELSE   [FieldName]
END 
, 1, '', 0, '', '', 2, 0, 0, 0
        FROM [rpt].[tblReportColumns] s
    outer apply(SELECT Top 1
                [fldValue]
            FROM [dbo].[tblDictionary] D
            where D.fldKey=s.[FieldName]
	) d
        where fldGroupName=@GroupName and fldReportName=@ReportName and fldUserId=@userId