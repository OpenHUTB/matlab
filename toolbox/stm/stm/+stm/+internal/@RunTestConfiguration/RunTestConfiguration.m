classdef RunTestConfiguration<handle




    properties(SetAccess=immutable)
        TestCaseSimMode;
    end

    properties

        out=[];
        modelToRun='';
        modelUtil=[];
        mainModel='';
        modelsClosedByCleanup=[];
        assessmentCleanupHandle=[];

        testSettings=[];
        testIteration=[];
        runningOnPCT=false;
        runningOnMRT=false;
        SimulationInput=[];
        assessmentHandle=[];
        assessmentsInfo=[];
        useAssessmentsInfoFromRunCfg=false;
        modelConfigSet=[];
    end

    properties(Access=private)
        RunUsingSimInFlag;
    end

    methods
        function obj=RunTestConfiguration(testCaseSimMode)
            if nargin==0,testCaseSimMode='';end
            obj.TestCaseSimMode=testCaseSimMode;
            obj.out.RunID=0;
            obj.out.messages={};
            obj.out.errorOrLog={};
            obj.out.SimulationModeUsed='';
            obj.out.SimulationFailed=false;
            obj.out.SimulationAsserted=false;
            obj.out.ExternalInputRunData=repmat(struct('type',[],'runID',[]),1,0);
            obj.out.SigBuilderInfo=struct('SignalSourceComponent','','SignalSourceBlock','');
            obj.out.TestSequenceInfo=struct('TestSequenceScenario','','TestSequenceBlock','');
            obj.out.preSimStreamedRun=0;
            obj.out.OutputTriggerInfo=struct('StartTriggerMode',int32(0),'StopTriggerMode',int32(0),...
            'StartTriggerCondition','','StopTriggerCondition','','StartTriggerDuration',0,...
            'StopTriggerDuration',0,'SymbolData','','ShiftTimeToZero',true,'TimeDiff',0.0);




            obj.out.IsIncomplete=false;
        end
    end

    methods
        success=processTestCaseSettings(obj,simInput);
        addMessages(obj,messages,errorOrLog);

        me=runPreload(obj,simInput);
        me=runPostload(obj,simInput,simWatcher);
        runCleanup(obj,simInput,simOut,useSimInArrayFeature);
        updateTestCaseSpinnerLabel(obj,id,msg);

        success=getParameterOverrideDetails(obj,simWatcher);

        [result,streamedRunID,sigLoggingName,outportName,dsmLoggingName,...
        codeExecutionProfileVarName,verifyResult,stateName]=...
        simulate(obj,simInputs,simWatcher,inputDataSetsRunFile,...
        inputSignalGroupRunFile,simIndex);

        initializeFastRestart(obj,simWatcher,simInputs);
        applySystemUnderTestSettings(obj,simWatcher);
        applyOutputSettings(obj,simWatcher);
        applyConfigSet(obj,simWatcher);
        applyParameterOverrides(obj,simWatcher)
        matlabWarnings=applyExternaInput(obj,simWatcher,inputDataSetsRunFile,inputSignalGroupRunFile);
        applySignalLogging(obj,simWatcher);
        applyIterationModelParameters(obj,simWatcher);
        applyIterationSignalBuilderGroup(obj,simWatcher);
        applyIterationVariableParameters(obj,simWatcher);
        [simMode,blockOrModelName,isModeAppliedOnCUT,simModeForCUT]=...
        getSimMode(this,simInputs,simWatcher);
        bool=runUsingSimIn(this);
    end

    methods(Access=private)
        msgList=configureSignalsForStreaming(obj,simWatcher);
    end

    methods(Static)
        valid=checkIfValidSimInput(simInput);

        revertModelSettingsAfterSimulation(simWatcher);

        mode=resolveSimulationMode(simMode);

        to=copyStructContent(target,from);

        deleteModelUtil(modelUtil);


        moveRunToApp(runID);

        setCheckedSignals(sigs,plotIndices);

        [sigs,plotIndices]=getCheckedSignals(runID);

        stopDebug(stepperObj);

        msgList=configureSignalsForStreamingHelper(loggedSignals,bFromIteration,...
        modelToRun,simWatcher);

        getAssessmentsData(simInputs,simWatcher,signalLoggingOn,sigLoggingName,obj);
        callback=getCallbackForAssessments(isRapidAccel);
    end
end
