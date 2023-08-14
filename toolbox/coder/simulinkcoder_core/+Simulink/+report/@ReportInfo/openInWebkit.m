function openInWebkit(url,title,helpMethod)
    dlg=Simulink.report.ReportInfo.setBrowserDialog(url,title,helpMethod);
    if~isempty(dlg)

        dlg.showNormal;
        dlg.show;
    end
end
