function ccSrcFileExpectedFullPath=getCustomCodeSrcFileExpectedFullPath(settingsChecksum,iscpp)


    fileGenCfg=Simulink.fileGenControl('getConfig');
    rootDir=fileGenCfg.CacheFolder;

    fileExt='.c';
    if iscpp
        fileExt='.cpp';
    end

    ccSrcFileName=[settingsChecksum,'_interface',fileExt];

    ccSrcFileExpectedFullPath=fullfile(rootDir,'slprj','_sloop',settingsChecksum,ccSrcFileName);


end
