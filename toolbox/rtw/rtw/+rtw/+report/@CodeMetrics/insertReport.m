function insertReport(reportInfo,codeMetricsRpt,isSameReportAsDisplay)
    narginchk(2,3);
    if nargin<3
        isSameReportAsDisplay=reportInfo.isSameReportAsDisplay;
    end

    if isempty(codeMetricsRpt)||isempty(codeMetricsRpt.Data)||strcmp(reportInfo.Config.GenerateCodeMetricsReport,'off')

        if isSameReportAsDisplay&&~rtw.report.ReportInfo.featureReportV2

            dlg=Simulink.report.ReportInfo.getBrowserDialog();

            if~isempty(dlg)

                pause(1);
                dlg=Simulink.report.ReportInfo.getBrowserDialog();

                if~isempty(dlg)
                    dlg.evalBrowserJS('Tag_Coder_Report_Dialog','top.rtwreport_nav_frame.CodeMetrics = null;');
                end
            end
        end

        return
    end

    useNewReport=rtw.report.ReportInfo.featureReportV2;
    if~useNewReport

        filename=fullfile(reportInfo.getReportDir,'metrics.js');
    else

        filename=fullfile(reportInfo.getReportDir,'pages','metrics.js');
    end

    if~exist(filename,'file')
        codeMetricsRpt.emitJS(filename);
    end
    dlg=Simulink.report.ReportInfo.getBrowserDialog();

    if~isempty(dlg)&&isSameReportAsDisplay


        filename=['file:///',strrep(filename,'\','\\')];
        pause(1);
        if~isempty(dlg)
            try
                dlg.evalBrowserJS('Tag_Coder_Report_Dialog',['top.load_js(top.rtwreport_nav_frame,"',filename,'");']);
            catch
            end
        end
    end
end
