function call=getEventSendCall(hObj)





    if isa(hObj,'CoderTarget.SettingsController')
        hObj=hObj.getConfigSet();
    elseif ischar(hObj)
        hObj=getActiveConfigSet(hObj);
    else
        assert(isa(hObj,'Simulink.ConfigSet'),[mfilename,' called with a wrong argument']);
    end

    rtos=codertarget.rtos.getTargetHardwareRTOS(hObj);
    if~isempty(rtos)
        call=rtos.getEventSendCall();
    else
        call='/* No rtos event send call registered */';
    end
end
