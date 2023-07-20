function updateDeps=HDLbrowseDir(cs,msg)


    data=msg.data;
    dlg=msg.dialog;
    pName=data.Parameter.Name;

    updateDeps=false;
    cs=cs.getConfigSet;
    hdl=cs.getComponent('HDL Coder');
    cli=hdl.getCLI;

    dir=uigetdir('',DAStudio.message('HDLShared:hdldialog:hdlccSelectTargetDir'));

    if dir~=0
        set(cli,pName,dir);
        if~isempty(dlg)
            dlg.getDialogSource.enableApplyButton(true);
            dirtyWidget(ConfigSet.DDGWrapper(dlg),pName,true);
        end
    end

