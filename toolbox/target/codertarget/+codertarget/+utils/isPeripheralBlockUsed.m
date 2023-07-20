function ret=isPeripheralBlockUsed(hObj)




    if isa(hObj,'Simulink.ConfigSet')||...
        isa(hObj,'Simulink.ConfigSetRef')
        hCS=hObj;
    elseif isa(hObj,'CoderTarget.SettingsController')
        hCS=hObj.getConfigSet;
    else
        hCS=getActiveConfigSet(hObj);
    end
    data=codertarget.resourcemanager.getAllResources(hCS);
    if isempty(data)
        ret=0;
    else
        ret=1;
    end
end