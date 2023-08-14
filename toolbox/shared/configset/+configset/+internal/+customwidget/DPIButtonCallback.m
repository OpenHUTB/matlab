function updateDeps=DPIButtonCallback(cs,msg)


    updateDeps=false;
    if isa(cs,'Simulink.ConfigSet')
        rtw=cs.getComponent('Code Generation');
        hObj=rtw.getComponent('Target');
    elseif isa(cs,'Simulink.RTWCC')
        hObj=cs.getComponent('Target');
    else
        hObj=cs;
    end

    if strcmp(msg.name,'DPICustomizeSystemVerilogBrowse_')
        tag='BrowseDPISystemVerilogTemplate';
    else
        tag='EditDPISystemVerilogTemplate';
    end

    dlg=msg.dialog;
    hObj.pushButtonCallBack(dlg,tag);



