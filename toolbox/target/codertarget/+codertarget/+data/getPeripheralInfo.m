function out=getPeripheralInfo(hObj)




    if isa(hObj,'Simulink.ConfigSet')||...
        isa(hObj,'Simulink.ConfigSetRef')
        hCS=hObj;
    else

        hCS=getActiveConfigSet(hObj);
    end

    assert(hCS.isValidParam('CoderTargetData'),'No CoderTargetData');

    out=[];
    data=get_param(hCS,'CoderTargetData');
    if isfield(data,'HardwareMapping')
        if isfield(data.HardwareMapping,'Peripherals')
            out=data.HardwareMapping.Peripherals;
        end
    end
end
