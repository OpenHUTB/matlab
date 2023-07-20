function choice=confirmSaveBeforeClose(modelHandle)






    modelName=get_param(modelHandle,"Name");
    quest=message("multisim:SetupGUI:SaveMultiSimSetupBeforeClose",modelName).getString;
    yes=message("multisim:SetupGUI:DialogYes").getString;
    no=message("multisim:SetupGUI:DialogNo").getString;
    title=message("multisim:SetupGUI:UnsavedChangesDialogTitle").getString;
    choice=questdlg(quest,title,yes,no,yes);

    switch choice
    case yes
        choice="yes";
    case no
        choice="no";
    end
end