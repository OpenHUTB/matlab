function call=getTargetHardwareSchedulerStopConfigure(hObj)





    if isa(hObj,'CoderTarget.SettingsController')
        hObj=hObj.getConfigSet();
    elseif ischar(hObj)
        hObj=getActiveConfigSet(hObj);
    else
        assert(isa(hObj,'Simulink.ConfigSet'),[mfilename,' called with a wrong argument']);
    end

    scheduler=codertarget.scheduler.getTargetHardwareScheduler(hObj);
    if~isempty(scheduler)
        call=scheduler.getConfigureStopCall();
    else
        call='';
    end
end
