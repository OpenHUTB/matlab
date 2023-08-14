function[out,dscr]=buildConfigStatus(cs,~)


    dscr='';

    cs=cs.getConfigSet;
    adp=configset.internal.getConfigSetAdapter(cs);


    if isempty(adp.toolchainInfo)
        configset.internal.customwidget.ToolchainValues(cs,'Toolchain',0);
    end

    if adp.toolchainInfo.TcFound
        out=configset.internal.data.ParamStatus.Normal;
    else
        out=configset.internal.data.ParamStatus.ReadOnly;
    end



