function call=getTaskDataType(hObj)





    if isa(hObj,'CoderTarget.SettingsController')
        hObj=hObj.getConfigSet();
    elseif ischar(hObj)
        hObj=getActiveConfigSet(hObj);
    else
        assert(isa(hObj,'Simulink.ConfigSet'),[mfilename,' called with a wrong argument']);
    end

    rtos=codertarget.rtos.getTargetHardwareRTOS(hObj);
    if~isempty(rtos)
        call=rtos.getTaskDataType();
    else
        call='/* No rtos task data type registered */';
    end
end
