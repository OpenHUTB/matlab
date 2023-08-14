function updateDeps=plcCallback(cs,msg)





    updateDeps=false;

    if isa(cs,'PLCCoder.ConfigComp')
        plc=cs;
    elseif isa(cs,'Simulink.ConfigSet')
        plc=cs.getComponent('PLC Coder');
    end

    if isempty(plc)
        return;
    end

    dlg=msg.dialog;
    tag=msg.data.getTag(cs);
    action=[];
    action.value=msg.value;

    plc.dialogCallback(dlg,tag,jsonencode(action));
