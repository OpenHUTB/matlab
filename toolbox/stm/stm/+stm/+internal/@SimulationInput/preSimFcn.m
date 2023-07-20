


























function simIn=preSimFcn(simIn,runCfg,simWatcher,simInStruct,useParallel,simWatcherCellArray,testCaseIndex,isfastRestartSimInRevert,simInputArrayFeature,TestSequenceScenarioFeature)
    import stm.internal.RunTestConfiguration;
    import stm.internal.SimulationInput;

    modelToRun=simInStruct.modelToRun;

    useFastRestart=simInStruct.IterationId>0&&simInStruct.FastRestartMode;

    try
        if~simWatcher.coverageSettingApplied
            simWatcher.coverage=stm.internal.Coverage(simInStruct.CoverageSettings,...
            simWatcher,runCfg);
            simWatcher.coverageSettingApplied=true;
        end


        if(~isempty(runCfg.testIteration.TestParameter.ConfigName))
            runCfg.testSettings.configSet.ConfigName=runCfg.testIteration.TestParameter.ConfigName;
            runCfg.testSettings.configSet.ConfigRefPath='';
            runCfg.testSettings.configSet.VarName='';
            runCfg.testSettings.configSet.ConfigSetOverrideSetting=1;
        end

        if(~strcmp(runCfg.testSettings.configSet.ConfigName,simWatcher.configName)||...
            ~strcmp(runCfg.testSettings.configSet.ConfigRefPath,simWatcher.configRefPath)||...
            ~strcmp(runCfg.testSettings.configSet.VarName,simWatcher.configVarName))



            simWatcher.revertSettings(true);
            if(simWatcher.revertingFailed)
                runCfg.addMessages(simWatcher.revertingErrors.messages,simWatcher.revertingErrors.errorOrLog);
                return;
            end
        end

        simWatcher.originalTopModelDirty=get_param(simInStruct.Model,'Dirty');
        runCfg.applyIterationSignalBuilderGroup(simWatcher);

        if(~strcmp(modelToRun,simInStruct.Model))
            runCfg.modelUtil.HarnessName=modelToRun;
        else
            runCfg.modelUtil.HarnessName=[];
        end

        modelToRunDirty=strcmp(get_param(modelToRun,'Dirty'),'on');







        if(testCaseIndex-1>0)&&isequal(simWatcherCellArray{testCaseIndex-1}.permutationId,simWatcherCellArray{testCaseIndex}.permutationId)
            simWatcherCellArray{testCaseIndex}.refreshParameterOverrides=simWatcherCellArray{testCaseIndex-1}.refreshParameterOverrides;
        end









        runcfgModelName=runCfg.SimulationInput.ModelName;
        simInModelName=simIn.ModelName;

        runCfg.SimulationInput=simIn;
        runCfg.SimulationInput.ModelName=runcfgModelName;

        stm.internal.SimulationInput.populateSimIn(runCfg,simInStruct,simWatcher);

        simIn=runCfg.SimulationInput;
        simIn.ModelName=simInModelName;







        runCfg.useAssessmentsInfoFromRunCfg=false;
        if(simInputArrayFeature==2)||(simInputArrayFeature==3)||(simInputArrayFeature==1&&~useParallel)
            runCfg.assessmentsInfo=stm.internal.getAssessmentsInfo(stm.internal.getAssessmentsID(simInStruct.TestCaseId));
            runCfg.useAssessmentsInfoFromRunCfg=true;
        end

        stm.internal.SimulationInput.cleanupSignalBuilder(simWatcher);

        if TestSequenceScenarioFeature
            stm.internal.SimulationInput.cleanupTestSequenceScenario(simWatcher);
        end

        if~modelToRunDirty&&bdIsLoaded(modelToRun)&&strcmp(get_param(modelToRun,'Dirty'),'on')
            set_param(modelToRun,'Dirty','off');
        end

        msg=stm.internal.MRT.share.getString(('stm:general:TestExecQueued'));
        if~isempty(simInStruct.IterationName)
            msg=[simInStruct.IterationName,newline,msg];
        end
        stm.internal.Spinner.updateTestCaseSpinnerLabel(simInStruct.TestCaseId,msg);

    catch me
        [tempErrors,tempErrorOrLog]=stm.internal.util.getMultipleErrors(me);
        runCfg.addMessages(tempErrors,tempErrorOrLog);
        try

            runCfg.runCleanup(simInStruct(1),[],true);
        catch ME
            stm.internal.SimulationInput.addExceptionMessages(runCfg,ME);
        end
        runCfg.out.overridesilpilmode=simInStruct.OverrideSILPILMode;
        rethrow(me);
    end


    try
        currSaveFormat=get_param(modelToRun,'SaveFormat');

        if~useFastRestart&&~strcmp(currSaveFormat,'StructureWithTime')&&~strcmp(currSaveFormat,'Dataset')
            simIn=simIn.setModelParameter('ReturnWorkspaceOutputs','on',...
            'SaveFormat','StructureWithTime');
        elseif useFastRestart
            simIn=simIn.setModelParameter('ReturnWorkspaceOutputs','on');
        end

        if useParallel&&~useFastRestart
            if strcmp(get_param(modelToRun,'StreamToWorkspace'),'off')
                simIn=simIn.setModelParameter('StreamToWorkspace','on',...
                'InspectSignalLogs','on','SaveFormat','Dataset');
            end
        else
            if strcmp(get_param(modelToRun,'StreamToWorkspace'),'on')
                simIn=simIn.setModelParameter('StreamToWorkspace','off');
            end
        end

        runCfg.out.preSimStreamedRun=stm.internal.util.getStreamedRunID(simIn.ModelName);

    catch me
        stm.internal.SimulationInput.addExceptionMessages(runCfg,me);
        rethrow(me);
    end

    if isfastRestartSimInRevert
        if(isa(simIn,'sltest.harness.SimulationInput'))
            harnessOwner=simIn.HarnessOwner;
            harnessName=simIn.HarnessName;
            modelToChange=harnessName;
            if~bdIsLoaded(harnessName)
                try
                    stm.internal.util.loadHarness(harnessOwner,harnessName);
                catch me
                    if isequal(me.identifier,'Simulink:Harness:AnotherHarnessAlreadyActivated')||...
                        isequal(me.identifier,'Simulink:Harness:CannotUpdateWhenATestingHarnessIsActive')
                        activeHarness=Simulink.harness.internal.getActiveHarness(simIn.ModelName);
                        if~isempty(activeHarness)
                            close_system(activeHarness.name,0);
                            stm.internal.util.loadHarness(harnessOwner,harnessName);
                        end
                    else
                        rethrow(me);
                    end
                end
            end
        else
            modelToChange=simIn.ModelName;
            if~bdIsLoaded(modelToChange)
                load_system(modelToChange);
            end
        end

        fastRestartSetParam(modelToChange,simInStruct,simWatcherCellArray{testCaseIndex});
    end

    h=get_param(modelToRun,'Handle');
    dataId='STM_SDIRunID';

    if~Simulink.BlockDiagramAssociatedData.isRegistered(h,dataId)
        Simulink.BlockDiagramAssociatedData.register(h,dataId,'any');
        runObj=Simulink.sdi.getCurrentSimulationRun(modelToRun);
        preSimRunID=0;
        if~isempty(runObj)
            preSimRunID=runObj.id;
        end
        Simulink.BlockDiagramAssociatedData.set(h,dataId,preSimRunID);
    end

    sigLoggingName=get_param(modelToRun,'SignalLoggingName');
    signalLoggingOn=get_param(modelToRun,'SignalLogging');
    funcHandle=@(~,~)stm.internal.RunTestConfiguration.getAssessmentsData(simInStruct,simWatcher,signalLoggingOn,sigLoggingName,runCfg);
    runCfg.assessmentHandle=stm.internal.MRT.share.attachAssessmentEvalParamCb(...
    modelToRun,simInStruct.Mode,funcHandle);

    if(isfield(simWatcher.cleanupIteration,'Vars')&&~isempty(simWatcher.cleanupIteration.Vars)...
        &&isfield(simWatcher.cleanupIteration,'VarsLoaded')&&~isempty(simWatcher.cleanupIteration.VarsLoaded))
        vars=simWatcher.cleanupIteration.Vars;
        varsLoaded=simWatcher.cleanupIteration.VarsLoaded;
        if isfield(simWatcher.cleanupIteration,'IsExcel')&&simWatcher.cleanupIteration.IsExcel
            for i=1:length(varsLoaded)
                assignin('base',varsLoaded{i},vars(i));
            end
        else
            cellfun(@(field)assignin('base',field,vars.(field)),varsLoaded);
        end
    end

    me=runCfg.runPostload(simInStruct,simWatcher);
    if~isempty(me)
        rethrow(me);
    end


    runCfg.applyConfigSet(simWatcher);
    if isfield(simWatcher.cleanupTestCase,'currConfigSet')
        runCfg.modelConfigSet=simWatcher.cleanupTestCase.currConfigSet;
    end

    stm.internal.SimulationInput.setupSignalBuilder(runCfg,simInStruct,simWatcher);

    stm.internal.SimulationInput.setupTestSequenceScenario(runCfg,simInStruct,simWatcher);

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




function fastRestartSetParam(modelToChange,simIn,simWatcher)

    csToChange=modelToChange;
    configSet=getActiveConfigSet(modelToChange);
    if isa(configSet,'Simulink.ConfigSetRef')
        csToChange=getRefConfigSet(configSet);
    end

    currSaveFormat=get_param(csToChange,'SaveFormat');

    if~strcmp(currSaveFormat,'StructureWithTime')&&~strcmp(currSaveFormat,'Dataset')
        simWatcher.cleanupTestCase.SaveFormat=get_param(csToChange,'SaveFormat');
        set_param(csToChange,'SaveFormat','StructureWithTime');
        set_param(modelToChange,'Dirty','off');
    end

    if strcmp(get_param(csToChange,'LoggingToFile'),'on')
        simWatcher.cleanupTestCase.LoggingToFile='on';
        set_param(csToChange,'LoggingToFile','off');
        set_param(modelToChange,'Dirty','off');
    end

    if(simIn.OutputCtrlEnabled)
        outputParams=["SaveOutput","SaveState","SaveFinalState","SignalLogging","DSMLogging"];
        for param=outputParams
            if simIn.(param)
                newValue='on';
            else
                newValue='off';
            end
            simWatcher.cleanupTestCase.(param)=get_param(csToChange,param);
            set_param(csToChange,param,newValue);
        end
        set_param(modelToChange,'Dirty','off');
    end
end
