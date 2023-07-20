function runIDMap=loadRuns(filename)



    mlock;
    persistent isSDILoaded;

    if isempty(isSDILoaded)
        isSDILoaded=1;
        Simulink.sdi.internal.startConnector();
    end


    repository=sdi.Repository(0);
    fileSerializer=stm.internal.MATFileSerializer;

    fileSerializer.setPath(filename,false);


    descriptor=fileSerializer.loadVariable('RunDescriptor');
    runIDMap=containers.Map('KeyType','int32','ValueType','int32');


    if isempty(descriptor)
        return;
    end

    runIDMap=repository.safeTransaction(@loadSignalsInTransaction,repository,filename,descriptor,runIDMap,fileSerializer);
end




function result=resolveRuns(descriptor,result)

    runCount=length(descriptor.Runs);
    runStruct=descriptor.Runs;
    comparisons=cell(sum(arrayfun(@(x)~isempty(x.Comparison),runStruct)),4);
    for i=1:runCount

        fileRunID=runStruct(i).RunID;
        fileRunName=runStruct(i).RunName;


        if~isempty(runStruct(i).Comparison)

            comparisons(i,:)={fileRunID,fileRunName,runStruct(i).Comparison(1),runStruct(i).Comparison(2)};
        else
            newRunID=stm.internal.createRun(fileRunName);

            result(fileRunID)=newRunID;
        end

    end
    for i=1:size(comparisons,1)

        newBaselineId=result(comparisons{i,4});
        newCompareToId=result(comparisons{i,3});
        newRunID=stm.internal.createRun(comparisons{i,2},newBaselineId,newCompareToId);
        result(comparisons{i,1})=newRunID;
    end

end

function signal=getSignalData(varName,descriptor)

    persistent sigmap
    if nargin==2
        sigmap=containers.Map('keytype','char','valuetype','any');
        for ss=1:length(descriptor.Signals)
            sigmap(descriptor.Signals(ss).varName)=descriptor.Signals(ss);
        end
    end
    if isempty(varName)
        signal=struct();
    else
        signal=sigmap(varName);
    end
end

function[newSignalID,signalIDMap]=loadSignal(repository,filename,newRunID,signal,signalIDMap,fileSerializer)




    dataRoot=fileSerializer.loadVariable(signal.varName);


    if~isempty(dataRoot.TimeValues)&&~isempty(dataRoot.DataValues)
        lenData=length(dataRoot.DataValues);
        timeAndData.Data=reshape(dataRoot.DataValues,lenData,1);
        timeAndData.Time=reshape(dataRoot.TimeValues,lenData,1);
    else
        timeAndData=[];
    end

    parent=signal.parent;

    if isempty(parent)
        parent=0;
    else
        if signalIDMap.isKey(parent)
            parent=signalIDMap.getDataByKey(parent);
        else
            try

                parentSignal=getSignalData(parent);
                [parentid,signalIDMap]=loadSignal(repository,filename,newRunID,parentSignal,signalIDMap,fileSerializer);
                signalIDMap.insert(parent,parentid);
                parent=parentid;
            catch

                parent=0;
            end
        end
    end

    if isempty(signal.SignalLabel)
        signal.SignalLabel=' ';
    end


    if~isfield(signal,'Units')
        signal.Units='';
    end
    if~isfield(signal,'InterpMethod')
        signal.InterpMethod='linear';
    end

    newSignalID=repository.add(...
    'dummy',...
    newRunID,...
    signal.RootSource,...
    signal.TimeSource,...
    signal.DataSource,...
    timeAndData,...
    signal.BlockSource,...
    signal.ModelSource,...
    signal.SignalLabel,...
    signal.TimeDim,...
    int32(1),...
    signal.PortIndex,...
    signal.Channel,...
    signal.SID,...
    [],...
    parent,...
    signal.rootDataSrc,...
    signal.InterpMethod,...
    signal.Units);

    if~isempty(timeAndData)
        repository.setSignalDataValues(newSignalID,timeAndData);


    else
        if parent~=0
            repository.setParent(newSignalID,parent);
        end

        stm.internal.setSignalPropertyInt32(newSignalID,'IsWithinTol',int32(signal.isWithinTol));
    end
    repository.setSignalLineDashed(newSignalID,signal.LineDashed);
    if isfield(signal,'marker')
        repository.setSignalMarker(newSignalID,signal.marker);
    end
    if isfield(signal,'SourceType')
        repository.setSignalSourceType(newSignalID,signal.SourceType);
    end
    if isfield(signal,'AlignedBy')
        stm.internal.setSignalPropertyString(newSignalID,'AlignedBy',signal.AlignedBy);
    end
    if isfield(signal,'relative')
        repository.setSignalRelTol(newSignalID,signal.relative);
    end

    if isfield(signal,'absolute')
        repository.setSignalAbsTol(newSignalID,signal.absolute);
    end

    if isfield(signal,'forwardTimeTol')
        repository.setSignalForwardTimeTol(newSignalID,signal.forwardTimeTol);
    end

    if isfield(signal,'backwardTimeTol')
        repository.setSignalBackwardTimeTol(newSignalID,signal.backwardTimeTol);
    end

    if isfield(signal,'SyncMethod')
        repository.setSignalSyncMethod(newSignalID,signal.SyncMethod);
    end

    if isfield(signal,'InterpMethod')
        repository.setSignalInterpMethod(newSignalID,signal.InterpMethod);
    end

    if isfield(signal,'isWithinTol')
        stm.internal.setSignalPropertyInt32(newSignalID,'IsWithinTol',int32(signal.isWithinTol));
    end

    if isfield(signal,'MaxDiff')
        repository.setSignalMetric(newSignalID,'MaxDifference',signal.MaxDiff);
    end

    if isfield(signal,'SampleTimeString')
        repository.setSignalSampleTimeLabel(newSignalID,signal.SampleTimeString);
    end

    if isfield(signal,'IsEventBased')
        repository.setSignalIsEventBased(newSignalID,signal.IsEventBased);
    end


    if isfield(signal,'IsAssessment')&&~isempty(signal.IsAssessment)
        repository.setSignalMetaData(newSignalID,'IsAssessment',int32(signal.IsAssessment));
    end

    if isfield(signal,'AssessmentResult')&&~isempty(signal.AssessmentResult)
        repository.setSignalMetaData(newSignalID,'AssessmentResult',int32(signal.AssessmentResult));
    end

    if isfield(signal,'Outcome')
        repository.setSignalMetaData(newSignalID,'Outcome',int32(signal.Outcome));
    end
    sdiEngine=Simulink.sdi.Instance.engine;
    if isfield(signal,'SSIDNumber')&&~isempty(signal.SSIDNumber)
        sdiEngine.setMetaDataV2(newSignalID,'SSIDNumber',signal.SSIDNumber);
    end

    if isfield(signal,'SubPath')&&~isempty(signal.SubPath)
        sdiEngine.setMetaDataV2(newSignalID,'SubPath',signal.SubPath);
    end

    repository.setSignalLineColor(newSignalID,[signal.LineColor(1),...
    signal.LineColor(2),...
    signal.LineColor(3)]);
    signalIDMap.insert(signal.varName,newSignalID);
end

function runIDMap=loadSignalsInTransaction(repository,filename,descriptor,runIDMap,fileSerializer)
    runIDMap=resolveRuns(descriptor,runIDMap);
    signalIDMap=Simulink.sdi.Map(char('a'),int32(0));

    getSignalData('',descriptor);

    for i=1:descriptor.NumSignals

        signal=descriptor.Signals(i);
        if~signalIDMap.isKey(signal.varName)
            runID=runIDMap(signal.RunID);
            [newSignalID,signalIDMap]=loadSignal(repository,filename,runID,signal,signalIDMap,fileSerializer);
            runIDMap(signal.DataID)=newSignalID;
        end
    end



    numRuns=runIDMap.Count;

    oldIDs=runIDMap.keys;
    newIDs=runIDMap.values;
    engine=Simulink.sdi.Instance.engine;
    for i=1:numRuns
        fileRunID=oldIDs{i};
        freshRunID=newIDs{i};

        rVarName=['runMetaData',sprintf('%d',fileRunID)];
        metadata=fileSerializer.loadVariable(rVarName);

        if~isempty(metadata)
            repository.setRunTag(freshRunID,metadata.tag);
            repository.setDateCreated(freshRunID,metadata.dateCreated);
            repository.setRunSimMode(freshRunID,metadata.simMode);
            repository.setRunModel(freshRunID,metadata.model);
            repository.setRunDescription(freshRunID,metadata.description);

            if(isfield(metadata,'topModel')&&isfield(metadata,'harnessField'))
                engine.setRunMetaDataV2(freshRunID,'TopModelName',metadata.topModel);
                engine.setRunMetaDataV2(freshRunID,'HarnessName',metadata.harnessField);
            end

        end
    end
end


