function out=HWDeviceVendor(cs,name)




    hh=targetrepository.getHardwareImplementationHelper();

    if strcmp(name(1:4),'Prod')
        prefix='Prod';
    else
        prefix='Target';
    end

    value=cs.get_param([prefix,'HWDeviceType']);

    vendorList=hh.getVendorList(prefix);
    device=hh.getDevice(value);




    if isempty(device)
        nameStruct=targetrepository.splitHWParameterString(value);

        if isempty(nameStruct)
            vendorList{end+1}='';
        else
            vendorList{end+1}=nameStruct.Vendor;
        end
    elseif device.Grandfathered
        vendorList{end+1}=device.Manufacturer;
    end

    out=struct('str',vendorList);


