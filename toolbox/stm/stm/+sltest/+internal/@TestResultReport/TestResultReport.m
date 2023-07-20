classdef TestResultReport<sltest.internal.TestResultReportBase



























































    properties




        CustomTemplateFile='';


        LaunchReport=true;





        IncludeTestResults=2;


        ReportTitle='';


        AuthorName='';


        IncludeMWVersion=true;


        IncludeTestRequirement=true;


        IncludeErrorMessages=true;


        IncludeSimulationSignalPlots=false;


        IncludeComparisonSignalPlots=false;


        IncludeMATLABFigures=false;


        IncludeSimulationMetadata=false;


        IncludeCoverageResult=false;


        NumPlotRowsPerPage(1,1){mustBeNumeric,mustBeGreaterThanOrEqual(NumPlotRowsPerPage,1),mustBeLessThanOrEqual(NumPlotRowsPerPage,4)}=2;


        NumPlotColumnsPerPage(1,1){mustBeNumeric,mustBeGreaterThanOrEqual(NumPlotColumnsPerPage,1),mustBeLessThanOrEqual(NumPlotColumnsPerPage,4)}=1;

    end

    properties(GetAccess=public,SetAccess=protected)



        IconFileTestFileResult='';

        IconFileTestSuiteResult='';

        IconFileTestCaseResult='';

        IconFileTestIterationResult='';


        IconFileScriptedTestFileResult='';

        IconFileScriptedTestSuiteResult='';

        IconFileScriptedTestCaseResult='';


        IconFileOutcomePassed='';

        IconFileOutcomeFailed='';

        IconFileOutcomeIncomplete='';

        IconFileOutcomeDisabled='';


        IconFileOutcomeMisaligned='';


        IconFileOutcomeUntested='';


        IconTopLevelModel='';
        IconModelReference='';



        BodyFontName='Arial';
        BodyFontColor='Black';
        BodyFontSize='12pt';


        TitleFontName='Arial';
        TitleFontColor='Black';
        TitleFontSize='16pt';


        HeadingFontName='Arial';
        HeadingFontColor='Black';
        HeadingFontSize='14pt';


        BodyFixedWidthFontName='Courier New';
        BodyFixedWidthFontSize='10pt';


        ChapterIndent='3mm';

        ChapterIndentL2='6mm';

        ChapterIndentL3='8mm';


        SectionSpacing='2mm';


        SignalPlotWidth='600px';
        SignalPlotHeight='500px';



        TableFontName='Arial';
        TableFontColor='Black';
        TableFontSize='7.5pt';
    end

    methods




        function this=TestResultReport(resultObjects,reportFilePath)
            this@sltest.internal.TestResultReportBase(resultObjects,reportFilePath);
        end
    end

    methods(Access=protected)



        layoutReport(obj);

        addTitlePage(obj);

        addReportTOC(obj);

        addReportBody(obj);







        docPart=genResultSetBlock(obj,result)


        docPart=genTestSuiteResultBlock(obj,result);


        docPart=genTestCaseResultBlock(obj,result);






        docPart=genMetadataBlockForTestResult(obj,result,isTestSuiteResult);


        docPart=genRunBlockForTestCaseResult(obj,run,runType,result,simIndex);









        table=genSimulationConfigurationTable(obj,result,simIndex);


        table=genBaselineInfoTable(obj,resultObj);


        overridesTable=genParameterOverridesTable(obj,resultObj,simIndex);


        docPart=genSignalSummaryTable(obj,signalList,isComparison,isSummaryTable);





        reqTable=genRequirementLinksTable(obj,resultObj,isTestSuiteResult);


        docPart=genIterationSettingTable(obj,result);




        docPart=genCoverageTable(obj,resultObj)


        para=genHyperLinkToToC(obj,indent);


        rowList=genTableRowsForResultMetaInfo(obj,result)


        plotOneSignalToFile(obj,filePath,onesig,isComparison);


        createNavigationLinksForPlots(obj,isComparison,run,docPart);


        plotMultipleSignals(obj,filePath,signalList,numRows,numCols,lastSigIdxPlotted);


        docPart=genCustomCriteriaResultBlock(reportObj,testResult);


        docPart=genDiagnosticRecordBlock(reportObj,ccr);


        docPart=genCustomCriteriaPlotsBlock(reportObj,testResult);


        docPart=genTestSuitePlotsBlock(reportObj,testResult);


        docPart=genSimulationCallbackPlotsBlock(reportObj,testResult,simIdx);

    end

    methods(Static)
        [strList1,strList2]=getSignalBuilderOrEditor(group,strList1,strList2);

        plotHandle=plotOneFigure(sig,sigName);
    end
end
