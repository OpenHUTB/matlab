function setCPUName(hObj,cpuName)



    if isa(hObj,'Simulink.ConfigSet')||...
        isa(hObj,'Simulink.ConfigSetRef')
        hCS=hObj;
    elseif isa(hObj,'CoderTarget.SettingsController')
        hCS=hObj.getConfigSet;
    else

        hCS=getActiveConfigSet(hObj);
    end

    if~codertarget.data.isParameterInitialized(hCS,'Runtime.CPU')

    else
        codertarget.data.setParameterValue(hCS,'Runtime.CPU',cpuName);
    end
end

