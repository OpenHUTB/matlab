function createExecutionManifest(buildDir,apiObj,modelName)










    processPath=apiObj.find('/','Process','PathType','FullyQualified');
    processStruct.Name=apiObj.get(processPath{1},'Name');
    if strcmp(get_param(modelName,'AutosarSchemaVersion'),'R20-11')
        machinePath=apiObj.find('/','Machine','PathType','FullyQualified');
        dltLogChannelPath=apiObj.find(machinePath{1},'DltLogChannel','PathType','FullyQualified');
        processStruct.LogTraceDefaultLogLevel=apiObj.get(dltLogChannelPath{1},'LogTraceDefaultLogLevel');
        logModes=apiObj.get(dltLogChannelPath{1},'LogTraceLogMode');
        processStruct.LogTraceLogMode=logModes{1};
        processStruct.LogTraceFilePath=apiObj.get(dltLogChannelPath{1},'LogTraceFilePath');
        processStruct.LogTraceProcessDesc=apiObj.get(dltLogChannelPath{1},'ApplicationDesc');
        processStruct.LogTraceProcessId=apiObj.get(dltLogChannelPath{1},'ApplicationId');
    else
        processStruct.LogTraceDefaultLogLevel=apiObj.get(processPath{1},'LogTraceDefaultLogLevel');
        logModes=apiObj.get(processPath{1},'LogTraceLogMode');
        processStruct.LogTraceLogMode=logModes{1};
        processStruct.LogTraceFilePath=apiObj.get(processPath{1},'LogTraceFilePath');
        processStruct.LogTraceProcessDesc=apiObj.get(processPath{1},'LogTraceProcessDesc');
        processStruct.LogTraceProcessId=apiObj.get(processPath{1},'LogTraceProcessId');
    end
    executionManifestStruct.Process=processStruct;


    execManifestFullFilePath=[buildDir.CodeGenFolder,filesep,'ExecutionManifest.json'];
    autosar.internal.adaptive.manifest.createJSONfileFromStruct(executionManifestStruct,execManifestFullFilePath);
end


