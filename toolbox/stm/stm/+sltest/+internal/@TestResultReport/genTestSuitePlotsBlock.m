function docPart=genTestSuitePlotsBlock(reportObj,testResult)














    p=inputParser;
    addRequired(p,'reportObj',...
    @(x)validateattributes(x,{'sltest.testmanager.TestResultReport',...
    'sltest.internal.TestResultReport'},{}));
    addRequired(p,'testResult',...
    @(x)validateattributes(x,{'sltest.testmanager.TestResult'},{}));
    p.parse(reportObj,testResult);

    import mlreportgen.dom.*;
    TestSuiteCallBackPlots=testResult.getSetupPlots;
    TestSuiteCallBackPlots=[TestSuiteCallBackPlots,testResult.getCleanupPlots];
    if isempty(TestSuiteCallBackPlots)

        docPart=Group.empty;
    else

        docPart=Group();


        if isa(testResult,'sltest.testmanager.TestFileResult')
            source=sltest.testmanager.PlotSources.TestFile;
        else
            source=sltest.testmanager.PlotSources.TestSuite;
        end
        sltest.testmanager.ReportUtility.addArtifactsHeader(docPart,reportObj,source);


        sltest.testmanager.ReportUtility.addPlotArtifacts(docPart,reportObj,TestSuiteCallBackPlots);
    end
end