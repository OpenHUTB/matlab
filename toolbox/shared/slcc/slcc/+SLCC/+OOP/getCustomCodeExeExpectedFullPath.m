function ccExeExpectedFullPath=getCustomCodeExeExpectedFullPath(settingsChecksum,fullChecksum)


    fileGenCfg=Simulink.fileGenControl('getConfig');
    rootDir=fileGenCfg.CacheFolder;

    fileExt='';
    if ispc
        fileExt='.exe';
    end

    ccExeFileName=[fullChecksum,fileExt];

    ccExeExpectedFullPath=fullfile(rootDir,'slprj','_sloop',settingsChecksum,ccExeFileName);


end
