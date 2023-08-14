function[result,verifyResult,covdata]=simulate(obj,simInputs,simWatcher,inputDataSetsRunFile,inputSignalGroupRunFile)




    cleanAfterSim=onCleanup(@()stm.internal.MRT.utility.RunTestConfiguration.revertModelSettingsAfterSimulation(simWatcher));
    result=[];
    verifyResult=[];
    covdata=[];

    persistent verLessThan16b;
    if isempty(verLessThan16b)
        verLessThan16b=verLessThan('matlab','9.1');
    end
    persistent verLessThan17a;
    if isempty(verLessThan17a)
        verLessThan17a=verLessThan('matlab','9.2');
    end
    persistent verLessThan17b;
    if isempty(verLessThan17b)
        verLessThan17b=verLessThan('matlab','9.3');
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


        if(simWatcher.fastRestart&&~isfield(simWatcher.cleanupTestCase,'InitializeInteractiveRuns'))
            simWatcher.cleanupTestCase.InitializeInteractiveRuns=get_param(obj.modelToRun,'InitializeInteractiveRuns');
            set_param(obj.modelToRun,'InitializeInteractiveRuns','on');
        end
        if(~isfield(simWatcher.cleanupTestCase,'SimulationMode'))
            simWatcher.cleanupTestCase.Dirty=get_param(obj.modelToRun,'Dirty');
            simWatcher.cleanupTestCase.SimulationMode=get_param(obj.modelToRun,'SimulationMode');
        end


        obj.applyConfigSet(simWatcher);

    catch me
        rethrow(me);
    end

    isModeAppliedOnCUT=false;
    simModeForCUT='';
    obj.modelUtil.startTimer();
    try
        if(~simWatcher.testCaseSimSettingApplied)

            simMode=stm.internal.MRT.utility.RunTestConfiguration.resolveSimulationMode(simInputs.Mode);
            blockOrModelName=obj.modelToRun;
            if(~isempty(simMode))


                if~isempty(simWatcher.componentUnderTest)
                    blockOrModelName=simWatcher.componentUnderTest;
                    isModeAppliedOnCUT=true;
                    simModeForCUT=simMode;
                end
                simWatcher.cleanupTestCase.SimulationMode=get_param(blockOrModelName,'SimulationMode');
                simWatcher.cleanupTestCase.SimulationModeAppliedOn=blockOrModelName;
                set_param(blockOrModelName,'SimulationMode',simMode);
            end
            obj.out.SimulationModeUsed=get_param(blockOrModelName,'SimulationMode');
            simWatcher.simMode=obj.out.SimulationModeUsed;

            if strcmpi(obj.out.SimulationModeUsed,'external')
                error(message('stm:general:ExtModeNotSupported'));
            end

            obj.applySystemUnderTestSettings(simWatcher);
            obj.applyOutputSettings(simWatcher);

            simWatcher.testCaseSimSettingApplied=true;
        end

        inputLoadWarnings=obj.applyExternaInput(simWatcher,inputDataSetsRunFile,inputSignalGroupRunFile);
        obj.applyParameterOverrides(simWatcher);
        obj.applySignalLogging(simWatcher);
        obj.applyIterationModelParameters(simWatcher);
        obj.applyIterationVariableParameters(simWatcher);
        obj.applyIterationSignalBuilderGroup(simWatcher);
        if~verLessThan16b
            obj.applySignalLoggingForAssessments(...
            simInputs.assessmentsLoggingInfo.signals,simWatcher);
        end

        if(~isfield(simWatcher.cleanupTestCase,'ReturnWorkspaceOutputs'))
            simWatcher.cleanupTestCase.ReturnWorkspaceOutputs=get_param(obj.modelToRun,'ReturnWorkspaceOutputs');
            if(~strcmp(simWatcher.cleanupTestCase.ReturnWorkspaceOutputs,'on'))
                set_param(obj.modelToRun,'ReturnWorkspaceOutputs','on');
            end

        end



        if(~isfield(simWatcher.cleanupTestCase,'SDIOptimizeVisual'))
            try
                val=get_param(obj.modelToRun,'SDIOptimizeVisual');
                simWatcher.cleanupTestCase.SDIOptimizeVisual=val;
                set_param(obj.modelToRun,'SDIOptimizeVisual','off');
            catch me %#ok<NASGU> 

            end
        end




        currSaveFormat=get_param(obj.modelToRun,'SaveFormat');
        if~strcmp(currSaveFormat,'Dataset')
            simWatcher.cleanupTestCase.SaveFormat=currSaveFormat;
            set_param(obj.modelToRun,'SaveFormat','Dataset');
        end


        try
            if strcmp(get_param(obj.modelToRun,'LoggingToFile'),'on')
                set_param(obj.modelToRun,'LoggingToFile','off');
                simWatcher.cleanupTestCase.LoggingToFile='on';
            end
        catch
        end

        try
            if strcmp(get_param(obj.modelToRun,'StreamToWorkspace'),'off')
                simWatcher.cleanupTestCase.StreamToWorkspace='off';
                set_param(obj.modelToRun,'StreamToWorkspace','on');
            end
        catch
        end

        if~verLessThan17b
            rv=stm.internal.util.RestoreVariable(stm.internal.Coverage.CovSaveName);%#ok<NASGU>

            simWatcher.coverage=stm.internal.Coverage(simInputs.CoverageSettings,...
            simWatcher,obj);
            simWatcher.coverageSettingApplied=true;
        else
            obj.addMessages({stm.internal.MRT.share.getString('stm:CoverageStrings:CannotCollectCoverageTC')},{false});
        end




        if strcmp(get_param(obj.modelToRun,'SignalLogging'),'off')&&(...
            ~isempty(simInputs.assessmentsLoggingInfo.signals)...
            ||simInputs.SignalLogging||simInputs.DSMLogging)
            simWatcher.cleanupTestCase.SignalLogging='off';
            set_param(obj.modelToRun,'SignalLogging','on');
        end




        try
            set_param(simInputs.Model,'Dirty','off');
        catch
        end

        sigLoggingName=get_param(obj.modelToRun,'SignalLoggingName');
        signalLoggingOn=get_param(obj.modelToRun,'SignalLogging');



        result=[];
        simException=[];
        try
            if~verLessThan16b
                hRunning=stm.internal.MRT.share.attachAssessmentEvalParamCb(...
                obj.modelToRun,simInputs.Mode,...
                @(~,~)stm.internal.MRT.utility.RunTestConfiguration.getAssessmentsData(...
                simInputs,signalLoggingOn,sigLoggingName,obj));
                cRunning=onCleanup(@()hRunning.delete);
            end
            [logs,result]=evalc(['sim(''',obj.modelToRun,''')']);
            if~isempty(logs)
                obj.addMessages({logs},{false});
            end

            if verLessThan16b
                obj.out.assessmentsData.unsupportedMRTAssessments=true;
            end




            if~verLessThan17a
                try
                    verifyResult=sltest.getAssessments(obj.modelToRun);
                catch me
                    if~strcmp(me.identifier,'Stateflow:reactive:GetAssessmentNoAssessments')
                        rethrow(me);
                    end
                end
            end








            if~(verLessThan16b||isempty(simInputs.assessmentsLoggingInfo.signals))
                outLoggingName=get_param(obj.modelToRun,'OutputSaveName');
                obj.out.assessmentsData.constantSignalIndices=...
                stm.internal.MRT.utility.RunTestConfiguration...
                .cacheConstSignalIndices(result,outLoggingName,sigLoggingName);
                obj.out.assessmentsData.discreteEventSignalPorts=stm...
                .internal.MRT.utility.RunTestConfiguration...
                .cacheDiscreteEventSignalPorts();
            end
        catch me

            obj.out.SimulationFailed=true;
            if strcmp(me.identifier,'Simulink:tools:rapidAccelAssertion')||...
                strcmp(me.identifier,'Simulink:blocks:AssertionAssert')
                obj.out.SimulationAsserted=true;
            end

            if(~isempty(inputLoadWarnings))
                inputLoadErrors={stm.internal.MRT.share.getString('stm:InputsView:InputFileLoadFailed'),...
                inputLoadWarnings{1}};
                isErrMsg={true,true};
                obj.addMessages(inputLoadErrors,isErrMsg);
            end

            simException=me;
        end



        obj.out.overridesilpilmode=false;


        obj.out.modelChecksum=[];
        try
            try
                mdata=result.getSimulationMetadata();
            catch
                mdata=[];
            end
            obj.out=stm.internal.util.getSimulationMetadata(obj.out,mdata,obj.modelToRun,simWatcher.mainModel);
            if(isempty(obj.out.simMode))
                obj.out.simMode=simWatcher.simMode;
            end


            warnDiagnostics=mdata.ExecutionInfo.WarningDiagnostics;
            numWarnDiagnostics=length(warnDiagnostics);

            for wd=1:numWarnDiagnostics
                diagnostics=warnDiagnostics(wd).Diagnostic;
                numDiagnostics=length(diagnostics);
                for d=1:numDiagnostics
                    identifier=diagnostics(d).identifier;
                    if strcmp(identifier,'Simulink:Engine:NonTunableVarChangedInFastRestart')
                        obj.addMessages({diagnostics(d).message},{true});
                    end
                end
            end


            if strcmpi(mdata.ExecutionInfo.StopEvent,'StopCommand')

                obj.out.IsIncomplete=true;
                obj.addMessages({mdata.ExecutionInfo.StopEventDescription},{false});
            end
        catch

        end


        if(isfield(obj.out,'simMode'))

            if(isModeAppliedOnCUT&&~isempty(simModeForCUT))
                obj.out.SimulationModeUsed=simModeForCUT;
            else
                obj.out.SimulationModeUsed=obj.out.simMode;
            end
        end


        try
            Simulink.sdi.internal.flushStreamingBackend();
        catch
        end

        if~isempty(simException)
            rethrow(simException);
        end

    catch me
        [tempErrors,tempErrorOrLog]=stm.internal.util.getMultipleErrors(me);
        obj.addMessages(tempErrors,tempErrorOrLog);
    end

    if evalin('base',['exist(''',stm.internal.Coverage.CovSaveName,''', ''var'')'])
        covdata=evalin('base',stm.internal.Coverage.CovSaveName);
    end

    obj.modelUtil.stopTimer();




    if(obj.modelUtil.stmBeenStopped==true)
        simWatcher.closeModel=true;
    end
end