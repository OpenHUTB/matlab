










function simulateAndEvaluate(runCfgArray,simInStructCellArray,simWatchersCellArray,useParallel,resultSetId)
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

    fastRestart2SimInStructIndexMapping=[];
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

            currSaveFormat=get_param(locRunCfg.modelToRun,'SaveFormat');

            if~useFastRestart&&~strcmp(currSaveFormat,'StructureWithTime')&&~strcmp(currSaveFormat,'Dataset')
                locSimInput=locSimInput.setModelParameter('ReturnWorkspaceOutputs','on',...
                'SaveFormat','StructureWithTime');
            elseif useFastRestart
                locSimInput=locSimInput.setModelParameter('ReturnWorkspaceOutputs','on');
            end

            if useParallel&&~useFastRestart
                if strcmp(get_param(locRunCfg.modelToRun,'StreamToWorkspace'),'off')
                    locSimInput=locSimInput.setModelParameter('StreamToWorkspace','on',...
                    'InspectSignalLogs','on','SaveFormat','Dataset');
                end
            else
                if strcmp(get_param(locRunCfg.modelToRun,'StreamToWorkspace'),'on')
                    locSimInput=locSimInput.setModelParameter('StreamToWorkspace','off');
                end
            end



            locSimInput=locSimInput.setModelParameter('SDIOptimizeVisual','off');

            locSimInput=locSimInput.setPreSimFcn(@(x)preSimFcn(locRunCfg,locSimWatcher,locSimInStruct));

            locSimInput=locSimInput.setPostSimFcn(@(x)postSimFcn(x,locSimWatcher,locRunCfg,locSimInStruct,useParallel));










            uniqueId=append(num2str(simInStructCellArray{i}.PermutationId),"_",num2str(simInStructCellArray{i}.IterationId));
            locSimInput=locSimInput.setUserString(uniqueId);

            runCfgArray(i).out.preSimStreamedRun=stm.internal.util.getStreamedRunID(locSimInput.ModelName);
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
            fastRestart2SimInStructIndexMapping=[fastRestart2SimInStructIndexMapping,i];
        end
    end









    createSLSSMgrConnections(simInArray,simMgrRunIdsArray,uniqueIdsArray,...
    simInStructCellArray,simWatchersCellArray,resultSetId,useParallel,false,fastRestart2SimInStructIndexMapping);


    simInRevertIndexArray=createSLSSMgrConnections(simInFastRestartArray,simMgrRunIdsArray_FastRestart,...
    uniqueIdsArray_FastRestart,simInStructCellArray,simWatchersCellArray,resultSetId,useParallel,true,fastRestart2SimInStructIndexMapping);

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












function preSimFcn(runCfg,simWatcher,simInStruct)

    h=get_param(simWatcher.modelToRun,'Handle');
    dataId='STM_FiguresData';

    if~Simulink.BlockDiagramAssociatedData.isRegistered(h,dataId)
        Simulink.BlockDiagramAssociatedData.register(h,dataId,'any');
        currFigs=handle(sort(double(findall(0,'type','figure'))));
        Simulink.BlockDiagramAssociatedData.set(h,dataId,currFigs);
    end

    dataId='STM_SDIRunID';

    if~Simulink.BlockDiagramAssociatedData.isRegistered(h,dataId)
        Simulink.BlockDiagramAssociatedData.register(h,dataId,'any');
        runObj=Simulink.sdi.getCurrentSimulationRun(simWatcher.modelToRun);
        preSimRunID=0;
        if~isempty(runObj)
            preSimRunID=runObj.id;
        end
        Simulink.BlockDiagramAssociatedData.set(h,dataId,preSimRunID);
    end

    sigLoggingName=get_param(runCfg.modelToRun,'SignalLoggingName');
    signalLoggingOn=get_param(runCfg.modelToRun,'SignalLogging');
    funcHandle=@(~,~)stm.internal.RunTestConfiguration.getAssessmentsData(simInStruct,simWatcher,signalLoggingOn,sigLoggingName,runCfg);
    runCfg.assessmentHandle=stm.internal.MRT.share.attachAssessmentEvalParamCb(...
    runCfg.modelToRun,simInStruct.Mode,funcHandle);

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









function simOut=postSimFcn(simOut,simWatcher,runCfg,simInStruct,useParallel)

    if~isempty(simWatcher.SubsystemManager)

        simWatcher.SubsystemManager.cleanupWorkflowParameters(simWatcher.harnessName);
        simWatcher.SubsystemManager.workflowTeardown();
    end

    runObj=Simulink.sdi.getCurrentSimulationRun(simWatcher.modelToRun);
    if slfeature('STMReplaceOutputRun')>0
        try
            scenerioModel=evalin('base','scenerioModel');
            scenerioModelRun=Simulink.sdi.getCurrentSimulationRun(scenerioModel);
            if~isempty(scenerioModelRun)
                runObj=scenerioModelRun;
            end
        catch me
            if~isequal(me.identifier,'MATLAB:UndefinedFunction')
                rethrow(me);
            end
        end
    end

    if~isempty(runObj)
        runid=runObj.id;
    else
        if useParallel
            runid=Simulink.sdi.createRun;
        else
            runid=simInStruct.RunID;
        end
    end

    runCfg.out.RunID=runid;

    sigLoggingName=get_param(runCfg.modelToRun,'SignalLoggingName');
    dsmLoggingName=get_param(runCfg.modelToRun,'DSMLoggingName');
    codeExecutionProfileVarName='';
    if strcmpi(get_param(runCfg.modelToRun,'CodeExecutionProfiling'),'on')
        codeExecutionProfileVarName=get_param(runCfg.modelToRun,'CodeExecutionProfileVariable');
    end
    outportLoggingName='';
    stateLoggingName='';



    if strcmpi(get_param(runCfg.modelToRun,'SaveFormat'),'Dataset')||...
        (useParallel&&(isOverrideSettings(runCfg,'SaveFormat')||isOverrideSettings(runCfg,'SaveOutput')))
        outportLoggingName=get_param(runCfg.modelToRun,'OutputSaveName');
        stateLoggingName=get_param(runCfg.modelToRun,'StateSaveName');
    end

    varsAlreadyStreamed=stm.internal.util.locGetStreamedVars(sigLoggingName,outportLoggingName,...
    codeExecutionProfileVarName,dsmLoggingName,stateLoggingName);


    streamoutWksVars=sdi.Repository(1).getBlockStreamedWksVarsForRun(runid);

    tempStruct=struct;
    fieldNames=simOut.who;
    for ind=1:length(fieldNames)
        if~ismember(fieldNames{ind},varsAlreadyStreamed)&&~any(strcmp(streamoutWksVars,fieldNames{ind}))
            tempStruct.(fieldNames{ind})=simOut.get(fieldNames{ind});
        end
    end
    tempDataset=Simulink.SimulationOutput(tempStruct,simOut.getSimulationMetadata());

    ws=warning('off','SDI:sdi:notValidBaseWorkspaceVar');
    cleanupWarning=onCleanup(@()warning(ws));

    Simulink.sdi.addToRun(runid,'namevalue',{'simOut'},{tempDataset});

    simOut.postSimRunID=runid;
    if~isempty(runObj)
        runObj.UserString='';
    end

    noRet_Assessment=onCleanup(@()delete(runCfg.assessmentHandle));
    h=get_param(simWatcher.modelToRun,'Handle');
    dataId='STM_AssessmentsData';
    simOut.assessmentsData=[];
    try
        simOut.assessmentsData=Simulink.BlockDiagramAssociatedData.get(h,dataId);
        Simulink.BlockDiagramAssociatedData.unregister(h,dataId);
    catch me
        if~strcmp(me.identifier,'Simulink:AssociatedData:NotRegistered')
            rethrow(me);
        end
    end

    dataId='STM_SDIRunID';
    preSimRunID=[];
    try
        preSimRunID=Simulink.BlockDiagramAssociatedData.get(h,dataId);
    catch me
        if~strcmp(me.identifier,'Simulink:AssociatedData:NotRegistered')
            rethrow(me);
        end
    end
    simOut.preSimRunID=preSimRunID;
    Simulink.BlockDiagramAssociatedData.unregister(h,dataId);

    if useParallel
        workerRun=Simulink.sdi.WorkerRun(runid);
        localRun=workerRun.getLocalRun();
        if~isequal(simOut.preSimRunID,simOut.postSimRunID)&&~isempty(localRun)
            simOut.workerRun=workerRun;
            Simulink.sdi.sendWorkerRunToClient(localRun.Id);
        end

        dataId='STM_FiguresData';
        existingFigs=[];
        try
            existingFigs=Simulink.BlockDiagramAssociatedData.get(h,dataId);
            Simulink.BlockDiagramAssociatedData.unregister(h,dataId);
        catch me
            if~strcmp(me.identifier,'Simulink:AssociatedData:NotRegistered')
                rethrow(me);
            end
        end

        currFigs=handle(sort(double(findall(0,'type','figure'))));
        figsToCapture=setdiff(currFigs,existingFigs);
        figData=getByteStreamFromArray(figsToCapture);
        simOut.mlFigures=figData;

    end

    if(~isempty(simInStruct.CleanupScript)||...
        ~isempty(simInStruct.TestIteration.TestParameter.CleanupScript))
        existingFigs=handle(sort(double(findall(0,'type','figure'))));
        try
            runCfg.runCleanup(simInStruct,simOut,true);
        catch me
            simOut.cleanupCBException=me;
        end
        if useParallel
            currFigs=handle(sort(double(findall(0,'type','figure'))));
            simOut.cleanupCBMLFigures=getByteStreamFromArray(setdiff(currFigs,existingFigs));
        end
    end
end


function out=isOverrideSettings(runCfg,propertyName)
    out=false;
    [~,index]=ismember(propertyName,{runCfg.SimulationInput.ModelParameters.Name});
    if index~=0&&strcmp({runCfg.SimulationInput.ModelParameters(index).Value},'on')
        out=true;
    end
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
        simWatcher=simWatchersCellArray{index};
        runCfg=runCfgArray(index);

        if(isprop(simOut,'assessmentsData'))
            runCfg.out.assessmentsData=simOut.assessmentsData;
            simOut=simOut.removeProperty('assessmentsData');
        end

        stm.internal.SimulationInput.evaluateSimOut(simOut,useParallel,simInStruct,simWatcher,runCfg,resultSetId)
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

function simInRevertIndexArray=createSLSSMgrConnections(simInArray,simMgrRunIdsArray,...
    uniqueIdsArray,simInStructCellArray,simWatchersCellArray,resultSetId,useParallel,useFastRestart,fastRestart2SimInStructIndexMapping)

    slssMgr=slss.Manager;
    modelsConnected=string.empty;
    simInArrayLength=length(simInArray);
    fastRestartmodelToRun2SimInIndexMap=containers.Map('KeyType','char','ValueType','double');

    for i=1:simInArrayLength
        harnessToClose='';
        if(isa(simInArray(i),'sltest.harness.SimulationInput'))
            modelToRun=simInArray(i).HarnessName;
            harnessOwner=simInArray(i).HarnessOwner;
            key=[harnessOwner,'_',modelToRun];
            if~bdIsLoaded(modelToRun)
                stm.internal.util.loadHarness(simInArray(i).HarnessOwner,simInArray(i).HarnessName);
            end

            if i~=simInArrayLength
                closeHarness=locShouldCloseHarness(simInArray(i),simInArray(i+1));
            else
                closeHarness=locShouldCloseHarness(simInArray(i),'');
            end
            if closeHarness
                harnessToClose=modelToRun;
            end
        else
            modelToRun=simInArray(i).ModelName;
            key=modelToRun;
            if~bdIsLoaded(modelToRun)
                load_system(modelToRun);
            end
        end









        if~ismember(modelToRun,modelsConnected)
            idMap=containers.Map(simMgrRunIdsArray,uniqueIdsArray);
            slssMgrEventReceiverHandle=@(msg)slssMgrEventReceiver(msg,idMap,simInStructCellArray,resultSetId,false);
            id=slssMgr.connect(slssMgrEventReceiverHandle,modelToRun,useParallel);
            modelsConnected=[modelsConnected,string(modelToRun)];
        end

        if useFastRestart
            if~isKey(fastRestartmodelToRun2SimInIndexMap,key)
                simInStructIndex=fastRestart2SimInStructIndexMapping(i);
                fastRestartSetParam(modelToRun,simInStructCellArray{simInStructIndex},simWatchersCellArray{simInStructIndex});
                fastRestartmodelToRun2SimInIndexMap(key)=simInStructIndex;
            end
        end

        if~isempty(harnessToClose)
            close_system(harnessToClose,0);
        end
    end

    simInRevertIndexArray=cell2mat(fastRestartmodelToRun2SimInIndexMap.values);
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
