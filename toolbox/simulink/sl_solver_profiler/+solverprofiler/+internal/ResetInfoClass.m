classdef ResetInfoClass<handle

    properties(SetAccess=private)
ModelResetStats
BlockResetStats
RankedBlockResetList
DiscDriContblkList
ResetTime
BlockStateStats
    end

    methods


        function obj=ResetInfoClass()
            obj.DiscDriContblkList=[];
            obj.ModelResetStats=[];
            obj.BlockResetStats=[];
            obj.RankedBlockResetList=[];
            obj.BlockStateStats=[];
        end


        function setDiscDriContblkList(obj,DiscDriContblkList)
            obj.DiscDriContblkList=DiscDriContblkList;
        end


        function setResetTime(obj,time)
            obj.ResetTime=time;
        end


        function list=getDiscDriContblkList(obj)
            list=obj.DiscDriContblkList;
        end


        function list=getRankedResetBlockList(obj)
            list=obj.RankedBlockResetList;
        end


        function populateResetInfo(obj,tout,pd,mdl,stats)
            import solverprofiler.util.*

            eventStruct=struct('eventTime',[],'stepSize',[]);

            resetStatsStruct=struct(...
            'blockIdx',[],...
            'allResets',eventStruct,...
            'zeroCrossing',eventStruct,...
            'discreteDerivative',eventStruct,...
            'zohDerivative',eventStruct,...
            'blockStateModeChange',eventStruct,...
            'initialReset',eventStruct,...
            'other',eventStruct);

            noReset=false;
            if isempty(pd)
                noReset=true;
            else
                eventInfo=pd.resetInfo;
                if isempty(eventInfo)||isempty(eventInfo.source)
                    noReset=true;
                end
            end


            if noReset
                obj.BlockResetStats=[];
                obj.ModelResetStats=[];
                obj.RankedBlockResetList=[];
                obj.ResetTime=[];
                obj.BlockStateStats=[];
                return;
            end

            obj.BlockStateStats=stats;


            modelSourceIndex=-1;
            for i=1:length(eventInfo.source)
                eventInfo.source{i}=solverprofiler.util.utilFormatBlockPathIfWithinModelRef(eventInfo.source{i});
                source=eventInfo.source{i};
                if(modelSourceIndex==-1&&strcmp(source,mdl))
                    modelSourceIndex=i;
                end
                if regexp(source,'zero_crossing_signal_')
                    sigIdx=eval(source(22:end));
                    srcIdx=pd.zcInfo.signalInfo.sourceIndex(sigIdx);
                    paths=pd.zcInfo.signalInfo.source(srcIdx).blockPath;
                    eventInfo.source{i}=solverprofiler.util.utilFormatBlockPathIfWithinModelRef(paths);
                end
            end








            reasonIndexToResetTypeVec=[];
            for i=1:length(eventInfo.reason)
                reason=eventInfo.reason{i};
                resetType=obj.determineCause(reason);
                reasonIndexToResetTypeVec(i)=resetType;
            end


            obj.ModelResetStats=resetStatsStruct;
            numBlocks=obj.BlockStateStats.getNumberOfBlocks();
            obj.BlockResetStats=repmat(resetStatsStruct,[numBlocks,1]);
            for i=1:length(obj.BlockResetStats)
                obj.BlockResetStats(i).blockIdx=i;
            end



            numEntry=length([eventInfo.details.sourceIndex]);
            rawInfo=zeros(numEntry,4);
            count=1;
            for i=1:length(eventInfo.details)
                numSources=length(eventInfo.details(i).sourceIndex);
                rawInfo(count:count+numSources-1,1)=eventInfo.details(i).t;
                count=count+numSources;
            end
            eventTime=rawInfo(:,1);
            paddedTout=[2*tout(1)-tout(2),tout'];
            [~,ib]=ismember(eventTime,paddedTout);



            ib(ib==0)=2;
            rawInfo(:,2)=paddedTout(ib)'-paddedTout(ib-1)';
            rawInfo(:,3)=[eventInfo.details.sourceIndex];
            rawInfo(:,4)=reasonIndexToResetTypeVec([eventInfo.details.reasonIndex]);


            allModelInfo=rawInfo(rawInfo(:,3)==modelSourceIndex,:);
            if~isempty(allModelInfo)
                uniqueTypes=unique(allModelInfo(:,4));
                info=unique(allModelInfo(:,1:2),'rows');
                obj.ModelResetStats.allResets.eventTime=info(:,1)';
                obj.ModelResetStats.allResets.stepSize=info(:,2)';
                for i=1:length(uniqueTypes)
                    resetType=uniqueTypes(i);
                    indices=allModelInfo(:,4)==resetType;
                    info=unique(allModelInfo(indices,1:2),'rows');
                    switch resetType
                    case 1
                        obj.ModelResetStats.zeroCrossing.eventTime=info(:,1)';
                        obj.ModelResetStats.zeroCrossing.stepSize=info(:,2)';
                    case 2
                        obj.ModelResetStats.discreteDerivative.eventTime=info(:,1)';
                        obj.ModelResetStats.discreteDerivative.stepSize=info(:,2)';
                    case 3
                        obj.ModelResetStats.zohDerivative.eventTime=info(:,1)';
                        obj.ModelResetStats.zohDerivative.stepSize=info(:,2)';
                    case 4
                        obj.ModelResetStats.blockStateModeChange.eventTime=info(:,1)';
                        obj.ModelResetStats.blockStateModeChange.stepSize=info(:,2)';
                    case 5
                        obj.ModelResetStats.initialReset.eventTime=info(:,1)';
                        obj.ModelResetStats.initialReset.stepSize=info(:,2)';
                    case 6
                        obj.ModelResetStats.other.eventTime=info(:,1)';
                        obj.ModelResetStats.other.stepSize=info(:,2)';
                    otherwise
                    end
                end
            end


            allBlockInfo=rawInfo(rawInfo(:,3)~=modelSourceIndex,:);
            if~isempty(allBlockInfo)
                uniqueSourceIndex=unique(allBlockInfo(:,3));
                for i=1:length(uniqueSourceIndex)
                    sourceIndex=uniqueSourceIndex(i);
                    allInfoForThisSource=allBlockInfo(allBlockInfo(:,3)==sourceIndex,:);
                    uniqueTypes=unique(allInfoForThisSource(:,4));
                    block=eventInfo.source{sourceIndex};


                    if~obj.BlockStateStats.blockExist(block)
                        obj.BlockStateStats.addBlockStats(block);
                        numBlocks=obj.BlockStateStats.getNumberOfBlocks();
                        obj.BlockResetStats(numBlocks)=resetStatsStruct;
                        obj.BlockResetStats(numBlocks).blockIdx=numBlocks;
                    end
                    blockIdx=obj.BlockStateStats.getBlockStatsIndex(block);

                    info=unique(allInfoForThisSource(:,1:2),'rows');
                    obj.BlockResetStats(blockIdx).allResets.eventTime=...
                    [obj.BlockResetStats(blockIdx).allResets.eventTime,info(:,1)'];
                    obj.BlockResetStats(blockIdx).allResets.stepSize=...
                    [obj.BlockResetStats(blockIdx).allResets.stepSize,info(:,2)'];
                    for j=1:length(uniqueTypes)
                        resetType=uniqueTypes(j);
                        indices=allInfoForThisSource(:,4)==resetType;
                        info=unique(allInfoForThisSource(indices,1:2),'rows');
                        switch resetType
                        case 1
                            obj.BlockResetStats(blockIdx).zeroCrossing.eventTime=...
                            [obj.BlockResetStats(blockIdx).zeroCrossing.eventTime,info(:,1)'];
                            obj.BlockResetStats(blockIdx).zeroCrossing.stepSize=...
                            [obj.BlockResetStats(blockIdx).zeroCrossing.stepSize,info(:,2)'];
                        case 2
                            obj.BlockResetStats(blockIdx).discreteDerivative.eventTime=...
                            [obj.BlockResetStats(blockIdx).discreteDerivative.eventTime,info(:,1)'];
                            obj.BlockResetStats(blockIdx).discreteDerivative.stepSize=...
                            [obj.BlockResetStats(blockIdx).discreteDerivative.stepSize,info(:,2)'];
                        case 3
                            obj.BlockResetStats(blockIdx).zohDerivative.eventTime=...
                            [obj.BlockResetStats(blockIdx).zohDerivative.eventTime,info(:,1)'];
                            obj.BlockResetStats(blockIdx).zohDerivative.stepSize=...
                            [obj.BlockResetStats(blockIdx).zohDerivative.stepSize,info(:,2)'];
                        case 4
                            obj.BlockResetStats(blockIdx).blockStateModeChange.eventTime=...
                            [obj.BlockResetStats(blockIdx).blockStateModeChange.eventTime,info(:,1)'];
                            obj.BlockResetStats(blockIdx).blockStateModeChange.stepSize=...
                            [obj.BlockResetStats(blockIdx).blockStateModeChange.stepSize,info(:,2)'];
                        case 5
                            obj.BlockResetStats(blockIdx).initialReset.eventTime=...
                            [obj.BlockResetStats(blockIdx).initialReset.eventTime,info(:,1)'];
                            obj.BlockResetStats(blockIdx).initialReset.stepSize=...
                            [obj.BlockResetStats(blockIdx).initialReset.stepSize,info(:,2)'];
                        case 6
                            obj.BlockResetStats(blockIdx).other.eventTime=...
                            [obj.BlockResetStats(blockIdx).other.eventTime,info(:,1)'];
                            obj.BlockResetStats(blockIdx).other.stepSize=...
                            [obj.BlockResetStats(blockIdx).other.stepSize,info(:,2)'];
                        otherwise
                        end
                    end
                end
            end


            resetNum=zeros(1,length(obj.BlockResetStats)+1);
            for i=1:length(obj.BlockResetStats)
                numEvents=length([obj.BlockResetStats(i).allResets.eventTime]);
                resetNum(i)=numEvents;
            end
            if~isempty(obj.ModelResetStats)
                resetNum(end)=length([obj.ModelResetStats.allResets.eventTime]);
            else
                resetNum(end)=0;
            end

            [resetNum,obj.RankedBlockResetList]=sort(resetNum,'descend');
            obj.RankedBlockResetList(resetNum==0)=[];

            obj.RankedBlockResetList(obj.RankedBlockResetList==(length(obj.BlockResetStats)+1))=-1;
        end


        function delete(obj)
            obj.BlockResetStats=[];
            obj.ModelResetStats=[];
            obj.RankedBlockResetList=[];
            obj.DiscDriContblkList=[];
        end


        function[blockIdxList,resetCounts]=getResetTable(obj,timeRange)
            blockIdxList=[];
            resetCounts=[];
            if isempty(obj.RankedBlockResetList)||...
                (isempty(obj.ModelResetStats)&&isempty(obj.BlockResetStats))
                return;
            end


            for i=1:length(obj.RankedBlockResetList)
                blockIdx=obj.RankedBlockResetList(i);
                if blockIdx==-1
                    stats=obj.ModelResetStats;
                else
                    stats=obj.BlockResetStats(blockIdx);
                end
                allTime=stats.allResets.eventTime;
                allTime=allTime(allTime>=timeRange(1)&allTime<=timeRange(2));
                if~isempty(allTime)
                    blockIdxList=[blockIdxList;blockIdx];
                    [numRows,~]=size(resetCounts);
                    resetCounts(numRows+1,1)=length(allTime);

                    allTime=stats.zeroCrossing.eventTime;
                    allTime=allTime(allTime>=timeRange(1)&allTime<=timeRange(2));
                    resetCounts(numRows+1,2)=length(allTime);

                    allTime=stats.discreteDerivative.eventTime;
                    allTime=allTime(allTime>=timeRange(1)&allTime<=timeRange(2));
                    resetCounts(numRows+1,3)=length(allTime);

                    allTime=stats.zohDerivative.eventTime;
                    allTime=allTime(allTime>=timeRange(1)&allTime<=timeRange(2));
                    resetCounts(numRows+1,4)=length(allTime);

                    allTime=stats.blockStateModeChange.eventTime;
                    allTime=allTime(allTime>=timeRange(1)&allTime<=timeRange(2));
                    resetCounts(numRows+1,5)=length(allTime);

                    allTime=stats.initialReset.eventTime;
                    allTime=allTime(allTime>=timeRange(1)&allTime<=timeRange(2));
                    resetCounts(numRows+1,6)=length(allTime);

                    allTime=stats.other.eventTime;
                    allTime=allTime(allTime>=timeRange(1)&allTime<=timeRange(2));
                    resetCounts(numRows+1,7)=length(allTime);
                end
            end
        end


        function matrix=getResetMatrixForSource(obj,blockIdx,type)
            if isempty(obj.RankedBlockResetList)||...
                (isempty(obj.ModelResetStats)&&isempty(obj.BlockResetStats))
                matrix=[];
            else
                if blockIdx==-1
                    stats=obj.ModelResetStats;
                else
                    stats=obj.BlockResetStats(blockIdx);
                end
                switch type
                case 0
                    allResets=stats.allResets;
                case 1
                    allResets=stats.zeroCrossing;
                case 2
                    allResets=stats.discreteDerivative;
                case 3
                    allResets=stats.zohDerivative;
                case 4
                    allResets=stats.blockStateModeChange;
                case 5
                    allResets=stats.initialReset;
                case 6
                    allResets=stats.other;
                otherwise
                    allResets=stats.allResets;
                end
                matrix=[[allResets.eventTime]',[allResets.stepSize]'];
                matrix=unique(matrix,'rows');
            end
        end


        function matrix=getTotalResetMatrix(obj,type)
            if isempty(obj.RankedBlockResetList)||...
                (isempty(obj.ModelResetStats)&&isempty(obj.BlockResetStats))
                matrix=[];
            else
                stats=obj.ModelResetStats;
                stats(2:length(obj.BlockResetStats)+1)=obj.BlockResetStats;
                switch type
                case 0
                    allResets=[stats.allResets];
                case 1
                    allResets=[stats.zeroCrossing];
                case 2
                    allResets=[stats.discreteDerivative];
                case 3
                    allResets=[stats.zohDerivative];
                case 4
                    allResets=[stats.blockStateModeChange];
                case 5
                    allResets=[stats.initialReset];
                case 6
                    allResets=[stats.other];
                otherwise
                    allResets=[stats.allResets];
                end
                matrix=[[allResets.eventTime]',[allResets.stepSize]'];
                matrix=unique(matrix,'rows');
            end
        end


        function tVec=getTotalResetTimeVec(obj,type)
            if isempty(obj.RankedBlockResetList)||...
                (isempty(obj.ModelResetStats)&&isempty(obj.BlockResetStats))
                tVec=[];
            else
                stats=obj.ModelResetStats;
                stats(2:length(obj.BlockResetStats)+1)=obj.BlockResetStats;
                switch type
                case 0
                    allResets=[stats.allResets];
                case 1
                    allResets=[stats.zeroCrossing];
                case 2
                    allResets=[stats.discreteDerivative];
                case 3
                    allResets=[stats.zohDerivative];
                case 4
                    allResets=[stats.blockStateModeChange];
                case 5
                    allResets=[stats.initialReset];
                case 6
                    allResets=[stats.other];
                otherwise
                    allResets=[stats.allResets];
                end
                tVec=unique([allResets.eventTime]);
            end
        end

    end


    methods(Static)






        function resetType=determineCause(cause)
            if~isempty(regexp(cause,'zero crossing','once'))
                resetType=1;
            elseif~isempty(regexp(cause,'discrete derivative','once'))
                resetType=2;
            elseif~isempty(regexp(cause,'fix in minor','once'))
                resetType=3;
            elseif~isempty(regexp(cause,'block','once'))
                resetType=4;
            elseif~isempty(regexp(cause,'initial reset','once'))
                resetType=5;
            else
                resetType=6;
            end
        end
    end

end


