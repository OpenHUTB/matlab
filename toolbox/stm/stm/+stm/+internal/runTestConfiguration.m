function out=runTestConfiguration(simInput,runID,simWatcher,saveRunTo,...
    inputDataSetsRunFile,inputSignalGroupRunFile,varargin)















    moveRun=true;
    if nargin==7
        moveRun=varargin{1};
    end

    saveSimOutTo='';
    if nargin==8
        saveSimOutTo=varargin{2};
    end




    simIndex=1;
    if nargin==9
        simIndex=varargin{3};
    end

    runcfg=runTestConfigurationHelper(simInput,runID,simWatcher,saveRunTo,...
    inputDataSetsRunFile,inputSignalGroupRunFile,moveRun,saveSimOutTo,simIndex);
    out=runcfg.out;

    out.OutputSignalSetUsed=stm.internal.MRT.utility.getLoggedSignalSet(simInput);
end

function runcfg=runTestConfigurationHelper(simInput,runID,simWatcher,...
    saveRunTo,inputDataSetsRunFile,inputSignalGroupRunFile,moveRun,saveSimOutTo,simIndex)
    import stm.internal.RunTestConfiguration;
    warnReporter=stm.internal.slrealtime.RTWarningDetector();
    simOut=[];


    warnState=warning('off','backtrace');
    oc=onCleanup(@()warning(warnState));

    runcfg=stm.internal.RunTestConfiguration(simInput.Mode);
    runcfg.runningOnPCT=~isempty(saveRunTo);

    isIncomplete=false;
    function helperMarkIncomplete(~,~)
        isIncomplete=true;
    end

    currentFeat2=slfeature('SimulationMetadata',2);
    featureReset2=onCleanup(@()slfeature('SimulationMetadata',currentFeat2));

    try
        model=simInput.Model;
        simWatcher.testCaseId=simInput.TestCaseId;
        simWatcher.permutationId=simInput.PermutationId;


        if simInput.RunOnTarget
            if slfeature('STMUseGenericRealTime')==0
                if~(stm.internal.slrealtime.checkxpctarget())
                    error(message('stm:realtime:RTNotInstalled'));
                end
                try
                    runcfg.out=stm.internal.slrealtime.runOnTarget(simInput,runID,simWatcher,saveRunTo,inputSignalGroupRunFile);
                catch me
                    [tempErrors,tempErrorOrLog]=stm.internal.util.getMultipleErrors(me);
                    runcfg.addMessages(tempErrors,tempErrorOrLog);
                end
                return;
            else

                if~(stm.internal.slrealtime.checkxpctarget())
                    error(message('stm:realtime:RTNotInstalled'));
                end
                try
                    runcfg.out=stm.internal.genericrealtime.runOnTarget(simInput,runID,simWatcher,saveRunTo,inputSignalGroupRunFile,moveRun);
                catch me
                    [tempErrors,tempErrorOrLog]=stm.internal.util.getMultipleErrors(me);
                    runcfg.addMessages(tempErrors,tempErrorOrLog);
                end
                return;
            end
        end





        if(simWatcher.revertingFailed)
            runcfg.out.IsIncomplete=true;
            tmpmsg=getString(message('stm:ScriptsView:TestIterationIncompleteDueToEarlierFailures'));
            runcfg.addMessages({tmpmsg},{false});
            return;
        end

        if isempty(model)
            msg=getString(message('stm:general:NoModelSpecified'));
            runcfg.addMessages({msg},{true});
            return;
        end

        if(~runcfg.processTestCaseSettings(simInput))
            return;
        end

        runcfg.runPreload(simInput);

        if(~simWatcher.modelResolved)
            simWatcher.modelsAlreadyLoaded=find_system('type','block_diagram');
        end


        stm.internal.Spinner.updateTestCaseSpinnerLabel(simInput.TestCaseId,...
        getString(message('stm:general:LoadModel')));
        if(~isa(simWatcher.simModel,'stm.internal.util.SimulinkModel'))
            simWatcher.simModel=stm.internal.util.SimulinkModel(model,simInput.SubSystem);
        end
        runcfg.modelUtil=stm.internal.util.SimulinkModel(model,simInput.SubSystem);

        h=addlistener(runcfg.modelUtil,'ModelStopped',@helperMarkIncomplete);
        ocd=onCleanup(@()delete(h));

        if(~simWatcher.modelResolved)
            simWatcher.resolveModelToRun();
        end
        runcfg.modelToRun=simWatcher.modelToRun;
        runcfg.mainModel=simWatcher.mainModel;

        if runcfg.runUsingSimIn
            runcfg.SimulationInput=stm.internal.SimulationInput.getSimIn('ModelName',simWatcher.modelToRun,...
            'HarnessOwner',simWatcher.ownerName,'HarnessName',simWatcher.harnessName);
        elseif simWatcher.fastRestart

            simMode=simInput.Mode;
            if(isempty(simMode))
                simMode='Normal';
            end
            if(~isempty(simWatcher.componentUnderTest))

                simMode=get_param(runcfg.modelToRun,'simulationmode');
            end

            if(~strcmpi(simMode,'Normal')&&~strcmpi(simMode,'Accelerator'))
                runcfg.addMessages({getString(message('stm:general:FastRestartNotSupported'))},{true});
                RunTestConfiguration.deleteModelUtil(runcfg.modelUtil);
                return;
            end
        end


        if bdIsLibrary(runcfg.modelToRun)||bdIsSubsystem(runcfg.modelToRun)
            libID='Simulink:Engine:NoSimBlockDiagram';
            libError=getString(message(libID,runcfg.modelToRun,get_param(runcfg.modelToRun,'BlockDiagramType')));
            throw(MException(libID,libError));
        end

        currModelStatus=get_param(runcfg.modelToRun,'SimulationStatus');

        fRestart=get_param(runcfg.modelToRun,'InitializeInteractiveRuns');
        isFSOn=strcmp(fRestart,'on');


        if(strcmpi(currModelStatus,'stopped')||isFSOn)

            if(~strcmp(runcfg.modelToRun,model))
                runcfg.modelUtil.HarnessName=runcfg.modelToRun;
            end

            me=runcfg.runPostload(simInput,simWatcher);
            if~isempty(me)
                rethrow(me);
            end


            simWatcher.originalTopModelDirty=get_param(simInput.Model,'Dirty');


            stm.internal.Spinner.updateTestCaseSpinnerLabel(simInput.TestCaseId,...
            getString(message('stm:general:SimModel')));
            [simOut,streamedRunID,sigLoggingName,outportLoggingName,...
            dsmLoggingName,codeExecutionProfileVarName,verifyOut,stateLoggingName]=...
            runcfg.simulate(simInput,simWatcher,...
            inputDataSetsRunFile,inputSignalGroupRunFile,simIndex);
            if(simWatcher.revertingFailed)
                runcfg.addMessages(simWatcher.revertingErrors.messages,simWatcher.revertingErrors.errorOrLog);
            end



            if(simInput.CacheSimOut)
                runcfg.out.simOut=simOut;
            end

            sdiEngine=Simulink.sdi.Instance.engine;

            ws=warning('off','SDI:sdi:notValidBaseWorkspaceVar');
            cleanupWarning=onCleanup(@()warning(ws));

            if(~runcfg.runningOnPCT)
                if(streamedRunID==0)
                    runcfg.out.RunID=runID;
                else




                    if moveRun
                        RunTestConfiguration.moveRunToApp(streamedRunID);
                    end
                    runcfg.out.RunID=streamedRunID;
                end





                if(~isempty(simOut))
                    varsAlreadyStreamed=stm.internal.util.locGetStreamedVars(sigLoggingName,outportLoggingName,...
                    codeExecutionProfileVarName,dsmLoggingName,stateLoggingName);


                    streamoutWksVars=sdi.Repository(1).getBlockStreamedWksVarsForRun(runcfg.out.RunID);

                    tempStruct=struct;
                    fieldNames=simOut.who;
                    for ind=1:length(fieldNames)
                        if~ismember(fieldNames{ind},varsAlreadyStreamed)&&~any(strcmp(streamoutWksVars,fieldNames{ind}))
                            tempStruct.(fieldNames{ind})=simOut.get(fieldNames{ind});
                        end
                    end
                    metadata=simOut.getSimulationMetadata();
                    tempDataset=Simulink.SimulationOutput(tempStruct,metadata);
                    Simulink.sdi.addToRun(runcfg.out.RunID,'namevalue',{'simOut'},{tempDataset});
                end
                if slfeature('STMOutputTriggering')>0
                    simInput=stm.internal.trigger.filterSignalLoggingOnTriggers(streamedRunID,simInput,simOut);
                    runcfg.out.OutputTriggerInfo=simInput.OutputTriggering;
                end
            else
                try
                    if(isfield(simInput,'RunningOnMRT')&&simInput.RunningOnMRT)
                        save(saveRunTo,'simOut','verifyOut');
                    else
                        if((~isempty(simOut)||~isempty(verifyOut)))







                            fieldNames=simOut.who;
                            if(~isempty(fieldNames)&&isequal(streamedRunID,0))
                                streamedRunID=Simulink.sdi.createRun;
                                Simulink.sdi.addToRun(streamedRunID,'vars',simOut);
                            end
                            if(streamedRunID>0)
                                stm.internal.saveRunToMLDATX(saveRunTo,streamedRunID);
                            end





                            if(~isempty(saveSimOutTo)&&simInput.CacheSimOut)
                                save(saveSimOutTo,'simOut','verifyOut');
                            end
                        end
                    end
                catch
                end
            end

            if(~runcfg.runningOnPCT)
                if(sdiEngine.getSignalCount(runcfg.out.RunID)==0)
                    noLoggedDataMsg=getString(message('stm:general:NoLoggedSignals',runcfg.modelToRun));
                    runcfg.addMessages({noLoggedDataMsg},{false});
                end
            end
        else

            msg=getString(message('stm:general:CannotRunModelNotStopped',runcfg.modelToRun));
            runcfg.addMessages({msg},{true});
        end
    catch me
        addExceptionMessages(runcfg,me);

        if runcfg.runUsingSimIn

            runcfg.out.overridesilpilmode=simInput.OverrideSILPILMode;
        else

            runcfg.out.overridesilpilmode=false;
        end
    end

    try

        simInArrayFeature=slfeature('STMSimulationInputArray');
        runcfg.runCleanup(simInput,simOut,simInArrayFeature>0);
    catch me
        addExceptionMessages(runcfg,me);
    end

    RunTestConfiguration.deleteModelUtil(runcfg.modelUtil);


    if(~runcfg.out.IsIncomplete)
        runcfg.out.IsIncomplete=isIncomplete;
    end


    warnings=warnReporter.DetectedWarnings;
    for i=1:numel(warnings)
        runcfg.out.messages{end+1}=stm.internal.util.getDiagnosticMessage(warnings(i));
        runcfg.out.errorOrLog{end+1}=false;
    end
end

function addExceptionMessages(runcfg,me)
    [tempErrors,tempErrorOrLog]=stm.internal.util.getMultipleErrors(me);
    runcfg.addMessages(tempErrors,tempErrorOrLog);
end

