function showVMgrSPKGInstallDialog()




    function openSSIDialog(input)


        if strcmp(input,addButton.message)
            matlab.internal.SupportSoftwareInstallerLauncher().launchWindow(...
            'MLPKGINSTALL','','','SLVMGR');
        end
    end

    obj=DAStudio.DialogProvider;
    dlgText=MException(message('Simulink:VariantManager:InstallVariantManagerSPKGText'));
    dlgTitle=MException(message('Simulink:VariantManager:InstallVariantManagerSPKGTitle'));
    addButton=MException(message('Simulink:dialog:AddButton'));

    obj.questdlg(dlgText.message,dlgTitle.message,{addButton.message},...
    addButton.message,@openSSIDialog);

end


