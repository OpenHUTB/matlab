function updateDeps=setHWDeviceType_Type(cs,msg)






    updateDeps=true;
    value=msg.value;
    paramName=msg.data.Parameter.Name;

    if~isa(cs,'Simulink.ConfigSet')&&~isa(cs,'Simulink.HardwareCC')
        cs=getConfigSet(cs);
    end

    newTypeName=value;

    if isempty(cs)
        return;
    end

    oldParamValue=cs.get_param(paramName);

    [vendorName,oldTypeName]=getResolvedVendorAndType(oldParamValue);

    if strcmp(newTypeName,oldTypeName)
        return;
    else
        newParamValue=[vendorName,'->',newTypeName];
        cs.setProp(paramName,newParamValue);


        configset.internal.util.resetInstructionSetExtensionsIfNecessary(cs,paramName);
    end
end

function[vendor,type]=getResolvedVendorAndType(deviceParamValue)

    vendor='';
    type='';

    if(strcmp(deviceParamValue,'Unspecified'))
        vendor='Custom Processor';
        type='Custom Processor';
        return;
    end

    hh=targetrepository.getHardwareImplementationHelper();
    device=hh.getDevice(deviceParamValue);

    if isempty(device)
        nameStruct=targetrepository.splitHWParameterString(deviceParamValue);
        if~isempty(nameStruct)
            vendor=nameStruct.Vendor;
            type=nameStruct.Type;
        end
    else
        vendor=device.Manufacturer;
        type=device.Name;
    end
end
