function writeConstraintFile(this,BuildInfo)






    device=BuildInfo.BoardObj;
    PartInfo=device.Component.PartInfo;

    fpga=eval(['eda.fpga.',PartInfo.FPGAVendor]);

    fpga.constraintFile(BuildInfo,this);

end
