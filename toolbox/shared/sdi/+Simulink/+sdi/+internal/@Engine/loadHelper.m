function validSDIMatFile=loadHelper(this,filename)




    validSDIMatFile=Simulink.sdi.internal.Util.isValidSDIMatFile(filename);
    signalIDMap=Simulink.sdi.Map(char(' '),int32(0));


    uniqueRunIDs=[];
    if validSDIMatFile

        descriptor=load(filename,'SDIDescriptor');
        descriptor=descriptor.SDIDescriptor;




        runIDMap=resolveRuns(this,descriptor);

        runIDs=zeros(descriptor.NumSignals,1);


        for idx=1:descriptor.NumSignals

            signal=descriptor.Signals(idx);


            newRunID=runIDMap.getDataByKey(signal.RunID);
            runIDs(idx)=newRunID;


            dataRoot=load(filename,signal.varName);%#ok<NASGU>
            dataRoot=eval(['dataRoot.',signal.varName]);


            if~isempty(dataRoot.TimeValues)&&~isempty(dataRoot.DataValues)
                dataTimeseries=timeseries(dataRoot.DataValues,dataRoot.TimeValues);
            else
                continue
            end


            parent=signal.parent;
            if~isempty(parent)&&signalIDMap.isKey(parent)
                parent=signalIDMap.getDataByKey(parent);
            else
                parent=0;
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


            totalChannels=prod(signal.SampleDims);
            curChannel=prod(signal.Channel);
            if totalChannels>1
                signal.Values=dataTimeseries;
                if curChannel==1
                    pendingChannels=signal;
                else
                    pendingChannels(end+1)=signal;%#ok<AGROW>
                end
                if curChannel<totalChannels
                    continue
                end
                timeAndData=locConcatTimeseries(pendingChannels);
            else
                pendingChannels=signal;
                lenData=length(dataTimeseries.Data);
                timeAndData.Data=reshape(dataTimeseries.Data,lenData,1);
                timeAndData.Time=reshape(dataTimeseries.Time,lenData,1);
            end


            channelIdx=int32(1);


            newSignalID=this.addSignal(...
            newRunID,...
            signal.RootSource,...
            signal.TimeSource,...
            signal.DataSource,...
            timeAndData,...
            signal.BlockSource,...
            signal.ModelSource,...
            signal.SignalLabel,...
            signal.TimeDim,...
            signal.SampleDims,...
            signal.PortIndex,...
            channelIdx,...
            signal.SID,...
            signal.MetaData,...
            parent,...
            signal.rootDataSrc,...
            signal.InterpMethod,...
            signal.Units);


            KEEP_DIMS=true;
            if totalChannels>1&&signal.TimeDim==1
                timeAndData.Data=timeAndData.Data.';
            end
            firstLeafID=locGetFirstLeafSignal(this.sigRepository,newSignalID);
            this.sigRepository.setSignalDataValues(firstLeafID,timeAndData,KEEP_DIMS);


            if totalChannels>1
                Simulink.sdi.expandMatrix(this.sigRepository,newSignalID);
                leafSigs=this.sigRepository.getSignalChildren(newSignalID);
                for idx2=1:numel(pendingChannels)
                    pendingChannels(idx2).id=leafSigs(idx2);
                end
            else
                pendingChannels.id=newSignalID;
            end


            for idx2=1:numel(pendingChannels)
                signal=pendingChannels(idx2);
                signalIDMap.insert(signal.varName,signal.id);

                if totalChannels>1
                    this.sigRepository.setSignalDataSource(signal.id,signal.DataSource);
                end
                this.setSignalLineDashed(signal.id,signal.LineDashed);
                if isfield(signal,'LineWidth')
                    this.setSignalLineWidth(signal.id,signal.LineWidth);
                end
                if isfield(signal,'marker')
                    this.setSignalMarker(signal.id,signal.marker);
                end
                if isfield(signal,'relative')
                    this.setSignalRelTol(signal.id,signal.relative);
                end
                if isfield(signal,'absolute')
                    this.setSignalAbsTol(signal.id,signal.absolute);
                end
                if isfield(signal,'SyncMethod')
                    this.setSignalSyncMethod(signal.id,signal.SyncMethod);
                end
                this.setSignalLineColor(signal.id,...
                [signal.LineColor(1),signal.LineColor(2),signal.LineColor(3)]);
            end
        end


        uniqueRunIDs=unique(runIDs);



        numRuns=runIDMap.getCount;


        if isfield(descriptor,'SLDD')
            for idx=1:numRuns
                fileRunID=runIDMap.getKeyByIndex(idx);
                freshRunID=runIDMap.getDataByIndex(idx);


                if this.getSignalCount(freshRunID)==0
                    this.deleteRun(freshRunID);
                    runIDMap.deleteDataByKey(fileRunID);
                    uniqueRunIDs(uniqueRunIDs==freshRunID)=[];
                    continue;
                end


                hVarName=['h',strrep(sprintf('%d',fileRunID),'-','_')];
                exists=whos('-file',filename,hVarName);
                if~isempty(exists)
                    load(filename,hVarName);
                    metadata=eval(hVarName);
                    this.setRunHarnessModelMetaData(freshRunID,metadata);
                end


                rVarName=['runMetaData',strrep(sprintf('%d',fileRunID),'-','_')];
                exists=whos('-file',filename,rVarName);
                if~isempty(exists)
                    load(filename,rVarName);
                    metadata=eval(rVarName);
                    this.setRunMetaData(freshRunID,metadata);
                end
            end
        end

        count=length(uniqueRunIDs);
        if count>0
            runName=this.getRunName(int32(uniqueRunIDs(count)));
            this.newRunIDs=uniqueRunIDs;
            this.updateFlag=runName;
        end
    else

    end


    if~isempty(uniqueRunIDs)
        this.loadListener=filename;
    end
end


function result=resolveRuns(engine,descriptor)


    result=Simulink.sdi.Map(int32(0),int32(0));


    runCount=length(descriptor.Runs);
    runStruct=descriptor.Runs;

    if isfield(runStruct,'RunOrderInd')
        fields=fieldnames(runStruct);
        runCells=struct2cell(runStruct);
        sz=size(runCells);

        runCells=reshape(runCells,sz(1),[]);

        runCells=runCells';

        if engine.showRunAtTop
            runCells=sortrows(runCells,-2);
        else
            runCells=sortrows(runCells,2);
        end

        runCells=reshape(runCells',sz);


        runStruct=cell2struct(runCells,fields,1);
    end


    highestIndex=0;
    existingHighestVal=engine.sigRepository.getHighestRunNumber();

    for i=1:runCount

        fileRunID=runStruct(i).RunID;
        fileRunName=runStruct(i).RunName;


        newRunID=engine.createRun(fileRunName);


        result.insert(fileRunID,newRunID);

        if isfield(runStruct,'RunIndex')
            prevRunIndex=runStruct(i).RunIndex;
            newRunIndex=existingHighestVal+prevRunIndex;

            engine.sigRepository.setRunNumber(newRunID,newRunIndex);
            if highestIndex<newRunIndex
                highestIndex=newRunIndex;
            end
        end
    end

    if highestIndex>0
        engine.sigRepository.setHighestRunNumber(highestIndex);
    end
end


function ret=locConcatTimeseries(sigs)



    numTimePts=length(sigs(1).Values.Time);
    ret.Time=reshape(sigs(1).Values.Time,numTimePts,1);


    if sigs(1).TimeDim==1
        dataDims=[numTimePts,sigs(1).SampleDims];
    else
        dataDims=[sigs(1).SampleDims,numTimePts];
    end
    ret.Data=ones(dataDims);


    numChannels=numel(sigs);
    for idx=1:numChannels
        idxStr=locGetChannelIdxStr(sigs(idx).SampleDims,idx);
        curData=sigs(idx).Values.Data;%#ok<NASGU>
        evalCmd=sprintf('ret.Data%s = curData;',idxStr);
        eval(evalCmd);
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


function sigID=locGetFirstLeafSignal(repo,sigID)
    childIDs=repo.getSignalChildren(sigID);
    if~isempty(childIDs)
        sigID=locGetFirstLeafSignal(repo,childIDs(1));
    end
end


