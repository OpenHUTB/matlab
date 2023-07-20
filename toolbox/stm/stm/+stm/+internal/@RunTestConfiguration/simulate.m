function[result,streamedRunID,sigLoggingName,outportName,dsmLoggingName,codeExecutionProfileVarName,verifyResult,stateName]=...
    simulate(obj,simInputs,simWatcher,inputDataSetsRunFile,inputSignalGroupRunFile,simIndex)




    import stm.internal.RunTestConfiguration;
    import stm.internal.SlicerDebuggingStatus;



    if stm.internal.slicerDebugStatus==SlicerDebuggingStatus.DebugInactive
        cleanAfterSim=onCleanup(@()RunTestConfiguration.revertModelSettingsAfterSimulation(simWatcher));
    end

    result=[];
    streamedRunID=0;
    verifyResult=[];
    simInputs.inputDataSetsRunFile=inputDataSetsRunFile;




    sigLoggingName=get_param(obj.modelToRun,'SignalLoggingName');
    dsmLoggingName=get_param(obj.modelToRun,'DSMLoggingName');
    signalLoggingOn=get_param(obj.modelToRun,'SignalLogging');
    outportName='';
    stateName='';
    codeExecutionProfileVarName='';



    if strcmpi(get_param(obj.modelToRun,'CodeExecutionProfiling'),'on')
        codeExecutionProfileVarName=get_param(obj.modelToRun,'CodeExecutionProfileVariable');
    end

    try

        if(~isempty(obj.testIteration.TestParameter.ConfigName))
            obj.testSettings.configSet.ConfigName=obj.testIteration.TestParameter.ConfigName;
            obj.testSettings.configSet.ConfigRefPath='';
            obj.testSettings.configSet.VarName='';
            obj.testSettings.configSet.ConfigSetOverrideSetting=1;
        end

        if(~strcmp(obj.testSettings.configSet.ConfigName,simWatcher.configName)||...
            ~strcmp(obj.testSettings.configSet.ConfigRefPath,simWatcher.configRefPath)||...
            ~strcmp(obj.testSettings.configSet.VarName,simWatcher.configVarName))



            simWatcher.revertSettings(true);
            if(simWatcher.revertingFailed)
                obj.addMessages(simWatcher.revertingErrors.messages,simWatcher.revertingErrors.errorOrLog);
                return;
            end
        end


        obj.initializeFastRestart(simWatcher,simInputs);

        if(~isfield(simWatcher.cleanupTestCase,'SimulationMode'))
            simWatcher.cleanupTestCase.Dirty=get_param(obj.modelToRun,'Dirty');
            simWatcher.cleanupTestCase.SimulationMode=get_param(obj.modelToRun,'SimulationMode');
        end


        obj.applyConfigSet(simWatcher);

    catch me
        rethrow(me);
    end

    obj.modelUtil.startTimer();
    try
        stmDebugger=[];

        [simMode,blockOrModelName,isModeAppliedOnCUT,simModeForCUT]=...
        obj.getSimMode(simInputs,simWatcher);
        if~obj.runUsingSimIn
            if strlength(simMode)>0
                set_param(blockOrModelName,'SimulationMode',simMode);
            end

            if~simWatcher.testCaseSimSettingApplied
                obj.applySystemUnderTestSettings(simWatcher);
                obj.applyOutputSettings(simWatcher);

                simWatcher.testCaseSimSettingApplied=true;
            end

            obj.applyExternaInput(simWatcher,simInputs.inputDataSetsRunFile,inputSignalGroupRunFile);
            obj.applyParameterOverrides(simWatcher);
            obj.applySignalLogging(simWatcher);
            obj.applyIterationModelParameters(simWatcher);
            obj.applyIterationVariableParameters(simWatcher);
        end


        obj.applyIterationSignalBuilderGroup(simWatcher);


        if(~isfield(simWatcher.cleanupTestCase,'ReturnWorkspaceOutputs'))
            simWatcher.cleanupTestCase.ReturnWorkspaceOutputs=get_param(obj.modelToRun,'ReturnWorkspaceOutputs');
            if(~strcmp(simWatcher.cleanupTestCase.ReturnWorkspaceOutputs,'on'))
                set_param(obj.modelToRun,'ReturnWorkspaceOutputs','on');
            end


            currSaveFormat=get_param(obj.modelToRun,'SaveFormat');
            if~strcmp(currSaveFormat,'StructureWithTime')&&~strcmp(currSaveFormat,'Dataset')
                simWatcher.cleanupTestCase.SaveFormat=currSaveFormat;
                set_param(obj.modelToRun,'SaveFormat','StructureWithTime');
            end
        end


        if strcmp(get_param(obj.modelToRun,'LoggingToFile'),'on')
            simWatcher.cleanupTestCase.LoggingToFile='on';
            set_param(obj.modelToRun,'LoggingToFile','off');
        end

        if(~obj.runningOnPCT)

            if strcmp(get_param(obj.modelToRun,'StreamToWorkspace'),'on')
                simWatcher.cleanupTestCase.StreamToWorkspace='on';
                set_param(obj.modelToRun,'StreamToWorkspace','off');
            end
        else

            if strcmp(get_param(obj.modelToRun,'StreamToWorkspace'),'off')
                simWatcher.cleanupTestCase.StreamToWorkspace='off';
                set_param(obj.modelToRun,'StreamToWorkspace','on');
            end

            if strcmp(get_param(obj.modelToRun,'InspectSignalLogs'),'off')
                simWatcher.cleanupTestCase.InspectSignalLogs='off';
                set_param(obj.modelToRun,'InspectSignalLogs','on');
            end

            if~strcmpi(get_param(obj.modelToRun,'SaveFormat'),'Dataset')
                simWatcher.cleanupTestCase.SaveFormat=get_param(obj.modelToRun,'SaveFormat');
                set_param(obj.modelToRun,'SaveFormat','Dataset');
            end
        end


        if strcmpi(get_param(obj.modelToRun,'SaveFormat'),'Dataset')
            outportName=get_param(obj.modelToRun,'OutputSaveName');
            stateName=get_param(obj.modelToRun,'StateSaveName');
        end


        rv=stm.internal.util.RestoreVariable(stm.internal.Coverage.CovSaveName);%#ok<NASGU>


        simInputs.CoverageSettings=stm.internal.Coverage.getCoverageSettings(...
        simInputs.CallingFunction,simInputs.TestCaseId);

        if~simWatcher.coverageSettingApplied

            simWatcher.coverage=stm.internal.Coverage(simInputs.CoverageSettings,...
            simWatcher,obj);
            simWatcher.coverageSettingApplied=true;
        end

        if obj.runUsingSimIn
            simInputs.testIteration.TestParameter.LoggedSignalSetId=obj.testIteration.TestParameter.LoggedSignalSetId;
            stm.internal.SimulationInput.populateSimIn(obj,simInputs,simWatcher);
            obj.SimulationInput=obj.SimulationInput.setPreSimFcn(@(x)locPreSimFcn(simWatcher));
            obj.SimulationInput=obj.SimulationInput.setPostSimFcn(@(x)locPostSimFcn(simWatcher));
        end




        try
            set_param(simInputs.Model,'Dirty','off');
        catch
        end

        result=[];
        simException=[];
        sigLoggingName=get_param(obj.modelToRun,'SignalLoggingName');
        try
            hRunning=stm.internal.MRT.share.attachAssessmentEvalParamCb(...
            obj.modelToRun,simInputs.Mode,...
            @(~,~)RunTestConfiguration.getAssessmentsData(...
            simInputs,simWatcher,signalLoggingOn,sigLoggingName,obj));
            cRunning=onCleanup(@()hRunning.delete);

            currSimMode=get_param(obj.modelToRun,'SimulationMode');



            if isSimulationSupportedForDebugBySlicer(currSimMode)
                stmDebugger=stm.internal.StmDebugger.getInstance();
            end




            if isSlicerDebugEnabled()&&~isSlicerSimulationToDebug(simIndex,stmDebugger)
                cleanAfterSim=onCleanup(@()RunTestConfiguration.revertModelSettingsAfterSimulation(simWatcher));
            end



            if isSlicerSimulationToDebug(simIndex,stmDebugger)
                result=stm.internal.StmDebugger.simulateForDebug(obj,simWatcher);

            elseif stm.internal.isDebugMode&&sltest.testmanager.Debugger.supportsDebug(currSimMode)
                sldbg=sltest.testmanager.Debugger.enterDebug(obj,simInputs.TestCaseId);
                sldbg.debugLoop(obj);

                sldbg.StepperCleanup.delete;
                sldbg.delete;
            else

                obj.out.preSimStreamedRun=stm.internal.util.getStreamedRunID(obj.modelToRun);
                if obj.out.preSimStreamedRun==streamedRunID

                    streamedRunID=0;
                end
                obj.updateTestCaseSpinnerLabel(simInputs.TestCaseId,...
                getString(message('stm:general:SimModel')));
                if isSlicerDebugEnabled()

                    setModelParamForSlicerDebugging(obj.modelToRun,simWatcher);
                end
                result=stmSim(obj);
                if isSlicerDebugEnabled()



                    if isprop(result,'logsout')
                        stmDebugger.secondSimData=result.logsout;
                    end
                end
            end

            try
                verifyResult=sltest.getAssessments(obj.modelToRun);
            catch me
                if~strcmp(me.identifier,'Stateflow:reactive:GetAssessmentNoAssessments')
                    rethrow(me);
                end
            end
        catch me

            obj.out.SimulationFailed=true;
            if strcmp(me.identifier,'Simulink:tools:rapidAccelAssertion')||...
                strcmp(me.identifier,'Simulink:blocks:AssertionAssert')
                obj.out.SimulationAsserted=true;
            end
            simException=me;
        end


        if obj.runUsingSimIn

            obj.out.overridesilpilmode=simInputs.OverrideSILPILMode;
        else

            obj.out.overridesilpilmode=false;
        end


        obj.out.modelChecksum=[];
        mdata=[];
        if~isempty(result)
            mdata=result.getSimulationMetadata();
        end
        obj.out=stm.internal.util.getSimulationMetadata(obj.out,mdata,obj.modelToRun,simWatcher.mainModel);

        if~isempty(mdata)
            checkForNonTunableWarnings(obj,mdata);


            if strcmpi(mdata.ExecutionInfo.StopEvent,'StopCommand')

                obj.out.IsIncomplete=true;
                obj.addMessages({mdata.ExecutionInfo.StopEventDescription},{false});
            end
        end


        if(isfield(obj.out,'simMode'))

            if(isModeAppliedOnCUT&&~isempty(simModeForCUT))
                obj.out.SimulationModeUsed=simModeForCUT;
            else
                obj.out.SimulationModeUsed=obj.out.simMode;
            end
        end


        Simulink.sdi.internal.flushStreamingBackend();
        streamedRunID=stm.internal.util.getStreamedRunID(obj.modelToRun);
        if obj.out.preSimStreamedRun==streamedRunID

            streamedRunID=0;
        end

        if~isempty(simException)
            throwWithSimDiagnostic(simException);
        end

    catch me
        [tempErrors,tempErrorOrLog]=stm.internal.util.getMultipleErrors(me);
        obj.addMessages(tempErrors,tempErrorOrLog);

        if me.identifier=="Simulink:Engine:SimCantChangeBDPropInFastRestart"||me.identifier=="configset:diagnostics:CannotChangeProp"
            obj.addMessages({getString(message('stm:OutputView:FastRestartParamSetNotAllowed'))},{true});
        end
    end

    obj.modelUtil.stopTimer();


    obj.out=stm.internal.Coverage.getCoverageResults(obj.out,simWatcher,simInputs);




    if(obj.modelUtil.stmBeenStopped==true)
        simWatcher.closeModel=true;
    end



    if isSlicerSimulationToDebug(simIndex,stmDebugger)
        if stmDebugger.resultsDebugger.isModelFastRestartCompatible
            stmDebugger.resultsDebugger.stepForward;
        else

            obj.addMessages({getString(message('stm:general:SlicerDebugFastRestartIncompatible',...
            stmDebugger.resultsDebugger.modelName))},{true});
        end
    end
end

function result=stmSim(obj)



    if~obj.runUsingSimIn
        text=['sim(''',obj.modelToRun,''');'];
    else
        text='sim(obj.SimulationInput);';



        id='Simulink:Logging:TopMdlOverrideUpdated';
        mdlRefLog=warning('off',id);
        oc=onCleanup(@()warning(mdlRefLog.state,id));
    end




    breakpoints=Simulink.Debug.BreakpointList.getAllBreakpoints();
    breakpoints=breakpoints(cellfun(@(bp)bp.isEnabled,breakpoints));
    cellfun(@disable,breakpoints);
    cleanupReenableBreakpoints=onCleanup(@()cellfun(@enable,breakpoints));

    [~,result]=evalc(text);
end

function throwWithSimDiagnostic(simException)
    errID='stm:general:ErrorCallingSim';
    diag=MSLException(message(errID,simException.identifier));
    diag=diag.addCause(simException);
    diag.throw;
end

function checkForNonTunableWarnings(obj,mdata)

    for warnDiagnostic=mdata.ExecutionInfo.WarningDiagnostics.'
        diag=warnDiagnostic.Diagnostic;
        idx={diag.identifier}=="Simulink:Engine:NonTunableVarChangedInFastRestart";
        obj.addMessages({diag(idx).message},repmat({true},[1,nnz(idx)]));
    end
end

function status=isSlicerSimulationToDebug(simIndex,stmDebugger)



    status=~isempty(stmDebugger)&&simIndex==stmDebugger.simulationToDebug;
end

function status=isSimulationSupportedForDebugBySlicer(currSimMode)
    status=exist('currSimMode','var')&&isSlicerDebugEnabled()&&...
    stm.internal.StmDebugger.supportsDebug(currSimMode);
end

function status=isSlicerDebugEnabled()
    import stm.internal.SlicerDebuggingStatus;
    status=stm.internal.slicerDebugStatus==SlicerDebuggingStatus.DebugModeTestRun;
end

function setModelParamForSlicerDebugging(modelName,simWatcher)


    currSignalLogging=get_param(modelName,'SignalLogging');
    if~strcmp(currSignalLogging,'on')
        simWatcher.cleanupTestCase.SignalLogging=currSignalLogging;
        set_param(modelName,'SignalLogging','on');
    end

    currSignalLoggingName=get_param(modelName,'SignalLoggingName');
    if~strcmp(currSignalLoggingName,'logsout')
        simWatcher.cleanupTestCase.SignalLoggingName=currSignalLoggingName;
        set_param(modelName,'SignalLoggingName','logsout');
    end

    currDatasetSignalFormat=get_param(modelName,'DatasetSignalFormat');
    if~strcmp(currDatasetSignalFormat,'timeseries')
        simWatcher.cleanupTestCase.DatasetSignalFormat=currDatasetSignalFormat;
        set_param(modelName,'DatasetSignalFormat','timeseries');
    end
end

function locPreSimFcn(simWatcher)


    if simWatcher.NeedSubsystemManager

        hInfo=Simulink.harness.find(simWatcher.ownerName,'Name',simWatcher.harnessName);
        if~isempty(hInfo.functionInterfaceName)
            simWatcher.SubsystemManager=rtw.pil.RLSManager(simWatcher.harnessName);
            runCompatibilityCheck=true;
        else
            simWatcher.SubsystemManager=rtw.pil.AtomicSubsystemManager(simWatcher.harnessName);
            runCompatibilityCheck=false;
        end
        simWatcher.SubsystemManager.workflowSLTSetup(runCompatibilityCheck);
        activationPvps=simWatcher.SubsystemManager.getActivationParamValuePairs();
        set_param(simWatcher.harnessName,activationPvps{:});
    end
end

function locPostSimFcn(simWatcher)
    if~isempty(simWatcher.SubsystemManager)

        simWatcher.SubsystemManager.cleanupWorkflowParameters(simWatcher.harnessName);
        simWatcher.SubsystemManager.workflowTeardown();
    end
end