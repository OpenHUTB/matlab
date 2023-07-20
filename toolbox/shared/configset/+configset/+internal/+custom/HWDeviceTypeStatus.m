function[status,dscr]=HWDeviceTypeStatus(cs,name)





    dscr='';

    param=strtok(name,'_');
    device=cs.get_param(param);

    hh=targetrepository.getHardwareImplementationHelper();
    hwDevice=hh.getDevice(device);

    if isempty(hwDevice)||isempty(hwDevice.Manufacturer)
        status=configset.internal.data.ParamStatus.InAccessible;
    else
        status=configset.internal.data.ParamStatus.Normal;
    end
