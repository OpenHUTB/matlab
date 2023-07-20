function close



    if~rtw.report.ReportInfo.featureReportV2
        rtw.report.ReportInfo.closeDialog;
    else

        dlgs=DAStudio.ToolRoot.getOpenDialogs;
        keyStr='RTW:report:DocumentTitle';
        expectedStr=DAStudio.message(keyStr,'');
        expectedStrProt=DAStudio.message('Simulink:protectedModel:ProtectedModelReportTitle','');
        for k=1:numel(dlgs)
            dlg=dlgs(k);
            src=dlg.getSource;
            if isa(src,'rtw.report.Web')||isa(src,'Simulink.document')
                if contains(src.Title,expectedStr)||contains(src.Title,expectedStrProt)

                    dlg.delete;
                    return;
                end
            end
        end
    end
