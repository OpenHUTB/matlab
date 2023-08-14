function fileResults=genFunctionBlockReport(emlChart,report,reportFolder)






    if isnumeric(emlChart)
        emlChart=idToHandle(sfroot,emlChart);
    end
    sid=Simulink.ID.getSID(emlChart);

    reportContext=coder.report.ReportContext(report);
    reportContext.SimulinkSID=sid;
    reportContext.IsStateflow=true;

    traceInfo=codergui.evalprivate('getFunctionBlockTraceInfo',sid);
    if~isempty(traceInfo)
        reportContext.BuildDirectory=traceInfo.buildDir;
        buildInfoFile=fullfile(traceInfo.buildDir,'buildInfo.mat');
        if~isfield(report.summary,'buildInfo')&&isfile(buildInfoFile)
            buildInfo=load(buildInfoFile,'buildInfo');
            if isfield(buildInfo,'buildInfo')
                reportContext.Report.summary.buildInfo=buildInfo.buildInfo;
            end
        end
    end

    if nargin>2
        reportContext.ReportDirectory=reportFolder;
    end

    fileResults=codergui.ReportServices.Generator.run(reportContext);
end
