classdef StatesExplorerDataClass<handle
    properties(SetAccess=private)
Model
Tout
Xout
FailureInfo
BlockStateStats
RankedStateIdx
StateScore
StateSelected
TLeft
TRight
HiliteTraceBlock
HUITableCallback
Mode
CustomAlg
    end

    methods


        function SEData=StatesExplorerDataClass(mdl,tout,xout,...
            failureInfo,stats,tSpan,customAlg)
            SEData.Model=mdl;
            SEData.Tout=tout;
            SEData.Xout=xout;
            SEData.FailureInfo=failureInfo;
            SEData.BlockStateStats=stats;
            SEData.RankedStateIdx=[];
            SEData.StateScore=[];
            SEData.StateSelected=1;
            SEData.TLeft=tSpan(1);
            SEData.TRight=tSpan(2);
            SEData.HiliteTraceBlock=[];
            SEData.HUITableCallback=[];
            SEData.Mode='derivative';
            SEData.CustomAlg=customAlg;
        end


        function delete(~)



        end


        function customSD=getCustomStatesData(obj)
            statesInfoStruct=struct(...
            'name',[],...
            'time',[],...
            'value',[]);

            exceptionEventsStruct=struct(...
            't',[],...
            'statesIdx',[],...
            'cause',[]);

            customSD=struct(...
            'stateInfo',statesInfoStruct,...
            'exceptionEvents',exceptionEventsStruct,...
            'tout',obj.Tout);

            for i=1:length(obj.BlockStateStats.getNumberOfStates())
                customSD.stateInfo(i).name=obj.BlockStateStats.getStateName(i);
                customSD.stateInfo(i).blockIdx=obj.BlockStateStats.getBlockIdxFromStateIdx(i);
                [customSD.stateInfo(i).time,customSD.stateInfo(i).value]=obj.Xout.getStateValue(i);
            end
            customSD.exceptionEvents=obj.FailureInfo.getSimplifiedFailureInfo();
        end


        function addAlg(SEData,path,file)
            if isempty(SEData.CustomAlg)
                num=1;
            else
                num=length(SEData.CustomAlg(:,1))+1;
            end
            SEData.CustomAlg{num,1}=path;
            SEData.CustomAlg{num,2}=file;
        end


        function removeAlg(SEData,indices)
            SEData.CustomAlg(indices,:)=[];
        end


        function resetData(SEData,tout,xout,failureInfo,stats,tSpan)
            SEData.Tout=tout;
            SEData.Xout=xout;
            SEData.FailureInfo=failureInfo;
            SEData.BlockStateStats=stats;
            SEData.TLeft=tSpan(1);
            SEData.TRight=tSpan(2);
        end


        function cacheUITableCallback(obj,handle)
            obj.HUITableCallback=handle;
        end


        function value=getData(obj,name)
            value=obj.(name);
        end


        function setData(obj,name,value)
            obj.(name)=value;
        end


        function value=isStreamed(SEData)
            value=SEData.Xout.isStreamed();
        end


        function stateIdx=getStateIdx(SEData)
            stateIdx=SEData.RankedStateIdx(SEData.StateSelected);
        end



        function index=getIndexInRankedStateIndexList(SEData,stateIdx)
            index=find(SEData.RankedStateIdx==stateIdx,1);
        end



        function blockName=getBlockNameOfSelectedState(SEData)
            stateIdx=SEData.RankedStateIdx(SEData.StateSelected);
            blockName=SEData.BlockStateStats.getBlockNameFromStateIdx(stateIdx);
        end


        function sortStates(obj)
            obj.StateScore=zeros(obj.BlockStateStats.getNumberOfStates(),1);


            if obj.TLeft<obj.Tout(1)
                obj.TLeft=obj.Tout(1);
            end
            if obj.TRight>obj.Tout(end)
                obj.TRight=obj.Tout(end);
            end

            if strcmp(obj.Mode,'state')
                [stateIdxLst,obj.StateScore]=obj.Xout.getScoresBasedOnStatesValue(...
                obj.TLeft,obj.TRight);

            elseif strcmp(obj.Mode,'derivative')||strcmp(obj.Mode,'chatter')
                [stateIdxLst,obj.StateScore]=obj.Xout.getScoreBasedOnStateDeriv(...
                obj.TLeft,obj.TRight,obj.Mode);

            elseif strcmp(obj.Mode,'newton')

                stateIdxLst=obj.Xout.getStateIndexList();
                for i=1:length(stateIdxLst)
                    stateIdx=stateIdxLst(i);
                    tVec=obj.getStateNewtonDAEExceptionTime(stateIdx);
                    indices=find(tVec>=obj.TLeft&tVec<=obj.TRight);
                    obj.StateScore(i)=length(indices);
                end

            elseif strcmp(obj.Mode,'error')

                stateIdxLst=obj.Xout.getStateIndexList();
                for i=1:length(stateIdxLst)
                    stateIdx=stateIdxLst(i);
                    tVec=obj.getStateErrorControlExceptionTime(stateIdx);
                    indices=find(tVec>obj.TLeft&tVec<obj.TRight);
                    obj.StateScore(i)=length(indices);
                end
            else
                stateIdxLst=obj.Xout.getStateIndexList();
                allStateNameList=obj.BlockStateStats.getStateNameList(stateIdxLst);
                [~,order]=sort(allStateNameList);
                obj.RankedStateIdx=stateIdxLst(order);
                obj.StateScore=[];
            end


            if~isempty(obj.StateScore)
                [obj.StateScore,order]=sort(obj.StateScore,'descend');
                obj.RankedStateIdx=stateIdxLst(order);
            end
        end


        function tableContent=createTableContent(SEData)
            tableContent=cell(length(SEData.RankedStateIdx),2);


            if strcmp(SEData.Mode,'newton')||strcmp(SEData.Mode,'error')
                for i=1:length(SEData.RankedStateIdx)
                    tableContent{i,1}=int32(SEData.StateScore(i));
                end
            elseif strcmp(SEData.Mode,'path')
                for i=1:length(SEData.RankedStateIdx)
                    tableContent{i,1}=int32(i);
                end
            else
                for i=1:length(SEData.RankedStateIdx)
                    tableContent{i,1}=SEData.StateScore(i);
                end
            end

            for i=1:length(SEData.RankedStateIdx)
                tableContent{i,2}=SEData.BlockStateStats.getStateName(SEData.RankedStateIdx(i));
            end
        end


        function tableContent=getCustomRankTableContent(SEData)
            if isempty(SEData.CustomAlg)||isempty(SEData.CustomAlg(:,1))
                tableContent={};
            else
                numAlg=length(SEData.CustomAlg(:,1));
                tableContent=cell(numAlg,2);
                for i=1:numAlg
                    tableContent{i,1}=false;
                    tableContent{i,2}=SEData.CustomAlg{i,2};
                end
            end
        end

        function[stateValTime,stateValue,stateDerivTime,stateDerivValue]=...
            getStateAndDerivValueForPlot(obj,stateIdx)
            [stateValTime,stateValue]=obj.Xout.getStateValue(stateIdx);
            [stateDerivTime,stateDerivValue]=obj.Xout.estimateStateDeriv(stateIdx);
        end

        function stateName=getStateNameFromIdx(obj,stateIdx)
            stateName=obj.BlockStateStats.getStateName(stateIdx);
        end

        function timeVec=getStateNewtonDAEExceptionTime(obj,stateIdx)
            failureType=2;
            timeVec=obj.FailureInfo.getFailureTimeVecForState(stateIdx,failureType);
            failureType=5;
            timeVec=[timeVec,obj.FailureInfo.getFailureTimeVecForState(stateIdx,failureType)];
            timeVec=sort(timeVec);
        end

        function timeVec=getStateErrorControlExceptionTime(obj,stateIdx)
            failureType=1;
            timeVec=obj.FailureInfo.getFailureTimeVecForState(stateIdx,failureType);
        end

        function isValid=isStateObjectValid(SEData)
            isValid=SEData.Xout.isStateObjectValid();
        end

        function isStreamed=isStateStreamed(SEData)
            isStreamed=SEData.Xout.isStreamed();
        end

    end

end