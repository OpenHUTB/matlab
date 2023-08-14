classdef FailureInfoClass<handle

    properties(SetAccess=private)
FailureStats
RankedStateFailureList
UnknownFailure
BlockStateStats
    end

    methods


        function obj=FailureInfoClass(tout,pd,stats)
            import solverprofiler.util.*

            eventStruct=struct('eventTime',[],'stepSize',[]);

            failureStatsStruct=struct(...
            'stateIdx',[],...
            'allFailure',eventStruct,...
            'toleranceNotMet',eventStruct,...
            'newtonFailure',eventStruct,...
            'stateInfinite',eventStruct,...
            'derivInfinite',eventStruct,...
            'DAEHminViolation',eventStruct);

            noFailure=false;
            if isempty(pd)
                noFailure=true;
            else
                if isfield(pd.odeInfo.failedStepInfo,'failedSteps')
                    eventInfo=pd.odeInfo.failedStepInfo.failedSteps;
                else
                    eventInfo=pd.odeInfo.failedStepInfo;
                end
                if isempty(eventInfo)
                    noFailure=true;
                end
            end


            if noFailure
                obj.FailureStats=[];
                obj.RankedStateFailureList=[];
                obj.UnknownFailure=[];
                obj.BlockStateStats=[];
                return;
            end

            obj.BlockStateStats=stats;


            numStates=obj.BlockStateStats.getNumberOfStates();
            obj.FailureStats=repmat(failureStatsStruct,[numStates,1]);
            for i=1:length(obj.FailureStats)
                obj.FailureStats(i).stateIdx=i;
            end
            obj.UnknownFailure=repmat(eventStruct,[1,1]);



            allFailedStateIdx=unique([eventInfo.limitStateIdx]);
            limitStateIdxToStateIdxVector=zeros(numStates,1);

            for i=1:length(allFailedStateIdx)
                [srcIdx,localIdx]=obj.getSrcIdx(pd,allFailedStateIdx(i));

                if srcIdx==0
                    continue;
                end

                stateName=pd.odeInfo.stateInfo.source(srcIdx).name;
                paths=pd.odeInfo.stateInfo.source(srcIdx).blockPath;
                blockPath=utilFormatBlockPathIfWithinModelRef(paths);


                if isempty(stateName)
                    stateName=blockPath;
                elseif~contains(stateName,'/')&&~contains(stateName,'.')



                    stateName=[blockPath,'/',stateName];
                end
                stateName=strrep(stateName,newline,' ');


                if localIdx>0
                    stateName=[stateName,'(',num2str(localIdx),')'];
                end

                if~obj.BlockStateStats.stateExist(stateName)
                    continue;
                end

                stateIdx=obj.BlockStateStats.getStateStatsIndex(stateName);
                limitStateIdxToStateIdxVector(allFailedStateIdx(i))=stateIdx;
            end


            if isfield(pd.odeInfo.failedStepInfo,'reasons')
                allCauses=cell(length(eventInfo),1);
                for i=1:length(eventInfo)
                    allCauses(i)=pd.odeInfo.failedStepInfo.reasons(eventInfo(i).reasonIdx);
                end
            else
                allCauses={eventInfo.cause}';
            end
            allTypes=zeros(length(allCauses),1);
            [uniqueCauses,~,ic]=unique(allCauses);


            for i=1:length(uniqueCauses)
                type=obj.determineCause(uniqueCauses{i});
                allTypes(ic==i)=type;
            end



            nfe=length(eventInfo);
            rawInfo=zeros(nfe,4);

            rawInfo(:,1)=[eventInfo.t0];
            for i=1:nfe
                limitStateIdx=eventInfo(i).limitStateIdx;
                if~isempty(limitStateIdx)
                    rawInfo(i,3)=limitStateIdxToStateIdxVector(limitStateIdx);
                else
                    rawInfo(i,3)=-1;
                end
            end
            rawInfo(:,4)=allTypes;


            rawInfo=sortrows(rawInfo,1);



            eventTime=rawInfo(:,1);
            paddedTout=[2*tout(1)-tout(2),tout'];
            [~,ib]=ismember(eventTime,paddedTout);



            ib(ib==0)=2;
            rawInfo(:,2)=paddedTout(ib)'-paddedTout(ib-1)';


            allStateIdx=rawInfo(:,3);
            [uniqueStateIdx,~,~]=unique(allStateIdx);



            indices=find(allStateIdx==-1);
            if~isempty(indices)
                obj.UnknownFailure.eventTime=rawInfo(indices,1);
                obj.UnknownFailure.stepSize=rawInfo(indices,2);
                idx=uniqueStateIdx==-1;
                uniqueStateIdx(idx)=[];
            end


            for i=1:length(uniqueStateIdx)

                stateIdx=uniqueStateIdx(i);
                info=rawInfo(allStateIdx==stateIdx,:);


                types=info(:,4);
                info(types==0,:)=[];

                obj.FailureStats(stateIdx).allFailure.eventTime=info(:,1)';
                obj.FailureStats(stateIdx).allFailure.stepSize=info(:,2)';


                indices=find(info(:,4)==1);
                obj.FailureStats(stateIdx).toleranceNotMet.eventTime=info(indices,1)';
                obj.FailureStats(stateIdx).toleranceNotMet.stepSize=info(indices,2)';


                indices=find(info(:,4)==2);
                obj.FailureStats(stateIdx).newtonFailure.eventTime=info(indices,1)';
                obj.FailureStats(stateIdx).newtonFailure.stepSize=info(indices,2)';


                indices=find(info(:,4)==3);
                obj.FailureStats(stateIdx).stateInfinite.eventTime=info(indices,1)';
                obj.FailureStats(stateIdx).stateInfinite.stepSize=info(indices,2)';


                indices=find(info(:,4)==4);
                obj.FailureStats(stateIdx).derivInfinite.eventTime=info(indices,1)';
                obj.FailureStats(stateIdx).derivInfinite.stepSize=info(indices,2)';


                indices=find(info(:,4)==5);
                obj.FailureStats(stateIdx).DAEHminViolation.eventTime=info(indices,1)';
                obj.FailureStats(stateIdx).DAEHminViolation.stepSize=info(indices,2)';
            end

            obj.RankedStateFailureList=obj.getFailureStateIdxLst();
        end


        function delete(obj)
            obj.FailureStats=[];
            obj.RankedStateFailureList=[];
            obj.UnknownFailure=[];
        end


        function list=getFailureStateIdxLst(obj)
            list=[];
            failureCounts=[];
            for i=1:length(obj.FailureStats)
                numFailure=length(obj.FailureStats(i).allFailure.eventTime);
                if numFailure>0
                    list=[list,i];
                    failureCounts=[failureCounts,numFailure];
                end
            end
            [~,order]=sort(failureCounts,'descend');
            list=list(order);
        end

        function list=getRankedFailureStateList(obj)
            list=obj.RankedStateFailureList;
        end


        function value=getTotalFailureNum(obj,type)
            value=length(obj.getTotalFailureTimeVec(type));
        end


        function tVec=getTotalFailureTimeVec(obj,type)
            if isempty(obj.RankedStateFailureList)
                tVec=[];
            else
                switch type
                case 0
                    allFailure=[obj.FailureStats.allFailure];
                case 1
                    allFailure=[obj.FailureStats.toleranceNotMet];
                case 2
                    allFailure=[obj.FailureStats.newtonFailure];
                case 3
                    allFailure=[obj.FailureStats.stateInfinite];
                case 4
                    allFailure=[obj.FailureStats.derivInfinite];
                case 5
                    allFailure=[obj.FailureStats.DAEHminViolation];
                end
                tVec=[allFailure.eventTime];
            end
        end


        function matrix=getTotalFailureMatrix(obj,type)
            if isempty(obj.RankedStateFailureList)
                matrix=[];
            else
                switch type
                case 0
                    allFailure=[obj.FailureStats.allFailure];
                case 1
                    allFailure=[obj.FailureStats.toleranceNotMet];
                case 2
                    allFailure=[obj.FailureStats.newtonFailure];
                case 3
                    allFailure=[obj.FailureStats.stateInfinite];
                case 4
                    allFailure=[obj.FailureStats.derivInfinite];
                case 5
                    allFailure=[obj.FailureStats.DAEHminViolation];
                end
                matrix=[[allFailure.eventTime]',[allFailure.stepSize]'];
            end
        end


        function value=getFailureNumForState(obj,stateIdx,type)
            value=length(obj.getFailureTimeVecForState(stateIdx,type));
        end



        function tVec=getFailureTimeVecForState(obj,stateIdx,type)
            if isempty(obj.RankedStateFailureList)||isempty(obj.FailureStats)
                tVec=[];
            else
                switch type
                case 0
                    allFailure=obj.FailureStats(stateIdx).allFailure;
                case 1
                    allFailure=obj.FailureStats(stateIdx).toleranceNotMet;
                case 2
                    allFailure=obj.FailureStats(stateIdx).newtonFailure;
                case 3
                    allFailure=obj.FailureStats(stateIdx).stateInfinite;
                case 4
                    allFailure=obj.FailureStats(stateIdx).derivInfinite;
                case 5
                    allFailure=obj.FailureStats(stateIdx).DAEHminViolation;
                otherwise
                    allFailure=obj.FailureStats(stateIdx).allFailure;
                end
                tVec=allFailure.eventTime;
            end
        end




        function matrix=getFailureMatrixForState(obj,stateIdx,type)
            if isempty(obj.RankedStateFailureList)||isempty(obj.FailureStats)
                matrix=[];
            else
                switch type
                case 0
                    allFailure=obj.FailureStats(stateIdx).allFailure;
                case 1
                    allFailure=obj.FailureStats(stateIdx).toleranceNotMet;
                case 2
                    allFailure=obj.FailureStats(stateIdx).newtonFailure;
                case 3
                    allFailure=obj.FailureStats(stateIdx).stateInfinite;
                case 4
                    allFailure=obj.FailureStats(stateIdx).derivInfinite;
                case 5
                    allFailure=obj.FailureStats(stateIdx).DAEHminViolation;
                otherwise
                    allFailure=obj.FailureStats(stateIdx).allFailure;
                end
                matrix=[[allFailure.eventTime]',[allFailure.stepSize]'];
            end
        end


        function[stateIdxList,failureCounts]=getFailureTable(obj,timeRange)
            stateIdxList=[];
            failureCounts=[];
            if isempty(obj.RankedStateFailureList)||isempty(obj.FailureStats)
                return;
            end

            for i=1:length(obj.RankedStateFailureList)
                stateIdx=obj.RankedStateFailureList(i);
                allTime=obj.getFailureTimeVecForState(stateIdx,0);
                allTime=allTime(allTime>=timeRange(1)&allTime<=timeRange(2));
                if~isempty(allTime)
                    stateIdxList=[stateIdxList;stateIdx];
                    [numRows,~]=size(failureCounts);
                    failureCounts(numRows+1,1)=length(allTime);

                    allTime=obj.getFailureTimeVecForState(stateIdx,1);
                    allTime=allTime(allTime>=timeRange(1)&allTime<=timeRange(2));
                    failureCounts(numRows+1,2)=length(allTime);

                    allTime=obj.getFailureTimeVecForState(stateIdx,2);
                    allTime=allTime(allTime>=timeRange(1)&allTime<=timeRange(2));
                    failureCounts(numRows+1,3)=length(allTime);

                    allTime=obj.getFailureTimeVecForState(stateIdx,3);
                    allTime=allTime(allTime>=timeRange(1)&allTime<=timeRange(2));
                    failureCounts(numRows+1,4)=length(allTime);

                    allTime=obj.getFailureTimeVecForState(stateIdx,4);
                    allTime=allTime(allTime>=timeRange(1)&allTime<=timeRange(2));
                    failureCounts(numRows+1,5)=length(allTime);

                    allTime=obj.getFailureTimeVecForState(stateIdx,5);
                    allTime=allTime(allTime>=timeRange(1)&allTime<=timeRange(2));
                    failureCounts(numRows+1,6)=length(allTime);
                end
            end
        end


        function list=getStateIdxListWithHmin(obj)
            list=[];
            if isempty(obj.RankedStateFailureList)||isempty(obj.FailureStats)
                return;
            end

            for i=1:length(obj.RankedStateFailureList)
                stateIdx=obj.RankedStateFailureList(i);
                allTime=obj.getFailureTimeVecForState(stateIdx,5);
                if~isempty(allTime)
                    list=[list,stateIdx];
                end
            end
        end



        function info=getSimplifiedFailureInfo(obj)
            eventStruct=struct(...
            't',[],...
            'stateIdx',[],...
            'cause',[]);

            if isempty(obj.RankedStateFailureList)||isempty(obj.FailureStats)
                info=[];
                return;
            end

            numFailure=obj.getTotalFailureNum(0);
            info=repmat(eventStruct,[numFailure,1]);
            count=1;


            for i=1:length(obj.RankedStateFailureList)
                stateIdx=obj.RankedStateFailureList(i);

                allStats=[obj.FailureStats(stateIdx).toleranceNotMet];
                ts=allStats.eventTime;
                if~isempty(ts)
                    for j=1:length(ts)
                        info(count).t=ts(j);
                        info(count).stateIdx=stateIdx;
                        info(count).cause='Error Control';
                        count=count+1;
                    end
                end

                allStats=[obj.FailureStats(stateIdx).newtonFailure];
                ts=allStats.eventTime;
                if~isempty(ts)
                    for j=1:length(ts)
                        info(count).t=ts(j);
                        info(count).stateIdx=stateIdx;
                        info(count).cause='Newton Iteration';
                        count=count+1;
                    end
                end

                allStats=[obj.FailureStats(stateIdx).stateInfinite];
                ts=allStats.eventTime;
                if~isempty(ts)
                    for j=1:length(ts)
                        info(count).t=ts(j);
                        info(count).stateIdx=stateIdx;
                        info(count).cause='Infinite State';
                        count=count+1;
                    end
                end

                allStats=[obj.FailureStats(stateIdx).derivInfinite];
                ts=allStats.eventTime;
                if~isempty(ts)
                    for j=1:length(ts)
                        info(count).t=ts(j);
                        info(count).stateIdx=stateIdx;
                        info(count).cause='Infinite Derivative';
                        count=count+1;
                    end
                end

                allStats=[obj.FailureStats(stateIdx).DAEHminViolation];
                ts=allStats.eventTime;
                if~isempty(ts)
                    for j=1:length(ts)
                        info(count).t=ts(j);
                        info(count).stateIdx=stateIdx;
                        info(count).cause='DAE';
                        count=count+1;
                    end
                end
            end

            tVec=[info.t];
            [~,order]=sort(tVec);
            info=info(order);
        end

    end


    methods(Static)

        function failureType=determineCause(cause)
            if~isempty(regexp(cause,'error estimate exceeds tolerance|does not satisfy error tolerance','once'))
                failureType=1;
            elseif~isempty(regexp(cause,'DAE Newton iteration failed|Newton iteration failed to converge','once'))
                failureType=2;
            elseif~isempty(regexp(cause,'Newton iteration failed|Newton iteration failed to converge','once'))
                failureType=2;
            elseif~isempty(regexp(cause,'DerivNotFinite|Derivative of state','once'))
                failureType=4;
            elseif~isempty(regexp(cause,'StateNotFinite| is non finite','once'))
                failureType=3;
            elseif~isempty(regexp(cause,'NewtonIterationFailureForDAE|DAE Error estimate exceed tolerance at minimum step size','once'))
                failureType=5;
            else
                failureType=0;
            end
        end





        function[srcIdx,localIdx]=getSrcIdx(pd,stateIdx)
            srcIdx=0;
            localIdx=0;

            if(stateIdx)
                startIdxLst=[pd.odeInfo.stateInfo.source.startIndex];
                inds=find(startIdxLst<=stateIdx);
                srcIdx=inds(end);


                if(pd.odeInfo.stateInfo.source(srcIdx).width>1)
                    localIdx=stateIdx-...
                    pd.odeInfo.stateInfo.source(srcIdx).startIndex+1;
                end
            end
        end

    end


end