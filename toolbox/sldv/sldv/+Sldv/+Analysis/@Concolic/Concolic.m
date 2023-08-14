classdef Concolic<Sldv.Analysis.Strategy



    properties
        mDvoAnalyzer=[];
        mTestComp=[];
        mSldvObjectivesData=[];
        mEnabledGoals=[];
    end
    properties

        toBeProcessedTestCases=[];
        mGoalIdToObjectiveIdMap=[];
        processedTestCases=[];
        mOutputDir='';
    end

    methods(Access=public)

        function init(obj,dataStruct)
            if nargin==2
                obj.mSldvObjectivesData=dataStruct.sldvData;
                obj.mGoalIdToObjectiveIdMap=dataStruct.goalIdToObjectiveIdMap;
                obj.processedTestCases=dataStruct.processedTestCases;
            else
                obj.mSldvObjectivesData=[];
            end
        end

        function strategyState=solveNext(obj)
            analysisOptions=obj.getOptionsForConcolic();
            obj.mDvoAnalyzer.setAnalysisOptions(analysisOptions);
            try
                LoggerId='sldv::task_manager';
                sldvprivate('SLDV_LOG_DEBUG',LoggerId,'Analysis::Concolic - Starting async analysis');

                analysisInput=[];
                analysisInput.goals=obj.mEnabledGoals;

                [status,msg]=obj.mDvoAnalyzer.runAnalysisAsync(analysisInput);
                sldvprivate('SLDV_LOG_DEBUG',LoggerId,'Analysis::Concolic - Async analysis started');
            catch MEx
                obj.mState=Sldv.Analysis.StrategyState.Failed;
                if~isvalid(obj)
                    MEx=MException('Sldv:AnalysisStrategy:invalidObj',...
                    'SLDV AnalysisStrategy is no longer valid');
                    throw(MEx);
                end
            end

            if~status
                obj.mTestComp.setInternalStrategy('');
                obj.mState=Sldv.Analysis.StrategyState.Failed;
            else
                obj.mState=Sldv.Analysis.StrategyState.AsyncRunning;
            end
            strategyState=obj.mState;

            return;
        end

        function strategyState=finishAsyncSolver(obj)
            testComp=obj.mTestComp;

            testComp.setInternalStrategy('');
            LoggerId='sldv::task_manager';
            sldvprivate('SLDV_LOG_DEBUG',LoggerId,'Analysis::Concolic - Finishing async analysis');
            obj.mDvoAnalyzer.finishAnalysis();
            sldvprivate('SLDV_LOG_DEBUG',LoggerId,'Analysis::Concolic - Async analysis finished');
            if isempty(obj.toBeProcessedTestCases)
                allTestCases=sldvprivate('sldv_datamodel_get_testcases',testComp);
                obj.toBeProcessedTestCases=allTestCases(obj.processedTestCases+1:end);
            end
            obj.mState=Sldv.Analysis.StrategyState.Done;
            strategyState=obj.mState;
            if obj.mState==Sldv.Analysis.StrategyState.Done
                obj.clearArtifacts();
            end
        end


        function incrementalResults=getResults(obj)
            incrementalResults.data=[];
            incrementalResults.objIndices=[];
            if~isempty(obj.mGoalIdToObjectiveIdMap)
                modelH=obj.mTestComp.analysisInfo.analyzedModelH;
                objectives=obj.mSldvObjectivesData.Objectives;

                [testCases,objectives]=Sldv.DataUtils.convertTestCasesToSldvDataFormat(...
                obj.toBeProcessedTestCases,modelH,...
                obj.mTestComp,objectives,...
                obj.mGoalIdToObjectiveIdMap);
                if~isempty(testCases)
                    modifiedObjs=[testCases.objectives];
                    modifiedObjIndices=[modifiedObjs.objectiveIdx];
                    dataStruct.TestCases=testCases;
                    dataStruct.Objectives=objectives;
                    incrementalResults.data=dataStruct;
                    incrementalResults.objIndices=modifiedObjIndices;
                end
            end
        end


        function setAnalysisGoals(obj,goals)
            assert(nargin==2);
            obj.mDvoAnalyzer.setAnalysisGoals(goals);
        end

        function terminate(obj,cause)
            obj.mTestComp.setInternalStrategy('');
            if(Sldv.Analysis.StrategyState.AsyncRunning==obj.mState)
                notifyOnTerminate=false;
                obj.mDvoAnalyzer.terminateAsyncAnalysis(notifyOnTerminate,cause);
            end
            obj.clearArtifacts();
            obj.mState=Sldv.Analysis.StrategyState.Terminated;
        end
    end

    methods(Access=public)

        function obj=Concolic(dvoAnalyzer,testComp)
            obj=obj@Sldv.Analysis.Strategy();
            obj.mDvoAnalyzer=dvoAnalyzer;
            obj.mTestComp=testComp;
            obj.mOutputDir=sldvprivate(...
            'mdl_get_output_dir',testComp);
        end
    end

    methods(Access=private)
        function options=getOptionsForConcolic(obj)
            options=containers.Map('KeyType','char','ValueType','any');
            testComp=obj.mTestComp;

            testComp.setInternalStrategy('Concolic');
            if isfield(obj.mSldvObjectivesData,'TestCases')&&...
                ~isempty(obj.mSldvObjectivesData.TestCases)

                userOptions=obj.mDvoAnalyzer.getSldvOptions();
                totalTime=userOptions.MaxProcessTime;
                elapsedTime=testComp.getElapsedTime();
                remainingTime=totalTime-elapsedTime;
                options('MaxProcessTime')=remainingTime;

                options('ExtendExistingTests')='on';
                outputDir=obj.mOutputDir;
                fileName=[outputDir,filesep,'sldvDataTemp.mat'];
                initSldvData=obj.mSldvObjectivesData;
                save(fileName,'initSldvData');
                options('ExistingTestFile')=fileName;
                options('IgnoreExistTestSatisfied')='off';
            end
        end

        function clearArtifacts(obj)


            fileName=[obj.mOutputDir,filesep,'sldvDataTemp.mat'];
            if exist(fileName,'file')==2
                delete(fileName);
            end
        end
    end

end


