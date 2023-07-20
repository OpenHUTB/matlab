function RegisteredCPUs=getRegisteredCPUs(hObj)



    if isa(hObj,'Simulink.ConfigSet')||...
        isa(hObj,'Simulink.ConfigSetRef')
        hCS=hObj;
    elseif isa(hObj,'CoderTarget.SettingsController')
        hCS=hObj.getConfigSet;
    else

        hCS=getActiveConfigSet(hObj);
    end

    targetHardware=codertarget.targethardware.getTargetHardware(hCS);
    ProcessingUnitInfo=codertarget.targethardware.getProcessingUnitsForTargetHardware(targetHardware);
    RegisteredCPUs=[];
    if~isempty(ProcessingUnitInfo)
        RegisteredCPUs={ProcessingUnitInfo.Name};
        RegisteredCPUs(contains(RegisteredCPUs,'None'))=[];
    end
end


