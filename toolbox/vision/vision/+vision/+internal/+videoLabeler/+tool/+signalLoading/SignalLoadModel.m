
classdef SignalLoadModel<handle

    properties(Access=private)


SignalSources


SignalInfoTable


TimeUnits
    end

    properties(Access=private)

SignalsAdded


SignalsDeleted


SignalsModified






SourcesNotLoaded
    end

    events
SignalAdded
SignalMarkedForDelete
    end




    methods

        function this=SignalLoadModel()

            tableVariables={'SignalName','LoaderId','SignalType',...
            'SourceName','DisplayName','TimeStamp','NumFrames',...
            'LastReadIndex','Temporary','Modified','ToDelete','OldDisplayName'};
            this.SignalInfoTable=table({},[],{},{},{},[],[],[],logical([]),...
            logical([]),logical([]),[],'VariableNames',tableVariables);
        end

    end




    methods

        function[TF,msg]=addSignalSource(this,signalSource)

            idx=numel(this.SignalSources)+1;

            try
                validateSignalSource(this,signalSource);

                this.SignalSources=[this.SignalSources(1:idx-1)...
                ,signalSource...
                ,this.SignalSources(idx:end)];

                updateTableOnAdd(this,signalSource,idx);

                msg=[];
                TF=true;
            catch ME
                msg=ME.message;
                TF=false;
            end

        end

        function deleteSignal(this,deleteIndices)
            updateTableOnDelete(this,deleteIndices);
        end

        function modifySignal(this,idx,data)
            updateTableOnModify(this,idx,data);
        end

    end




    methods
        function confirmChanges(this)

            if isempty(this.SignalInfoTable)
                return;
            end


            notMarkedForDelete=~this.SignalInfoTable.ToDelete;
            addedIdx=find(this.SignalInfoTable.Temporary(:)&notMarkedForDelete);

            if~isempty(addedIdx)
                this.SignalsAdded=struct();
                this.SignalsAdded.SignalNames=this.SignalInfoTable.DisplayName(addedIdx);
                this.SignalsAdded.SignalType=this.SignalInfoTable.SignalType(addedIdx);
                this.SignalsAdded.NumFrames=this.SignalInfoTable.NumFrames(addedIdx);

                this.SignalInfoTable.Temporary(addedIdx)=false;
            end



            modifiedIdx=find(this.SignalInfoTable.Modified(:));

            this.SignalsModified=struct();

            this.SignalsModified.SignalNames=this.SignalInfoTable.DisplayName(modifiedIdx);
            this.SignalsModified.OldDisplayNames=this.SignalInfoTable.OldDisplayName(modifiedIdx);

            this.SignalInfoTable.Modified(modifiedIdx)=false;
            this.SignalInfoTable.OldDisplayName(modifiedIdx)={''};


            confirmDeletionOfSignal(this);
        end

        function removeChanges(this)

            if isempty(this.SignalInfoTable)
                return;
            end


            addedIdx=this.SignalInfoTable.Temporary;
            this.SignalInfoTable(addedIdx,:)=[];
            this.SignalSources(addedIdx)=[];


            modifiedIdx=this.SignalInfoTable.Temporary;

            this.SignalInfoTable.DisplayName(modifiedIdx)=...
            this.SignalInfoTable.OldDisplayName(modifiedIdx);

            this.SignalInfoTable.Modified(modifiedIdx)=false;



            this.SignalInfoTable.ToDelete(this.SignalInfoTable.ToDelete)=false;

        end

        function clearSignalChanges(this)
            this.SignalsAdded=[];
            this.SignalsDeleted=[];
        end
    end




    methods
        function[frameArray,exception]=readFrame(this,ts,signalNames)

            if height(this.SignalInfoTable)<1
                frameArray=[];
                return;
            end



            if nargin<3
                signalNames=this.SignalInfoTable.SignalName;
            end

            numSignals=numel(signalNames);
            frameArray=cell(1,numSignals);

            [indices,timestamps]=getTimeToIndices(this,ts,signalNames);

            exception=struct();
            exception.IsTrue=false;
            exception.ME=[];

            for i=1:numSignals
                try
                    signalIdx=find(this.SignalInfoTable.SignalName==signalNames(i));
                    loaderId=this.SignalInfoTable{signalIdx,'LoaderId'};

                    frameStruct=struct();

                    if indices(i)>0
                        frame=readFrame(this.SignalSources(loaderId),...
                        signalNames(i),indices(i));

                        frameStruct.Data=frame;
                    else
                        frameStruct.Data=[];
                    end

                    frameStruct.FrameIndex=indices(i);
                    frameStruct.FrameTimeStamp=timestamps(i);
                    frameStruct.SignalName=signalNames(i);
                    frameStruct.SignalId=signalIdx;

                    frameArray{i}=frameStruct;

                    this.SignalInfoTable{signalIdx,'LastReadIndex'}=indices(i);
                catch ME
                    exception.IsTrue=true;
                    exception.ME=ME;
                    exception.Source=this.SignalSources(loaderId).SourceName;
                end
            end
        end
    end




    methods
        function signalInfo=getSignalInfo(this)
            signalInfo=removevars(this.SignalInfoTable,{'LoaderId',...
            'NumFrames','LastReadIndex','Temporary','Modified',...
            'ToDelete','OldDisplayName'});
        end

        function[signalsAdded,signalsDeleted]=getSignalChanges(this)
            signalsAdded=this.SignalsAdded;
            signalsDeleted=this.SignalsDeleted;
        end

        function timeVectors=getTimeVectors(this,signalNames)

            if nargin<2
                signalNames=this.SignalInfoTable.SignalNames;
            end

            signalNames=string(signalNames);

            indices=ismember(this.SignalInfoTable.SignalName,signalNames);
            timeVectors=this.SignalInfoTable.TimeStamp(indices);
        end

        function[startTime,endTime]=getStartAndEndTime(this)

            if height(this.SignalInfoTable)<1
                startTime=[];
                endTime=[];
                return;
            end

            timeVector=this.SignalInfoTable.TimeStamp{1};

            startTime=timeVector(1);
            if numel(timeVector)>1
                frameRate=timeVector(2)-timeVector(1);
            else



                frameRate=seconds(1);
            end

            endTime=timeVector(end)+frameRate;

        end

        function timeUnits=getTimeUnits(this)
            timeUnits=this.TimeUnits;
        end

        function numSignals=getNumberOfSignals(this)
            numSignals=height(this.SignalInfoTable);
        end

        function lastReadIdx=getLastReadIdx(this,signalIdOrName)

            if~isnumeric(signalIdOrName)
                signalName=signalIdOrName;
                signalId=find(this.SignalInfoTable.SignalName==signalName,1);
            else
                signalId=signalIdOrName;
            end

            if getNumberOfSignals(this)
                lastReadIdx=this.SignalInfoTable.LastReadIndex(signalId);
            else
                lastReadIdx=[];
            end
        end

        function lastReadIdx=getLastReadIdxFromIdNoCheck(this,signalId)
            lastReadIdx=this.SignalInfoTable.LastReadIndex(signalId);
        end

        function TF=hasPointCloudSignal(this)
            if isempty(this.SignalInfoTable.SignalType)
                TF=false;
            else
                TF=~isempty(find(this.SignalInfoTable.SignalType==1,1));
            end
        end

        function TF=hasImageVideoSignal(this)
            if isempty(this.SignalInfoTable.SignalType)
                TF=false;
            else
                TF=any(this.SignalInfoTable.SignalType==vision.labeler.loading.SignalType.Image);
            end
        end

        function[frameIndices,outTimeVector]=getFrameIndexFromTime(this,timeVector,signalName)

            numTimeVector=numel(timeVector);

            frameIndices=zeros(1,numTimeVector);
            outTimeVector=seconds(zeros(1,numTimeVector));

            for idx=1:numel(timeVector)
                [frameIndices(idx),outTimeVector(idx)]=getTimeToIndices(this,...
                timeVector(idx),signalName);
            end
        end

        function timeInterval=clipTimeInterval(this,timeInterval,signalName)

            signalIdx=(this.SignalInfoTable.SignalName==signalName);
            timeVector=this.SignalInfoTable.TimeStamp{signalIdx};

            tvStart=seconds(timeVector(1));
            tvEnd=seconds(timeVector(end));

            if timeInterval(1)<tvStart
                timeInterval(1)=tvStart;
            end
            if timeInterval(2)>tvEnd
                timeInterval(2)=tvEnd;
            end

            if timeInterval(1)>timeInterval(2)
                timeInterval(1)=timeInterval(2);
            end

            if timeInterval(2)<timeInterval(1)
                timeInterval(2)=timeInterval(1);
            end

        end

        function sourceNames=getSourceNames(this)
            numSources=numel(this.SignalSources);

            if numSources>0
                sourceNames=[this.SignalSources.SourceName];
            else
                sourceNames=[];
            end
        end

        function sourceNames=getSourceNamesFromSignalNames(this,signalNames)
            signalNames=string(signalNames);
            numSignals=numel(signalNames);
            sourceNames=strings(1,numSignals);

            for idx=1:numSignals
                signalIdx=(this.SignalInfoTable.SignalName==(signalNames(idx)));

                sourceNames(idx)=this.SignalInfoTable.SourceName(signalIdx);
            end
        end

        function numFrames=getNumberOfFrames(this,signalNames)
            if nargin<2
                numFrames=this.SignalInfoTable.NumFrames;
            else
                signalNames=string(signalNames);
                numFrames=this.SignalInfoTable.NumFrames(this.SignalInfoTable.SignalName==signalNames);
            end

        end

        function signalNames=getSignalNames(this)
            signalNames=this.SignalInfoTable.SignalName;
        end

        function signalTypes=getSignalTypes(this,signalNames)
            if nargin<2
                signalTypes=this.SignalInfoTable.SignalType;
            else
                signalNames=string(signalNames);
                signalTypes=this.SignalInfoTable.SignalType(this.SignalInfoTable.SignalName==signalNames);
            end
        end

        function sourcesNotLoaded=getSourcesNotLoaded(this)
            sourcesNotLoaded=this.SourcesNotLoaded;
        end

        function sourceObj=getSource(this,sourceIdx)
            if nargin<2
                sourceObj=this.SignalSources;
            else
                sourceObj=this.SignalSources(sourceIdx);
            end
        end

        function sourceObj=getSourceBySignalName(this,signalName)
            signalId=this.SignalInfoTable.SignalName==signalName;
            sourceIdx=this.SignalInfoTable.LoaderId(signalId);
            sourceObj=this.SignalSources(sourceIdx);
        end

        function validTimeVector=getValidTimeVector(this,tStart,tEnd,signalName)

            if nargin<4||isempty(signalName)
                signalName=this.MasterSignal;
            end

            signalIdx=(this.SignalInfoTable.SignalName==signalName);
            timeVector=this.SignalInfoTable.TimeStamp{signalIdx};

            tStart=seconds(tStart);
            tEnd=seconds(tEnd);

            isValid=timeVector>=tStart&timeVector<=tEnd;
            validTimeVector=timeVector(isValid)';

            if~isempty(validTimeVector)
                if tStart~=validTimeVector(1)
                    [~,ts]=getTimeToIndices(this,tStart,signalName);
                    validTimeVector=[ts,validTimeVector];
                end

                if tEnd~=validTimeVector(end)&&...
                    validTimeVector(end)~=timeVector(end)

                    [~,ts]=getTimeToIndices(this,tEnd,signalName);
                    [~,tCheck]=getTimeToIndices(this,validTimeVector(end),signalName);

                    if ts~=tCheck
                        validTimeVector=[validTimeVector,tEnd];
                    end
                end
            end

        end

    end




    methods(Access=private)
        function updateTableOnAdd(this,signalSource,loaderId)

            numSignals=signalSource.NumSignals;
            signalNames=signalSource.SignalName;
            signalTypes=signalSource.SignalType;
            sourceName=signalSource.SourceName;
            timeStamps=signalSource.Timestamp;

            if iscell(timeStamps)
                if numel(timeStamps)==1&&numSignals>1
                    timeStamps=repmat(timeStamps,1,numSignals);
                end
            else
                if numSignals>1
                    timeStamps=repmat({timeStamps},1,numSignals);
                else
                    timeStamps={timeStamps};
                end
            end

            signalsAddedInfo=[];

            for idx=1:numSignals
                tablerow=table(signalNames(idx),loaderId,signalTypes(idx),...
                sourceName,signalNames(idx),timeStamps(idx),...
                numel(timeStamps{idx}),1,true,false,false,...
                "",'VariableNames',{'SignalName','LoaderId',...
                'SignalType','SourceName','DisplayName','TimeStamp',...
                'NumFrames','LastReadIndex','Temporary','Modified','ToDelete',...
                'OldDisplayName'});

                this.SignalInfoTable=[this.SignalInfoTable;tablerow];

                data=removevars(tablerow,{'LoaderId','NumFrames',...
                'Temporary','LastReadIndex','Modified','ToDelete','OldDisplayName'});
                signalsAddedInfo=[signalsAddedInfo;data];
            end

            import vision.internal.videoLabeler.tool.signalLoading.events.*
            evtData=SignalAddedEvent(signalsAddedInfo);
            notify(this,'SignalAdded',evtData);

        end

        function updateTableOnDelete(this,deleteIndices)

            toDeleteIndices=this.SignalInfoTable.ToDelete;



            prevDeleted=0;
            indiceNum=1;
            for i=1:numel(toDeleteIndices)
                if toDeleteIndices(i)==1
                    prevDeleted=prevDeleted+1;
                end
                if i==deleteIndices(indiceNum)
                    indiceVal=deleteIndices(indiceNum)+prevDeleted;
                    this.SignalInfoTable.ToDelete(indiceVal)=true;
                    indiceNum=indiceNum+1;
                    if indiceNum>numel(deleteIndices)
                        break;
                    end
                end
            end

            import vision.internal.videoLabeler.tool.signalLoading.events.*
            evtData=DeleteSignalEvent(deleteIndices);

            notify(this,'SignalMarkedForDelete',evtData);
        end

        function confirmDeletionOfSignal(this)

            deleteIndices=find(this.SignalInfoTable.ToDelete==true);

            if~isempty(deleteIndices)
                deleteLoaderIds=this.SignalInfoTable.LoaderId(deleteIndices);
                deleteLoaderIds=unique(deleteLoaderIds);

                removedSignals=this.SignalInfoTable.DisplayName(deleteIndices);
                removedSignals(this.SignalInfoTable.Temporary(deleteIndices))=[];

                this.SignalsDeleted=[this.SignalsDeleted,removedSignals'];
                this.SignalInfoTable(deleteIndices,:)=[];

                allLoaderIds=this.SignalInfoTable.LoaderId;
                deleteLoaderIds=deleteLoaderIds(~ismember(deleteLoaderIds,allLoaderIds));

                this.SignalSources(deleteLoaderIds)=[];

                for i=1:numel(allLoaderIds)
                    loaderId=allLoaderIds(i);

                    newLoaderId=loaderId-sum(deleteLoaderIds<loaderId);

                    allLoaderIds(i)=newLoaderId;
                end

                this.SignalInfoTable.LoaderId=allLoaderIds;

                if isempty(this.SignalSources)
                    this.TimeUnits=[];
                end

            end
        end

        function updateTableOnModify(this,idx,data)
            oldDisplayName=this.SignalInfoTable.DisplayName(idx);

            if oldDisplayName==data.OldName
                this.SignalInfoTable.DisplayName(idx)=data.NewName;
                this.SignalInfoTable.Modified(idx)=true;
                this.SignalInfoTable.OldDisplayName(idx)=oldDisplayName;
            end
        end

    end




    methods(Access=private)
        function validateSignalSource(this,signalSource)


            numSignals=signalSource.NumSignals;

            validateattributes(numSignals,{'numeric'},{'scalar','>',0,...
            'integer'},'','NumSignals');


            signalNames=signalSource.SignalName;
            validateattributes(signalNames,{'string','cell'},...
            {'vector','nrows',1,'ncols',numSignals},'','SignalName');

            currentSignalNames=this.SignalInfoTable.SignalName(~this.SignalInfoTable.ToDelete);

            indices=ismember(signalNames,currentSignalNames);
            if any(indices)
                errorStr=strjoin(signalNames(indices),newline);
                error(vision.getMessage('vision:labeler:SignalExistsError',errorStr));
            end

            for idx=1:numel(signalNames)
                if~isvarname(signalNames(idx))
                    error(vision.getMessage('vision:labeler:SignalNameValidVarname',signalNames(idx)));
                end
            end


            signalTypes=signalSource.SignalType;
            validateattributes(signalTypes,{'vision.labeler.loading.SignalType'},...
            {'vector','nrows',1,'ncols',numSignals},'','SignalType');


            timeStamps=signalSource.Timestamp;

            if~iscell(timeStamps)
                timeStamps={timeStamps};
            end

            if numSignals~=numel(timeStamps)
                error(vision.getMessage('vision:labeler:TimestampsSizeError'));
            end

            if isempty(this.TimeUnits)
                this.TimeUnits="duration";
            end

            for idx=numel(timeStamps)
                timeStampVector=timeStamps{idx};
                if isempty(this.TimeUnits)
                    timeUnits="duration";
                else
                    timeUnits=this.TimeUnits;
                end
                validateattributes(timeStampVector,timeUnits,...
                {'vector'},'','Timestamp');
            end


            sourceName=signalSource.SourceName;
            validateattributes(sourceName,{'string'},...
            {'scalar'},'','SourceName');

        end

    end




    methods(Access=private)
        function[indices,timestamps]=getTimeToIndices(this,ts,signalNames)

            numSignals=numel(signalNames);
            indices=zeros(1,numSignals);

            if isnumeric(ts)
                ts=seconds(ts);
            end
            timestamps(numSignals)=eval(class(ts));
            timestamps.Format=ts.Format;

            import vision.internal.videoLabeler.tool.signalLoading.helpers.*

            for i=1:numSignals

                signalIndices=this.SignalInfoTable.SignalName==signalNames(i);
                timeVector=this.SignalInfoTable{signalIndices,'TimeStamp'};

                if~isempty(timeVector)
                    timeVector=timeVector{1};



                    if numel(timeVector)>1
                        lastFrameTs=timeVector(end)+(timeVector(end)-timeVector(end-1));
                    else
                        lastFrameTs=timeVector(end)+timeVector(end);
                    end

                    if ts<=(lastFrameTs+eps)
                        [indices(i),timestamps(i)]=getTimeToIndex(timeVector,ts);
                    else
                        timestamps(i)=seconds(NaN);
                    end
                else
                    timestamps(i)=seconds(NaN);
                end
            end
        end
    end




    methods(Static,Hidden)
        function this=loadobj(that)
            this=vision.internal.videoLabeler.tool.signalLoading.SignalLoadModel();
            this.SignalSources=that.SignalSources;
            this.SignalInfoTable=that.SignalInfoTable;
            this.TimeUnits=that.TimeUnits;
            this.SourcesNotLoaded=that.SourcesNotLoaded;

            if isstruct(this.SourcesNotLoaded)&&~isfield(this.SourcesNotLoaded,'SignalNames')
                [this.SourcesNotLoaded(:).SignalNames]=deal([]);
            end

            for idx=1:numel(this.SignalSources)
                sourceName=this.SignalSources(idx).SourceName;
                sourceParams=this.SignalSources(idx).SourceParams;

                try
                    this.SignalSources(idx).loadSource(sourceName,sourceParams);
                catch
                    sourcesNotLoaded=struct();
                    sourcesNotLoaded.Id=idx;
                    sourcesNotLoaded.SourceName=sourceName;
                    sourcesNotLoaded.SourceParams=sourceParams;

                    sourceIndices=(this.SignalInfoTable.LoaderId==idx);
                    signalNames=[this.SignalInfoTable.SignalName(sourceIndices)];
                    sourcesNotLoaded.SignalNames=signalNames;

                    this.SourcesNotLoaded=[this.SourcesNotLoaded,sourcesNotLoaded];

                    this.SignalInfoTable(sourceIndices,:)=[];
                end
            end

            this.SignalsAdded=struct();
            this.SignalsAdded.SignalNames=this.SignalInfoTable.SignalName;
            this.SignalsAdded.SignalType=this.SignalInfoTable.SignalType;
            this.SignalsAdded.NumFrames=this.SignalInfoTable.NumFrames;
        end
    end

    methods
        function signalNames=fixSource(this,sourceId,sourceName,sourceParams)

            try
                sourceObj=this.SignalSources(sourceId);
                sourceObj.loadSource(sourceName,sourceParams);

                currentSignalNames=this.SignalInfoTable.SignalName;
                signalNames=sourceObj.SignalName;

                if~any(signalNames==currentSignalNames)
                    validateSignalSource(this,sourceObj);

                    updateTableOnAdd(this,sourceObj,sourceId);
                end
            catch
                signalNames=[];
                return;
            end

            logicalIdx=([this.SourcesNotLoaded.Id]==sourceId);
            this.SourcesNotLoaded(logicalIdx)=[];
        end



        function TF=callLoadSource(this,signalSource,sourceName,sourceParams)
            try
                signalSource.loadSource(sourceName,sourceParams);
                addSignalSource(this,signalSource);
                confirmChanges(this);
                TF=true;
            catch
                this.SignalSources=signalSource;
                this.SourcesNotLoaded=struct;
                this.SourcesNotLoaded.Id=1;
                this.SourcesNotLoaded.SourceName=sourceName;
                this.SourcesNotLoaded.SourceParams=sourceParams;
                this.SourcesNotLoaded.SignalNames=[];
                TF=false;
            end
        end


    end
end