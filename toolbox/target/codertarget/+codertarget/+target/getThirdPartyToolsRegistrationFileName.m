function fileName=getThirdPartyToolsRegistrationFileName(targetFolder)





    arch=lower(computer('arch'));
    folder=codertarget.target.getThirdPartyToolsRegistryFolder(targetFolder);
    fileName=fullfile(folder,['thirdpartytools_',arch,'.xml']);
end