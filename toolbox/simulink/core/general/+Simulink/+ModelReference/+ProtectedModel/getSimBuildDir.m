function rootBDir=getSimBuildDir()




    fileGenCfg=Simulink.fileGenControl('getConfig');
    rootBDir=fileGenCfg.CacheFolder;
end