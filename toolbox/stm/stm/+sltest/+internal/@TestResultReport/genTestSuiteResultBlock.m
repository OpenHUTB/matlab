function groupObj=genTestSuiteResultBlock(obj,result)














    p=inputParser;
    addRequired(p,'obj',...
    @(x)validateattributes(x,{'sltest.testmanager.TestResultReport',...
    'sltest.internal.TestResultReport'},{}));
    addRequired(p,'result',...
    @(x)validateattributes(x,{'sltest.testmanager.ReportUtility.ReportResultData'},{}));
    p.parse(obj,result);

    import mlreportgen.dom.*;

    groupObj=Group();
    testCaseResultMetaBlk=obj.genMetadataBlockForTestResult(result,true);
    append(groupObj,testCaseResultMetaBlk);


    if(obj.IncludeCoverageResult==true&&isempty(result.ParentResultName))
        table=obj.genCoverageTable(result.Data);
        append(groupObj,table);
    end


    if(~isempty(result.Data.ErrorMessages))
        tmpName=getString(message('stm:ReportContent:Field_TestError'));
        msgPart=sltest.testmanager.ReportUtility.genMessageBlock(obj,...
        result.Data.ErrorMessages,tmpName,'Red',obj.ChapterIndent);
        append(groupObj,msgPart);
    end


    if(obj.IncludeMATLABFigures)
        TestSuiteCallBackPlotsPart=obj.genTestSuitePlotsBlock(result.Data);
        if~isempty(TestSuiteCallBackPlotsPart)
            append(groupObj,TestSuiteCallBackPlotsPart);
        end
    end

    linkPara=obj.genHyperLinkToToC(obj.ChapterIndent);
    append(groupObj,linkPara);
end
