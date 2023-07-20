function driver=getDriver(radioObj,appObj,packagebase)





    plugin=getPlugin(radioObj);
    radioType=plugin.DeviceType;
    switch(radioType)
    case 'rfnoc'
        driverFunc=str2func(strcat(packagebase,'.',radioType,'.Driver'));
        driver=driverFunc(radioObj,appObj);
    end
end

