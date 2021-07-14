USE KosarWebDBReporter
GO
TRUNCATE TABLE [rpt].[tblGroups]
TRUNCATE TABLE [rpt].[tblReports]
TRUNCATE TABLE [rpt].[tblGroupColumns]
TRUNCATE TABLE [rpt].[tblReportColumns]
TRUNCATE TABLE [rpt].[tblReportColumnsTemp]
TRUNCATE TABLE [rpt].[tblFilds]
TRUNCATE TABLE [rpt].[tblTables]
TRUNCATE TABLE [rpt].[tblFilter]
INSERT INTO [rpt].[tblGroups]
	([fldTitle],[fldName],[fldViewName],[fldConnectionName])
VALUES
	(N'حسابها و وام ها ', N'rpt.VSanadHesabVam', N'rpt.VSanadHesabVam', 'BANK')
	,
	(N'اسناد مشتتری', N'rpt.VsanadCustomer', N'rpt.VsanadCustomer', 'BANK')
INSERT INTO [rpt].[tblReports]
	([fldName],[fk_fldGroupTitle],[fldUserId],[fldIsChart],[fldChartType],[fldTableType])
VALUES
	(N'گزارش اول',N'rpt.VSanadHesabVam', N'hajjar', 0, N'bar', N'blue')	
           ,
	(N'گزارش دوم',N'rpt.VSanadHesabVam',N'hajjar', 0, N'bar', N'green')	
           ,
	( N'گزراش سند',N'rpt.VsanadCustomer', N'hajjar', 0, N'bar', N'blue')
INSERT INTO [rpt].[tblGroupColumns]
	([fldGroupName], [fldFieldName], [fldType],[fldQuery], [fldIsGroupable], [fldFuncDef], [fldIsGroupedDef], [fldIncludedDef])
VALUES
	(N'rpt.VSanadHesabVam', N'fldDate', N'NUMBER', N'', 0, N'', 0, 1)
 ,
	(N'rpt.VSanadHesabVam', N'fldHesabType', N'LIST'
--ListQuery
, N'
    SELECT fldHesabTypeName,
           fldHesabTypeCode
    FROM tblHesabType
    WHERE fldTag = 1
          AND fldHesabTypeCode <> 5;
', 0, N'MAX', 0, 1)
,
	(N'rpt.VSanadHesabVam', N'fldHesabID', N'STRING'
-- AutoCompleteQuery
, N'
SELECT TOP 10  cast(fldHesabID as nvarchar(10)) + ''--'' + fldName
FROM tblHesab
WHERE fldMainGrp not in (4,140) and (fldName LIKE ''%''+replace(@text,'' '',''%'')+''%'' 
	OR fldHesabID LIKE ''%''+replace(#text#,'' '',''%'')+''%'')
ORDER BY fldHesabID
', 0, N'MAX', 0, 1)
,
	(N'rpt.VSanadHesabVam', N'fldBed', N'NUMBER', N'', 0, N'MAX', 0, 1)
,
	(N'rpt.VSanadHesabVam', N'fldBes', N'NUMBER', N'', 0, N'MAX', 0, 1)
,
	(N'rpt.VSanadHesabVam', N'fldSanadID', N'NUMBER', N'', 0, N'MAX', 0, 1)
,
	(N'rpt.VSanadHesabVam', N'fldDescription', N'NUMBER', N'', 0, N'', 0, 1)
,
	(N'rpt.VSanadHesabVam', N'fldOperationType', N'NUMBER', N'', 0, N'', 0, 1)
,
	(N'rpt.VSanadHesabVam', N'fldNaghdPrice', N'NUMBER', N'', 0, N'', 0, 1)

,
	(N'rpt.VsanadCustomer', N'fldDate', N'NUMBER', N'', 0, N'', 0, 1)
,
	(N'rpt.VsanadCustomer', N'fldTime', N'NUMBER', N'', 0, N'', 0, 1)
,
	(N'rpt.VsanadCustomer', N'fldHesabType', N'LIST'
--ListQuery
, N'
    SELECT fldHesabTypeName,
           fldHesabTypeCode
    FROM tblHesabType
    WHERE fldTag = 1
          AND fldHesabTypeCode <> 5;
', 0, N'MAX', 0, 1)

,
	(N'rpt.VsanadCustomer', N'fldHesabID', N'STRING'
-- AutoCompleteQuery
, N'
SELECT TOP 20 fldHesabCode + '' -- ''+ fldHesabName FROM  tvHesabNew WHERE 
(fldHesabName LIKE ''%''+replace(cast(@text as varchar(100)),'' '',''%'')+''%'' 
OR 
fldHesabCode LIKE ''%''+replace(#text#,'' '',''%'')+''%'') and fldEnd = 1 and fldPatern = #user:key#  
', 0, N'MAX', 0, 1)
,
	(N'rpt.VsanadCustomer', N'fldBed', N'NUMBER', N'', 0, N'', 0, 1)
,
	(N'rpt.VsanadCustomer', N'fldBes', N'NUMBER', N'', 0, N'', 0, 1)
,
	(N'rpt.VsanadCustomer', N'fldSanadID', N'NUMBER', N'', 0, N'', 0, 1)
,
	(N'rpt.VsanadCustomer', N'fldDescription', N'NUMBER', N'', 0, N'', 0, 1)
,
	(N'rpt.VsanadCustomer', N'fldOperationType', N'NUMBER', N'', 0, N'', 0, 1)
,
	(N'rpt.VsanadCustomer', N'fldNaghdPrice', N'NUMBER', N'', 0, N'', 0, 1)
,
	(N'rpt.VsanadCustomer', N'fldReference', N'NUMBER', N'', 0, N'', 0, 1)
,
	(N'rpt.VsanadCustomer', N'fldStatus', N'NUMBER', N'', 0, N'', 0, 1)
,
	(N'rpt.VsanadCustomer', N'fldOperator', N'NUMBER', N'', 0, N'', 0, 1)
,
	(N'rpt.VsanadCustomer', N'fldLastUpdateDate', N'NUMBER', N'', 0, N'', 0, 1)
GO
INSERT [rpt].[tblReportColumns]
	([fldUserId],[fldReportId], [fldGroupName], [fldReportName], [FieldName], [AggreegateFunc], [IsGrouped])
VALUES
	 (N'hajjar',2, N'rpt.VSanadHesabVam', N'report2', N'fldHesabID', N'MAX', 1)
	,(N'hajjar',2, N'rpt.VSanadHesabVam', N'report2', N'fldBed', N'COUNT', 0)
	,(N'hajjar',2, N'rpt.VSanadHesabVam', N'report2', N'fldBes', N'AVG', 0)

	,(N'hajjar',3, N'rpt.VsanadCustomer', N'sanadReport', N'fldHesabType', N'MIN', 0)
	,(N'hajjar',3, N'rpt.VsanadCustomer', N'sanadReport', N'fldBed', N'MIN', 0)
	,(N'hajjar',3, N'rpt.VsanadCustomer', N'sanadReport', N'fldBes', N'MIN', 1)

	,(N'hajjar',1, N'rpt.VSanadHesabVam', N'report1', N'fldDate', N'', 0)
	,(N'hajjar',1, N'rpt.VSanadHesabVam', N'report1', N'fldHesabID', N'MIN', 0)
	,(N'hajjar',1, N'rpt.VSanadHesabVam', N'report1', N'fldBes', N'AVG', 0)
	,(N'hajjar',1, N'rpt.VSanadHesabVam', N'report1', N'fldSanadID', N'MAX', 1)
GO
--INSERT [rpt].[tblReportColumnsTemp] ([Included], [fldUserId], [FieldName], [AggreegateFunc], [IsGrouped]) VALUES 
-- (0, N'hajjar', N'fldDate', N'', 0)
--,(0, N'hajjar', N'fldTime', N'', 0)
--,(1, N'hajjar', N'fldHesabType', N'MIN', 0)
--,(0, N'hajjar', N'fldHesabID', N'', 0)
--,(1, N'hajjar', N'fldBed', N'MIN', 0)
--,(1, N'hajjar', N'fldBes', N'MIN', 1)
--,(0, N'hajjar', N'fldSanadID', N'', 0)
--,(0, N'hajjar', N'fldDescription', N'', 0)
--,(0, N'hajjar', N'fldOperationType', N'', 0)
--,(0, N'hajjar', N'fldNaghdPrice', N'', 0)
--,(0, N'hajjar', N'fldReference', N'', 0)
--,(0, N'hajjar', N'fldStatus', N'', 0)
--,(0, N'hajjar', N'fldOperator', N'', 0)
--,(0, N'hajjar', N'fldLastUpdateDate', N'', 0)
--GO
INSERT INTO [rpt].[tblFilter]
	([fldUserId],[fldReportId],[fldReportName],[fldFieldName],[fldOperator],[fldOprand])
VALUES
	 (N'hajjar',2, N'report2', N'fldHesabID', N'x=a', '')
	,(N'hajjar',2, N'report2', N'fldBed', N'x>=a', '')
	,(N'hajjar',2, N'report2', N'fldBes', N'x>=a', '') 
	,(N'hajjar',2, N'report2', N'fldBes', N'x>=a', '') 

	,(N'hajjar',3, N'sanadReport', N'fldHesabType', N'x=a', '')
	,(N'hajjar',3, N'sanadReport', N'fldBed', N'x>=a', '')
	,(N'hajjar',3, N'sanadReport', N'fldBes', N'x>=a', '')

	,(N'hajjar',1, N'report1', N'fldDate', N'x>=a', '')
	,(N'hajjar',1, N'report1', N'fldHesabID', N'x=a', '')
	,(N'hajjar',1, N'report1', N'fldBes', N'x>=a', '')
	,(N'hajjar',1, N'report1', N'fldSanadID', N'x>=a', 1)
GO

INSERT [rpt].[tblFilds]
	( [fldName], [fldFildName], [fldFieldType], [fldOperator], [fldOrder], [fldStyle], [fldFildLabelTdStyle], [fldFildDivStyle], [fldFildTdStyle], [flDModal], [fldTypeCode], [fldDisable], [fldVisible], [fldRegularExp], [fldAutoCompelete], [fldDefault], [fldTypeName], [fldNewLine], [fldSize], [fldSubmitName], [fldSubmitQuery], [fldSubmitRedirect], [fldLabelText], [fldListQuery], [fldListTitle], [fldframeURL], [fldframeHeight], [fldIsComputedFilde], [fldComputedQuery], [fldComputedDependenceFilde], [fldLabel], [fldFrameWith], [fldButtonOnClick], [fldTextAreaRows], [fldTextAreaColumns], [fldSubmitConfirm], [fldSubmitConfirmMessage], [fldIsPassWord], [fldEncrypt], [fldencryptionKey], [fldSplit], [fldDate], [fldFixDate], [fldWaitOnSubmit], [fldDisableAfterDone], [fldDate10], [fldFileAccept], [fldFileMaxSize], [fldRequired], [fldSubmitPreControl], [fldFileMultiple], [fldDirectScan], [fldEnClient], [fldReportName], [fldAutoSplitChar], [fldPlaceHolder], [fldProgram], [fldLazyReport], [fldAccess], [fldLog], [fldSubmitLog], [fldSync], [fldSubmitSuccessfullMessage], [fldGroupName])
VALUES
	(N'از:', N'NumberGreater', N'NUMBER', N'x>a', 1, N'z-index: 10; height: 100%; width: 100%; font-size: 1.5vw; ', N'width: 15%; height: 9.41375%; z-index: 10; font-size: 1.5vw; text-align: right; direction: rtl; align-items: center; left: 89.5132%; top: 4.06486%;', N'width: 100px; height: 6.56835%; z-index: 10; font-size: 1.5vw; text-align: right; direction: rtl; display: grid; align-items: center; left: 70.289%; top: 4.51313%;', N'', N'', N'TEXT', 0, 1, NULL, N'', N'', NULL, 1, NULL, N'', N'', N'', N'', N'', N'', N'', NULL, NULL, NULL, NULL, 1, NULL, N'', 0, 0, 0, N'', 0, 0, N'', 0, 0, 0, 0, 0, 0, N'', 0, NULL, NULL, 0, 0, NULL, N'', N'', N'', NULL, 0, 0, 0, N'', 0, N'', N'')
,
	(N'مساوی یا بیشتر از :', N'NumberGreaterOrEqual', N'NUMBER', N'x>=a', 1, N'z-index: 10; height: 100%; width: 100%; font-size: 1.5vw; ', N'width: 15%; height: 9.41375%; z-index: 10; font-size: 1.5vw; text-align: right; direction: rtl; align-items: center; left: 89.5132%; top: 4.06486%;', N'width: 100px; height: 6.56835%; z-index: 10; font-size: 1.5vw; text-align: right; direction: rtl; display: grid; align-items: center; left: 70.289%; top: 4.51313%;', N'', N'', N'TEXT', 0, 1, NULL, N'', N'', NULL, 1, NULL, N'', N'', N'', N'', N'', N'', N'', NULL, NULL, NULL, NULL, 1, NULL, N'', 0, 0, 0, N'', 0, 0, N'', 0, 0, 0, 0, 0, 0, N'', 0, NULL, NULL, 0, 0, NULL, N'', N'', N'', NULL, 0, 0, 0, N'', 0, N'', N'')
,
	(N'تا:', N'NumberLess', N'NUMBER', N'x<a', 1, N'z-index: 10; height: 100%; width: 100%; font-size: 1.5vw; ', N'width: 15%; height: 9.41375%; z-index: 10; font-size: 1.5vw; text-align: right; direction: rtl;  align-items: center;  left: 89.5132%; top: 4.06486%;', N'width: 100px;height: 6.56835%; z-index: 10; font-size: 1.5vw; text-align: right; direction: rtl; display: grid; align-items: center;  left: 70.289%; top: 4.51313%;', N'', N'', N'TEXT', 0, 1, NULL, N'', N'', NULL, 1, NULL, N'', N'', N'', N'', N'', N'', N'', NULL, NULL, NULL, NULL, 1, NULL, N'', 0, 0, 0, N'', 0, 0, N'', 0, 0, 0, 0, 0, 0, N'', 0, NULL, NULL, 0, 0, NULL, N'', N'', N'', NULL, 0, 0, 0, N'', 0, N'', N'')
,
	(N'مساوی یا کمتر از:', N'NumberLessOrEqual', N'NUMBER', N'x<=a', 1, N'z-index: 10; height: 100%; width: 100%; font-size: 1.5vw; ', N'width: 15%; height: 9.41375%; z-index: 10; font-size: 1.5vw; text-align: right; direction: rtl;  align-items: center;  left: 89.5132%; top: 4.06486%;', N'width: 100px;height: 6.56835%; z-index: 10; font-size: 1.5vw; text-align: right; direction: rtl; display: grid; align-items: center;  left: 70.289%; top: 4.51313%;', N'', N'', N'TEXT', 0, 1, NULL, N'', N'', NULL, 1, NULL, N'', N'', N'', N'', N'', N'', N'', NULL, NULL, NULL, NULL, 1, NULL, N'', 0, 0, 0, N'', 0, 0, N'', 0, 0, 0, 0, 0, 0, N'', 0, NULL, NULL, 0, 0, NULL, N'', N'', N'', NULL, 0, 0, 0, N'', 0, N'', N'')
,
	(N'از تاریخ:', N'fldDATE', N'STRING', N'x<a', 1, N'z-index: 10; height: 100%; width: 100%; font-size: 1.5vw; ', N'width:15%; height: 9.41375%; z-index: 10; font-size: 1.5vw; text-align: right; direction: rtl;  align-items: center; left: 89.5132%; top: 4.06486%;', N'width: 100px ; height: 6.56835%; z-index: 10; font-size: 1.5vw; text-align: right; direction: rtl; display: grid; align-items: center; left: 70.289%; top: 4.51313%;', N'', N'', N'TEXT', 0, 1, NULL, N'', N'', NULL, 1, NULL, N'', N'', N'', N'', N'', N'', N'', NULL, NULL, NULL, NULL, 1, NULL, N'', 0, 0, 0, N'', 0, 0, N'', 0, 0, 0, 0, 0, 0, N'', 0, NULL, NULL, 0, 0, NULL, N'', N'', N'', NULL, 0, 0, 0, N'', 0, N'', N'')
,
	(N'', N'equsl', N'STRING', N'x=a', 1, N'z-index: 10; height: 100%; width: 100%; font-size: 1.5vw; ', N'width:15%; height: 9.41375%; z-index: 10; font-size: 1.5vw; text-align: right; direction: rtl;  align-items: center; left: 89.5132%; top: 4.06486%;', N'width: 100px ; height: 6.56835%; z-index: 10; font-size: 1.5vw; text-align: right; direction: rtl; display: grid; align-items: center; left: 70.289%; top: 4.51313%;', N'', N'', N'TEXT', 0, 1, NULL, N'', N'', NULL, 1, NULL, N'', N'', N'', N'', N'', N'', N'', NULL, NULL, NULL, NULL, 1, NULL, N'', 0, 0, 0, N'', 0, 0, N'', 0, 0, 0, 0, 0, 0, N'', 0, NULL, NULL, 0, 0, NULL, N'', N'--', N'', NULL, 0, 0, 0, N'', 0, N'', N'')
,
	(N'', N'equsl', N'LIST', N'x=a', 1, N'z-index: 10; height: 100%; width: 100%; font-size: 1.5vw; ', N'width:15%; height: 9.41375%; z-index: 10; font-size: 1.5vw; text-align: right; direction: rtl;  align-items: center; left: 89.5132%; top: 4.06486%;', N'width: 100px ; height: 6.56835%; z-index: 10; font-size: 1.5vw; text-align: right; direction: rtl; display: grid; align-items: center; left: 70.289%; top: 4.51313%;', N'', N'', N'LIST', 0, 1, NULL, N'', N'', NULL, 1, NULL, N'', N'', N'', N'', N'', N'', N'', NULL, NULL, NULL, NULL, 1, NULL, N'', 0, 0, 0, N'', 0, 0, N'', 0, 0, 0, 0, 0, 0, N'', 0, NULL, NULL, 0, 0, NULL, N'', N'', N'', NULL, 0, 0, 0, N'', 0, N'', N'')

--المانهای صفحه بندی
,
	(N'شماره صفحه', N'txtPageIndex', N'DEFAULT', N'', 200, N'z-index: 10; height: 10%; width: 10%; font-size: 1.5vw; ', N'width: 10%; height: 10%; z-index: 10; font-size: 1.5vw; text-align: right; direction: rtl; display: none; align-items: center; position: absolute; left: 91.0448%; top: 2.56714%;', N'width: 10%; height: 10%; z-index: 10; font-size: 1.5vw; text-align: right; direction: rtl; display: none; align-items: center; position: absolute; left: 71.3249%; top: 3.36114%;', N'', N'', N'TEXT', 0, 1, NULL, N'', N'1', NULL, 0, NULL, N'', N'', N'', N'', N'', N'صفحه بندی', N'', NULL, NULL, NULL, NULL, 1--inline 
	, NULL, N'', 0, 0, 0, N'', 0, 0, N'', 0, 0, 0, 0, 0, 0, N'', 0, NULL, NULL, 0, 0, NULL, N'', N'', N'', N'BankdariWeb', 0, 0, 0, N'', 0, N'', N'صفحه بندی')
,
	(N'اندازه صفحه', N'lstPageSize', N'DEFAULT', N'',200, N'z-index: 10; height: 100%; width: 100%; font-size: 1.5vw; ', N'width:15%; height: 9.41375%; z-index: 10; font-size: 1.5vw; text-align: right; direction: rtl;  align-items: center; left: 89.5132%; top: 4.06486%;', N'width: 100px ; height: 6.56835%; z-index: 10; font-size: 1.5vw; text-align: right; direction: rtl; display: grid; align-items: center; left: 70.289%; top: 4.51313%;', N'', N'', N'LIST', 0, 1, NULL, N'', N'20', NULL, 1, NULL, N'', N'', N'', N'', N'Q_PageSize', N'صفحه بندی', N'', NULL, NULL, NULL, NULL, 1, NULL, N'', 0, 0, 0, N'', 0, 0, N'', 0, 0, 0, 0, 0, 0, N'', 0, NULL, NULL, 0, 0, NULL, N'', N'', N'', NULL, 0, 0, 0, N'', 0, N'', N'صفحه بندی')

,
	(N'نمایش گزارش', N'rpt_btnBuildQuery', N'DEFAULT', N'', 900, N'z-index: 10; height: 100%; width: 40%; font-size: 1.5vw; ', N'width:15%; height: 9.41375%; z-index: 10; font-size: 1.5vw; text-align: right; direction: rtl;  align-items: center; left: 89.5132%; top: 4.06486%;', N'width: 100%;  z-index: 10; font-size: 1.5vw; text-align: right; direction: rtl;  align-items: center;left: 10%; top: 10%;', N'', N'', N'SUBMITN', 0, 1, NULL, N'', N'', NULL, 1, NULL, N'نمایش گزارش', N'', N'', N'', N'', N'', N'', NULL, NULL, NULL, NULL, 1, NULL, N'', 0, 0, 0, N'', 0, 0, N'', 0, 0, 0, 0, 0, 0, N'', 0, NULL, NULL, 0, 0, NULL, N'', N'', N'', NULL, 0, 0, 0, N'', 0, N'', N'')
--,(N'کوئری ساخته شده', N'rpt_fldQueryString', N'DEFAULT', N'', 1000, N'z-index: 10;  width: 100%;height: 150px; font-size: 1.5vw;  ', N'width:15%; height: 9.41375%; z-index: 10; font-size: 1.5vw; text-align: right; direction: rtl;  align-items: center; left: 89.5132%; top: 4.06486%;', N'width: 100%;  z-index: 10; font-size: 1.5vw; text-align: right; direction: rtl;  align-items: center;left: 10%; top: 10%;', N'', N'', N'TEXTAREA', 0, 1, NULL, N'', N'', NULL, 1, NULL, N'', N'', N'', N'', N'', N'', N'', NULL, NULL, NULL, NULL, 1, NULL, N'', 0, 0, 0, N'', 0, 0, N'', 0, 0, 0, 0, 0, 0, N'', 0, NULL, NULL, 0, 0, NULL, N'', N'', N'', NULL, 0, 0, 0, N'', 0, N'', N'')
,
	(N'نام گزارش', N'htxtReportName', N'DEFAULT', N'', 901, N'z-index: 10; height: 0%; width: 0%; font-size: 1.5vw; ', N'width: 0%; height: 0%; z-index: 10; font-size: 1.5vw; text-align: right; direction: rtl; display: grid; align-items: center; position: absolute; left: 59.82%; top: 2.03232%;', N'width: 0%; height: 0%; z-index: 10; font-size: 1.5vw; text-align: right; direction: rtl; display: grid; align-items: center; position: absolute; left: 40.5586%; top: 3.36114%;', N'', N'', N'HIDDEN', 0, 1, NULL, N'', N'#PQ:ReportName|#UP:ReportName##', NULL, 0, NULL, N'', N'', N'', N'', N'reportNames', N'نام گزارش', N'', NULL, NULL, NULL, NULL, 0, NULL, N'', 0, 0, 0, N'', 0, 0, N'', 0, 0, 0, 0, 0, 0, N'', 0, NULL, NULL, 0, 0, NULL, N'', N'', N'', N'BankdariWeb', 0, 0, 0, N'', 0, N'', N'')
,
	(N'گروه گزارش', N'htxtGroupName', N'DEFAULT', N'', 902, N'z-index: 10; height: 0%; width: 0%; font-size: 1.5vw; ', N'width: 0%; height: 0%; z-index: 10; font-size: 1.5vw; text-align: right; direction: rtl; display: grid; align-items: center; position: absolute; left: 91.0448%; top: 2.56714%;', N'width: 0%; height: 0%; z-index: 10; font-size: 1.5vw; text-align: right; direction: rtl; display: grid; align-items: center; position: absolute; left: 71.3249%; top: 3.36114%;', N'', N'', N'HIDDEN', 0, 1, NULL, N'', N'#PQ:GroupName|#UP:GroupName##', NULL, 0, NULL, N'', N'', N'', N'', N'reportGroups', N'گروه گزارش', N'', NULL, NULL, NULL, NULL, 0, NULL, N'', 0, 0, 0, N'', 0, 0, N'', 0, 0, 0, 0, 0, 0, N'', 0, NULL, NULL, 0, 0, NULL, N'', N'', N'', N'BankdariWeb', 0, 0, 0, N'', 0, N'', N'')




GO

-- Insert rows into table 'tblReports'
INSERT INTO [rpt].[tblTables]
	( -- columns to insert data into
		[fldName], [fldStyle]
	)
VALUES
	( -- first row: values for the columns in the list above
		'green', N'
		table #mtb {
		width: 100%;
		background-color: #FFFFFF;
		border-collapse: collapse;
		border-width: 2px;
		border-color: #cecece;
		border-style: solid;
		color: #000000;
		text-align: center !important;
		font-size: 1.5vw !important;
		}

		table #mtb td,
		table #mtb th {
		border-width: 2px;
		border-color: #cecece;
		border-style: solid;
		text-align: center !important;
		}

		table #mtb thead,
		table thead #mtb {
		background-color: #598696;
		text-align: center !important;
		color: #FFFFFF;
		}

		tbody #mtb tr:hover,
		tbody #mtb td:hover {
		background-color: #8dacb8 !important;
		color: #000 !important;
		text-align: center !important;
		}

		#mtb tbody tr:nth-child(even) {
		background-color: #f9f9f9;
		text-align: center !important;
		}

		#mtb .rowSelected {
		background-color: #9fbcc7 !important;
		color: #fff !important;
		text-align: center !important;
		}
 '
),
	( -- second row: values for the columns in the list above
		'blue', N'
 table #mtb {
  width: 100%;
  background-color: #FFFFFF;
  border-collapse: collapse;
  border-width: 2px;
  border-color: #ececec;
  border-style: solid;
  color: #000000;
  text-align: center !important;
  font-size: 1.4vw !important;
  font-family: ''iransans'';
	padding: 3px;
}

table #mtb td,
table #mtb th {
  border-width: 2px;
  border-color: #ececec;
  border-style: solid;
  text-align: center !important;
}

table #mtb thead,
table thead #mtb {
  background-color: #456990;
  text-align: center !important;
  color: #fff;
}

tbody #mtb tr:hover,
tbody #mtb td:hover {
  color: #000 !important;
  text-align: center !important;
  background-color: #D2D2CF !important;
}

#mtb tbody tr:nth-child(even) {
  background-color: #F7F7F7;
  text-align: center !important;
}

#mtb .rowSelected {
  background-color: #c9d2d6 !important;
  color: #000 !important;
  text-align: center !important;
}

#mtb td {
  TEXT-ALIGN: center !important;
}

 '
)
-- add more rows here
GO


EXEC	[rpt].[FormGenerator]
		@userId = 'hajjar',
		@ReportId = 2
		
EXEC	[rpt].[FormGenerator]
		@userId = 'hajjar',
		@ReportId = 1

EXEC	[rpt].[FormGenerator]
		@userId = 'hajjar',
		@ReportId = 3