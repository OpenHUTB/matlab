function[out,dscr]=buildConfigUnknown(cs,~)



    dscr='';

    cs=cs.getConfigSet;
    adp=configset.internal.getConfigSetAdapter(cs);


    if isempty(adp.toolchainInfo)
        configset.internal.customwidget.ToolchainValues(cs,'Toolchain',0);
    end

    if~isfield(adp.toolchainInfo,'BcFound')
        configset.internal.customwidget.BuildConfigValues(cs,'BuildConfiguration',0);
    end

    if adp.toolchainInfo.BcFound
        out=3;
    else
        out=0;
    end



