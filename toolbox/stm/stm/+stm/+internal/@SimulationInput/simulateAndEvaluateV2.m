










function simulateAndEvaluateV2(runCfgArray,simInStructCellArray,simWatchersCellArray,useParallel,resultSetId)
    import stm.internal.SimulationInput;
    openPool=[];
    if(useParallel)
        openPool=gcp('nocreate');
        noRet3=onCleanup(@()deleteWorkers(useParallel,openPool));
    end

    numInputs=length(runCfgArray);
    simInArray=[];
    simInFastRestartArray=[];

    simMgrRunIdsArray=[];
    uniqueIdsArray=[];

    simMgrRunIdsArray_FastRestart=[];
    uniqueIdsArray_FastRestart=[];

    simInRevertIndexArray=[];

    simInputArrayFeature=slfeature('STMSimulationInputArray');
    TestSequenceScenarioFeature=slfeature('STMTestSequenceScenario');
    dbLocation=stm.internal.getRepositoryLocation;
    fastRestartModelHarness2indexMap=containers.Map('KeyType','char','ValueType','double');
    for i=1:numInputs
        if(stm.internal.readStopTest()==1)
            return;
        end



        if(~isempty(runCfgArray(i).out.messages)&&any(cell2mat(runCfgArray(i).out.errorOrLog)))
            try

                runCfgArray(i).runCleanup(simInStructCellArray{1},[],true);
            catch me
                SimulationInput.addExceptionMessages(runCfgArray(i),me);
            end
            runCfgArray(i).out.overridesilpilmode=simInStructCellArray{i}.OverrideSILPILMode;
            stm.internal.processSimOutResults(runCfgArray(i).out,simInStructCellArray{i}.PermutationId,simInStructCellArray{i}.IterationId,...
            simInStructCellArray{i}.TestCaseId,useParallel,resultSetId,simInStructCellArray{i}.RunID);
            continue;
        end

        try
            useFastRestart=simInStructCellArray{i}.IterationId>0&&simInStructCellArray{i}.FastRestartMode;

            locRunCfg=runCfgArray(i);
            locSimInStruct=simInStructCellArray{i};
            locSimWatcher=simWatchersCellArray{i};
            locSimInput=locRunCfg.SimulationInput;

            isfastRestartSimInRevert=false;
            if useFastRestart
                if(isa(locSimInput,'sltest.harness.SimulationInput'))
                    key=[locSimInput.HarnessOwner,'_',locSimInput.HarnessName];
                else
                    key=locSimInput.ModelName;
                end

                if~isKey(fastRestartModelHarness2indexMap,key)
                    isfastRestartSimInRevert=true;
                    simInRevertIndexArray=[simInRevertIndexArray,i];
                    fastRestartModelHarness2indexMap(key)=i;
                else
                    isfastRestartSimInRevert=false;
                end
            end



            locRunCfg.SimulationInput=locRunCfg.SimulationInput.setModelParameter('SDIOptimizeVisual','off');

            locSimInput.PreLoadFcn=@(x)stm.internal.SimulationInput.preloadFcn(locRunCfg,locSimInStruct,locSimWatcher,useParallel);
            locSimInput=locSimInput.setPostSimFcn(@(x)stm.internal.SimulationInput.postSimFcn(x,locSimWatcher,locRunCfg,locSimInStruct,useParallel));

            locSimInput=locSimInput.setPreSimFcn(@(x)stm.internal.SimulationInput.preSimFcn(x,locRunCfg,locSimWatcher,locSimInStruct,useParallel,simWatchersCellArray,i,isfastRestartSimInRevert,simInputArrayFeature,TestSequenceScenarioFeature));










            uniqueId=append(num2str(simInStructCellArray{i}.PermutationId),"_",num2str(simInStructCellArray{i}.IterationId));
            locSimInput=locSimInput.setUserString(uniqueId);
        catch me
            SimulationInput.addExceptionMessages(runCfgArray(i),me);
            stm.internal.processSimOutResults(runCfgArray(i).out,simInStructCellArray{i}.PermutationId,simInStructCellArray{i}.IterationId,...
            simInStructCellArray{i}.TestCaseId,useParallel,resultSetId,simInStructCellArray{i}.RunID);
            continue;
        end
        if~useFastRestart
            simInArray=[simInArray,locSimInput];
            simMgrRunIdsArray=[simMgrRunIdsArray,length(simInArray)];
            uniqueIdsArray=[uniqueIdsArray,uniqueId];
        else
            simInFastRestartArray=[simInFastRestartArray,locSimInput];
            simMgrRunIdsArray_FastRestart=[simMgrRunIdsArray_FastRestart,length(simInFastRestartArray)];
            uniqueIdsArray_FastRestart=[uniqueIdsArray_FastRestart,uniqueId];
        end
    end









    createSLSSMgrConnections(simInArray,simMgrRunIdsArray,uniqueIdsArray,...
    simInStructCellArray,resultSetId,useParallel);



    createSLSSMgrConnections(simInFastRestartArray,simMgrRunIdsArray_FastRestart,...
    uniqueIdsArray_FastRestart,simInStructCellArray,resultSetId,useParallel);

    noRet=onCleanup(@()clearSlssMgrConnections());

    id='Simulink:Logging:TopMdlOverrideUpdated';
    mdlRefLog=warning('off',id);
    oc=onCleanup(@()warning(mdlRefLog.state,id));

    id='Simulink:Commands:SimulationsWithErrors';
    simMgrError=warning('off',id);
    oc2=onCleanup(@()warning(simMgrError.state,id));

    id='Simulink:slbuild:unsavedMdlRefsAllowed';
    unsavedMdlRefId=warning('off',id);
    oc3=onCleanup(@()warning(unsavedMdlRefId.state,id));

    id='Simulink:slbuild:unsavedMdlRefsCause';
    unsavedMdlRefCauseId=warning('off',id);
    oc4=onCleanup(@()warning(unsavedMdlRefCauseId.state,id));

    id='Simulink:Commands:MultiSimExecuteError';
    multiSimErr=warning('off',id);
    oc5=onCleanup(@()warning(multiSimErr.state,id));

    id='Simulink:Commands:SimInputPrePostFcnError';
    simErr=warning('off',id);
    oc6=onCleanup(@()warning(simErr.state,id));


    rv=stm.internal.util.RestoreVariable(stm.internal.Coverage.CovSaveName);%#ok<NASGU>




    breakpoints=Simulink.Debug.BreakpointList.getAllBreakpoints();
    breakpoints=breakpoints(cellfun(@(bp)bp.isEnabled,breakpoints));
    cellfun(@disable,breakpoints);
    cleanupReenableBreakpoints=onCleanup(@()cellfun(@enable,breakpoints));

    if(~isempty(simInArray))
        [simMgr,lh1,lh2,stopObjCleanup]=prepareSimMgr(simInArray,false,...
        simInStructCellArray,simWatchersCellArray,runCfgArray,resultSetId,useParallel,openPool);
        oc=onCleanup(@()slssMgrEventReceiver([],[],[],[],true));
        simulate(simMgr);
        oc.delete;
    end

    if(~isempty(simInFastRestartArray))
        [simMgr,lh1,lh2,stopObjCleanup]=prepareSimMgr(simInFastRestartArray,true,...
        simInStructCellArray,simWatchersCellArray,runCfgArray,resultSetId,useParallel,openPool);
        noRet_fastRestart=onCleanup(@()revertParamsForFastRestart(simWatchersCellArray,simInRevertIndexArray));
        oc=onCleanup(@()slssMgrEventReceiver([],[],[],[],true));
        simulate(simMgr);
        oc.delete;
    end
end




function revertParamsForFastRestart(simWatchersCellArray,simInRevertIndexArray)
    for i=1:length(simInRevertIndexArray)
        harnessToClose='';
        index=simInRevertIndexArray(i);
        if~isempty(simWatchersCellArray{index}.harnessName)
            modelToChange=simWatchersCellArray{index}.harnessName;
            if~bdIsLoaded(modelToChange)
                stm.internal.util.deactivateAndloadHarness(simWatchersCellArray{index}.ownerName,simWatchersCellArray{index}.harnessName,simWatchersCellArray{index}.mainModel);
            end
            harnessToClose=modelToChange;
        else
            modelToChange=simWatchersCellArray{index}.mainModel;
            if~bdIsLoaded(modelToChange)
                load_system(modelToChange);
            end
        end

        simWatchersCellArray{index}.revertTestCaseSettings(true);

        if~isempty(harnessToClose)
            close_system(harnessToClose,0);
        end
    end
end

function[simMgr,lh1,lh2,stopObjCleanup]=prepareSimMgr(simIn,useFastRestart,...
    simInStructCellArray,simWatchersCellArray,runCfgArray,resultSetId,useParallel,openPool)
    simMgr=Simulink.SimulationManager(simIn);
    simMgr.Options.UseParallel=useParallel;

    if(useParallel)
        Simulink.sdi.enablePCTSupport('manual');





        dbLocation=stm.internal.getRepositoryLocation;
        if strcmp(openPool.Cluster.Type,'MJS')
            simMgr.Options.AttachedFiles={dbLocation};
            [~,name,ext]=fileparts(dbLocation);
            simMgr.Options.SetupFcn=@()connectToDB([name,ext],true);
        elseif runCfgArray(1).runningOnPCT
            simMgr.Options.SetupFcn=@()connectToDB(dbLocation,false);
        end
    end

    simMgr.Options.UseFastRestart=useFastRestart;
    simMgr.Options.AllowMultipleModels=true;
    simMgr.Options.TransferBaseWorkspaceVariables=true;

    args={simMgr,simInStructCellArray,simWatchersCellArray,runCfgArray,resultSetId};
    lh1=addlistener(simMgr,'SimulationFinished',@(~,evt)simEventCB(evt,args{:}));
    lh2=addlistener(simMgr,'SimulationAborted',@(~,evt)simEventCB(evt,args{:}));
    stopObj=stm.internal.STMStop(simMgr);
    stopObj.startTimer();
    stopObjCleanup=onCleanup(@()stopObj.stopTimer());
end

function deleteWorkers(useParallel,openPool)
    if(useParallel&&isempty(openPool))
        delete(gcp('nocreate'))
    end
end


function connectToDB(dbFileName,isMPS)

    if isMPS
        dbLocation=which(dbFileName);
        stm.internal.connectRepository(dbLocation);
    else

        stm.internal.connectRepository(dbFileName);
    end
end

function clearSlssMgrConnections()
    m=slss.Manager;
    arrayfun(@(slot)m.disconnect(slot.Id),m.getSlots);
end







function simEventCB(evtData,simMgr,simInStructCellArray,simWatchersCellArray,runCfgArray,resultSetId)



    useParallel=simMgr.Options.UseParallel;
    if strcmp(evtData.EventName,'SimulationAborted')||stm.internal.readStopTest==1
        simMgr.cancel();
    elseif strcmp(evtData.EventName,'SimulationFinished')

        simOut=evtData.SimulationOutput;

        userString=simOut.SimulationMetadata.UserString;
        splitStr=strsplit(userString,"_");
        permutationId=str2double(splitStr{1});
        iterationId=str2double(splitStr{2});
        index=0;

        for i=1:length(simInStructCellArray)
            if(simInStructCellArray{i}.PermutationId==permutationId&&simInStructCellArray{i}.IterationId==iterationId)
                index=i;
                break;
            end
        end

        simInStruct=simInStructCellArray{index};


        if(isprop(simOut,'simWatcher'))
            simWatcher=simOut.simWatcher;
            simOut=simOut.removeProperty('simWatcher');
        else
            simWatcher=simWatchersCellArray{index};
        end

        runCfg=runCfgArray(index);

        if(isprop(simOut,'out'))
            runCfg.out=simOut.out;
            simOut=simOut.removeProperty('out');
        end

        if(isprop(simOut,'ExternalInput'))
            runCfg.SimulationInput.ExternalInput=simOut.ExternalInput;
            simOut=simOut.removeProperty('ExternalInput');
        end

        if(isprop(simOut,'assessmentsData'))
            runCfg.out.assessmentsData=simOut.assessmentsData;
            simOut=simOut.removeProperty('assessmentsData');
        end

        if(isfield(runCfg.out,'overridesilpilmode'))
            runCfg.out.RunID=0;
            stm.internal.processSimOutResults(runCfg.out,simInStruct.PermutationId,simInStruct.IterationId,...
            simInStruct.TestCaseId,useParallel,resultSetId,simInStruct.RunID);
        else
            stm.internal.SimulationInput.evaluateSimOut(simOut,useParallel,simInStruct,simWatcher,runCfg,resultSetId);
        end
    end
end


function slssMgrEventReceiver(msg,idMap,simInStructCellArray,resultSetId,clearMap)
    persistent statusMap;
    if clearMap
        statusMap=[];
        return;
    end

    if isempty(statusMap)
        statusMap=containers.Map;
    end

    keyVals=keys(idMap);
    reqKey='';
    for i=1:length(keyVals)
        if(keyVals{i}==msg.RunId)
            reqKey=keyVals{i};
            break;
        end
    end

    if(~isempty(reqKey))
        uniqueId=idMap(reqKey);
        splitStr=strsplit(uniqueId,"_");
        permutationId=str2double(splitStr{1});
        iterationId=str2double(splitStr{2});

        for i=1:length(simInStructCellArray)
            if(simInStructCellArray{i}.PermutationId==permutationId&&simInStructCellArray{i}.IterationId==iterationId)
                index=i;
                break;
            end
        end

        simInStruct=simInStructCellArray{index};

        if~isKey(statusMap,int2str(msg.RunId))
            stm.internal.updateTestCaseResultOutcome(resultSetId,...
            simInStruct.IterationId,simInStruct.TestCaseId,uint32(sltest.testmanager.TestResultOutcomeTypes.Running));
            statusMap(int2str(msg.RunId))=msg.Model;
        else
            if isfield(msg,'SimStatus')&&isequal(msg.SimStatus,getString(message('Simulink:Engine:SimStatusRunning')))
                statusMap(int2str(msg.RunId))='Running';
            end
        end

        spinnerMsg=constructStatusUpdateString(statusMap,msg);

        if~isempty(spinnerMsg)
            if~isempty(simInStruct.IterationName)
                spinnerMsg=[simInStruct.IterationName,newline,spinnerMsg];
            end
            stm.internal.Spinner.updateTestCaseSpinnerLabel(simInStruct.TestCaseId,...
            spinnerMsg);
        end
    end
end

function bool=locShouldCloseHarness(simInput1,simInput2)
    import stm.internal.SimulationInput;
    nextHarnessString='';
    nextMainModel='';
    bool=false;
    if~isa(simInput1,'sltest.harness.SimulationInput')
        return;
    end
    if~isempty(simInput2)&&...
        isa(simInput2,'sltest.harness.SimulationInput')
        nextMainModel=simInput2.ModelName;
        nextHarnessString=simInput2.HarnessName;
    end

    bool=SimulationInput.shouldCloseHarness(simInput1.HarnessName,simInput1.ModelName,...
    nextMainModel,nextHarnessString);
end

function spinnerMsg=constructStatusUpdateString(statusMap,msg)
    spinnerMsg=[];
    if isfield(msg,'StatusString')
        if contains(msg.StatusString,...
            getString(message('Simulink:Engine:Comp_Start')))
            spinnerMsg=getString(message('stm:Execution:CompilingModel',msg.Model));
        else
            spinnerMsg=msg.StatusString;
        end
    elseif isfield(msg,'Progress')&&isKey(statusMap,int2str(msg.RunId))...
        &&isequal(statusMap(int2str(msg.RunId)),'Running')
        spinnerMsg=getString(message('stm:Execution:SimProgress',int2str(msg.Progress)));
    end
end

function createSLSSMgrConnections(simInArray,simMgrRunIdsArray,...
    uniqueIdsArray,simInStructCellArray,resultSetId,useParallel)

    slssMgr=slss.Manager;
    modelsConnected=string.empty;
    simInArrayLength=length(simInArray);
    for i=1:simInArrayLength
        if(isa(simInArray(i),'sltest.harness.SimulationInput'))
            modelToRun=simInArray(i).HarnessName;
        else
            modelToRun=simInArray(i).ModelName;
        end









        if~ismember(modelToRun,modelsConnected)
            idMap=containers.Map(simMgrRunIdsArray,uniqueIdsArray);
            slssMgrEventReceiverHandle=@(msg)slssMgrEventReceiver(msg,idMap,simInStructCellArray,resultSetId,false);
            id=slssMgr.connect(slssMgrEventReceiverHandle,modelToRun,useParallel);
            modelsConnected=[modelsConnected,string(modelToRun)];
        end
    end
end

function simulate(simMgr)
    if(stm.internal.util.getFeatureFlag('MultipleHarnessOpen')>0)
        slfeature('MultipleHarnessOpen',0);
    end
    sltest.internal.Events.getInstance.notifySimMgrConfigured;

    if sltest.testmanager.getpref('ShowSimulationLogs','IncludeOnCommandPrompt')
        simMgr.run;
    else
        [~]=evalc('simMgr.run');
    end
end
