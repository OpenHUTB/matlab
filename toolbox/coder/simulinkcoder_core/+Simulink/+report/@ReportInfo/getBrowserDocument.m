function h=getBrowserDocument
    h=[];
    hDlg=Simulink.report.ReportInfo.getBrowserDialog();
    if isa(hDlg,'DAStudio.Dialog')
        hSrc=hDlg.getDialogSource;
        if isa(hSrc,'Simulink.document')
            h=hSrc;
        end
    end
end
