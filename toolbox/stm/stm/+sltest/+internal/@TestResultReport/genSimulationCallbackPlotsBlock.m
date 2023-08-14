function docPart=genSimulationCallbackPlotsBlock(reportObj,testResult,simIdx)















    p=inputParser;
    addRequired(p,'reportObj',...
    @(x)validateattributes(x,{'sltest.testmanager.TestResultReport',...
    'sltest.internal.TestResultReport'},{}));
    addRequired(p,'testResult',...
    @(x)validateattributes(x,{'sltest.testmanager.TestResult'},{}));
    addRequired(p,'simIdx',...
    @(x)validateattributes(x,{'double'},{}));
    p.parse(reportObj,testResult,simIdx);

    import mlreportgen.dom.*;
    simCallBackPlots=testResult.getSimulationPlots(simIdx);
    if isempty(simCallBackPlots)

        docPart=Group.empty;
    else

        docPart=Group();


        source=sltest.testmanager.PlotSources.Simulation;
        sltest.testmanager.ReportUtility.addArtifactsHeader(docPart,reportObj,source);


        sltest.testmanager.ReportUtility.addPlotArtifacts(docPart,reportObj,simCallBackPlots);
    end
end