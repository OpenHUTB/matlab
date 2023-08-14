function addDataToBlock(handleToBlock,varargin)































    try
        SOURCE_OPTIONS={'workspace','file','sdi'};
        PORT_OPTIONS={'auto','none'};
        blockHandle=handleToBlock;
        if ischar(handleToBlock)||isstring(handleToBlock)
            blockHandle=get_param(handleToBlock,"Handle");
        end
        p=inputParser;
        p.addOptional('source','',@(x)mustBeMember(lower(x),SOURCE_OPTIONS));
        p.addOptional('filepath','',@mustBeTextScalar);
        p.addOptional('customReader','built-in',@mustBeTextScalar);
        p.addOptional('variables',{},@(x)mustBeA(x,["string","cell"]));
        p.addOptional('portAssignment','auto',@(x)mustBeMember(lower(x),PORT_OPTIONS));
        p.addOptional('isLinked',false,@mustBeNumericOrLogical);
        p.addOptional('sourceRunIDs',[],@mustBeVector);
        p.addOptional('sourceSignalIDs',[],@mustBeVector);
        p.parse(varargin{:});
        params=p.Results;


        locPublishToClient(blockHandle,'showSpinner');


        runID=Simulink.playback.internal.getActiveRunID(blockHandle);
        if~runID
            ME=MException('Playback:AddDataError','Invalid Block Handle');
            throw(ME);
        end

        fileInfo=Simulink.playback.internal.getFileInfo(params.filepath);
        params.fullFilePath=fileInfo.fullFilePath;
        params.filepath=fileInfo.shortFilePath;

        addedSignalInfo=addDataToRun(runID,blockHandle,params);


        if~isempty(addedSignalInfo)
            locHideEmptyState(blockHandle);
        end


        Simulink.playback.internal.addSignalMetadata(blockHandle,...
        addedSignalInfo,lower(params.source),...
        params.filepath,params.fullFilePath,params.isLinked,params.portAssignment,params.customReader);
    catch me
        sldiagviewer.reportError(me);
    end


    locPublishToClient(blockHandle,'hideSpinner');
end


function addedSignalIDs=addDataToRun(runID,blockHandle,params)
    addedSignalIDs=[];
    if(lower(params.source)=="workspace")
        addedSignalIDs=addWorkspaceVariablesToRun(runID,blockHandle,params);
    elseif(lower(params.source)=="file")
        addedSignalIDs=addFileVariablesToRun(runID,params);
    elseif(lower(params.source)=="sdi")
        addedSignalIDs=addSDISignalsToRun(runID,params);
    elseif(isempty(params.source))
        addedSignalIDs=addVariablesToRun(runID,params);
    end
end


function addedSignalIDs=addWorkspaceVariablesToRun(runID,blockHandle,params)
    if isempty(params.variables)
        ME=MException('Playback:AddDataError',...
        'Pass variable names to add');
        throw(ME);
    end
    if~iscellstr(params.variables)&&~isstring(params.variables)
        ME=MException('Playback:AddDataError',...
        'Pass variable names in cellstr or string array to add');
        throw(ME);
    end
    repo=sdi.Repository(1);
    existingSignalIDs=repo.getAllSignalIDs(runID,'all');
    wksParser=Simulink.sdi.internal.import.WorkspaceParser.getDefault();
    wksParser.resetParser();
    engine=Simulink.sdi.Instance.engine;
    varParser={};
    for i=1:numel(params.variables)
        variableparser=parseVariable(params.variables{i},blockHandle,wksParser);
        if~isempty(variableparser)
            varParser{end+1}=variableparser{1};%#ok <AGROW>
        end
    end
    mdlName='';
    overwrittenRunID=0;
    parentRunID=int32.empty;
    for i=1:numel(varParser)
        setVariableChecked(varParser{i},1);
    end
    addToRun(wksParser,engine,runID,varParser,mdlName,overwrittenRunID,...
    parentRunID,'OneRun',true);
    addedSignalIDs=getAddedSignalsInfo(repo,runID,existingSignalIDs,varParser);
end


function addedSignalIDs=addFileVariablesToRun(runID,params)
    if isempty(params.filepath)
        ME=MException('Playback:AddDataError','No filePath specified');
        throw(ME);
    end
    repo=sdi.Repository(1);
    existingSignalIDs=repo.getAllSignalIDs(runID,'all');

    addDataUIObj=Simulink.playback.addDataUI();
    varOutputs=addDataUIObj.getParsedDataFromFile(params.fullFilePath,params.customReader);
    numOfSignalsInFile=size(varOutputs);
    if~isempty(params.variables)

        selectedRowIDs=[];
        for i=1:numel(params.variables)
            variableName=params.variables{i};
            variableIndexes=getVariableIndex(variableName,varOutputs);
            selectedRowIDs=[selectedRowIDs,variableIndexes];%#ok <AGROW>
        end

        for i=1:numOfSignalsInFile(2)
            if(isempty(find(selectedRowIDs==varOutputs(i).RowID,1)))
                addDataUIObj.updateCheckedStateInHierarchicalData(...
                varOutputs(i).RowID,0);
            end
        end
        addDataUIObj.updateCheckedStateInHierarchicalData(selectedRowIDs,1);
    end
    runName=Simulink.sdi.getRun(runID).Name;
    importer=Simulink.sdi.internal.import.FileImporter.getDefault();
    importer.verifyFileAndImport(...
    sdi.Repository(1),...
    params.fullFilePath,runName,...
    true,...
    runID,...
    'reader','',...
    'parser',addDataUIObj.VarParser,...
    'OneRun',true);
    addedSignalIDs=getAddedSignalsInfo(repo,runID,existingSignalIDs,addDataUIObj.VarParser);
end


function addedSignalIDs=addVariablesToRun(runID,params)
    if isempty(params.variables)||iscellstr(params.variables)
        ME=MException('Playback:AddDataError',...
        'Pass actual variables to add data in case of no source');
        throw(ME);
    end
    if logical(params.isLinked)
        ME=MException('Playback:AddDataError',...
        'Actual variables cannot added using link option');
        throw(ME);
    end
    repo=sdi.Repository(1);
    existingSignalIDs=repo.getAllSignalIDs(runID,'all');
    for i=1:numel(params.variables)
        Simulink.sdi.addToRun(runID,'vars',params.variables{i});
    end
    varParser={};

    addedSignalIDs=getAddedSignalsInfo(repo,runID,existingSignalIDs,varParser);
end


function addedSignalsInfo=addSDISignalsToRun(runID,params)
    if isempty(params.isLinked)
        ME=MException('Playback:AddDataError','SDI Signals cannot be linked');
        throw(ME);
    end
    srcrunIDs=params.sourceRunIDs;
    srcsignalIds=[];
    if~isempty(params.sourceSignalIDs)
        srcsignalIds=params.sourcesignalIDs;
    end

    numofRunsTobeAdded=numel(srcrunIDs);
    repo=sdi.Repository(1);
    for i=1:numofRunsTobeAdded
        existingSignalIDs=repo.getAllSignalIDs(srcrunIDs(i),'all');
        srcsignalIds=[existingSignalIDs,srcsignalIds];%#ok <AGROW>
    end
    numOfSignalsToAdd=numel(srcsignalIds);
    sigIDs=repelem(int32(0),numOfSignalsToAdd);
    for i=1:numOfSignalsToAdd
        sigIDs(i)=int32(srcsignalIds(i));
    end
    addedSignalsInfo=Simulink.playback.internal.addSDISignalsToRun(sigIDs,runID);
end


function addedSignalIDs=getAddedSignalsInfo(repo,runID,existingSignalIDs,~)
    currentSignalIDs=repo.getAllSignalIDs(runID,'all');
    index=1;
    numOfSignalsAdded=numel(currentSignalIDs)-numel(existingSignalIDs);
    addedSignalIDs=repelem(int32(0),numOfSignalsAdded);
    for i=numel(existingSignalIDs)+1:numel(currentSignalIDs)
        addedSignalIDs(index)=currentSignalIDs(i);
        index=index+1;
    end
end


function variableIndexes=getVariableIndex(variableName,varOutputs)
    numSignalsInFile=size(varOutputs);
    variableIndexes=[];
    for i=1:numSignalsInFile(2)
        if(strcmp(string(variableName),string(varOutputs(i).Name))~=0)
            variableIndexes=[variableIndexes,varOutputs(i).RowID];%#ok <AGROW>
        end
    end
end


function ret=parseVariable(varName,blockHandle,wksParser)
    try
        vars=struct;
        vars.VarName=varName;
        vars.VarValue=slResolve(varName,blockHandle);
        ret=parseVariables(wksParser,vars);
    catch
        ME=MException('Playback:AddDataError',...
        message('record_playback:errors:InvalidVariableName',varName));
        throw(ME);
    end
end


function locHideEmptyState(blockHandle)
    sigMetadata=get_param(blockHandle,'signalMetadata');

    if isempty(sigMetadata)
        locPublishToClient(blockHandle,'hideEmptyState');
    end
end


function locPublishToClient(blockHandle,msg)
    dispatcher=Simulink.sdi.internal.controllers.SDIDispatcher.getDispatcher();
    clientID=get_param(blockHandle,'clientId');
    dispatcher.publishToClient(clientID,'mainApp',msg,[]);
end