function result=getRapidAccelBuildDir(model)




    fileGenCfg=Simulink.fileGenControl('getConfig');
    result=fullfile(fileGenCfg.CacheFolder,'slprj','raccel',model);
end