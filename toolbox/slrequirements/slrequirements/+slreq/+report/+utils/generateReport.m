function reportName=generateReport(reqSet,varargin)



    p=inputParser;

    addParameter(p,'ReportOptions',slreq.report.utils.getDefaultOptions());
    addParameter(p,'ShowUI',false);
    p.parse(varargin{:});

    showui=p.Results.ShowUI;
    opts=p.Results.ReportOptions;

    slreq.utils.updateProgress(showui,...
    'start',...
    getString(message('Slvnv:slreq:ReportGenProgressBarStart')));

    c1=onCleanup(@()slreq.utils.updateProgress(showui,'clear'));
    if~isfield(opts,'templatePath')
        [~,~,ext]=fileparts(opts.reportPath);
        opts.templatePath=slreq.report.utils.getDefaultTemplatePath(ext(2:end));
    end
    rpt=slreq.report.Report(reqSet,'ReportOptions',opts,'ShowUI',showui);
    rpt.fill();
    close(rpt);
    reportName=rpt.ReportOptions.reportPath;
    if opts.openReport
        slreq.report.utils.openReport(reportName,showui);
    end
    slreq.utils.updateProgress(showui,'clear');
    rpt.dumpWarning;
    if~showui


        disp(getString(message('Slvnv:slreq:ReportIsGenerated',reportName)));
    end
end
