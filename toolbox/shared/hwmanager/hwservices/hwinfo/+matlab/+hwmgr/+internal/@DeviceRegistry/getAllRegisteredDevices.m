function out=getAllRegisteredDevices(~)






    baseFolder=matlab.hwmgr.internal.utils.getDevInfoDir;
    files=dir([baseFolder,filesep,'**/*.json']);
    hwInfoFiles={files.name};
    devSpecificFolders={files.folder};
    out={};

    for i=1:numel(hwInfoFiles)
        filename=fullfile(devSpecificFolders{i},hwInfoFiles{i});
        out{i}=matlab.hwmgr.internal.DeviceInfo.getObjFromFilename(filename);%#ok<AGROW>
    end