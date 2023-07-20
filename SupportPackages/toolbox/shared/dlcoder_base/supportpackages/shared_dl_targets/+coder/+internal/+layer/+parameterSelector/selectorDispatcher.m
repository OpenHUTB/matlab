function parameterSelector=selectorDispatcher(buildContext)






    hardwareImplementation=buildContext.getHardwareImplementation;
    assert(~isempty(hardwareImplementation));



    if(islogical(hardwareImplementation.ProdEqTarget)&&hardwareImplementation.ProdEqTarget==1)...
        ||strcmp(hardwareImplementation.ProdEqTarget,'on')


        deviceType=hardwareImplementation.ProdHWDeviceType;
    else
        deviceType=hardwareImplementation.TargetHWDeviceType;
    end

    switch deviceType
    case{'ARM Compatible->ARM Cortex','ARM Compatible->ARM Cortex-A',...
        'ARM Compatible->ARM Cortex-M'}
        parameterSelector=coder.internal.layer.parameterSelector.ARMParameterSelector();
    case{'Intel->x86-64 (Linux 64)','Intel->x86-64 (Mac OS X)','Intel->x86-64 (Windows64)',...
        'Generic->MATLAB Host Computer'}
        parameterSelector=coder.internal.layer.parameterSelector.IntelParameterSelector();
    otherwise
        parameterSelector=coder.internal.layer.parameterSelector.DefaultParameterSelector();
    end

end