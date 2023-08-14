function out=getDeviceInfo(~,spPkgBaseDir)






    filename=matlab.hwmgr.internal.DeviceInfo.getDeviceInfoFileForBaseDir(spPkgBaseDir);

    out={};
    if~isempty(filename)
        out=matlab.hwmgr.internal.DeviceInfo.getObjFromFilename(filename);
    end

