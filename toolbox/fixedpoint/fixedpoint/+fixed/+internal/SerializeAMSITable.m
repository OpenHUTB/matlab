function SerializeAMSITable(modelName)





    fileGenCfg=Simulink.fileGenControl('getConfig');
    rootDir=fileGenCfg.CacheFolder;
    buildDir=fullfile(rootDir,'slprj','_sfprj',modelName);
    hModel=get_param(modelName,'handle');

    if exist(buildDir,'dir')>0

        ffAMSI=fullfile(buildDir,'amsi_serial.mat');
        amsi_serial=get_param(hModel,'AMSITableSerialized');
        save(ffAMSI,'amsi_serial');
    end
end
