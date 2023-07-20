function updateDeps=ccsTargetSelectCallback(cs,msg)



    updateDeps=false;

    dlg=cs.getDialogHandle;
    dlg.enableApplyButton(true,false);

    if isa(cs,'Simulink.ConfigSet')
        src=cs.getComponent('Host-Target Communication');
    elseif isa(cs,'CCSTargetConfig.HostTargetConfig')
        src=cs;
    end

    if isempty(dlg)||isempty(src)
        return;
    end

    switch msg.name
    case 'CcsBoard'
        type='board';
    case 'CcsProc'
        type='proc';
    otherwise
        type='';
    end

    try
        src.set(msg.name,str2double(msg.value));
        targetSelectCallback(src,dlg,type);
    catch e
        errordlg(e.message);
    end
