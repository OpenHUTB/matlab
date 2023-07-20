function InferenceReportGenerator(iReport,fullBlkPath)


    modelName=bdroot(fullBlkPath);
    htmlDirPath=cgxeprivate('create_directory_path',pwd,'slprj','_cgxe',modelName,'info');

    reportName='SysObjReport';

    summary=struct(...
    'directory',pwd,...
    'htmldirectory',htmlDirPath,...
    'passed',1);

    report=struct(...
    'summary',summary,...
    'inference',iReport);

    mainInfoName=fullfile(htmlDirPath,[reportName,'.mat']);
    save(mainInfoName,'report');

    codergui.evalprivate('genSystemBlockReport',report,Simulink.ID.getSID(fullBlkPath),htmlDirPath);

end
