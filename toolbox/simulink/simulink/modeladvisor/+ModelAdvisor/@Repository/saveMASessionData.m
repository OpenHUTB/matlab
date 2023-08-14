
function saveMASessionData(obj)
    PerfTools.Tracer.logMATLABData('MAGroup','Save MA Session Data',true);

    if~isa(obj.MAObj,'Simulink.ModelAdvisor')
        DAStudio.error('ModelAdvisor:engine:DBCannotAccessMA');
    end


    R2FInfo={};
    R2FInfo.R2FMode=obj.MAObj.R2FMode;
    if isa(obj.MAObj.R2FStart,'ModelAdvisor.Node')
        R2FInfo.R2FStart=obj.MAObj.R2FStart.ID;
    else
        R2FInfo.R2FStart={};
    end
    if isa(obj.MAObj.R2FStop,'ModelAdvisor.Node')
        R2FInfo.R2FStop=obj.MAObj.R2FStop.ID;
    else
        R2FInfo.R2FStop={};
    end

    try
        workDir=obj.MAObj.getWorkDir('CheckOnly');
        beginIdx=strfind(workDir,['slprj',filesep,'modeladvisor',filesep])+18;
        workDir(1:beginIdx)='';
        all=strfind(workDir,filesep);
        startIdx=1;
        path={};
        if~isempty(all)
            for i=1:length(all)
                path=[path,workDir(startIdx:all(i)-1)];%#ok<AGROW>
                startIdx=all(i)+1;
            end
            path=[path,workDir(all(end)+1:end)];
        else
            path=[path,workDir];
        end
    catch

        path='calculate failed';
    end

    [recordCellArray,taskCellArray,TaskAdvisorCellArray,ResultDetailsCellArray]=obj.prepareMAData;


    ConfigFilePathInfo.name=obj.MAObj.ConfigFilePath;
    if exist(obj.MAObj.ConfigFilePath,'file')
        dirInfo=dir(obj.MAObj.ConfigFilePath);
        ConfigFilePathInfo.date=dirInfo.date;
    else
        ConfigFilePathInfo.date='';
    end


    emitDataCell={'recordCellArray',recordCellArray,'taskCellArray',taskCellArray,...
    'TaskAdvisorCellArray',TaskAdvisorCellArray,'MAExplorerPosition',obj.MAObj.MAExplorerPosition,...
    'StartInTaskPage',obj.MAObj.StartInTaskPage,'CustomTARootID',obj.MAObj.CustomTARootID,...
    'R2FInfo',R2FInfo,'ConfigFilePathInfo',ConfigFilePathInfo};

    if obj.MAObj.parallel

        ResultMap=obj.MAObj.ResultMap;
        emitDataCell{end+1}='ResultMap';
        emitDataCell{end+1}=ResultMap;
    end


    if~strcmp(path,'calculate failed')
        emitDataCell=[emitDataCell,{'path',path}];
    end
    if isfield(obj.MAObj.AtticData,'callbackFuncInfoStruct')
        emitDataCell=[emitDataCell,{'callbackFuncInfoStruct',obj.MAObj.AtticData.callbackFuncInfoStruct}];
    end
    obj.overwriteLatestData('MdladvInfo',emitDataCell{:});
    obj.saveMAResultDetails(ResultDetailsCellArray);
    obj.MAObj.SessionDataHasBeenSaved=true;

    PerfTools.Tracer.logMATLABData('MAGroup','Save MA Session Data',false);
end
