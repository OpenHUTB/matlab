function value=getPropertyForModel(hObj,propertyName)





    if isa(hObj,'CoderTarget.SettingsController')
        hObj=hObj.getConfigSet();
    elseif ischar(hObj)
        hObj=getActiveConfigSet(hObj);
    else
        assert(isa(hObj,'Simulink.ConfigSet'),[mfilename,' called with a wrong argument']);
    end

    rtos=codertarget.rtos.getTargetHardwareRTOS(hObj);
    if~isempty(rtos)
        value=rtos.(propertyName);
    else
        error(message('codertarget:targetapi:NoRTOSUsedForModel'));
    end
end
