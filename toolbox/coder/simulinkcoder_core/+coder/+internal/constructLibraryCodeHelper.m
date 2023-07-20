function retVal=constructLibraryCodeHelper(libraryFileLocation,...
    libraryName,...
    stf,...
    hardware,...
    sharedUtilsOrCodeFolder)




    fc=Simulink.filegen.internal.FolderConfiguration.forSpecifiedSTFAndHardware(libraryName,...
    stf,...
    hardware,...
    'TargetEnvironmentSubfolder');

    folderSet=fc.getFolderSetFor('RTW');

    if strcmp(sharedUtilsOrCodeFolder,'sharedutils')
        retVal=fullfile(libraryFileLocation,folderSet.SharedUtilityCode);
    else
        retVal=fullfile(libraryFileLocation,folderSet.ModelCode,['R',version('-release')]);
    end

end


