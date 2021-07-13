SET IDENTITY_INSERT [dbo].[tblReportFilde] ON
delete [dbo].[tblReportFilde]
INSERT INTO [dbo].[tblReportFilde]
           ( [fldID]
		   ,[fldReportID]
           ,[fldTitle]
           ,[fldName]
           ,[fldOrder]
           ,[fldLink]
           ,[fldLinkShow]
           ,[fldButton]
           ,[fldButtonFunction]
           ,[fldStyle]
           ,[fldShowType]
           ,[fldSplit]
           ,[fldCalcExperssion]
           ,[fldSum]
           ,[fldEncrypt]
           ,[fldEncKey]
           ,[fldTdStyle]
           ,[fldWidth]
           ,[fldNoWrap]
           ,[fldPrint]
           ,[fldForeColor]
           ,[fldBackColor]
           ,[fldFont]
           ,[fldFontSize]
           ,[fldEditable]
           ,[fldIsReport]
           ,[fldProgram]
           ,[fldDiv])
  SELECT [fldID]
      ,[fldReportID]
      ,[fldTitle]
      ,[fldName]
      ,[fldOrder]
      ,[fldLink]
      ,[fldLinkShow]
      ,[fldButton]
      ,[fldButtonFunction]
      ,[fldStyle]
      ,[fldShowType]
      ,[fldSplit]
      ,[fldCalcExperssion]
      ,[fldSum]
      ,[fldEncrypt]
      ,[fldEncKey]
      ,[fldTdStyle]
      ,[fldWidth]
      ,[fldNoWrap]
      ,[fldPrint]
      ,[fldForeColor]
      ,[fldBackColor]
      ,[fldFont]
      ,[fldFontSize]
      ,[fldEditable]
      ,[fldIsReport]
      ,[fldProgram]
      ,[fldDiv]
  FROM [KosarWebDBBank].[dbo].[tblReportFilde]
  where fldReportID in (
  SELECT  [fldID]
FROM [KosarWebDBBank].[dbo].[tblReport]
  where fldGroupName='����� ���')  

SET IDENTITY_INSERT [dbo].[tblReportFilde] OFF