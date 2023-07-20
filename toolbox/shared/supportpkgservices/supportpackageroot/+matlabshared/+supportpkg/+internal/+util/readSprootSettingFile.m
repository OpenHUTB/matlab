function settingVal=readSprootSettingFile(settingFileFullPath)



    if~logical(exist(settingFileFullPath,'file'))
        error(message('supportpkgservices:supportpackageroot:NoSettingFile'));
    end



    settingVal=matlabshared.supportpkg.internal.biReadSettingXMLFile(settingFileFullPath);

    if isempty(settingVal)
        error(message('supportpkgservices:supportpackageroot:CorruptSettingFile',settingFileFullPath));
    end
end