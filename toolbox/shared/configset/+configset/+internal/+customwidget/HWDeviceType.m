function out=HWDeviceType(cs,name)




    hh=targetrepository.getHardwareImplementationHelper();

    if strcmp(name(1:4),'Prod')
        prefix='Prod';
    else
        prefix='Target';
    end

    value=cs.get_param([prefix,'HWDeviceType']);
    device=hh.getDevice(value);

    if isempty(device)
        nameStruct=targetrepository.splitHWParameterString(value);
        if isempty(nameStruct)
            typeList='';
        else
            typeList=nameStruct.Type;
        end
    elseif device.Grandfathered
        typeList=device.Name;
    else
        if isempty(device.Manufacturer)
            vendor=device.Name;
        else
            vendor=device.Manufacturer;
        end

        deviceList=hh.getDevices(prefix,vendor);
        if isempty(deviceList)
            typeList=device.Name;
        else
            typeList={deviceList.Name}';
        end
    end

    out=struct('str',typeList);


