classdef ZcInfoClass<handle

    properties(SetAccess=private)
ZcStats
ZcSigInfo
ZcSigValue
RankedBlockZcList
BlockStateStats
    end

    methods


        function obj=ZcInfoClass(pd,stats,fixedStepZcInfo)
            import solverprofiler.util.*

            eventStruct=struct(...
            'eventTime',[],...
            'stepSize',[],...
            'sigIdx',[]);

            zcStatsStruct=struct(...
            'blockIdx',[],...
            'events',eventStruct);

            zcSigInfoStruct=struct(...
            'name','',...
            'blockIdx',[],...
            'tag','',...
            'events',struct('eventTime',[],'stepSize',[],'sigValue',[],'type',''));


            if isempty(pd)||isempty(pd.zcInfo)
                obj.ZcStats=[];
                obj.ZcSigInfo=[];
                obj.ZcSigValue=[];
                obj.RankedBlockZcList=[];
                obj.BlockStateStats=[];
                return;
            end


            obj.BlockStateStats=stats;


            obj.ZcSigValue=pd.zcInfo.signalValues;
            pd.zcInfo.signalValues=[];


            sources=[pd.zcInfo.signalInfo.source];
            sourceIndices=[pd.zcInfo.signalInfo.sourceIndex];
            nSig=length(sourceIndices);
            obj.ZcSigInfo=repmat(zcSigInfoStruct,nSig,1);



            vistiedSignalsWithinSource=containers.Map();

            for i=1:nSig
                sourceIdx=sourceIndices(i);
                paths=sources(sourceIdx).blockPath;
                obj.ZcSigInfo(i).tag=sources(sourceIdx).locationTag;
                blockName=utilFormatBlockPathIfWithinModelRef(paths);


                if~obj.BlockStateStats.blockExist(blockName)
                    obj.BlockStateStats.addBlockStats(blockName);
                end
                obj.ZcSigInfo(i).blockIdx=obj.BlockStateStats.getBlockStatsIndex(blockName);

                sourceName=sources(sourceIdx).name;
                blockNameAfterUnwrap=utilUnwrapBlockNameIfInModelRef(blockName);
                bType=get_param(blockNameAfterUnwrap,'blocktype');
                if~contains(bType,'Simscape')
                    sourceName=[blockName,'_',sourceName];
                end

                if(sources(sourceIdx).width>1)
                    if~isKey(vistiedSignalsWithinSource,sourceName)
                        vistiedSignalsWithinSource(sourceName)=0;
                    end
                    currentIdx=vistiedSignalsWithinSource(sourceName)+1;
                    vistiedSignalsWithinSource(sourceName)=currentIdx;
                    obj.ZcSigInfo(i).name=[sourceName,'(',num2str(currentIdx),')'];
                else
                    obj.ZcSigInfo(i).name=sourceName;
                end
            end


            numBlocks=obj.BlockStateStats.getNumberOfBlocks();
            obj.ZcStats=repmat(zcStatsStruct,[1,numBlocks]);
            for i=1:numBlocks
                obj.ZcStats(i).blockIdx=i;
            end



            eventInfo=[pd.zcInfo.eventInfo];
            pd.zcInfo.eventInfo=[];
            nzce=length([eventInfo.sigIdx]);
            rawInfo=zeros(nzce,4);


            types=cell(nzce,1);


            eventTime=[eventInfo.tZR];

            if~isempty(fixedStepZcInfo)
                tout=fixedStepZcInfo.majorTimes;
                stepAtEvent=(tout(2)-tout(1))*ones(1,length(eventInfo));
            else
                stepAtEvent=[eventInfo.tZR]-[eventInfo.tL0];
            end
            count=0;


            for i=1:length(eventInfo)
                if isnan(eventTime(i)),continue;end

                for j=1:length(eventInfo(i).sigIdx)
                    sigIdx=double(eventInfo(i).sigIdx(j));
                    count=count+1;
                    rawInfo(count,:)=[sigIdx,eventTime(i),stepAtEvent(i),eventInfo(i).vZR(j)];
                    types{count}=eventInfo(i).type{j};
                end
            end
            rawInfo=rawInfo(1:count,:);
            types=types(1:count);

            triggeredZcSigIdxLst=unique(rawInfo(:,1));
            for i=1:length(triggeredZcSigIdxLst)

                sigIdx=triggeredZcSigIdxLst(i);
                rawInfoForCurrentSigIdx=rawInfo(rawInfo(:,1)==sigIdx,:);
                typesForCurrentSigIdx=types(rawInfo(:,1)==sigIdx,:);
                nEvents=length(rawInfoForCurrentSigIdx(:,1));


                obj.ZcSigInfo(sigIdx).events(1:nEvents)=struct(...
                'eventTime',num2cell(rawInfoForCurrentSigIdx(:,2)),...
                'stepSize',num2cell(rawInfoForCurrentSigIdx(:,3)),...
                'sigValue',num2cell(rawInfoForCurrentSigIdx(:,4)),...
                'type',typesForCurrentSigIdx);


                blockIdx=obj.ZcSigInfo(sigIdx).blockIdx;
                numCachedEvents=length([obj.ZcStats(blockIdx).events.eventTime]);


                obj.ZcStats(blockIdx).events(numCachedEvents+1:numCachedEvents+nEvents)=struct(...
                'eventTime',num2cell(rawInfoForCurrentSigIdx(:,2)),...
                'stepSize',num2cell(rawInfoForCurrentSigIdx(:,3)),...
                'sigIdx',sigIdx);

            end


            blockZcNum=zeros(1,length(obj.ZcStats));
            for i=1:length(obj.ZcStats)
                numEvents=length([obj.ZcStats(i).events.eventTime]);
                blockZcNum(i)=numEvents;
            end

            [blockZcNum,obj.RankedBlockZcList]=sort(blockZcNum,'descend');
            obj.RankedBlockZcList(blockZcNum==0)=[];
        end


        function delete(obj)
            obj.ZcSigInfo=[];
            obj.ZcSigValue=[];
            obj.ZcStats=[];
            obj.RankedBlockZcList=[];
        end


        function[zcSigIdxLst,zcEventsNumber]=sortSignals(obj,tl,tr)
            zcEventsNumber=zeros(length(obj.ZcSigInfo),1);


            for i=1:length(obj.ZcSigInfo)
                allTime=[obj.ZcSigInfo(i).events.eventTime];
                zcEventsNumber(i)=length(allTime(allTime>=tl&allTime<=tr));
            end


            [zcEventsNumber,zcSigIdxLst]=sort(zcEventsNumber,'descend');
        end


        function sigName=getSignalNameFromSigIdx(obj,sigIdx)
            sigName=obj.ZcSigInfo(sigIdx).name;
        end


        function blockName=getBlockNameFromSigIdx(obj,sigIdx)
            blockIdx=obj.ZcSigInfo(sigIdx).blockIdx;
            blockName=obj.BlockStateStats.getBlockName(blockIdx);
        end


        function tag=getLocationTagFromSigIdx(obj,sigIdx)
            tag=obj.ZcSigInfo(sigIdx).tag;
        end


        function[time,value]=getSignal(obj,sigIdx)
            sigVal=obj.ZcSigValue(sigIdx);
            time=sigVal.time;
            value=sigVal.value;
        end


        function[time,value]=getEvents(obj,sigIdx)
            events=obj.ZcSigInfo(sigIdx).events;
            time=[events.eventTime];
            value=[events.sigValue];
        end


        function type=getCrossingType(obj,sigIdx,etime)
            events=obj.ZcSigInfo(sigIdx).events;
            time=[events.eventTime];
            index=find(time==etime);
            if~isempty(index)
                type=events(index).type;
            else
                type='';
            end
        end


        function[zcSigInfo,zcEvents]=getSimplifiedZcInfo(obj)
            zcSourceInfoStruct=struct(...
            'name',[],...
            'blockIdx',[]);

            zcEventsStruct=struct(...
            't',[],...
            'srcIdx',[]);

            if~isempty(obj.ZcSigInfo)

                zcSigInfo=repmat(zcSourceInfoStruct,[obj.numSrcs,1]);
                for i=1:length(zcSigInfo)
                    zcSigInfo(i).name=obj.ZcSigInfo(i).name;
                    zcSigInfo(i).blockIdx=obj.ZcSigInfo(i).blockIdx;
                end


                if~isempty(obj.RankedBlockZcList)
                    events=[obj.ZcStats(obj.RankedBlockZcList).events];
                    zcEvents=repmat(zcEventsStruct,[length(events),1]);
                    for i=1:length(events)
                        zcEvents(i).t=events(i).eventTime;
                        zcEvents(i).srcIdx=events(i).srcIdx;
                    end

                    tVec=[zcEvents.t];
                    [~,order]=sort(tVec);
                    zcEvents=zcEvents(order);
                else
                    zcEvents=[];
                end
            else
                zcSigInfo=[];
                zcEvents=[];
            end
        end


        function list=getRankedBlockZcList(obj)
            list=obj.RankedBlockZcList;
        end


        function flag=zcEventsDetected(obj)
            flag=~isempty(obj.RankedBlockZcList);
        end


        function value=numSrcs(obj)
            if~isempty(obj.ZcSigInfo)
                value=length(obj.ZcSigInfo);
            else
                value=0;
            end
        end


        function value=numTriggerdSrcs(obj)
            if~isempty(obj.RankedBlockZcList)
                allEvents=[obj.ZcStats(obj.RankedBlockZcList).events];
                allTriggeredSigs=unique([allEvents.sigIdx]);
                value=length(allTriggeredSigs);
            else
                value=0;
            end
        end


        function value=totalZcNum(obj)
            if~isempty(obj.RankedBlockZcList)
                value=length([obj.ZcStats(obj.RankedBlockZcList).events]);
            else
                value=0;
            end
        end


        function matrix=getTotalZcMatrix(obj)
            if~isempty(obj.RankedBlockZcList)
                allEvents=[obj.ZcStats(obj.RankedBlockZcList).events];
                matrix=[[allEvents.eventTime]',[allEvents.stepSize]'];
            else
                matrix=[];
            end
        end


        function matrix=getZcMatrixForBlock(obj,blockIdx)
            if~isempty(obj.RankedBlockZcList)
                events=obj.ZcStats(blockIdx).events;
                matrix=[[events.eventTime]',[events.stepSize]'];
            else
                matrix=[];
            end
        end


        function[blockIdxList,zcCounts]=getZcTable(obj,timeRange)
            blockIdxList=[];
            zcCounts=[];
            if isempty(obj.RankedBlockZcList)
                return;
            end

            for i=1:length(obj.RankedBlockZcList)
                blockIdx=obj.RankedBlockZcList(i);
                allTime=[obj.ZcStats(blockIdx).events.eventTime];
                indices=find(allTime>=timeRange(1)&allTime<=timeRange(2));
                if~isempty(indices)
                    blockIdxList=[blockIdxList;blockIdx];
                    zcCounts=[zcCounts;length(indices)];
                end
            end


            if~isempty(blockIdxList)
                [zcCounts,order]=sort(zcCounts,'descend');
                blockIdxList=blockIdxList(order);
            end
        end


        function flag=hasZCValue(obj)
            flag=~isempty(obj.ZcSigValue);
        end

    end


end


