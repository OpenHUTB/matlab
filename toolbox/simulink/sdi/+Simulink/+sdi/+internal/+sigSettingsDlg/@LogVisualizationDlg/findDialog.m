function dlg=findDialog(this)



    dlg=[];
    dlgs=DAStudio.ToolRoot.getOpenDialogs;
    for nDlg=1:length(dlgs)
        if isa(dlgs(nDlg).getSource,'Simulink.sdi.internal.sigSettingsDlg.LogVisualizationDlg')
            if this.DlgUUID==dlgs(nDlg).getSource.DlgUUID
                dlg=dlgs(nDlg);
                return;
            end
        end
    end
end
