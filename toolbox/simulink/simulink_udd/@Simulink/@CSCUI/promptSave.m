function goahead=promptSave(hUI,causeaction)




    goahead=true;




    if~hUI.IsDirty
        return;
    end




    switch causeaction
    case{'Cancel','cancel','Close','close'}



        return;

    case{'SelectPackage','Ok','ok'}


    end




    questMsg=DAStudio.message('Simulink:dialog:CSCUIPromptSaveDefns',hUI.CurrPackage);
    yes=DAStudio.message('Simulink:dialog:CSCYes');
    no=DAStudio.message('Simulink:dialog:CSCNo');
    cancel=DAStudio.message('Simulink:dialog:CSCCancel');

    if strcmp(causeaction,'SelectPackage')
        toSave=questdlg(questMsg,DAStudio.message('Simulink:dialog:CSCDesignerTitle'),...
        yes,no,cancel,yes);
    else


        toSave=questdlg(questMsg,DAStudio.message('Simulink:dialog:CSCDesignerTitle'),...
        yes,no,yes);
    end




    switch toSave
    case yes
        goahead=hUI.saveCurrPackage();

    case no

        hUI.IsDirty=false;

    case cancel
        goahead=false;
    end




