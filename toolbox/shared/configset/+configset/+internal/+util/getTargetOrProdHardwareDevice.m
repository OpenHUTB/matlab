function hwDeviceType=getTargetOrProdHardwareDevice(hardwareConfig)





    prodEqTgt=strcmp(hardwareConfig.ProdEqTarget,'on');

    if~prodEqTgt
        hwDeviceType=hardwareConfig.TargetHWDeviceType;
    else
        hwDeviceType=hardwareConfig.ProdHWDeviceType;
    end
end