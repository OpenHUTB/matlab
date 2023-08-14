function saveRuns(filename,runIDs)




    repository=sdi.Repository(0);


    RunDescriptor.SimulinkVersion=ver('simulink');


    RunDescriptor.NumSignals=0;


    firstSignal=true;

    fileSerializer=stm.internal.MATFileSerializer;
    fileSerializer.setPath(filename,true);

    RunDescriptor.Runs=[];
    RunDescriptor.Signals=[];
    for runIndex=1:length(runIDs)
        runID=runIDs(runIndex);

        if repository.isValidRunID(runID)
            [Runs,Signals]=saveRun(repository,filename,runID,fileSerializer);
            RunDescriptor.Runs=[RunDescriptor.Runs,Runs];
            RunDescriptor.Signals=[RunDescriptor.Signals,Signals];
            RunDescriptor.NumSignals=RunDescriptor.NumSignals+length(Signals);
            firstSignal=false;
        end
    end
    if~firstSignal
        fileSerializer.putVariable('RunDescriptor',RunDescriptor);
    end
end

function[Runs,Signals]=saveRun(repository,filename,runID,fileSerializer)

    runName=repository.getRunName(runID);


    sigIDList=repository.getAllSignalIDs(runID,'leaf');


    Runs.RunID=runID;
    Runs.RunName=runName;
    Runs.SignalCount=length(sigIDList);
    writtenSigMap=Simulink.sdi.Map(int32(0),char(' '));


    runInd=repository.getRunNumber(runID);
    Runs.RunIndex=runInd;
    Signals=[];
    for signalIndex=1:Runs.SignalCount
        [signal,writtenSigMap]=saveSignal(repository,...
        runID,...
        sigIDList(signalIndex),...
        filename,...
        writtenSigMap,...
        fileSerializer);

        Signals=[Signals;signal];
    end


    runData=repository.getRunData(runID);
    runVarName=['r',sprintf('%d',runID)];

    eval([runVarName,'= runData;']);
    fileSerializer.putVariable(runVarName,runData);


    runMetaData.dateCreated=repository.getDateCreated(runID);
    runMetaData.name=repository.getRunName(runID);
    runMetaData.tag=repository.getRunTag(runID);
    runMetaData.description=repository.getRunDescription(runID);
    runMetaData.version=repository.getVersion(runID);
    runMetaData.simMode=repository.getRunSimMode(runID);
    runMetaData.model=repository.getRunModel(runID);
    runMetaData.topModel=stm.internal.getRunModel(runID,int32(0));
    runMetaData.harnessField=stm.internal.getRunModel(runID,int32(1));
    Runs.Comparison=[];

    rVarName=['runMetaData',sprintf('%d',runID)];
    eval([rVarName,'= runMetaData;']);
    fileSerializer.putVariable(rVarName,runMetaData);
end

function[signal,writtenSigMap]=saveSignal(repository,runID,signalID,filename,writtenSigMap,fileSerializer)

    signal=getSignal(repository,runID,signalID);


    signal.varName=['s',sprintf('%d',signalID)];


    parent=signal.ParentID;

    if(parent~=0)
        signal.parent=['s',sprintf('%d',parent)];
    else
        signal.parent=[];
    end




    try
        signalToCopy.TimeValues=signal.DataValues.Time;
        signalToCopy.DataValues=signal.DataValues.Data;
    catch
        signalToCopy.TimeValues=[];
        signalToCopy.DataValues=[];
    end


    signal=rmfield(signal,'DataValues');


    eval([signal.varName,'=signalToCopy;']);

    fileSerializer.putVariable(signal.varName,signalToCopy);
    writtenSigMap.insert(signalID,'');


    try
        pID=signal.ParentID;
        if pID~=0&&~isempty(pID)
            parentNotAlreadyWritten=~writtenSigMap.isKey(pID);
        else
            parentNotAlreadyWritten=true;
        end
    catch
        parentNotAlreadyWritten=true;
    end
    if(parent~=0&&parentNotAlreadyWritten)
        [newSig,writtenSigMap]=saveSignal(repository,runID,parent,filename,writtenSigMap,fileSerializer);
        signal=[signal;newSig];
    end
end

function out=getSignalHelper(repository,runID,sigID)
    out.DataID=sigID;
    out.RunID=runID;
    engine=Simulink.sdi.Instance.engine;
    out.SourceType=repository.getSignalSourceType(sigID);
    out.RootSource=repository.getSignalRootSource(sigID);
    out.TimeSource=repository.getSignalTimeSource(sigID);
    out.DataSource=repository.getSignalDataSource(sigID);
    blockSource=engine.getSignalBlockSource(sigID,true);
    out.BlockSource=blockSource{end};
    out.ModelSource=repository.getSignalModelSource(sigID);
    out.SignalLabel=repository.getSignalLabel(sigID);
    out.TimeDim=repository.getSignalTimeDim(sigID);
    out.SampleDims=repository.getSignalSampleDims(sigID);
    out.PortIndex=repository.getSignalPortIndex(sigID);
    out.Channel=repository.getSignalChannel(sigID);
    out.Units=repository.getUnit(sigID);
    out.SID=repository.getSignalSID(sigID);
    out.HierarchyReference=repository.getSignalHierarchyReference(sigID);
    out.LineColor=repository.getSignalLineColor(sigID);
    out.LineDashed=repository.getSignalLineDashed(sigID);
    out.ParentID=repository.getSignalParent(sigID);
    out.rootDataSrc=repository.getSignalRootSource(sigID);
    out.DataValues=repository.getSignalDataValues(sigID);
    out.absolute=repository.getSignalAbsTol(sigID);
    out.relative=repository.getSignalRelTol(sigID);
    out.forwardTimeTol=repository.getSignalForwardTimeTol(sigID);
    out.backwardTimeTol=repository.getSignalBackwardTimeTol(sigID);
    out.SyncMethod=repository.getSignalSyncMethod(sigID);
    out.InterpMethod=repository.getSignalInterpMethod(sigID);
    out.checked=repository.getSignalChecked(sigID);
    out.marker=repository.getSignalMarker(sigID);
    out.isWithinTol=repository.getIsWithinTol(sigID);
    out.AlignedBy=repository.getSignalAlignedBy(sigID);
    out.DataType=repository.getSignalDataTypeLabel(sigID);
    out.MaxDiff=repository.getSignalMetric(sigID,'MaxDifference');
    out.SampleTimeString=repository.getSignalSampleTimeLabel(sigID);
    out.IsEventBased=repository.getSignalIsEventBased(sigID);


    out.IsAssessment=repository.getSignalMetaData(sigID,'IsAssessment');
    out.AssessmentResult=repository.getSignalMetaData(sigID,'AssessmentResult');
    out.Outcome=repository.getSignalMetaData(sigID,'Outcome');
    out.SSIDNumber=engine.getMetaDataV2(sigID,'SSIDNumber');
    out.SubPath=engine.getMetaDataV2(sigID,'SubPath');
end

function out=getSignal(repository,runID,sigID)
    out=repository.safeTransaction(...
    @getSignalHelper,repository,runID,sigID);
end
