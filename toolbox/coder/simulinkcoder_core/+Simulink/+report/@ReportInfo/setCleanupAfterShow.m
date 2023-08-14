function setCleanupAfterShow(val)


    dlg=Simulink.report.ReportInfo.getBrowserDialog();
    if~isempty(dlg)
        src=dlg.getDialogSource;
        if isa(src,'Simulink.document')
            src.CleanupAfterShow=val;
        end
    end
end
