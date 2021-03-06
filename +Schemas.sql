use KosarWebDBReporter
IF (NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'rpt')) 
BEGIN
    EXEC ('CREATE SCHEMA [rpt]')
END
GO
IF NOT EXISTS (SELECT * FROM sys.types WHERE name = 'FilterType' AND is_table_type = 1 /*AND is_user_defined = 1*/ )
BEGIN
    /****** GOObject:  UserDefinedTableType [rpt].[FilterType]    Script Date: 05/03/1400 08:19:16 ق.ظ ******/
    CREATE TYPE [rpt].[FilterType] AS TABLE(
        [fldID] [bigint] IDENTITY(1,1) NOT NULL,
        [fldFieldName] [nvarchar](50) NOT NULL,
        [fldFieldType] [nvarchar](10) NOT NULL,
        [fldOperator] [nvarchar](10) NOT NULL,
        [fldOprand] [nvarchar](max) NULL,
        CHECK (([fldOperator]='x=a' OR [fldOperator]='x<>a' OR [fldOperator]='x<a' OR [fldOperator]='x<=a' OR [fldOperator]='x>a' OR [fldOperator]='x>=a' OR [fldOperator]='b<x<a' OR [fldOperator]='b<x<=a' OR [fldOperator]='b<=x<=a' OR [fldOperator]='b<=x<a' OR [fldOperator]='in' OR [fldOperator]='notIn' OR [fldOperator]='like' OR [fldFieldType]='NUMBER' OR [fldFieldType]='STRING' OR [fldFieldType]='DATETIME'))
    )
END
GO
IF NOT EXISTS (SELECT * FROM sys.types WHERE name = 'SettingType' AND is_table_type = 1 /*AND is_user_defined = 1*/ )
BEGIN
    /****** Object:  UserDefinedTableType [rpt].[SettingType]    Script Date: 05/03/1400 08:19:16 ق.ظ ******/
    CREATE TYPE [rpt].[SettingType] AS TABLE(
        [FieldName] [varchar](50) NULL,
        [AggreegateFunc] [varchar](10) NULL,
        [IsGrouped] [bit] NULL,
        CHECK (([AggreegateFunc]='VARP' OR [AggreegateFunc]='VAR' OR [AggreegateFunc]='SUM' OR [AggreegateFunc]='STRING_AGG' OR [AggreegateFunc]='STDEVP' OR [AggreegateFunc]='STDEV' OR [AggreegateFunc]='MIN' OR [AggreegateFunc]='MAX' OR [AggreegateFunc]='GROUPING_ID' OR [AggreegateFunc]='GROUPING' OR [AggreegateFunc]='COUNT_BIG' OR [AggreegateFunc]='COUNT' OR [AggreegateFunc]='CHECKSUM_AGG' OR [AggreegateFunc]='AVG' OR [AggreegateFunc]='APPROX_COUNT_DISTINCT' OR [AggreegateFunc]=''))
    )
END
GO
-- =============================================
-- Author:		M.Reza Hajjar
-- Create date: 1400/03/02
-- Description: این تابع  ورودی ها را به رشته معتبری از محدودیت تبدیل میکند 
-- و در صورت بروز خطا آنرا در پیامها پرینت میکند
-- =============================================
CREATE OR ALTER FUNCTION [rpt].[criteriaBuilder]
(	
	@FieldName [nvarchar](50),
	@FieldType [nvarchar](10),
	@Operator  [nvarchar](10),
	@Oprand    [nvarchar](max)
)
RETURNS nvarchar(50)  
AS
BEGIN
    declare @Criteria [nvarchar](50);
    SET @Criteria =   
        CASE  
			WHEN @FieldType='DATE&TIME' THEN [rpt].[DateTime_criteriaBuilder](@FieldName,@Operator,@Oprand)
			WHEN @FieldType='NUMBER' THEN  [rpt].[Number_criteriaBuilder](@FieldName,@Operator,@Oprand)
			WHEN (@FieldType='STRING') or (@FieldType='LIST') THEN  [rpt].[String_criteriaBuilder](@FieldName,@Operator,@Oprand)
			ELSE  'null in Criteria Builder'
		END;
    RETURN  @Criteria;
END;  
GO

-- =============================================
-- Author:		M.Reza Hajjar
-- Create date: 1400/03/02
-- Description: این تابع  ورودی ها را به رشته معتبری از محدودیت تبدیل میکند 
-- و در صورت بروز خطا آنرا در پیامها پرینت میکند
-- =============================================
CREATE OR ALTER FUNCTION [rpt].[DateTime_criteriaBuilder]
(	
	@FieldName [nvarchar](50),
	@Operator  [nvarchar](10),
	@Oprand    [nvarchar](max)
)
RETURNS nvarchar(50)   
AS
BEGIN
    -- Declare the return variable here
    DECLARE @criteria nvarchar(50)

    -- Add the T-SQL statements to compute the return value here
    SELECT @criteria = null

    -- Return the result of the function
    RETURN @criteria

END
GO

-- =============================================
-- Author:		M.Reza Hajjar
-- Create date: 1400/03/02
-- Description: این تابع  ورودی ها را به رشته معتبری از محدودیت تبدیل میکند 
-- و در صورت بروز خطا آنرا در پیامها پرینت میکند
-- =============================================
CREATE OR ALTER FUNCTION [rpt].[Number_criteriaBuilder]
(	
	@FieldName [nvarchar](50),
	@Operator  [nvarchar](10),
	@Oprand    [nvarchar](max)
)
RETURNS nvarchar(50)   
AS
BEGIN
    declare @Criteria [nvarchar](50)=' ';

    declare @indx  int,@Oprand_a [nvarchar](max),@Oprand_b [nvarchar](max);
    if (@Oprand='') return null;
    select @indx=CHARINDEX('@@',@Oprand)
    select @Oprand_a=@Oprand
    IF (@indx>0)
BEGIN
        select @Oprand_a=LEFT(@Oprand,@indx - 1)
        select @Oprand_b=Right(@Oprand,LEN(@Oprand)-@indx)
    END



    IF ((CHARINDEX('x>',@Operator)>0) or (CHARINDEX('x<',@Operator)>0))
	BEGIN
        SET @Criteria = REPLACE(@Operator, 'x', '['+@FieldName+']');
        IF ((CHARINDEX('a',@Operator)>0))
			BEGIN
            SET @Criteria =SUBSTRING(@Criteria, 1,Len(@Criteria)-1) + @Oprand_a;
        END
        IF ((CHARINDEX('b',@Operator)>0))
			BEGIN
            if (@Oprand_b='') return null;
            SET @Criteria = @Oprand_b + SUBSTRING(@Criteria, 2,Len(@Criteria))
        ;
        END
        SET	@Criteria = @Criteria+' ';
    END
ELSE If(@Operator='in')
	BEGIN
        SET	@Criteria ='['+@FieldName+'] IN ('+REPLACE(@Oprand, '@@', ',')+') ';
    END
ELSE If( @Operator='notIn' )
	BEGIN
        SET	@Criteria ='['+@FieldName+'] NOT IN ('+REPLACE(@Oprand, '@@', ',')+') ';
    END
ELSE	
	SET	@Criteria = 'NULL in Number_criteriaBuilder ' ;
    RETURN @criteria
END
GO


-- =============================================
-- Author:		M.Reza Hajjar
-- Create date: 1400/03/02
-- Description: این تابع  ورودی ها را به رشته معتبری از محدودیت تبدیل میکند 
-- و در صورت بروز خطا آنرا در پیامها پرینت میکند
-- =============================================
CREATE OR ALTER FUNCTION [rpt].[String_criteriaBuilder]
(	
	@FieldName [nvarchar](50),
	@Operator  [nvarchar](10),
	@Oprand    [nvarchar](max)
)
RETURNS nvarchar(50)   
AS
BEGIN

    declare @Criteria [nvarchar](50)=' ';

    declare @indx  int,@Oprand_a [nvarchar](max),@Oprand_b [nvarchar](max);
    if (@Oprand='') return null;
    select @indx=CHARINDEX('@@',@Oprand)
    select @Oprand_a=@Oprand
    IF (@indx>0)
BEGIN
        select @Oprand_a=LEFT(@Oprand,@indx - 1)
        select @Oprand_b=Right(@Oprand,LEN(@Oprand)-@indx)
    END

    IF ((CHARINDEX('x>',@Operator)>0) or (CHARINDEX('x<',@Operator)>0) or (CHARINDEX('x=',@Operator)>0))
	BEGIN
        SET @Criteria = REPLACE(@Operator, 'x', '['+@FieldName+']');
        IF ((CHARINDEX('a',@Operator)>0))
			BEGIN
            SET @Criteria =SUBSTRING(@Criteria, 1,Len(@Criteria)-1) + @Oprand_a;
        END
        IF ((CHARINDEX('b',@Operator)>0))
			BEGIN
            if (@Oprand_b='') return null;
            SET @Criteria = @Oprand_b + SUBSTRING(@Criteria, 2,Len(@Criteria))
        ;
        END
        SET	@Criteria = @Criteria+' ';
    END
ELSE If(@Operator='like')
	BEGIN
        select @indx=CHARINDEX('@@',@Oprand)
        if (@indx>0) return null;
        SET	@Criteria =  '['+@FieldName+'] like %'+@Oprand+'@@ ';
    END
ELSE If(@Operator='in')
	BEGIN
        SET	@Criteria ='['+@FieldName+'] IN ('+REPLACE(@Oprand, '@@', ',')+') ';
    END
ELSE If( @Operator='notIn' )
	BEGIN
        SET	@Criteria ='['+@FieldName+'] NOT IN ('+REPLACE(@Oprand, '@@', ',')+') ';
    END
ELSE	
	SET	@Criteria =  'NULL';
    RETURN @criteria
END
GO
IF OBJECT_ID('dbo.tblDictionary', 'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[tblDictionary](
    	[fldID] [bigint] IDENTITY(1,1) NOT NULL,
    	[fldKey] [nvarchar](50) NOT NULL,
    	[fldValue] [nvarchar](50) NULL,
    	[fldSaveDate] [datetime] NULL,
    	[fldOperator] [nvarchar](100) NULL,
     CONSTRAINT [PK_tblDictionary] PRIMARY KEY CLUSTERED 
    (
    	[fldKey] ASC
    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
    ) ON [PRIMARY]
    
    ALTER TABLE [dbo].[tblDictionary] ADD  CONSTRAINT [DF_tblDictionary_fldSaveDate]  DEFAULT (getdate()) FOR [fldSaveDate]
END
GO
IF OBJECT_ID('rpt.tblFilds', 'U') IS NULL
BEGIN
    CREATE TABLE [rpt].[tblFilds](
    	[fldName] [nvarchar](500) NULL,
    	[fldFildName] [nvarchar](500) NULL,
    	[fldFieldType] [nvarchar](50) NOT NULL,
    	[fldOperator] [nvarchar](10) NOT NULL,
    	[fldOrder] [int] NULL,
    	[fldStyle] [nvarchar](max) NULL,
    	[fldFildLabelTdStyle] [nvarchar](max) NULL,
    	[fldFildDivStyle] [nvarchar](max) NULL,
    	[fldFildTdStyle] [nvarchar](max) NULL,
    	[flDModal] [nvarchar](50) NULL,
    	[fldTypeCode] [nvarchar](20) NULL,
    	[fldDisable] [bit] NULL,
    	[fldVisible] [bit] NULL,
    	[fldRegularExp] [nvarchar](250) NULL,
    	[fldAutoCompelete] [nvarchar](max) NULL,
    	[fldDefault] [nvarchar](100) NULL,
    	[fldTypeName] [nvarchar](50) NULL,
    	[fldNewLine] [bit] NULL,
    	[fldSize] [nvarchar](50) NULL,
    	[fldSubmitName] [nvarchar](50) NULL,
    	[fldSubmitQuery] [nvarchar](200) NULL,
    	[fldSubmitRedirect] [nvarchar](500) NULL,
    	[fldLabelText] [nvarchar](max) NULL,
    	[fldListQuery] [nvarchar](max) NULL,
    	[fldListTitle] [nvarchar](150) NULL,
    	[fldframeURL] [nvarchar](max) NULL,
    	[fldframeHeight] [nvarchar](50) NULL,
    	[fldIsComputedFilde] [bit] NULL,
    	[fldComputedQuery] [nvarchar](200) NULL,
    	[fldComputedDependenceFilde] [nvarchar](500) NULL,
    	[fldLabel] [bit] NULL,
    	[fldFrameWith] [nvarchar](20) NULL,
    	[fldButtonOnClick] [nvarchar](1350) NULL,
    	[fldTextAreaRows] [int] NULL,
    	[fldTextAreaColumns] [int] NULL,
    	[fldSubmitConfirm] [bit] NULL,
    	[fldSubmitConfirmMessage] [nvarchar](450) NULL,
    	[fldIsPassWord] [bit] NULL,
    	[fldEncrypt] [bit] NULL,
    	[fldencryptionKey] [nvarchar](max) NULL,
    	[fldSplit] [bit] NULL,
    	[fldDate] [bit] NULL,
    	[fldFixDate] [bit] NULL,
    	[fldWaitOnSubmit] [bit] NULL,
    	[fldDisableAfterDone] [bit] NULL,
    	[fldDate10] [bit] NULL,
    	[fldFileAccept] [nvarchar](100) NULL,
    	[fldFileMaxSize] [bigint] NULL,
    	[fldRequired] [bit] NULL,
    	[fldSubmitPreControl] [nvarchar](250) NULL,
    	[fldFileMultiple] [bit] NULL,
    	[fldDirectScan] [bit] NULL,
    	[fldEnClient] [bit] NULL,
    	[fldReportName] [nvarchar](250) NULL,
    	[fldAutoSplitChar] [nvarchar](250) NULL,
    	[fldPlaceHolder] [nvarchar](250) NULL,
    	[fldProgram] [nvarchar](250) NULL,
    	[fldLazyReport] [bit] NULL,
    	[fldAccess] [bit] NULL,
    	[fldLog] [bit] NULL,
    	[fldSubmitLog] [nvarchar](250) NULL,
    	[fldSync] [bit] NULL,
    	[fldSubmitSuccessfullMessage] [nvarchar](1500) NULL,
    	[fldGroupName] [nvarchar](250) NULL
    ) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
    
    ALTER TABLE [rpt].[tblFilds]  WITH CHECK ADD CHECK  (([fldOperator]='' OR [fldOperator]='x=a' OR [fldOperator]='x<>a' OR [fldOperator]='x<a' OR [fldOperator]='x<=a' OR [fldOperator]='x>a' OR [fldOperator]='x>=a' OR [fldOperator]='b<x<a' OR [fldOperator]='b<x<=a' OR [fldOperator]='b<=x<=a' OR [fldOperator]='b<=x<a' OR [fldOperator]='in' OR [fldOperator]='notIn' OR [fldOperator]='like' OR [fldFieldType]='NUMBER' OR [fldFieldType]='STRING' OR [fldFieldType]='DATETIME'))
END
GO
/****** Object:  Table [rpt].[tblFilter]    Script Date: 7/10/2021 12:32:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('rpt.tblFilter', 'U') IS NULL
BEGIN
    CREATE TABLE [rpt].[tblFilter](
    	[fldID] [bigint] IDENTITY(1,1) NOT NULL,
        [fldReportId] [bigint] NOT NULL,
    	[fldUserId] [nvarchar](150) NOT NULL,
    	[fldReportName] [nvarchar](50) NOT NULL,
    	[fldFieldName] [nvarchar](50) NOT NULL,
    	[fldOperator] [nvarchar](10) NOT NULL,
    	[fldOprand] [nvarchar](max) NULL,
     CONSTRAINT [PK_tblFilter] PRIMARY KEY CLUSTERED 
    (
    	[fldID] ASC
    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
    ) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
    
    ALTER TABLE [rpt].[tblFilter]  WITH CHECK ADD CHECK  (([fldOperator]='x=a' OR [fldOperator]='x<>a' OR [fldOperator]='x<a' OR [fldOperator]='x<=a' OR [fldOperator]='x>a' OR [fldOperator]='x>=a' OR [fldOperator]='b<x<a' OR [fldOperator]='b<x<=a' OR [fldOperator]='b<=x<=a' OR [fldOperator]='b<=x<a' OR [fldOperator]='in' OR [fldOperator]='notIn' OR [fldOperator]='like'))
END
GO
/****** Object:  Table [rpt].[tblFilterTemp]    Script Date: 7/10/2021 12:32:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('rpt.tblFilterTemp', 'U') IS NULL
BEGIN
    CREATE TABLE [rpt].[tblFilterTemp](
    	[fldUserId] [nvarchar](150) NULL,
    	[FieldName] [varchar](50) NULL,
    	[fldFilterOperator] [nvarchar](10) NULL
    ) ON [PRIMARY]
END
GO
/****** Object:  Table [rpt].[tblGroupColumns]    Script Date: 7/10/2021 12:32:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('rpt.tblGroupColumns', 'U') IS NULL
BEGIN
    CREATE TABLE [rpt].[tblGroupColumns](
    	[fldGroupName] [nvarchar](50) NOT NULL,
    	[fldFieldName] [nvarchar](50) NOT NULL,
    	[fldType] [nvarchar](50) NOT NULL,
    	[fldQuery] [nvarchar](max) NULL,
    	[fldIsGroupable] [bit] NOT NULL,
    	[fldFuncDef] [nvarchar](50) NOT NULL,
    	[fldIsGroupedDef] [bit] NOT NULL,
    	[fldIncludedDef] [bit] NOT NULL
    ) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
/****** Object:  Table [rpt].[tblGroups]    Script Date: 7/10/2021 12:32:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('rpt.tblGroups', 'U') IS NULL
BEGIN
    CREATE TABLE [rpt].[tblGroups](
    	[fldTitle] [nvarchar](50) NOT NULL,
    	[fldName] [nvarchar](100) NOT NULL,
    	[fldViewName] [nvarchar](200) NOT NULL,
    	[fldConnectionName] [nvarchar](100) NOT NULL
    ) ON [PRIMARY]
END
GO
/****** Object:  Table [rpt].[tblReportColumns]    Script Date: 7/10/2021 12:32:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('rpt.tblReportColumns', 'U') IS NULL
BEGIN
    CREATE TABLE [rpt].[tblReportColumns](
    	[fldID] [bigint] IDENTITY(1,1) NOT NULL,
    	[fldReportId] [bigint] NOT NULL,
    	[fldUserId] [nvarchar](150) NOT NULL,
    	[fldGroupName] [nvarchar](50) NOT NULL,
    	[fldReportName] [nvarchar](50) NOT NULL,
    	[FieldName] [varchar](50) NULL,
    	[AggreegateFunc] [varchar](10) NULL,
    	[IsGrouped] [bit] NULL,
     CONSTRAINT [PK_tblReportColumns] PRIMARY KEY CLUSTERED 
    (
    	[fldID] ASC
    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
    ) ON [PRIMARY]
END
GO
/****** Object:  Table [rpt].[tblReportColumnsTemp]    Script Date: 7/10/2021 12:32:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('rpt.tblReportColumnsTemp', 'U') IS NULL
BEGIN
    CREATE TABLE [rpt].[tblReportColumnsTemp](
    	[Included] [bit] NOT NULL,
    	[fldUserId] [nvarchar](150) NULL,
    	[FieldName] [varchar](50) NULL,
    	[AggreegateFunc] [varchar](10) NULL,
    	[IsGrouped] [bit] NULL
    ) ON [PRIMARY]
END
GO
/****** Object:  Table [rpt].[tblReports]    Script Date: 7/10/2021 12:32:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('rpt.tblReports', 'U') IS NULL
BEGIN
    CREATE TABLE [rpt].[tblReports](
    	[fldID] [bigint] IDENTITY(1,1) NOT NULL,
    	[fldName] [nvarchar](100) NOT NULL,
    	[fk_fldGroupTitle] [nvarchar](50) NOT NULL,
    	[fldUserId] [nvarchar](150) NOT NULL,
    	[fldIsChart] [bit] NOT NULL,
    	[fldChartType] [nvarchar](10) NOT NULL,
    	[fldTableType] [nvarchar](10) NOT NULL,
     CONSTRAINT [PK_tblReports] PRIMARY KEY CLUSTERED 
    (
    	[fldID] ASC
    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
    ) ON [PRIMARY]
END
GO
/****** Object:  Table [rpt].[tblTables]    Script Date: 7/10/2021 12:32:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('rpt.tblTables', 'U') IS NULL
BEGIN
    CREATE TABLE [rpt].[tblTables](
    	[fldName] [nvarchar](10) NOT NULL,
    	[fldStyle] [nvarchar](max) NULL
    ) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
-- =============================================
-- Author:		m.Reza Hajjar
-- Create date: 1400/02/25
-- Description:	گزارش گیری با امکان شخصی سازی توسط کاربر
--این پروسجور اطلاعات تنظیمات گزارش را در قالب یک جدول از کاربر میگیرد  
-- و کوئری مناسب را میسازد
-- =============================================
CREATE OR ALTER PROCEDURE [rpt].[QueryGenerator]
    -- Add the parameters for the stored procedure here
    @Setting SettingType READONLY,
    @Filters FilterType READONLY,
    @ReportName nvarchar(50) ,
    @index int,
    @pageSize int,
    @Query nvarchar(max) OUTPUT
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;
    --declare @Query nvarchar(max);
    --*******************Generate Criterias**********************
    BEGIN TRY  
	declare @hasGroupBy bit;
	SELECT @hasGroupBy= CASE
		WHEN SUM(CASE WHEN IsGrouped = 1 THEN 1 ELSE 0 END)<1  THEN 'FALSE'
		ELSE 'TRUE'
	END
    From @Setting

    declare @filter nvarchar(max);

	IF EXISTS (SELECT *
    FROM @filters )
		set @filter= CHAR(13)+ 'where ';
	else 
		set @filter= '';

set @Query='
    declare @index int,@pageSize int
    select @index=#txtPageIndex#,@pageSize=#lstPageSize#
    select  (ROW_NUMBER() OVER(ORDER BY ';
	
    -- add row number 
	SELECT @Query= CASE
         WHEN @hasGroupBy>0 and IsGrouped<1 and AggreegateFunc!=''  THEN @Query+' '+ AggreegateFunc+'('+FieldName+') ,' 
         WHEN @hasGroupBy>0 and IsGrouped<1 and AggreegateFunc=''  THEN @Query+ ' COUNT('+FieldName+') ,'  
         ELSE @Query+' '+FieldName+','  
       END
    From @Setting
	
	select @Query=reverse(stuff(reverse(@Query), 1, 1, ''));
    SELECT @Query= @Query+ ')) AS rowNumber,'+ CHAR(10);
    -- Insert statements for procedure here
	SELECT
        --@filter=  @filter+ rpt.criteriaBuilder(fldFieldName,'STRING',fldOperator,fldOprand) + 'AND'
        @filter=CASE  
			WHEN rpt.criteriaBuilder(fldFieldName,[fldFieldType],fldOperator,fldOprand) IS NULL THEN  @filter 
			ELSE   @filter +' '+ rpt.criteriaBuilder(fldFieldName,[fldFieldType],fldOperator,fldOprand) + 'AND'
		END
    From @Filters as f
	set @filter=SUBSTRING(@filter,0,Len(@filter)-3)+' ';
	PRINT @filter
END TRY  
BEGIN CATCH  
    PRINT 'Error in Generate Criterias' 
END CATCH
    --**************/Generate Criterias*******************************


    --**************/Generate Report*******************************
    -- Insert statements for procedure here
    SELECT @Query= CASE
         WHEN @hasGroupBy>0 and IsGrouped<1 and AggreegateFunc!=''  THEN @Query+' '+ AggreegateFunc+'('+FieldName+') '+FieldName+'_'+ AggreegateFunc+','  
         WHEN @hasGroupBy>0 and IsGrouped<1 and AggreegateFunc=''  THEN @Query+ ' COUNT('+FieldName+') '+FieldName+'_COUNT,'  
         ELSE @Query+' '+FieldName+' AS '+FieldName+','  
       END
    From @Setting

    select @Query=reverse(stuff(reverse(@Query), 1, 1, ''))


    SELECT @Query= @Query+ CHAR(10)+ 'From '+@ReportName+ @filter
    ;

    IF(@hasGroupBy>0)
	Begin
        SELECT @Query=  @Query+ CHAR(13) +'Group by '

        SELECT @Query= CASE
			WHEN IsGrouped<1  THEN @Query
			ELSE @Query+ ' '+FieldName+','
		END
        From @Setting

        select @Query=reverse(stuff(reverse(@Query), 1, 1, ''))
    END

    
    -- add OrderBY
	SELECT @Query= @Query+ ' order by '
	SELECT @Query= CASE
         WHEN @hasGroupBy>0 and IsGrouped<1 and AggreegateFunc!=''  THEN @Query+' '+ AggreegateFunc+'('+FieldName+') ,' 
         WHEN @hasGroupBy>0 and IsGrouped<1 and AggreegateFunc=''  THEN @Query+ ' COUNT('+FieldName+') ,'  
         ELSE @Query+' '+FieldName+','  
       END
    From @Setting
	
	select @Query=reverse(stuff(reverse(@Query), 1, 1, ''));
    SELECT @Query= @Query+' OFFSET @pageSize*(@index -1) rows  FETCH NEXT @pageSize rows only'+ CHAR(10);



    PRINT @Query
    RETURN
END
GO

-- =============================================
-- Author:		m.Reza Hajjar
-- Create date: 1400/02/25
-- Description:	گزارش گیری با امکان شخصی سازی توسط کاربر
--این پروسجور اطلاعات تنظیمات گزارش را در قالب یک جدول از کاربر میگیرد  
-- و کوئری مناسب را میسازد
-- =============================================
CREATE OR ALTER PROCEDURE [rpt].[QueryGenerator_title]
    -- Add the parameters for the stored procedure here
    @Setting SettingType READONLY,
    @Filters FilterType READONLY,
    @ReportName nvarchar(50) ,
    @index int,
    @pageSize int,
    @Query nvarchar(max) OUTPUT
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;
    --declare @Query nvarchar(max);
    --*******************Generate Criterias**********************
    BEGIN TRY  
	declare @hasGroupBy bit;
	SELECT @hasGroupBy= CASE
		WHEN SUM(CASE WHEN IsGrouped = 1 THEN 1 ELSE 0 END)<1  THEN 'FALSE'
		ELSE 'TRUE'
	END
    From @Setting

    declare @filter nvarchar(max);

	IF EXISTS (SELECT *
    FROM @filters )
		set @filter= CHAR(13)+ 'where ';
	else 
		set @filter= '';

	set @Query='select   ';

    -- Insert statements for procedure here
	SELECT
        --@filter=  @filter+ rpt.criteriaBuilder(fldFieldName,'STRING',fldOperator,fldOprand) + 'AND'
        @filter=CASE  
			WHEN rpt.criteriaBuilder(fldFieldName,[fldFieldType],fldOperator,fldOprand) IS NULL THEN  @filter 
			ELSE   @filter +' '+ rpt.criteriaBuilder(fldFieldName,[fldFieldType],fldOperator,fldOprand) + 'AND'
		END
    From @Filters as f
	set @filter=SUBSTRING(@filter,0,Len(@filter)-3)+' ';
	PRINT @filter
END TRY  
BEGIN CATCH  
    PRINT 'Error in Generate Criterias' 
END CATCH
    --**************/Generate Criterias*******************************


    --**************/Generate Report*******************************
    -- Insert statements for procedure here
    SELECT @Query= CASE
         WHEN @hasGroupBy>0 and IsGrouped<1 and AggreegateFunc!=''  THEN @Query+' '+ AggreegateFunc+'('+FieldName+') '+FieldName+'_'+ AggreegateFunc+','  
         WHEN @hasGroupBy>0 and IsGrouped<1 and AggreegateFunc=''  THEN @Query+ ' COUNT('+FieldName+') '+FieldName+'_COUNT,'  
         ELSE @Query+' '+FieldName+' AS '+FieldName+','  
       END
    From @Setting

    select @Query=reverse(stuff(reverse(@Query), 1, 1, ''))


    SELECT @Query= @Query+ CHAR(10)+ 'From '+@ReportName+ @filter
    ;

    IF(@hasGroupBy>0)
	Begin
        SELECT @Query=  @Query+ CHAR(13) +'Group by '

        SELECT @Query= CASE
			WHEN IsGrouped<1  THEN @Query
			ELSE @Query+ ' '+FieldName+','
		END
        From @Setting

        select @Query=reverse(stuff(reverse(@Query), 1, 1, ''))
    END
    PRINT @Query
    RETURN
END
GO
-- ==============[FormGenerator]================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE OR ALTER PROCEDURE [rpt].[FormGenerator]
    @userId [nvarchar](150) ,
	@ReportId bigint
AS
BEGIN

    declare @isChart bit, @chartType  [nvarchar](10) ,@QueryAndReportName  nvarchar(200) ,@ChartReportName nvarchar(200),@connection nvarchar(100),
@fldName  [nvarchar](50),@GroupName [nvarchar](50),@ReportName [nvarchar](50) ,@fldFormId bigint  ,@fldLevelID bigint ,@btnRefreshReportID bigint,@fldReportID bigint,@tblReportID bigint


    select @isChart=fldIsChart ,@chartType =fldChartType,@GroupName=fk_fldGroupTitle,@ReportName=fldName
    From [rpt].tblReports as r
    where r.fldID=@ReportId

    select @fldName='autoReport'+'_'+cast(@ReportId as nvarchar(150))

    --پیدا کردن شناسه فرم مربوطه
    SELECT @fldFormId=fldID
    FROM [tblForms]
    WHERE  fldName= @fldName
    --حذف کوئری و گزارش قبلی تعریف شده
    select @QueryAndReportName=N'tableForm_'+CAST(@fldFormId AS VARCHAR) 
, @ChartReportName=N'chartForm_'+CAST(@fldFormId AS VARCHAR)
    delete from [tblQuery] where [fldName]=@QueryAndReportName
    delete from [tblQuery] where fldName=@QueryAndReportName+N'_title'
    delete from [tblReport] where [fldName]=@QueryAndReportName or [fldName]=@ChartReportName
    delete from [tblAPI] where [fldName]= @ChartReportName

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
    where  f.fldReportId=@ReportId and f.fldFieldName=S.fldFieldName
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

    select @QueryAndReportName=N'tableForm_'+CAST(@fldFormId AS VARCHAR) 
, @ChartReportName=N'chartForm_'+CAST(@fldFormId AS VARCHAR) 
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
    where  f.fldReportId=@ReportId and f.fldFieldName=S.fldFieldName

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
        ( @QueryAndReportName, @ReportName+N'_جدولی' , @headTitle, @QueryAndReportName, N'اتوگزارش', NULL, NULL, 1, NULL, 0, N'', N'',  @QueryAndReportName+N'_title', 1, N'table'
 --fldStyle
 ,@style, NULL, NULL, NULL, 1, NULL, 1, 0, N'', N'', N'', 1, NULL, NULL, NULL, NULL, 1, NULL, NULL)
,
        ( @ChartReportName, @ReportName+N'_نموداری' 
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
        (@ChartReportName--<fldName, nvarchar(50),>
           , @ChartReportName--<fldQuery, nvarchar(150),>
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
END
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE OR ALTER PROCEDURE [rpt].[DeleteReport]
    @userId [nvarchar](150) ,
    @ReportId bigint,
    @ReportName [nvarchar](50) ,
    @GroupName [nvarchar](50)
AS
BEGIN
    declare @QueryAndReportName  nvarchar(200), @ChartReportName  nvarchar(200),@connection nvarchar(100),
@fldName  [nvarchar](50),@fldFormId bigint, @fldLevelID bigint,@fldAccessId bigint,@btnRefreshReportID bigint,@fldReportID bigint,@tblReportID bigint

    DELETE FROM [rpt].[tblFilter]
  where fldUserId=@userId and fldReportName=@ReportName

    DELETE FROM [rpt].[tblReportColumns]
  where fldUserId=@userId and fldReportName=@ReportName

    select @GroupName=[dbo].[Fingilish](@GroupName), @ReportName=[dbo].[Fingilish](@ReportName)


    select @fldName='rptcnfg_'+@GroupName+'_'+ @ReportName

    --پپیدا کردن شناسه فرم مربوطه
    SELECT @fldFormId=fldID
    FROM [tblForms]
    WHERE  fldName= @fldName
    --حذف کوئری و گزارش قبلی تعریف شده
    select @QueryAndReportName=N'tableForm_'+CAST(@fldFormId AS VARCHAR)
    , @ChartReportName=N'chartForm_'+CAST(@fldFormId AS VARCHAR) 
    delete from [tblReport] where [fldName]=@QueryAndReportName or  [fldName]=@ChartReportName
    delete from [tblQuery] where fldName=@QueryAndReportName or  [fldName]=@ChartReportName
    delete from [tblQuery] where fldName=@QueryAndReportName+N'_title'
    delete from [tblAPI] where [fldName]=@ChartReportName

    SELECT @fldLevelID=[fldID]
    from [dbo].[tblFormAccessLevels]
    where fldName='NULL' and fldFormID=@fldFormId
    delete from [dbo].[tblFormAccessDetail] where   fldLevelID=@fldLevelID and fldFildName='API:'+@QueryAndReportName
    delete from [dbo].[tblFormAccessLevels] where fldName='NULL' and fldFormID=@fldFormId
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

    delete from tblFormFilds where fldFormID= @fldFormId

    SELECT @fldAccessId=fldID
    FROM [dbo].[tblFormAccessLevels]
    WHERE  fldName= 'NULL' and fldFormID=@fldFormId
    delete from [dbo].[tblFormAccessDetail] where fldLevelID= @fldAccessId and fldFildID='API:'+@QueryAndReportName

    delete from [dbo].[tblFormAccessLevels] where fldFormID= @fldFormId
    -- read form ID
    SELECT @fldFormId=fldID
    FROM [tblForms]
    WHERE  fldName= @fldName

    --**********Set Dependencies**************
    SELECT @btnRefreshReportID=[fldID]
    FROM [dbo].[tblFormFilds]
    where fldFormID=@fldFormId and fldFildName= 'rpt_btnBuildQuery'

    delete FROM [dbo].[tblFormFilds]
where fldFormID=@fldFormId and fldFildName='TableReport'

    delete FROM  [tblForms] WHERE  fldName= @fldName
    delete from [dbo].[tblFormAccessLevels] where fldFormID= @fldFormId and fldName='NULL'


End

GO


