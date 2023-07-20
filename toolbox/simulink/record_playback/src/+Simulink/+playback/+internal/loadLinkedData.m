



function signalInfo=loadLinkedData(blkHandle,runID)

    signals_metadata=get_param(blkHandle,"SignalMetadata");
    numOfSignals=size(signals_metadata);
    linkedWorkSpaceSignals=[];

    linkedFileSignals=containers.Map;
    for i=1:numOfSignals(2)
        if(signals_metadata(i).IsLinked...
            &&~isempty(signals_metadata(i).SourceVariableName))
            signalSource=signals_metadata(i).SignalSource;
            resolvedFilePath=signals_metadata(i).ResolvedFullFilePath;
            if(signalSource=="workspace")
                linkedWorkSpaceSignals=[linkedWorkSpaceSignals,signals_metadata(i)];%#ok <AGROW>
            else
                if(linkedFileSignals.isKey(resolvedFilePath))
                    sig=linkedFileSignals(resolvedFilePath);
                    sig=[sig,signals_metadata(i)];%#ok <AGROW>
                    linkedFileSignals(resolvedFilePath)=sig;
                else
                    linkedFileSignals(resolvedFilePath)=signals_metadata(i);
                end
            end
        end
    end
    workSpacesignalInfo=loadLinkedWorkSpaceSignalsData(linkedWorkSpaceSignals,blkHandle,runID);
    filesSignalInfo=loadFilesSignalsData(linkedFileSignals,blkHandle,runID);
    signalInfo=[workSpacesignalInfo,filesSignalInfo];
end

function signalsInfo=loadLinkedWorkSpaceSignalsData(linkedWorkSpaceSignals,blkHandle,runID)
    signalsInfo=[];
    numOfSignals=size(linkedWorkSpaceSignals);
    if(numOfSignals(2)==0)

        return;
    end
    repo=sdi.Repository(1);
    existingSigIDs=repo.getAllSignalIDs(runID,'all');
    try
        for signalIndex=1:numOfSignals(2)
            signalInfo=struct;
            childSignalNames=getChildSignalNames(blkHandle,linkedWorkSpaceSignals(signalIndex));
            signalInfo=locValidateAndLoadWorkspaceVar(linkedWorkSpaceSignals(signalIndex),blkHandle,childSignalNames,runID);
            signalInfo.SignalUUID=linkedWorkSpaceSignals(signalIndex).SignalUUID;
            signalInfo.SignalName=linkedWorkSpaceSignals(signalIndex).SignalName;
            signalInfo.LinkedFileStatus='';
            signalsInfo=[signalsInfo,signalInfo];%#ok <AGROW>
        end
    catch me


        newSignalIDs=repo.getAllSignalIDs(runID,'all');
        for i=length(existingSigIDs)+1:length(newSignalIDs)
            repo.remove(newSignalIDs(i));
        end

        signalsInfo=[];
        me.throwAsCaller();
    end
end


function filesSignalsInfo=loadFilesSignalsData(linkedFileSignals,blkHandle,runID)
    filesSignalsInfo=[];
    linkedFiles=linkedFileSignals.keys;
    for i=1:numel(linkedFiles)
        linkedFile=linkedFiles{i};
        fileSignalInfo=loadSignalsFromFile(linkedFileSignals(linkedFile),linkedFile,blkHandle,runID);
        filesSignalsInfo=[filesSignalsInfo,fileSignalInfo];%#ok <AGROW>
    end
end


function fileSignalInfo=loadSignalsFromFile(linkedFileSignals,linkedFile,blkHandle,runID)
    fileSignalInfo=[];
    fileStatus='FILE_MISSING';

    parsedFileObjsMap=containers.Map;
    if(isFileAccesible(linkedFile))
        fileStatus='FILE_EXISTS';
    end
    for i=1:numel(linkedFileSignals)
        signalID=0;
        childSignalNames=getChildSignalNames(blkHandle,linkedFileSignals(i));
        signalInfo.SignalID=linkedFileSignals(i).SignalID;
        signalInfo.IsSignalUpdated=1;
        signalInfo.IsSignalMissing=1;
        signalInfo.UpdatedChecksum='';
        signalInfo.SignalUUID=linkedFileSignals(i).SignalUUID;
        signalInfo.SignalName=linkedFileSignals(i).SignalName;
        variableName=linkedFileSignals(i).SourceVariableName;
        customReader=linkedFileSignals(i).CustomReader;
        if fileStatus=="FILE_EXISTS"&&linkedFileSignals(i).IsDataStale


            parsedFileObject=[];
            if(parsedFileObjsMap.isKey(customReader))
                parsedFileObject=parsedFileObjsMap(customReader);
            else
                parsedFileObject=getParsedFileObject(linkedFile,customReader);


                parsedFileObjsMap(customReader)=parsedFileObject;
            end
            if parsedFileObject.fileStatus=="FILE_PARSABLE"

                loadInfo=locLoadSignalFromFile(variableName,linkedFile,...
                parsedFileObject,childSignalNames,runID,customReader);
                parsedFileObjsMap(customReader)=loadInfo.parsedFileObject;
                if(loadInfo.signalID)

                    signalInfo.SignalID=loadInfo.signalID;
                    signalInfo.IsSignalMissing=0;
                end
            end
            if parsedFileObject.fileStatus=="MISSING_CUSTOM_READER"
                fileStatus='FILE_EXISTS_MISSING_CUSTOM_READER';
            end
        else

            if fileStatus=="FILE_EXISTS"&&~linkedFileSignals(i).IsDataStale
                signalInfo.IsSignalUpdated=0;
                signalInfo.IsSignalMissing=0;
            end
        end
        signalInfo.LinkedFileStatus=fileStatus;
        fileSignalInfo=[fileSignalInfo,signalInfo];%#ok <AGROW>
    end
end


function signalID=addParsedSignalToRun(file,addDataUIObj,variableIndexes,varOutputs,runID,customReader)
    numParsers=size(addDataUIObj.VarParser);
    repo=sdi.Repository(1);
    for i=1:numParsers(2)
        setVariableChecked(addDataUIObj.VarParser{i},0);
    end

    numberofSignalsInFile=size(varOutputs);
    for i=1:numberofSignalsInFile(2)
        addDataUIObj.updateCheckedStateInHierarchicalData(...
        varOutputs(i).RowID,0);
    end
    checkedVariableIndexes=[];
    for i=1:numel(variableIndexes)
        if~varOutputs(variableIndexes(i)).HasChildren



            checkedVariableIndexes=[variableIndexes(i),checkedVariableIndexes];%#ok <AGROW
        end
    end
    addDataUIObj.updateCheckedStateInHierarchicalData(checkedVariableIndexes,1);
    runName=Simulink.sdi.getRun(runID).Name;
    importer=Simulink.sdi.internal.import.FileImporter.getDefault();
    sigIDs=repo.getAllSignalIDs(runID,'all');
    importer.verifyFileAndImport(...
    sdi.Repository(1),...
    file,runName,...
    true,...
    runID,...
    'reader',customReader,...
    'parser',addDataUIObj.VarParser,...
    'OneRun',true);
    newSigIDs=repo.getAllSignalIDs(runID,'all');
    signalID=newSigIDs(numel(sigIDs)+1);
end


function variableIndexes=getVariableIndexInParsedFile(variableName,varOutputs)
    numSignalsInFile=size(varOutputs);
    variableIndexes=[];
    for i=1:numSignalsInFile(2)
        varOutput=varOutputs(i);
        if(varOutput.ParentID==0&&varOutput.IsLoaded==0&&...
            strcmp(string(variableName),string(varOutputs(i).RootSource))~=0)
            variableIndexes=[variableIndexes,varOutputs(i).RowID];%#ok <AGROW>
            break;
        end
    end
end



function signalInfo=locValidateAndLoadWorkspaceVar(linkedWorkSpaceSignal,blkHandle,childSignalNames,runID)
    variableName=linkedWorkSpaceSignal.SourceVariableName;
    signalInfo.SignalID=linkedWorkSpaceSignal.SignalID;
    signalInfo.IsSignalUpdated=1;
    signalInfo.IsSignalMissing=1;
    signalInfo.UpdatedChecksum='';

    if isVariableExistsInWorkspace(variableName,blkHandle)

        varParsers=parseVariable(variableName,blkHandle);
        if isempty(varParsers)

            return;
        end


        signalInfo.IsSignalMissing=0;


        computedChecksum=computeVariableChecksum(variableName,blkHandle);
        if strcmp(computedChecksum,linkedWorkSpaceSignal.SourceChecksum)


            signalInfo.IsSignalUpdated=0;
            return;
        else

            addDataUIObj=Simulink.playback.addDataUI();
            varOutputs=addDataUIObj.getParsedDataFromVarParser(varParsers);
            if(~isempty(childSignalNames))

                selectedRows=getSelectedRows(childSignalNames,varOutputs);
                if(numel(childSignalNames)~=numel(selectedRows))

                    signalInfo.IsSignalMissing=1;
                    return;
                end

                for i=1:numel(varOutputs)
                    if(isempty(find(selectedRows==varOutputs(i).RowID)))
                        addDataUIObj.updateCheckedStateInHierarchicalData(...
                        varOutputs(i).RowID,0);
                    end
                end
                checkedVariableIndexes=[];
                for i=1:numel(selectedRows)
                    if~varOutputs(selectedRows(i)).HasChildren



                        checkedVariableIndexes=[selectedRows(i),checkedVariableIndexes];%#ok <AGROW
                    end
                end
                addDataUIObj.updateCheckedStateInHierarchicalData(checkedVariableIndexes,1);
            end
            signalInfo.UpdatedChecksum=computedChecksum;
            signalInfo.SignalID=updateSignalOnLoadData(addDataUIObj.VarParser,...
            linkedWorkSpaceSignal,runID);
        end
    end
end



function signalID=updateSignalOnLoadData(varParser,~,runID)
    repo=sdi.Repository(1);

    signalID=Simulink.sdi.internal.safeTransaction(...
    @createSignal,varParser,repo,runID);
end

function signalID=createSignal(varParser,repo,runID)
    wksParser=Simulink.sdi.internal.import.WorkspaceParser.getDefault();
    engine=Simulink.sdi.Instance.engine;
    sigIDs=repo.getAllSignalIDs(runID,'all');
    mdlName='';
    overwrittenRunID=0;
    parentRunID=int32.empty;
    addToRun(wksParser,engine,runID,varParser,mdlName,overwrittenRunID,...
    parentRunID,'OneRun',true);
    newSigIDs=repo.getAllSignalIDs(runID,'all');
    signalID=newSigIDs(numel(sigIDs)+1);
end



function exists=isVariableExistsInWorkspace(varName,blkHandle)
    exists=0;
    try
        varInfo=slResolve(char(varName),blkHandle);
        if~isempty(varInfo)
            exists=1;
        end
    catch

    end
end


function ret=parseVariable(varName,blkHandle)
    vars=struct;
    vars.VarName=varName;
    vars.VarValue=slResolve(varName,blkHandle);

    wksParser=Simulink.sdi.internal.import.WorkspaceParser.getDefault();
    ret=parseVariables(wksParser,vars);
end


function varCheksum=computeVariableChecksum(varName,blkHandle)
    var=slResolve(varName,blkHandle);
    varCheksum=Simulink.playback.internal.computeVariableChecksum(var);
end


function signalNames=getChildSignalNames(blkHandle,linkedWorkspaceSignal)
    signalNames=[];
    if(isempty(linkedWorkspaceSignal.ChildSignalUUIDs))
        return;
    end
    for i=1:numel(linkedWorkspaceSignal.ChildSignalUUIDs)
        childSignalMetadata=getSignalMetadataWithUUID(blkHandle,...
        linkedWorkspaceSignal.ChildSignalUUIDs{i});
        if(~isMatrixLeaf(childSignalMetadata)&&...
            ~isComplexLeaf(childSignalMetadata))
            signalNames=[signalNames,string(childSignalMetadata.SignalName)];%#ok <AGROW>
            childSignalNames=getChildSignalNames(blkHandle,childSignalMetadata);
            signalNames=[signalNames,childSignalNames];%#ok <AGROW>
        end
    end
end


function ret=isMatrixLeaf(signalMetadata)
    ret=false;
    numChannels=signalMetadata.NumberOfChannels;
    if(numChannels>1&&...
        isempty(signalMetadata.ChildSignalUUIDs))
        ret=true;
    end
end


function ret=isComplexLeaf(signalMetadata)
    ret=false;
    complexity=signalMetadata.Complexity;
    if(complexity=="complex"&&...
        isempty(signalMetadata.ChildSignalUUIDs))
        ret=true;
    end
end


function signalMetadata=getSignalMetadataWithUUID(blkHandle,signalUUID)
    signals_metadata=get_param(blkHandle,"SignalMetadata");
    numOfSignals=size(signals_metadata);
    for i=1:numOfSignals(2)
        if(signals_metadata(i).SignalUUID==signalUUID)
            signalMetadata=signals_metadata(i);
            break;
        end
    end
end


function selectedRows=getSelectedRows(childSignalNames,varOutputs)
    selectedRows=[];
    for i=1:numel(varOutputs)
        varOutputs(i).IsLoaded=0;
    end
    for i=1:numel(childSignalNames)
        rowID=getRowIDForSignalName(childSignalNames{i},varOutputs);
        if(rowID)
            selectedRows=[selectedRows,rowID];%#ok <AGROW>
            for index=1:numel(varOutputs)
                if(varOutputs(index).RowID==rowID)
                    varOutputs(index).IsLoaded=1;
                end
            end
        end
    end
end


function selectedRows=getSelectedRowsFromFileVariable(childSignalNames,...
    varOutputs,parentvariableIndex)
    childRows=[];
    parentIndexes=[parentvariableIndex];
    for i=1:numel(varOutputs)
        childRow=varOutputs(i);
        if(find(parentIndexes==childRow.ParentID))
            childRows=[childRows,childRow];%#ok <AGROW>
            if(childRow.HasChildren)


                parentIndexes=[parentIndexes,childRow.RowID];%#ok <AGROW>
            end
        end
    end
    selectedRows=getSelectedRows(childSignalNames,childRows);
end


function rowID=getRowIDForSignalName(childSignalName,varOutputs)
    rowID=0;
    for i=1:numel(varOutputs)
        varSignalName=locRepInvalidChars(varOutputs(i).Name);
        if(strcmp(childSignalName,varSignalName)&&...
            varOutputs(i).IsLoaded==0)
            rowID=varOutputs(i).RowID;
            return;
        end
    end
end


function isAccesible=isFileAccesible(linkedFilePath)
    isAccesible=0;
    if(exist(linkedFilePath,'file'))
        isAccesible=1;
    end
end


function ret=locRepInvalidChars(str)
    ret=regexprep(str,'\n',' ');
end

function parsedFileObject=getParsedFileObject(fileName,customReader)
    parsedFileObject=[];
    parsedFileObject.fileObj=Simulink.playback.addDataUI();
    try
        customReaderStatus=validateAndRegisterParser(fileName,customReader);
        if customReaderStatus=="MISSING_CUSTOM_READER"
            parsedFileObject.fileStatus=customReaderStatus;
            return;
        end
        parsedFileObject.fileVariables=parsedFileObject.fileObj.getParsedDataFromFile(fileName,customReader);
        numSignasInFile=size(parsedFileObject.fileVariables);
        for i=1:numSignasInFile(2)
            parsedFileObject.fileVariables(i).IsLoaded=0;
        end
        parsedFileObject.fileStatus='FILE_PARSABLE';
    catch me

        parsedFileObject.fileStatus=me.identifier;
    end
end


function customReaderStatus=validateAndRegisterParser(fileName,customReader)
    customReaderStatus='';
    if customReader=="built-in"

        return;
    end
    try
        reader=feval(customReader);
        [~,~,ext]=fileparts(fileName);
        reader.registerFileReader(ext);
    catch

        customReaderStatus='MISSING_CUSTOM_READER';
    end
end


function signalLoadInfo=locLoadSignalFromFile(variableName,linkedFile,parsedFileObject,childSignalNames,runID,customReader)
    signalLoadInfo.signalID=0;
    signalLoadInfo.loadStatus='SIGNAL_MISSING';
    variableRowIndex=getVariableIndexInParsedFile(variableName,parsedFileObject.fileVariables);
    numSignasInFile=size(parsedFileObject.fileVariables);
    if~isempty(variableRowIndex)
        for index=1:numSignasInFile(2)
            if parsedFileObject.fileVariables(index).RowID==variableRowIndex
                parsedFileObject.fileVariables(index).IsLoaded=1;
            end
        end
    end
    signalLoadInfo.parsedFileObject=parsedFileObject;
    if(variableRowIndex)

        if(~isempty(childSignalNames))

            variableRowIndex=getSelectedRowsFromFileVariable(...
            childSignalNames,parsedFileObject.fileVariables,variableRowIndex);

            if(numel(childSignalNames)~=numel(variableRowIndex))

                return;
            end
        end
        try
            signalLoadInfo.signalID=addParsedSignalToRun(linkedFile,parsedFileObject.fileObj,...
            variableRowIndex,parsedFileObject.fileVariables,runID,customReader);
            signalLoadInfo.loadStatus='SIGNAL_LOADED';
        catch me
            signalLoadInfo.loadStatus=me.identifier;
        end
    end
end