function updateDeps=HDLRestoreFactoryDefaults(cs,msg)



    dlg=msg.dialog;%#ok<NASGU>
    updateDeps=false;
    adp=configset.internal.getConfigSetAdapter(cs);
    cs=cs.getConfigSet;
    hObj=cs.getComponent('HDL Coder');

    str=DAStudio.message('HDLShared:hdldialog:hdlccRestoreDefaultQuestion');


    answer=questdlg(str,...
    DAStudio.message('HDLShared:hdldialog:hdlccRestoreDefault'),...
    DAStudio.message('HDLShared:hdldialog:hdlccYes'),...
    DAStudio.message('HDLShared:hdldialog:hdlccNo'),...
    DAStudio.message('HDLShared:hdldialog:hdlccNo'));

    if strcmp(answer,DAStudio.message('HDLShared:hdldialog:hdlccYes'))
        modelName=hObj.getModelName;
        hObj.registerEventsAtPostLoad(modelName);


        hObj.createCLI(false);


        mP=slprops.hdlmdlprops({'HDLSubsystem',modelName});
        set_param(modelName,'HDLParams',mP);




        adp.resetAdapter;
    end


