function runIDs=addToRunImpl(this,repo,runID,varParsers,onlyOneRun,mdlName,overwrittenRunID,addToparentID)
    fw=Simulink.sdi.internal.AppFramework.getSetFramework();
    fw.isImportCancelled(0);
    runIDs=int32(runID);
    existingSigIDs=repo.getAllSignalIDs(runIDs,'all');


    this.EnableLazyImport=true;


    progTracker=fw.createProgressTrackerForImport(varParsers,this.ProgressTracker);



    streamedRunID=0;
    streamedWksVars={};
    if~isempty(mdlName)
        streamedRunID=repo.getCurrentStreamingRunID(mdlName);
        streamedWksVars=repo.getBlockStreamedWksVarsForRun(streamedRunID);
    end


    if nargin<8
        overwrittenRunID=0;
    end



    if nargin<9
        addToparentID=int32.empty;
    end



    numParsers=length(varParsers);
    if numParsers==1&&getRepresentsRun(varParsers{1})
        onlyOneRun=true;
        setRunMetaData(varParsers{1},repo,runID);
    end


    leafSigs=int32.empty;
    runTimeRange=struct('Start',[],'Stop',[]);
    parentSigID=addToparentID;
    try
        for parserIdx=1:numParsers
            if~onlyOneRun&&getRepresentsRun(varParsers{parserIdx})
                [runIDs,leafIDs]=locCreateRun(this,repo,varParsers{parserIdx},runIDs,progTracker,streamedRunID,streamedWksVars);
            elseif isHierarchical(varParsers{parserIdx})
                [~,runIDs,leafIDs,runTimeRange]=locCreateHierarchicalSignal(...
                this,repo,runID,parentSigID,varParsers{parserIdx},onlyOneRun,runIDs,progTracker,streamedRunID,streamedWksVars,runTimeRange);
            else
                [~,leafIDs,runTimeRange]=locCreateLeafSignal(this,repo,runID,parentSigID,varParsers{parserIdx},progTracker,runTimeRange);
            end
            leafSigs=[leafSigs,leafIDs];%#ok<AGROW>
        end
    catch


        newSignalIDs=repo.getAllSignalIDs(runIDs,'all');
        for i=length(existingSigIDs)+1:length(newSignalIDs)
            repo.remove(newSignalIDs(i))
        end
    end


    if~isempty(runTimeRange.Start)&&~isempty(runTimeRange.Stop)
        repo.setRunStartAndStopTime(runID,runTimeRange.Start,runTimeRange.Stop);
    end
    if~isempty(mdlName)
        repo.setRunModel(runID,mdlName);
        interface=Simulink.sdi.internal.Framework.getFramework();
        simMode=getParam(interface,mdlName,'simulationmode');
        repo.setRunSimMode(runID,simMode);
    end


    if overwrittenRunID
        locUpdateLeafSignalsForOverwrite(leafSigs,overwrittenRunID,repo);
    end



    closeOpenedModels(this);
    runIDs=reshape(runIDs,[length(runIDs),1]);
end


function[runIDs,leafSigs]=locCreateRun(this,repo,varParser,runIDs,progTracker,streamedRunID,streamedWksVars)
    leafSigs=int32.empty;
    if~isVariableChecked(varParser)
        return
    end


    runID=repo.createEmptyRun(repo.getRunNameTemplate(),0);
    setRunMetaData(varParser,repo,runID);


    runTimeRange=struct('Start',[],'Stop',[]);
    [~,runIDs,leafSigs]=locCreateHierarchicalSignal(...
    this,repo,runID,int32.empty,varParser,false,runIDs,progTracker,streamedRunID,streamedWksVars,runTimeRange);


    if isempty(leafSigs)
        repo.removeRun(runID);
    else
        runIDs(end+1)=runID;
    end
end


function[sigID,runIDs,leafSigs,runTimeRange]=locCreateHierarchicalSignal(...
    this,repo,runID,parentSigID,varParser,onlyOneRun,runIDs,progTracker,streamedRunID,streamedWksVars,runTimeRange)

    leafSigs=int32.empty;
    sigID=int32.empty;
    if~isVariableChecked(varParser)
        return
    end




    if locSignalIsStreamedAndLogged(varParser,streamedRunID,streamedWksVars,repo)
        return
    end


    sigID=parentSigID;
    if~isVirtualNode(varParser)
        sigID=locCreateLeafSignal(this,repo,runID,parentSigID,varParser,progTracker);
        forEachDims=getForEachParentDims(varParser);
        if~isempty(forEachDims)
            setSignalIsForEachParent(repo,sigID,uint64(forEachDims));
        end
    end


    try
        childParsers=getChildren(varParser);
        for idx=1:length(childParsers)
            if~onlyOneRun&&getRepresentsRun(childParsers{idx})
                [runIDs,leafIDs]=locCreateRun(this,repo,childParsers{idx},runIDs,progTracker,streamedRunID,streamedWksVars);
            elseif isHierarchical(childParsers{idx})
                [~,runIDs,leafIDs,runTimeRange]=locCreateHierarchicalSignal(...
                this,repo,runID,sigID,childParsers{idx},onlyOneRun,runIDs,progTracker,streamedRunID,streamedWksVars,runTimeRange);
            else
                [~,leafIDs,runTimeRange]=locCreateLeafSignal(this,repo,runID,sigID,childParsers{idx},progTracker,runTimeRange);
            end
            leafSigs=[leafSigs,leafIDs];%#ok<AGROW>
        end
    catch me %#ok<NASGU>

    end


    if isempty(leafSigs)&&~isVirtualNode(varParser)
        repo.remove(sigID);
        sigID=int32.empty;
    end
end


function[sigID,leafSigs,runTimeRange]=locCreateLeafSignal(this,repo,runID,parentSigID,varParser,progTracker,runTimeRange)
    if nargin<7
        runTimeRange.Start=int32.empty;
        runTimeRange.Stop=int32.empty;
    end
    leafSigs=int32.empty;
    sigID=int32.empty;
    if~isVariableChecked(varParser)
        return
    end


    sampleDims=int32(getSampleDims(varParser));
    timeDim=int32(getTimeDim(varParser));
    dataVals=getTimeAndDataForSignalConstruction(varParser);
    hasData=~isempty(dataVals.Data);
    isEmptySignal=false;
    if~hasData&&~isHierarchical(varParser)

        dataVals=[];
        isEmptySignal=true;
    elseif~hasData

        dataVals=[];
    else
        totalChannels=prod(sampleDims);


        if~useLazyConstruction(varParser)
            if isempty(runTimeRange.Start)||dataVals.Time(1)<runTimeRange.Start
                runTimeRange.Start=dataVals.Time(1);
            end
            if isempty(runTimeRange.Stop)||dataVals.Time(end)>runTimeRange.Stop
                runTimeRange.Stop=dataVals.Time(end);
            end
        end
    end


    bpath=locRepInvalidChars(getBlockSource(varParser));
    signalName=locRepInvalidChars(getSignalLabel(varParser));
    if isempty(bpath)&&~isempty(varParser.VariableBlockPath)
        bpath=varParser.VariableBlockPath;
        if~isempty(varParser.VariableSignalName)||...
            contains(signalName,'.find(''')
            signalName=varParser.VariableSignalName;
        end
    end
    if~isempty(varParser.ForEachIter)
        dimsStr=sprintf('%d,',varParser.ForEachIter);
        signalName=[signalName,'(',dimsStr(1:end-1),')'];
    end


    if hasData
        channelIdx=int32(1);
    else
        channelIdx=int32.empty;
    end


    bVarDims=hasData&&iscell(dataVals.Data);
    if bVarDims
        sampleDims=size(dataVals.Data{1});
        numPts=numel(dataVals.Data);
        for idx=1:numPts
            sampleDims=max(sampleDims,size(dataVals.Data{idx}));
        end
        sampleDims=int32(sampleDims);
    end


    dataSourceStr=getDataSource(varParser);
    unitStr=getUnit(varParser);
    sigID=repo.add(...
    repo,...
    runID,...
    getRootSource(varParser),...
    getTimeSource(varParser),...
    dataSourceStr,...
    dataVals,...
    bpath,...
    getModelSource(varParser),...
    signalName,...
    timeDim,...
    sampleDims,...
    int32(getPortIndex(varParser)),...
    channelIdx,...
    getSID(varParser),...
    getMetaData(varParser),...
    int32(parentSigID),...
    getRootSource(varParser),...
    getInterpolation(varParser),...
    unitStr);


    fullPath=getFullBlockPath(varParser);
    if fullPath.getLength()>1
        repo.setSignalBlockSource(sigID,fullPath.convertToCell());
    end


    tmMode=getTimeMetadataMode(varParser);
    tmNumPts=0;
    if~isempty(tmMode)
        repo.setSignalTmMode(sigID,tmMode);
        if~isempty(dataVals)
            tmNumPts=length(dataVals.Time);
            repo.setSignalTmNumPoints(sigID,tmNumPts);
        end
    end


    hierRef=getHierarchyReference(varParser);
    if~isempty(hierRef)
        repo.setSignalHierarchyReference(sigID,hierRef);
    end
    leafPathStr=locRepInvalidChars(varParser.LeafBusPath);
    if~isempty(leafPathStr)
        repo.setLeafBusSignal(sigID,leafPathStr);
    end
    if hasData
        if~isempty(progTracker)
            incrementValue(progTracker);
        end
        if Simulink.sdi.internal.AppFramework.getSetFramework().isImportCancelled()
            wksParser=Simulink.sdi.internal.import.WorkspaceParser.getDefault();
            wksParser.IsImportCancelled=true;

            msgID='SDIImport:Cancelled';
            msg='SDI import is cancelled';
            impEx=MException(msgID,msg);
            throw(impEx);
        end
    end
    stStr=getSampleTimeString(varParser);
    if~isempty(stStr)
        repo.setSignalSampleTimeLabel(sigID,stStr);
    end

    dtStr=getDomainType(varParser);
    if~isempty(dtStr)
        repo.setSignalDomainType(sigID,dtStr);
    end
    if isEventBasedSignal(varParser)
        repo.setSignalIsEventBased(sigID,true);
    end
    if~isempty(varParser.ForEachIter)
        repo.setSignalForEachIter(sigID,uint64(varParser.ForEachIter));
    end
    [logName,sigName,propName]=getCustomExportNames(varParser);
    if~isempty(logName)||~isempty(sigName)||~isempty(propName)
        repo.setSignalExportNames(sigID,logName,sigName,propName);
    end
    descStr=getDescription(varParser);
    if~isempty(descStr)
        repo.setSignalDescription(sigID,descStr);
    end

    [smType,smWriters]=getSharedMemoryInfo(varParser);
    if smType






        bIsHidden=isempty(bpath);
        repo.setSignalSharedMemoryInfo(sigID,smType,smWriters,bIsHidden);
    end


    if hasData&&~useLazyConstruction(varParser)

        keepDimensions=true;
        firstLeafID=locGetFirstLeafSignal(repo,sigID);



        bIsFixedMatrix=totalChannels>1&&~bVarDims;
        if bIsFixedMatrix&&~isempty(timeDim)&&timeDim==1&&numel(sampleDims)<2
            dataVals.Data=dataVals.Data.';
        end


        repo.setSignalDataValues(firstLeafID,dataVals,keepDimensions);



        if firstLeafID~=sigID
            leafSigs=repo.getSignalChildren(sigID);
            info=repo.getSignalComplexityAndLeafPath(sigID);
            locSetChannelProperties(repo,leafSigs,dataSourceStr,sampleDims,...
            tmMode,tmNumPts,unitStr,dtStr,leafPathStr,hierRef,bIsFixedMatrix,info.IsComplex);
        else
            leafSigs=firstLeafID;
        end
    elseif hasData

        repo.setSignalLazyImport(sigID);
        this.LazyImportParsers.insert(sigID,varParser);
        this.LazyImportRunIDs.insert(runID,true);


        if isempty(this.PreDeleteListener)
            fw=Simulink.sdi.internal.AppFramework.getSetFramework();
            this.PreDeleteListener=fw.createPreRunDeleteListener(...
            @(x,y)preRepositoryDeleteCallback(this,x,y));
        end

        leafSigs=sigID;
    elseif isEmptySignal
        repo.setSignalEmpty(sigID);
        leafSigs=sigID;
    end


    tmd=getTemporalMetaData(varParser);
    if~isempty(tmd)
        repo.setSignalTemporalMetaData(sigID,tmd);
    end













    if isTopLevelDatasetElement(varParser)
        repo.setSignalIsTopLevelElement(sigID);
    end


    setSignalCustomMetaData(varParser,sigID);
end


function locSetChannelProperties(repo,childIDs,dataSourceStr,sampleDims,...
    tmMode,tmNumPts,unitStr,dtStr,leafPathStr,hierRef,bIsFixedMatrix,bComplex)


    numLeaves=numel(childIDs);
    for idx=1:numLeaves
        if bIsFixedMatrix&&bComplex
            curIDs=[childIDs(idx),repo.getSignalChildren(childIDs(idx))];
        else
            curIDs=childIDs(idx);
        end
        for idx2=1:numel(curIDs)
            curID=curIDs(idx2);
            if bIsFixedMatrix
                idxStr=locGetChannelIdxStr(sampleDims,idx);
                repo.setSignalDataSource(curID,[dataSourceStr,idxStr]);
            else
                repo.setSignalDataSource(curID,dataSourceStr);
            end
            if~isempty(tmMode)
                repo.setSignalTmMode(curID,tmMode);
                repo.setSignalTmNumPoints(curID,tmNumPts);
            end
            if~isempty(unitStr)
                repo.setUnit(curID,unitStr);
            end
            if~isempty(dtStr)
                repo.setSignalDomainType(curID,dtStr);
            end
            if~isempty(leafPathStr)
                repo.setLeafBusSignal(curID,leafPathStr);
            end
            if~isempty(hierRef)
                repo.setSignalHierarchyReference(curID,hierRef);
            end
        end
    end
end


function idxStr=locGetChannelIdxStr(sampleDims,channelIdx)
    dimIdx=cell(size(sampleDims));
    [dimIdx{:}]=ind2sub(sampleDims,channelIdx);
    channel=cell2mat(dimIdx);
    numDims=length(channel);
    if numDims==1
        idxStr=sprintf('(:,%d)',channel);
    else
        idxStr=sprintf('%d,',channel);
        idxStr=sprintf('(%s:)',idxStr);
    end
end


function ret=locRepInvalidChars(str)
    ret=regexprep(str,'\n',' ');
end


function ret=locSignalIsStreamedAndLogged(varParser,streamedRunID,streamedWksVars,repo)
    ret=false;


    if~streamedRunID
        return
    end

    if isa(varParser.VariableValue,'Simulink.SimulationData.Signal')


        bpath=varParser.VariableValue.BlockPath;
        portIdx=varParser.VariableValue.PortIndex;
        ret=repo.isSignalStreamed(streamedRunID,bpath.convertToCell(),portIdx);
    elseif isa(varParser.VariableValue,'Stateflow.SimulationData.State')


        ret=true;
    elseif isa(varParser.VariableValue,'Stateflow.SimulationData.Data')


        ret=true;
    elseif isa(varParser.VariableValue,'coder.profile.ExecutionTime')

        ret=true;
    elseif isa(varParser.VariableValue,'sltest.Assessment')

        ret=true;
    elseif isa(varParser.VariableValue,'simscape.logging.Node')

        ret=locRunContainsSimscapeData(streamedRunID);
    elseif isa(varParser.VariableValue,'Simulink.SimulationData.State')

        ret=true;
    elseif isa(varParser.VariableValue,'Simulink.SimulationData.DataStoreMemory')

        ret=true;
    elseif isa(varParser.Parent,'Simulink.sdi.internal.import.SimulationOutputParser')



        if isprop(varParser,'ElementName')
            ret=any(strcmp(streamedWksVars,varParser.ElementName));
        end
    end
end


function ret=locRunContainsSimscapeData(runID)







    dsr=Simulink.sdi.DatasetRef(runID,"sscape");
    ret=dsr.numElements>0;
end


function locUpdateLeafSignalsForOverwrite(leafSigIDs,overwrittenRunID,repo)
    numSigs=length(leafSigIDs);
    for idx=1:numSigs
        newSigID=leafSigIDs(idx);
        oldSigID=repo.findAlignedSignalFromRun(newSigID,overwrittenRunID);
        if oldSigID
            clr=repo.getSignalLineColor(oldSigID);
            lineStyle=repo.getSignalLineDashed(oldSigID);
            lineWidth=repo.getSignalLineWidth(oldSigID);
            plts=repo.getSignalChecked(oldSigID);

            repo.setSignalLineColor(newSigID,clr);
            repo.setSignalLineDashed(newSigID,lineStyle);
            repo.setSignalLineWidth(newSigID,lineWidth);

            if~isempty(plts)
                repo.setSignalChecked(newSigID,plts);
            end
        end
    end
end


function sigID=locGetFirstLeafSignal(repo,sigID)
    childIDs=repo.getSignalChildren(sigID);
    if~isempty(childIDs)
        sigID=locGetFirstLeafSignal(repo,childIDs(1));
    end
end
