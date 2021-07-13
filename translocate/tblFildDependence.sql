SET IDENTITY_INSERT KosarWebDBAutoReport.[dbo].[tblFildDependence] ON
delete KosarWebDBAutoReport.[dbo].[tblFildDependence]
INSERT INTO [dbo].[tblFildDependence]
           (fldID
		   ,[fldFildID]
           ,[fldFildDepName]
           ,[fldQuery]
           ,[fldReportReSelect]
           ,[fldProgram]
           ,[fldFildDepID])
   SELECT  dep.[fldID]
      ,[fldFildID]
      ,[fldFildDepName]
      ,[fldQuery]
      ,[fldReportReSelect]
      ,[fldProgram]
      ,[fldFildDepID]
  FROM [KosarWebDBBank].[dbo].[tblFildDependence] dep
  outer apply (
  SELECT  [fldID]
  FROM [KosarWebDBBank].[dbo].[tblFormFilds]
  where dep.[fldFildID]= fldID and  fldFormID in(10257,10657)
  )oap 
  where oap.fldID Is NOT NULL
SET IDENTITY_INSERT KosarWebDBAutoReport.[dbo].[tblFildDependence] OFF