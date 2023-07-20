function call=getSemaphoreWaitCall(hObj)





    if isa(hObj,'CoderTarget.SettingsController')
        hObj=hObj.getConfigSet();
    elseif ischar(hObj)
        hObj=getActiveConfigSet(hObj);
    else
        assert(isa(hObj,'Simulink.ConfigSet'),[mfilename,' called with a wrong argument']);
    end

    rtos=codertarget.rtos.getTargetHardwareRTOS(hObj);
    if~isempty(rtos)
        call=rtos.getSemaphoreWaitCall();
    else
        call='/* No semaphore post call registered */';
    end
end
