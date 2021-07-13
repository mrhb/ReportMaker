SET IDENTITY_INSERT KosarWebDBAutoReport.[dbo].[tblQuery] ON
delete KosarWebDBAutoReport.[dbo].[tblQuery]
INSERT INTO KosarWebDBAutoReport.[dbo].[tblQuery]
           ([fldID]
		   ,[fldName]
           ,[fldCommand]
           ,[fldConnectionName]
           ,[fldProgram]
           ,[fldGroupName])
    SELECT  [fldID]
      ,[fldName]
      ,[fldCommand]
      ,[fldConnectionName]
      ,[fldProgram]
      ,[fldGroupName]
  FROM [KosarWebDBBank].[dbo].[tblQuery]
where fldGroupName= 'ê“«—‘ ”«“'
SET IDENTITY_INSERT KosarWebDBAutoReport.[dbo].[tblQuery] OFF