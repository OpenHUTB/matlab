function updateDeps=setHWDeviceType(cs,msg)






    updateDeps=true;
    name=msg.name;
    value=msg.value;
    paramName=msg.data.Parameter.Name;

    if~isa(cs,'Simulink.ConfigSet')&&~isa(cs,'Simulink.HardwareCC')
        cs=getConfigSet(cs);
    end

    hh=targetrepository.getHardwareImplementationHelper();

    vendorName=value;

    if isempty(cs)
        return;
    end
    oldValue=cs.get_param(paramName);
    oldDevice=hh.getDevice(oldValue);
    if~isempty(oldDevice)&&strcmp(oldDevice.Manufacturer,vendorName)
        return;
    else
        prefix=name(1:strfind(paramName,'HWDeviceType')-1);
        nameList={hh.getDevices(prefix,vendorName).Name};
        newValue=[vendorName,'->',nameList{1}];
        cs.setProp(paramName,newValue);


        configset.internal.util.resetInstructionSetExtensionsIfNecessary(cs,paramName);
    end

