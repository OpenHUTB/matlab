function restoreDir=getCurrentRestoreDir





    fileGenCfg=Simulink.fileGenControl('getConfig');
    rootBDir=fileGenCfg.CacheFolder;
    session=restorepoint.internal.utils.SessionInformationManager.getSessionIdentifier.UUID;
    restoreDir=fullfile(rootBDir,'slprj','modelrestore',session);
end


