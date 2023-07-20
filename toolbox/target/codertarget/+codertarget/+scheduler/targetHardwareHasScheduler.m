function ret=targetHardwareHasScheduler(hObj)





    if~isa(hObj,'Simulink.ConfigSet')
        hObj=getActiveConfigSet(hObj);
    end

    ret=~isempty(codertarget.scheduler.getTargetHardwareScheduler(hObj));
end
