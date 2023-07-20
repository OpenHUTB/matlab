function rootBDir=getRTWBuildDir()




    fileGenCfg=Simulink.fileGenControl('getConfig');
    rootBDir=fileGenCfg.CodeGenFolder;
end