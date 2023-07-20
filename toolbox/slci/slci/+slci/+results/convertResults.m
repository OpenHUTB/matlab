

function convertResults(Config)

    ProfileConvert=slci.internal.Profiler('SLCI',...
    'ConvertResults',...
    Config.getModelName(),...
    Config.getTargetName());

    DataFile=Config.getMatFile();
    load(DataFile,'verification_data');

    datamgr=Config.getDataManager();

    codeTable=containers.Map;
    blockTable=containers.Map;
    functionInterfaceTable=containers.Map;
    tempVarTable=containers.Map;


    slci.results.prepareObjects(Config,verification_data,datamgr);

    pfiler=slci.internal.Profiler('SLCI','readRegistrationDataDesc','','');



    blockTable=slci.results.readRegistrationDataDesc(verification_data,...
    blockTable,...
    datamgr);

    pfiler.stop();
    pfiler=slci.internal.Profiler('SLCI','convertFunctionData','','');


    functionInterfaceTable=slci.results.convertFunctionData(...
    datamgr,...
    verification_data,...
    functionInterfaceTable,...
    Config);

    pfiler.stop();
    pfiler=slci.internal.Profiler('SLCI','convertFunctionBodyData','','');



    slci.results.convertFunctionBodyData(datamgr,verification_data,Config);

    pfiler.stop();
    pfiler=slci.internal.Profiler('SLCI','convertCodeData','','');




    [codeTable,blockTable,functionInterfaceTable]=...
    slci.results.convertCodeData(datamgr,verification_data,codeTable,...
    blockTable,functionInterfaceTable);

    pfiler.stop();
    pfiler=slci.internal.Profiler('SLCI','convertModelData','','');


    [blockTable,codeTable,functionInterfaceTable]=...
    slci.results.convertModelData(Config,datamgr,verification_data,...
    blockTable,codeTable,functionInterfaceTable);

    pfiler.stop();
    pfiler=slci.internal.Profiler('SLCI','convertTempVarData','','');


    [tempVarTable,codeTable]=...
    slci.results.convertTempVarData(datamgr,verification_data,...
    tempVarTable,codeTable);

    pfiler.stop();
    pfiler=slci.internal.Profiler('SLCI','convertErrorData','','');



    slci.results.convertErrorData(datamgr,verification_data);

    pfiler.stop();
    pfiler=slci.internal.Profiler('SLCI','convertTypeReplacementData','','');


    codeTable=slci.results.convertTypeReplacementData(datamgr,...
    verification_data,...
    codeTable);

    pfiler.stop();
    pfiler=slci.internal.Profiler('SLCI','convertFunctionCallData','','');


    codeTable=...
    slci.results.convertFunctionCallData(datamgr,...
    verification_data,...
    codeTable);

    pfiler.stop();
    pfiler=slci.internal.Profiler('SLCI','convertSubSystemData','','');


    codeTable=slci.results.convertSubSystemData(datamgr,...
    verification_data,...
    codeTable);

    pfiler.stop();
    pfiler=slci.internal.Profiler('SLCI','cacheData','','');

    slci.results.cacheData('save',blockTable,datamgr,...
    datamgr.getBlockReader(),'replaceObject');
    slci.results.cacheData('save',codeTable,datamgr,...
    datamgr.getCodeReader(),'replaceObject');
    slci.results.cacheData('save',functionInterfaceTable,datamgr,...
    datamgr.getFunctionInterfaceReader,'replaceObject');
    slci.results.cacheData('save',tempVarTable,datamgr,...
    datamgr.getTempVarReader(),'replaceObject');

    pfiler.stop();
    ProfileConvert.stop();

end
