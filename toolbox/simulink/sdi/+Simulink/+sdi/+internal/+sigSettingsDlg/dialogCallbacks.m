function dialogCallbacks(dlgUUID,lineSettings)



    dlgs=DAStudio.ToolRoot.getOpenDialogs;
    for i=1:length(dlgs)
        if Simulink.sdi.internal.sigSettingsDlg.isSigSettingsDlg(dlgs(i))
            if dlgUUID==dlgs(i).getSource.DlgUUID
                dlgSrc=dlgs(i).getSource;
                dlgSrc.LineSettings=lineSettings;
                dlgs(i).enableApplyButton(true);
            end
        end
    end
end
