function schedulerNames=getSupportedSchedulerNames(hObj)




    schedulerNames={};
    hardwareInfo=codertarget.targethardware.getHardwareConfiguration(hObj);
    if isempty(hardwareInfo)
        return
    end
    attributeInfo=codertarget.attributes.getTargetHardwareAttributes(hObj);
    if isempty(attributeInfo)
        return;
    end
    for i=1:numel(hardwareInfo.SchedulerInfoFiles)
        defFile=codertarget.utils.replaceTokens(hObj,hardwareInfo.SchedulerInfoFiles{i},attributeInfo.Tokens);
        myinfo=codertarget.Registry.manageInstance('get','scheduler',defFile);
        schedulerNames{end+1}=myinfo.getName();%#ok<AGROW>
    end
end
