function updateDeps=ccsLoadProgram(cs,msg)



    updateDeps=false;

    dlg=msg.dialog;
    if isa(cs,'Simulink.ConfigSet')
        src=cs.getComponent('Host-Target Communication');
    elseif isa(cs,'CCSTargetConfig.HostTargetConfig')
        src=cs;
    end

    if isempty(dlg)||isempty(src)
        return;
    end

    try
        loadProgram(src,dlg);
    catch e
        errordlg(e.message);
    end