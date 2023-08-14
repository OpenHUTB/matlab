function scheduler=getTargetHardwareScheduler(hObj)





    if isa(hObj,'CoderTarget.SettingsController')
        hObj=hObj.getConfigSet();
    elseif ischar(hObj)
        hObj=getActiveConfigSet(hObj);
    else
        assert(isa(hObj,'Simulink.ConfigSet'),[mfilename,' called with a wrong argument']);
    end

    hwInfo=codertarget.targethardware.getHardwareConfiguration(hObj);
    scheduler=[];
    if~isempty(hwInfo)&&~isempty(hwInfo.SchedulerInfoFiles)
        attributeInfo=codertarget.attributes.getTargetHardwareAttributes(hObj);
        objValue=codertarget.data.getParameterValue(hObj,'Scheduler_interrupt_source');
        if isempty(codertarget.rtos.getTargetHardwareRTOS(hObj))
            defFile=codertarget.utils.replaceTokens(hObj,hwInfo.SchedulerInfoFiles{objValue+1},attributeInfo.Tokens);
            scheduler=codertarget.Registry.manageInstance('get','scheduler',defFile);
        end
    end
end
