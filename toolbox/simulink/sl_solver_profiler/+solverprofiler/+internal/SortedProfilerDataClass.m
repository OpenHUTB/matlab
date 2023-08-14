classdef SortedProfilerDataClass<handle

    properties(SetAccess=private)

















Model
Overview
ProfileTime
Xout
Tout
ZcInfo
FailureInfo
JacobianInfo
SscStiffInfo
Simlog
ResetInfo
MetaData
CompiledInfo
BlockStateStats
fszcInfo
    end

    methods


        function SortedPD=SortedProfilerDataClass
            import solverprofiler.internal.StreamedStatesClass;
            import solverprofiler.internal.ResetInfoClass;
            import solverprofiler.internal.JacobianInfoClass;
            import solverprofiler.internal.ZcInfoClass;
            import solverprofiler.internal.FailureInfoClass;

            SortedPD.Model=[];
            SortedPD.ProfileTime=0;
            SortedPD.Xout=StreamedStatesClass();
            SortedPD.Tout=[];
            SortedPD.Simlog=[];
            SortedPD.MetaData=[];
            SortedPD.FailureInfo=FailureInfoClass([],[],[]);
            SortedPD.JacobianInfo=JacobianInfoClass([]);
            SortedPD.SscStiffInfo=[];
            SortedPD.ZcInfo=ZcInfoClass([],[],[]);
            SortedPD.ResetInfo=ResetInfoClass();
            SortedPD.Overview=[];
            SortedPD.CompiledInfo=struct('hMax',[]);
            SortedPD.BlockStateStats=[];
            SortedPD.fszcInfo=[];
        end


        function delete(obj)
            if~isempty(obj.Xout)&&isvalid(obj.Xout)
                delete(obj.Xout);
            end
            if~isempty(obj.ZcInfo)&&isvalid(obj.ZcInfo)
                delete(obj.ZcInfo);
            end
            if~isempty(obj.FailureInfo)&&isvalid(obj.FailureInfo)
                delete(obj.FailureInfo);
            end
            if~isempty(obj.JacobianInfo)&&isvalid(obj.JacobianInfo)
                delete(obj.JacobianInfo);
            end
            if~isempty(obj.Overview)&&isvalid(obj.Overview)
                delete(obj.Overview);
            end
            if~isempty(obj.BlockStateStats)&&isvalid(obj.BlockStateStats)
                delete(obj.BlockStateStats);
            end
        end


        function initializeWithData(obj,mdl,tout,pd,simlog,metaData,profileTime)
            import solverprofiler.util.*
            import solverprofiler.internal.StreamedStatesClass;
            import solverprofiler.internal.ResetInfoClass;
            import solverprofiler.internal.BlockStateStatsClass;
            import solverprofiler.internal.JacobianInfoClass;
            import solverprofiler.internal.ZcInfoClass;
            import solverprofiler.internal.FailureInfoClass;

            obj.Model=mdl;
            obj.ProfileTime=profileTime;
            obj.BlockStateStats=BlockStateStatsClass(pd);







            if isempty(pd)
                obj.Tout=tout;
                obj.FailureInfo=FailureInfoClass([],[],[]);
                obj.JacobianInfo=JacobianInfoClass([]);
                obj.SscStiffInfo=[];
                obj.ZcInfo=ZcInfoClass([],[],[]);
                obj.Overview=[];
            else



                if(strcmpi(get_param(obj.Model,'EnableFixedStepZeroCrossing'),'on')&&...
                    strcmpi(get_param(obj.Model,'SolverType'),'Fixed-step')&&...
                    ~isempty(pd.zcInfo))
                    obj.getMajorTimeStepsForFSZC(pd,metaData);
                    if~isempty(obj.fszcInfo)
                        obj.Tout=obj.fszcInfo.majorTimes;
                    end
                else
                    obj.Tout=pd.majorTimes;
                end

            end
            obj.Simlog=simlog;
            obj.Xout=StreamedStatesClass(obj.BlockStateStats);


            list=obj.ResetInfo.getDiscDriContblkList();
            obj.ResetInfo=ResetInfoClass();
            obj.ResetInfo.setDiscDriContblkList(list);
            if~isempty(pd)
                obj.ResetInfo.setResetTime(pd.resetTimes);
            end

            obj.MetaData=metaData;

            obj.CompiledInfo.hMax=utilGetScalarValue(get_param(mdl,'CompiledStepSize'));
        end





        function move(SortedPD,rhs)
            assert(isa(rhs,'solverprofiler.internal.SortedProfilerDataClass'));
            memebers=fieldnames(SortedPD);
            for i=1:length(memebers)
                SortedPD.(memebers{i})=rhs.(memebers{i});
            end
            rhs.Xout=[];
            rhs.ZcInfo=[];
            rhs.FailureInfo=[];
            rhs.JacobianInfo=[];
            rhs.ResetInfo=[];
            rhs.Overview=[];
            rhs.BlockStateStats=[];
        end





        function fillStateValue(SortedPD,arg)
            import solverprofiler.util.*
            if isempty(arg),return;end

            SortedPD.attachStateData(arg);
            SortedPD.Xout.skipTimePointsForDerivEstiamtion(SortedPD.getTimeToAvoid());
        end


        function setStateRange(SortedPD,value)
            SortedPD.Xout.setStateRange(value);
        end



        function timeToAvoid=getTimeToAvoid(SortedPD)
            zcMatrix=SortedPD.getAllZCEvents();
            resetTime=SortedPD.ResetInfo.getTotalResetTimeVec(0);
            if~isempty(zcMatrix)
                timeToAvoid=unique([zcMatrix(:,1);resetTime']);
            else
                timeToAvoid=unique(resetTime);
            end
        end




        function fillZeroCrossingInfo(SortedPD,pd)
            import solverprofiler.internal.ZcInfoClass;
            SortedPD.ZcInfo=ZcInfoClass(pd,SortedPD.BlockStateStats,SortedPD.fszcInfo);
        end


        function fillResetInfo(SortedPD,pd)
            SortedPD.ResetInfo.populateResetInfo(SortedPD.Tout,pd,SortedPD.Model,SortedPD.BlockStateStats);
        end


        function fillFailureInfo(SortedPD,pd)
            import solverprofiler.internal.FailureInfoClass;
            SortedPD.FailureInfo=FailureInfoClass(SortedPD.Tout,pd,SortedPD.BlockStateStats);
        end


        function analyzeModelJacobian(SortedPD,pd)
            import solverprofiler.internal.JacobianInfoClass;
            SortedPD.JacobianInfo=JacobianInfoClass(pd);
        end


        function setSimscapeStiff(SortedPD,data)
            SortedPD.SscStiffInfo=[];

            if~isempty(data)
                n=length(data);
                hasData=false(n,1);

                for i=1:n
                    hasData(i)=data(i).stiffness~=0;
                end
                SortedPD.SscStiffInfo=data(hasData);
            end
        end


        function getOverview(SortedPD)
            import solverprofiler.internal.OverviewClass;
            SortedPD.Overview=OverviewClass(SortedPD);
        end


        function simplifiedOverview=getSimplifiedOverview(SortedPD)
            simplifiedOverview=SortedPD.Overview.getSimplifiedOverview();
        end


        function value=getData(SortedPD,dataName)
            value=SortedPD.(dataName);
        end

        function value=getTotalResetNum(SortedPD,type)
            value=length(SortedPD.ResetInfo.getTotalResetTimeVec(type));
        end

        function setSimlog(SortedPD,value)
            SortedPD.Simlog=value;
        end

        function setDiscDriContblkList(SortedPD,value)
            SortedPD.ResetInfo.setDiscDriContblkList(value);
        end

        function list=getBlockListWithZcEvents(SortedPD)
            list=SortedPD.ZcInfo.getRankedBlockZcList();
        end

        function hmax=getHmax(SortedPD)
            hmax=SortedPD.CompiledInfo.hMax;
        end

        function tStop=getTStop(SortedPD)
            tStop=SortedPD.Tout(end);
        end

        function hmaxRatio=getHmaxRatio(SortedPD)
            dt=diff(SortedPD.Tout);
            hmax=SortedPD.getHmax();
            hmaxdt=dt(abs(dt-hmax)<hmax/1000);
            hmaxRatio=length(hmaxdt)*100/length(dt);
        end


        function stateList=getRankedFailureStateList(SortedPD)
            stateList=SortedPD.FailureInfo.getRankedFailureStateList();
        end


        function blockList=getRankedResetBlockList(SortedPD)
            blockList=SortedPD.ResetInfo.getRankedResetBlockList();
        end


        function tableContent=getStatisticsTableContent(SortedPD)
            tableContent=SortedPD.Overview.getOverviewTableContent();
        end

        function[tableContent,stateIdxList]=updateJacobianTableContent(SortedPD,range)
            [stateIdxList,counts]=SortedPD.JacobianInfo.getJacobianTable(range);
            if isempty(stateIdxList)
                tableContent=[];
            else
                tableContent=cell(length(stateIdxList),2);
                for i=1:length(stateIdxList)
                    tableContent{i,1}=counts(i);
                    tableContent{i,2}=SortedPD.BlockStateStats.getStateName(stateIdxList(i));
                end
            end
        end

        function tableContent=getSscStiffTableContent(SortedPD)
            tableContent=[];

            if~isempty(SortedPD.SscStiffInfo)
                n=length(SortedPD.SscStiffInfo);
                tableContent=cell(n,2);

                for i=1:n
                    stiff=sprintf('%8.5e',SortedPD.SscStiffInfo(i).stiffness);
                    stime=sprintf('%22.16e',SortedPD.SscStiffInfo(i).time);
                    tableContent{i,1}=stime;
                    tableContent{i,2}=stiff;
                    tableContent{i,3}=SortedPD.SscStiffInfo(i).variable;
                end
            end
        end


        function blockName=getBlockNameFromSscStiffData(SortedPD,idx)
            blockName=[];
            if~isempty(idx)&&idx<=length(SortedPD.SscStiffInfo)
                blockName=SortedPD.SscStiffInfo(idx).block;
            end
        end


        function fileInfo=getFileInfoFromSscStiffData(SortedPD,idx)
            fileInfo=[];
            if~isempty(idx)&&idx<=length(SortedPD.SscStiffInfo)&&SortedPD.SscStiffInfo(idx).line>0
                fileInfo={SortedPD.SscStiffInfo(idx).location,SortedPD.SscStiffInfo(idx).line};
            end
        end


        function[tableContent,blockIdxList]=updateZeroCrossingTableContent(SortedPD,range)
            [blockIdxList,zcCounts]=SortedPD.ZcInfo.getZcTable(range);
            if isempty(blockIdxList)
                blockIdxList=[];
                tableContent=[];
                return;
            end


            tableContent=cell(length(blockIdxList),2);
            for i=1:length(blockIdxList)
                blockIdx=blockIdxList(i);
                tableContent{i,1}=zcCounts(i);
                tableContent{i,2}=SortedPD.BlockStateStats.getBlockName(blockIdx);
            end
        end


        function[tableContent,stateIdxList]=updateExceptionTableContent(SortedPD,range,type)
            [stateIdxList,failureCounts]=SortedPD.FailureInfo.getFailureTable(range);


            if isempty(stateIdxList)
                tableContent=[];
                return;
            end

            tableContent=cell(length(stateIdxList),7);
            for i=1:length(stateIdxList)
                stateIdx=stateIdxList(i);
                tableContent{i,7}=SortedPD.BlockStateStats.getStateName(stateIdx);
                for j=1:6
                    tableContent{i,j}=failureCounts(i,j);
                end
            end

            if type==7
                [tableContent,order]=sortrows(tableContent,type);
            else
                [tableContent,order]=sortrows(tableContent,-type);
            end
            stateIdxList=stateIdxList(order);
        end


        function[tableContent,blockIdxList]=getResetTableContent(SortedPD,range)
            [blockIdxList,resetCounts]=SortedPD.ResetInfo.getResetTable(range);


            if isempty(blockIdxList)
                tableContent=[];
                return;
            end

            tableContent=cell(length(blockIdxList),2);
            for i=1:length(blockIdxList)
                blockIdx=blockIdxList(i);
                if blockIdx==-1
                    tableContent{i,8}=SortedPD.Model;
                else
                    tableContent{i,8}=SortedPD.BlockStateStats.getBlockName(blockIdx);
                end
                tableContent{i,1}=resetCounts(i,1);
                tableContent{i,2}=resetCounts(i,2);
                tableContent{i,3}=resetCounts(i,3);
                tableContent{i,4}=resetCounts(i,4);
                tableContent{i,5}=resetCounts(i,5);
                tableContent{i,6}=resetCounts(i,6);
                tableContent{i,7}=resetCounts(i,7);
            end
        end



        function[tableContent,stateIdxList]=getInaccurateStateTableContent(SortedPD)
            aTolValue=SortedPD.Overview.getAbsoluteTolerance();
            if(isnumeric(aTolValue))
                [minMaxValue,stateIdxList]=SortedPD.Xout.getInaccurateStateStats(aTolValue);
                tableContent=cell(length(stateIdxList),4);
                for i=1:length(stateIdxList)
                    stateIdx=stateIdxList(i);
                    tableContent{i,1}=minMaxValue(i,1);
                    tableContent{i,2}=minMaxValue(i,2);
                    tableContent{i,3}=aTolValue;
                    tableContent{i,4}=SortedPD.BlockStateStats.getStateName(stateIdx);
                end
            else
                tableContent={};
                stateIdxList=[];
            end
        end




        function zcMatrix=getZCEventsFromSelectedBlock(SortedPD,blockIdx)
            zcMatrix=SortedPD.ZcInfo.getZcMatrixForBlock(blockIdx);
        end


        function zcMatrix=getAllZCEvents(SortedPD)
            zcMatrix=SortedPD.ZcInfo.getTotalZcMatrix();
        end



        function exceptionMatrix=getFailureMatrixForState(SortedPD,stateIdx,type)
            exceptionMatrix=SortedPD.FailureInfo.getFailureMatrixForState(stateIdx,type);
        end

        function exceptionMatrix=getTotalFailureMatrix(SortedPD,type)
            exceptionMatrix=SortedPD.FailureInfo.getTotalFailureMatrix(type);
        end



        function resetMatrix=getResetMatrixForSource(SortedPD,blockIdx,type)
            resetMatrix=SortedPD.ResetInfo.getResetMatrixForSource(blockIdx,type);
        end

        function resetMatrix=getTotalResetMatrix(SortedPD,type)
            resetMatrix=SortedPD.ResetInfo.getTotalResetMatrix(type);
        end



        function nodeName=getSimscapeNodeNameForBlock(SortedPD,blockName)
            nodeName=SortedPD.BlockStateStats.getSSCName(blockName);
        end


        function blockName=getBlockNameFromBlockIdx(SortedPD,blockIdx)
            blockName=SortedPD.BlockStateStats.getBlockName(blockIdx);
        end


        function blockName=getBlockNameFromStateIdx(SortedPD,stateIdx)
            blockName=SortedPD.BlockStateStats.getBlockNameFromStateIdx(stateIdx);
        end



        function customPD=getSimplifiedPD(SortedPD)

            statesInfoStruct=struct(...
            'name',[],...
            'time',[],...
            'blockIdx',[],...
            'value',[]);

            blockInfoStruct=struct(...
            'name',[],...
            'stateIdx',[]);

            zcSignalInfoStruct=struct(...
            'name',[],...
            'blockIdx',[]);

            zcEventsStruct=struct(...
            't',[],...
            'srcIdx',[]);

            exceptionEventsStruct=struct(...
            't',[],...
            'statesIdx',[],...
            'cause',[]);

            customPD=struct(...
            'stateInfo',statesInfoStruct,...
            'blockInfo',blockInfoStruct,...
            'zcSigInfo',zcSignalInfoStruct,...
            'zcEvents',zcEventsStruct,...
            'exceptionEvents',exceptionEventsStruct,...
            'resetTime',SortedPD.ResetInfo.getTotalResetTimeVec(0),...
            'tout',SortedPD.Tout);

            for i=1:length(SortedPD.BlockStateStats.getNumberOfStates())
                customPD.stateInfo(i).name=SortedPD.BlockStateStats.getStateName(i);
                customPD.stateInfo(i).blockIdx=SortedPD.BlockStateStats.getBlockIdxFromStateIdx(i);
                [customPD.stateInfo(i).time,customPD.stateInfo(i).value]=SortedPD.Xout.getStateValue(i);
            end
            customPD.exceptionEvents=SortedPD.FailureInfo.getSimplifiedFailureInfo();

            for i=1:length(SortedPD.BlockStateStats.getNumberOfBlocks())
                customPD.blockInfo(i).name=SortedPD.BlockStateStats.getBlockName(i);
                customPD.blockInfo(i).stateIdx=SortedPD.BlockStateStats.getStateIdxFromBlockIdx(i);
            end
            [customPD.zcSigInfo,customPD.zcEvents]=SortedPD.getSimplifiedZcInfo();
        end


        function status=isDataReady(SortedPD)
            status=~isempty(SortedPD.Overview);
        end

        function flag=zcEventsDetected(SortedPD)
            flag=SortedPD.ZcInfo.zcEventsDetected();
        end

        function[zcSrcInfo,zcEvents]=getSimplifiedZcInfo(SortedPD)
            [zcSrcInfo,zcEvents]=SortedPD.ZcInfo.getSimplifiedZcInfo();
        end

        function getMajorTimeStepsForFSZC(SortedPD,rawPD,metaData)






            zcTimes=[rawPD.zcInfo.eventInfo.tR0];
            fixedStepSize=metaData.ModelInfo.SolverInfo.FixedStepSize;
            expMajor=metaData.ModelInfo.StartTime:fixedStepSize:metaData.ModelInfo.StopTime;







            absTol=128*eps(eps);
            relTolFactor=128*eps;
            zcTimesAtMajor=[];
            maxBracketingIterations=get_param(SortedPD.Model,'MaxZcBracketingIterations');
            for k=1:length(zcTimes)
                [diffFromMajorTimeStep,idx]=min(abs(zcTimes(k)-expMajor));
                relTol=relTolFactor*expMajor(idx);
                timeTolerance=max(absTol,relTol)/(2*maxBracketingIterations);
                if diffFromMajorTimeStep<timeTolerance
                    zcTimesAtMajor=[zcTimesAtMajor,zcTimes(k)];%#ok
                end
            end
            zcTimesAtMinor=setdiff(zcTimes,zcTimesAtMajor);


            majorTimeSteps=setdiff(rawPD.majorTimes,zcTimesAtMinor);

            SortedPD.fszcInfo=struct(...
            'majorTimes',majorTimeSteps,...
            'zcTimesAtMinor',zcTimesAtMinor,...
            'zcTimeAtMajor',zcTimesAtMajor);
        end

        function jacobianTime=getJacobianUpdateTime(SortedPD)
            jacobianTime=SortedPD.JacobianInfo.getJacobianTimes();
        end

        function sigName=getSignalNameFromSigIdx(SortedPD,sigIdx)
            sigName=SortedPD.ZcInfo.getSignalNameFromSigIdx(sigIdx);
        end

        function[time,value]=getZCEvents(SortedPD,sigIdx)
            [time,value]=SortedPD.ZcInfo.getEvents(sigIdx);
        end

        function deleteStreamedStateFile(SortedPD)
            SortedPD.Xout.deleteStreamedStateFile();
        end

        function flag=hasZCValue(obj)
            flag=obj.ZcInfo.hasZCValue();
        end

        function isValid=isStateObjectValid(SortedPD)
            isValid=SortedPD.Xout.isStateObjectValid();
        end

        function flag=isStateStreamed(SortedPD)
            flag=SortedPD.Xout.isStreamed();
        end

        function attachStateData(SortedPD,xout)
            SortedPD.Xout.attachData(xout,SortedPD.Tout);
        end

        function copyFileToLocation(SortedPD,destination)
            SortedPD.Xout.copyFileToLocation(destination);
        end

    end

end
