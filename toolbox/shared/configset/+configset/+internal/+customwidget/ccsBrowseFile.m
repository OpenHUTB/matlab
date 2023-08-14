function updateDeps=ccsBrowseFile(cs,msg)


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

    switch msg.name
    case 'CcsBrowseProj'
        opt='project';
    case 'CcsBrowseProg'
        opt='program';
    otherwise
        opt='';
    end

    try
        browseFile(src,opt,dlg);
    catch e
        errordlg(e.message);
    end


