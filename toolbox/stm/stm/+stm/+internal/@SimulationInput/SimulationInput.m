


classdef SimulationInput<handle

    properties(SetAccess=protected)
        RunTestCfg(1,1)stm.internal.RunTestConfiguration;
        SimIn(1,1)struct;
        SimWatcher(1,1)stm.internal.util.SimulationWatcher;
    end

    methods
        function this=SimulationInput(simIn,runTestCfg,simWatcher)
            narginchk(3,3);
            this.SimIn=simIn;
            this.RunTestCfg=runTestCfg;
            this.SimWatcher=simWatcher;
        end

        applySUTSettings(this);
        applyParameterOverrides(this);
        applyInputs(this);
        applyOutputSettings(this);
        applyLoggingSettings(this);
        applyIterationModelParameters(this);
        applyIterationVariableParameters(this);

        setLoggingSpecification(this,loggedSignals);
        setDsmBlock(this,dsm);
        setDsmSimulinkSignal(this,dsm);
    end

    methods(Access=private)
        cache=applyVariablesAndBlockParameters(this,parameters);
    end

    methods(Static)
        simIn=getSimIn(varargin);
        populateSimIn(runTestConfig,simInputStruct,simWatcher);
        ids=getIdsFromResultObject(resultObject);

        simIn=addLoggedSignals(simIn,blockPath,portIdx);
        simIn=setBlockParameter(simIn,varargin);

        preloadFcn(runCfg,simInStruct,simWatcher,useParallel,dbLocation);
        simIn=preSimFcn(simIn,runCfg,simWatcher,simInStruct,useParallel,simWatcherCellArray,testCaseIndex,isfastRestartSimInRevert,simInputArrayFeature,TestSequenceScenarioFeature);
        simOut=postSimFcn(simOut,simWatcher,runCfg,simInStruct,useParallel);

        setDiff=getFastRestartLoggedSignals(allLoggedSignals,fastRestartLoggedSignals);

        simulateAndEvaluate(runCfgArray,simInStructCellArray,simWatcher,useParallel,resultSetId);
        simulateAndEvaluateV2(runCfgArray,simInStructCellArray,simWatcher,useParallel,resultSetId);
        [runCfgArray,simInStructCellArray,simWatchersCellArray]=constructRunCfgArray(simInStructCellArray,simWatchersCellArray,useParallel);
        [runCfgArray,simInStructCellArray,simWatchersCellArray]=constructRunCfgArrayV2(simInStructCellArray,simWatchersCellArray,useParallel);
        setupSignalBuilder(runCfg,simInStruct,simWatcher);
        setupTestSequenceScenario(runCfg,simInStruct,simWatcher);
        cleanupSignalBuilder(simWatcher);
        cleanupTestSequenceScenario(simWatcher);
        evaluateSimOut(simOut,useParallel,simInStruct,simWatcher,runCfg,resultSetId);
        runCfgOut=constructRunCfgOut(runCfg,simInStruct,simWatcher,cacheSimOut,simOut);
        addExceptionMessages(runcfg,me);
        bool=shouldCloseHarness(modelToRun,mainModel,nextMainModel,nextHarnessString);
    end
end
