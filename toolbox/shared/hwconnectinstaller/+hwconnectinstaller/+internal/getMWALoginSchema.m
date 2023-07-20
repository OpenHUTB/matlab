function dlgstruct=getMWALoginSchema(hStep,dlgstruct)




    nextBtnIndex=hStep.findDialogWidget(dlgstruct,'Next');
    dlgstruct.Items{nextBtnIndex}.Name=DAStudio.message('hwconnectinstaller:setup:MWALogin_Next');
    dlgstruct.Items{nextBtnIndex}.Enabled=true;
    if hStep.getSetup.InstallerWorkflow.isDownload
        descIndex=hStep.findDialogWidget(dlgstruct,'Description');
        dlgstruct.Items{descIndex}.Name=DAStudio.message('hwconnectinstaller:setup:MWALogin_Description_Download');
    end
end
