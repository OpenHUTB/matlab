function docPart=genCustomCriteriaPlotsBlock(reportObj,testResult)















    p=inputParser;
    addRequired(p,'reportObj',...
    @(x)validateattributes(x,{'sltest.testmanager.TestResultReport',...
    'sltest.internal.TestResultReport'},{}));
    addRequired(p,'testResult',...
    @(x)validateattributes(x,{'sltest.testmanager.TestResult'},{}));
    p.parse(reportObj,testResult);

    import mlreportgen.dom.*;
    customCriteriaPlots=testResult.getCustomCriteriaPlots;
    if isempty(customCriteriaPlots)

        docPart=Group.empty;
    else

        docPart=Group();


        source=sltest.testmanager.PlotSources.CustomCriteria;
        sltest.testmanager.ReportUtility.addArtifactsHeader(docPart,reportObj,source);


        sltest.testmanager.ReportUtility.addPlotArtifacts(docPart,reportObj,customCriteriaPlots);
    end
end