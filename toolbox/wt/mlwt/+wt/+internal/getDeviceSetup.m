function deviceSetup=getDeviceSetup(radioObj,appObj,packagebase)

    plugin=getPlugin(radioObj);
    radioType=plugin.DeviceType;
    switch(radioType)
    case 'rfnoc'
        deviceFunc=str2func(strcat(packagebase,'.',radioType,'.DeviceSetup'));
        deviceSetup=deviceFunc(radioObj,appObj);
    end
end

