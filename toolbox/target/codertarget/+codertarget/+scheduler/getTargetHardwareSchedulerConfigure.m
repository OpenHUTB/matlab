function call=getTargetHardwareSchedulerConfigure(hObj)





    if isa(hObj,'CoderTarget.SettingsController')
        hObj=hObj.getConfigSet();
    elseif ischar(hObj)
        hObj=getActiveConfigSet(hObj);
    else
        assert(isa(hObj,'Simulink.ConfigSet'),[mfilename,' called with a wrong argument']);
    end

    scheduler=codertarget.scheduler.getTargetHardwareScheduler(hObj);
    if~isempty(scheduler)
        call=scheduler.getConfigureStartCall();
    else
        call='';
    end
end
