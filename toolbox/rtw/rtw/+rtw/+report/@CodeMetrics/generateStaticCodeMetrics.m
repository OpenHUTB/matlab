function generateStaticCodeMetrics(reportInfo,buildInfo,saveLocation,sourceSubsystem,needCMReportGen,modelName)

    if isempty(reportInfo)
        return
    end

    if nargin<6
        modelName=reportInfo.ModelName;
    end

    if nargin<5



        needCMReportGen=strcmp(get_param(modelName,'GenerateReport'),'on');
    end

    opts.SourceSubsystem=sourceSubsystem;
    opts.BuildDir=reportInfo.BuildDirectory;
    opts.StartDir=reportInfo.StartDir;
    codeMetrics=rtw.codemetrics.CodeMetrics(buildInfo,opts);

    if needCMReportGen
        codeMetricsRpt=reportInfo.getPage('CodeMetrics');
        if isempty(codeMetricsRpt)
            codeMetricsRpt=rtw.report.CodeMetrics(codeMetrics.BuildDir,true);
            reportInfo.addPage(codeMetricsRpt);
        end
        codeMetricsRpt.Data=codeMetrics;
        codeMetricsRpt.generate();
        if rtw.report.ReportInfo.DisplayInCodeTrace||rtw.report.ReportInfo.featureReportV2
            rtw.report.CodeMetrics.insertReport(reportInfo,codeMetricsRpt);
        end
        if reportInfo.Dirty
            reportInfo.saveMat;
        end
    end
    save(fullfile(saveLocation,'codeMetrics.mat'),'codeMetrics');







































end

