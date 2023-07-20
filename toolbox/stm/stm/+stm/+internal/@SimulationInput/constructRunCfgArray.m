
function[runCfgArray,simInputStructArray,simWatcherArray]=constructRunCfgArray(simInputStructArray,simWatcherArray,useParallel)

    import stm.internal.RunTestConfiguration;
    import stm.internal.SimulationInput;

    for i=1:length(simInputStructArray)
        if(stm.internal.readStopTest()==1)
            return;
        end
        try

            runCfgArray(i)=stm.internal.RunTestConfiguration(simInputStructArray{i}.Mode);
            runCfgArray(i).runningOnPCT=useParallel;

            if(simWatcherArray{i}.revertingFailed)
                runCfgArray(i).out.IsIncomplete=true;
                tmpmsg=getString(message('stm:ScriptsView:TestIterationIncompleteDueToEarlierFailures'));
                runCfgArray(i).addMessages({tmpmsg},{false});
                continue;
            end

            if isempty(simInputStructArray{i}.Model)
                msg=getString(message('stm:general:NoModelSpecified'));
                runCfgArray(i).addMessages({msg},{true});
                continue;
            end

            if(~runCfgArray(i).processTestCaseSettings(simInputStructArray{i}))
                continue;
            end

            runCfgArray(i).runPreload(simInputStructArray{i});
            mainModel=simWatcherArray{i}.mainModel;

            if(~simWatcherArray{i}.modelResolved)
                if~bdIsLoaded(mainModel)
                    load_system(mainModel);
                end
                simWatcherArray{i}.resolveModelToRun();
            end

            if useParallel
                if isequal(get_param(simWatcherArray{i}.mainModel,'Dirty'),'on')
                    errID='Simulink:Commands:ParsimUnsavedChanges';
                    unsavedError=getString(message(errID,simWatcherArray{i}.mainModel));
                    throw(MException(errID,unsavedError));
                end

                if isequal(get_param(simWatcherArray{i}.modelToRun,'Dirty'),'on')
                    errID='Simulink:Commands:ParsimUnsavedChanges';
                    unsavedError=getString(message(errID,simWatcherArray{i}.modelToRun));
                    throw(MException(errID,unsavedError));
                end
            end

            runCfgArray(i).modelToRun=simWatcherArray{i}.modelToRun;
            modelToRun=runCfgArray(i).modelToRun;
            runCfgArray(i).mainModel=mainModel;

            runCfgArray(i).SimulationInput=SimulationInput.getSimIn('ModelName',simWatcherArray{i}.modelToRun,...
            'HarnessOwner',simWatcherArray{i}.ownerName,'HarnessName',simWatcherArray{i}.harnessName,...
            'UseParallel',useParallel);

            if bdIsLibrary(modelToRun)||bdIsSubsystem(modelToRun)
                libID='Simulink:Engine:NoSimBlockDiagram';
                libError=getString(message(libID,modelToRun,get_param(modelToRun,'BlockDiagramType')));
                throw(MException(libID,libError));
            end

            simInputStructArray{i}.CoverageSettings=stm.internal.Coverage.getCoverageSettings(...
            simInputStructArray{i}.CallingFunction,simInputStructArray{i}.TestCaseId);

            if~simWatcherArray{i}.coverageSettingApplied

                simWatcherArray{i}.coverage=stm.internal.Coverage(simInputStructArray{i}.CoverageSettings,...
                simWatcherArray{i},runCfgArray(i));
                simWatcherArray{i}.coverageSettingApplied=true;
            end

            simWatcherArray{i}.testCaseId=simInputStructArray{i}.TestCaseId;
            simWatcherArray{i}.permutationId=simInputStructArray{i}.PermutationId;

            simInputStructArray{i}.testIteration.TestParameter.LoggedSignalSetId=runCfgArray(i).testIteration.TestParameter.LoggedSignalSetId;


            if(~isempty(runCfgArray(i).testIteration.TestParameter.ConfigName))
                runCfgArray(i).testSettings.configSet.ConfigName=runCfgArray(i).testIteration.TestParameter.ConfigName;
                runCfgArray(i).testSettings.configSet.ConfigRefPath='';
                runCfgArray(i).testSettings.configSet.VarName='';
                runCfgArray(i).testSettings.configSet.ConfigSetOverrideSetting=1;
            end

            if(~strcmp(runCfgArray(i).testSettings.configSet.ConfigName,simWatcherArray{i}.configName)||...
                ~strcmp(runCfgArray(i).testSettings.configSet.ConfigRefPath,simWatcherArray{i}.configRefPath)||...
                ~strcmp(runCfgArray(i).testSettings.configSet.VarName,simWatcherArray{i}.configVarName))



                simWatcherArray{i}.revertSettings(true);
                if(simWatcherArray{i}.revertingFailed)
                    runCfgArray(i).addMessages(simWatcherArray{i}.revertingErrors.messages,simWatcherArray{i}.revertingErrors.errorOrLog);
                    return;
                end
            end


            simWatcherArray{i}.originalTopModelDirty=get_param(simInputStructArray{i}.Model,'Dirty');
            runCfgArray(i).applyIterationSignalBuilderGroup(simWatcherArray{i});

            if(~strcmp(modelToRun,simInputStructArray{i}.Model))
                runCfgArray(i).modelUtil.HarnessName=modelToRun;
            else
                runCfgArray(i).modelUtil.HarnessName=[];
            end

            modelToRunDirty=strcmp(get_param(modelToRun,'Dirty'),'on');






            if(i-1>0)&&isequal(simWatcherArray{i-1}.permutationId,simWatcherArray{i}.permutationId)
                simWatcherArray{i}.refreshParameterOverrides=simWatcherArray{i-1}.refreshParameterOverrides;
            end

            SimulationInput.populateSimIn(runCfgArray(i),simInputStructArray{i},simWatcherArray{i});

            useParallel=runCfgArray(i).runningOnPCT;
            simInputArrayFeature=slfeature('STMSimulationInputArray');







            runCfgArray(i).useAssessmentsInfoFromRunCfg=false;
            if(simInputArrayFeature==2)||(simInputArrayFeature==1&&~useParallel)
                runCfgArray(i).assessmentsInfo=stm.internal.getAssessmentsInfo(stm.internal.getAssessmentsID(simInputStructArray{i}.TestCaseId));
                runCfgArray(i).useAssessmentsInfoFromRunCfg=true;
            end

            if(~isfield(simWatcherArray{i}.cleanupTestCase,'SimulationMode'))
                simWatcherArray{i}.cleanupTestCase.Dirty=get_param(modelToRun,'Dirty');
                simWatcherArray{i}.cleanupTestCase.SimulationMode=get_param(modelToRun,'SimulationMode');
            end

            SimulationInput.cleanupSignalBuilder(simWatcherArray{i});

            if slfeature('STMTestSequenceScenario')
                SimulationInput.cleanupTestSequenceScenario(simWatcherArray{i});
            end

            if~modelToRunDirty&&bdIsLoaded(modelToRun)&&strcmp(get_param(modelToRun,'Dirty'),'on')
                set_param(modelToRun,'Dirty','off');
            end

            msg=stm.internal.MRT.share.getString(('stm:general:TestExecQueued'));
            if~isempty(simInputStructArray{i}.IterationName)
                msg=[simInputStructArray{i}.IterationName,newline,msg];
            end
            stm.internal.Spinner.updateTestCaseSpinnerLabel(simInputStructArray{i}.TestCaseId,msg);
        catch me
            [tempErrors,tempErrorOrLog]=stm.internal.util.getMultipleErrors(me);
            runCfgArray(i).addMessages(tempErrors,tempErrorOrLog);
        end
    end
end
