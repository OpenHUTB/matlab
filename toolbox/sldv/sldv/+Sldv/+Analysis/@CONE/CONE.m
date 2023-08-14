




classdef CONE<Sldv.Analysis.Strategy
    properties
        mDvoAnalyzer=[];
        mTestComp=[];
        mStrategyObj=[];
    end
    properties
        mLoggerId='sldv::task_manager';
    end

    methods(Access=public)
        function init(obj)
            [sldvObjectivesData,...
            objectiveIdToGoalMap,...
            goalIdToObjectiveIdMap]=obj.mDvoAnalyzer.getStaticSldvData();





            proximityAtBackend=(slavteng('feature','ProximityTableCal')~=0);
            if proximityAtBackend
                logStr=sprintf('CONE: Disabling CONEWithProximity irrespective of model as ProximityTableCal FF is not 0');
                sldvprivate('SLDV_LOG_DEBUG',obj.mLoggerId,logStr);
            end
            isProximityEnabled=~proximityAtBackend&&obj.canRunProximity(sldvObjectivesData);

            testComp=obj.mTestComp;
            if isProximityEnabled
                obj.mStrategyObj=Sldv.Analysis.CONEWithProximity(...
                obj.mDvoAnalyzer,testComp);
                obj.mStrategyObj.init(sldvObjectivesData,...
                objectiveIdToGoalMap,...
                goalIdToObjectiveIdMap);
                sldvprivate('SLDV_LOG_DEBUG',obj.mLoggerId,...
                'Analysis::CONE - Analyzing with Proximity Enabled');
            else

                obj.mStrategyObj=Sldv.Analysis.SimpleStrategy(...
                obj.mDvoAnalyzer,testComp);
                obj.mStrategyObj.init();
                sldvprivate('SLDV_LOG_DEBUG',obj.mLoggerId,...
                'Analysis::CONE - Analyzing without Proximity');

            end
        end

        function strategyState=solveNext(obj)
            obj.mState=obj.mStrategyObj.solveNext();
            strategyState=obj.mState;
            return;
        end

        function strategyState=finishAsyncSolver(obj)
            obj.mState=obj.mStrategyObj.finishAsyncSolver();
            strategyState=obj.mState;
            return;
        end

        function terminate(obj,cause)
            if~isempty(obj.mStrategyObj)
                obj.mStrategyObj.terminate(cause);
            end
            obj.mState=Sldv.Analysis.StrategyState.Terminated;
            return;
        end
    end

    methods(Access=public)

        function obj=CONE(dvoAnalyzer,testComp)
            obj=obj@Sldv.Analysis.Strategy();
            obj.mDvoAnalyzer=dvoAnalyzer;
            obj.mTestComp=testComp;
        end

        function delete(~)
        end
    end
    methods(Access=private)
        function status=canRunProximity(obj,sldvData)
            status=true;
            if~isfield(sldvData,'Objectives')||isempty(sldvData.Objectives)
                status=false;
                return;
            end
            if slavteng('feature','CONEWithProximity')==2
                status=true;
                return;
            end

            if length(sldvData.Objectives)>700
                status=false;
                return;
            end




            inportInfo=sldvData.AnalysisInformation.InputPortInfo;
            numInports=length(sldvData.AnalysisInformation.InputPortInfo);
            for portIdx=1:numInports


                if iscell(inportInfo{portIdx})&&...
                    isfield(inportInfo{portIdx}{1},'Dimensions')&&...
                    any(inportInfo{portIdx}{1}.Dimensions~=1)
                    status=false;
                    return;
                end
            end
            transMObjFlags=strcmp({sldvData.ModelObjects.sfObjType},...
            'Transition');
            if isempty(transMObjFlags)
                status=false;
                return;
            end
            transMObjs=sldvData.ModelObjects(transMObjFlags);
            if~any(contains({transMObjs.descr},'after('))
                status=false;
                return;
            end
        end
    end

end


