function call=getSemaphoreDestroyCall(hObj)





    if isa(hObj,'CoderTarget.SettingsController')
        hObj=hObj.getConfigSet();
    elseif ischar(hObj)
        hObj=getActiveConfigSet(hObj);
    else
        assert(isa(hObj,'Simulink.ConfigSet'),[mfilename,' called with a wrong argument']);
    end

    rtos=codertarget.rtos.getTargetHardwareRTOS(hObj);
    if~isempty(rtos)
        call=rtos.getSemaphoreDestroyCall();
    else
        call='/* No semaphore destroy call registered */';
    end
end
