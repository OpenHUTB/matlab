function openReportInfoDlg(sys)



    dialogSrc=rtw.report.ReportDlg.rptDlg(sys,'open');
    if~isempty(dialogSrc)
        dlgBox=DAStudio.Dialog(dialogSrc);
        dlgBox.show;
        dlgBox.setFocus('openrpt_ReportFolder');
    end
