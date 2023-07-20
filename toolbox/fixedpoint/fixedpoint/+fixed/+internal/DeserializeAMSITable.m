function DeserializeAMSITable(modelName)





    fileGenCfg=Simulink.fileGenControl('getConfig');
    rootDir=fileGenCfg.CacheFolder;
    buildDir=fullfile(rootDir,'slprj','_sfprj',modelName);
    hModel=get_param(modelName,'handle');

    fileName='amsi_serial.mat';
    fullFileName=fullfile(buildDir,fileName);

    if exist(fullFileName,'file')==2

        amsiTable=load(fullFileName);


        set_param(hModel,'AMSITableSerialized',amsiTable.amsi_serial);
    end
end
