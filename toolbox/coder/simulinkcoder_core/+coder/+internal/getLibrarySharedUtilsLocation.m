function retVal=getLibrarySharedUtilsLocation(libraryName,stf,libraryFileLocation)



    suffix=stf(1:end-4);

    libraryCodeFolder=fullfile(libraryFileLocation,[libraryName,'_',suffix]);

    if(~(exist(libraryCodeFolder,'dir')==7))
        retVal='';
        return;
    end

    load(fullfile(libraryCodeFolder,'libraryConfigSetAndSharedPath'),'configset');

    hardware=get_param(configset,'TargetHWDeviceType');

    fc=Simulink.filegen.internal.FolderConfiguration.forSpecifiedSTFAndHardware(libraryName,...
    stf,...
    hardware);

    folderSet=fc.getFolderSetFor('RTW');
    retVal=fullfile(libraryFileLocation,folderSet.SharedUtilityCode);
end
