function[returnValue,userData]=showPasswordDialogForCommandLine(creator,askforVerification)



    assert(isa(creator,'Simulink.ModelReference.ProtectedModel.Creator'));

    encryptionCategories={};
    if creator.getModifiable()
        encryptionCategories{end+1}='MODIFY';
    end


    if creator.Encrypt
        isSIMCategoryAdded=false;
        if creator.supportsView()
            encryptionCategories{end+1}='VIEW';
        end
        if strcmp(creator.Modes,'Normal')||strcmp(creator.Modes,'Accelerator')
            encryptionCategories{end+1}='SIM';
        end
        if strcmp(creator.Modes,'CodeGeneration')&&creator.getSupportsC()
            encryptionCategories{end+1}='SIM';
            encryptionCategories{end+1}='RTW';
            isSIMCategoryAdded=true;
        end
        if creator.supportsHDLCodeGen()
            if~isSIMCategoryAdded
                encryptionCategories{end+1}='SIM';
            end
            encryptionCategories{end+1}='HDL';
        end
    end

    hiddenFigure=figure('visible','off');
    removeHiddenFigure=onCleanup(@()delete(hiddenFigure));

    pwDlg=Simulink.ModelReference.ProtectedModel.PasswordEntryDialog(encryptionCategories,creator.ModelName,hiddenFigure,askforVerification);
    pwDlg.fGuiEntry=false;
    dlg=DAStudio.Dialog(pwDlg);


    waitfor(dlg,'dialogTag');
    userData=get(hiddenFigure,'UserData');
    returnValue=get(hiddenFigure,'Name');
end
