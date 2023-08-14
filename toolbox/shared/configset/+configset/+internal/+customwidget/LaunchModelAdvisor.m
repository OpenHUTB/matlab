function updateDeps=LaunchModelAdvisor(~,msg)





    updateDeps=false;
    hDlg=msg.dialog;
    hSrc=hDlg.getDialogSource;
    if isa(hSrc,'configset.dialog.HTMLView')
        hSrc=hSrc.Source.getCS;
    end
    hController=hSrc.getDialogController;
    hConfigSet=hSrc.getConfigSet;
    if isa(hConfigSet,'Simulink.ConfigSet')
        hSrc=hConfigSet.getComponent('Code Generation');
    end
    tag='Tag_ConfigSet_Objective_LaunchModelAdvisor';


    activemdladvObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj;
    if isa(activemdladvObj,'Simulink.ModelAdvisor')&&isa(activemdladvObj.ConfigUIWindow,'DAStudio.Explorer')
        warndlgHandle=warndlg(getString(message('Simulink:tools:MAUnableStartMAWhenMACEOpen')));
        set(warndlgHandle,'Tag','MAUnableStartMAWhenMACEOpen');
        setEnabled(hDlg,tag,true);
        return;
    end


    continueLaunch=slprivate('checkSimPrm',hConfigSet);
    if~continueLaunch||~isa(hSrc,'Simulink.RTWCC')
        setEnabled(hDlg,tag,true);
        hController.inRunningCGA=0;
        return;
    end

    hMdl=hSrc.getModel;


    op=hConfigSet.get_param('ObjectivePriorities');
    if isempty(op)
        msgText=getString(message('RTW:configSet:objUnspecifiedDialog',get_param(hMdl,'Name')));
        msgbox(msgText,getString(message('Simulink:dialog:ErrorText')),'warn');
        setEnabled(hDlg,tag,true);
        hController.inRunningCGA=0;
        return;
    end

    ss=CodeGenAdvisor.SystemSelectorForConfigSet(hDlg,hMdl);
    DAStudio.Dialog(ss);
    ss.Listener=handle.listener(hController,'ObjectBeingDestroyed',@ss.closeDlg);



