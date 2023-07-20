function[status,dscr]=CustomToolchainOptions(cs,name)



    dscr='';

    cs=cs.getConfigSet;
    adp=configset.internal.getConfigSetAdapter(cs);


    if isempty(adp.toolchainInfo)
        configset.internal.customwidget.ToolchainValues(cs,'Toolchain',0);
    end

    if~isfield(adp.toolchainInfo,'BcFound')
        configset.internal.customwidget.BuildConfigValues(cs,'BuildConfiguration',0);
    end

    switch name
    case 'CustomToolchainOptions'
        if adp.toolchainInfo.ModelSpecific
            status=configset.internal.data.ParamStatus.Normal;
        else
            status=configset.internal.data.ParamStatus.ReadOnly;
        end
    case 'CustomToolchainOptionsSpecify'
        if adp.toolchainInfo.ModelSpecific
            status=configset.internal.data.ParamStatus.Normal;
        else
            status=configset.internal.data.ParamStatus.UnAvailable;
        end
    case 'CustomToolchainOptionsRead'
        if adp.toolchainInfo.ModelSpecific
            status=configset.internal.data.ParamStatus.UnAvailable;
        else
            status=configset.internal.data.ParamStatus.ReadOnly;
        end
    end

