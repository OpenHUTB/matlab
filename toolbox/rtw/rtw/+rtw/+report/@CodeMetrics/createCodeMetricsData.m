function createCodeMetricsData(reportInfo)
    opts.SourceSubsystem=reportInfo.SourceSubsystem;
    opts.BuildDir=reportInfo.BuildDirectory;
    opts.StartDir=reportInfo.StartDir;
    buildInfo=reportInfo.getBuildInfo();
    reportFolder=fullfile(reportInfo.CodeGenFolder,reportInfo.ModelRefRelativeBuildDir,'tmwinternal');

    codeMetrics=rtw.codemetrics.CodeMetrics(buildInfo,opts);

    codeMetricsRpt=reportInfo.getPage('CodeMetrics');
    if isempty(codeMetricsRpt)
        codeMetricsRpt=rtw.report.CodeMetrics(codeMetrics.BuildDir,true);
        reportInfo.addPage(codeMetricsRpt);
    end
    codeMetricsRpt.Data=codeMetrics;

    if~exist(reportFolder,'dir')
        rtwprivate('rtw_create_directory_path',reportFolder);
    end
    save(fullfile(reportFolder,'codeMetrics.mat'),'codeMetrics');
end
