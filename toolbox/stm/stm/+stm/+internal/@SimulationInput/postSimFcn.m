









function simOut=postSimFcn(simOut,simWatcher,runCfg,simInStruct,useParallel)

    modelToRun=simInStruct.modelToRun;

    if~isempty(simWatcher.SubsystemManager)

        simWatcher.SubsystemManager.cleanupWorkflowParameters(simWatcher.harnessName);
        simWatcher.SubsystemManager.workflowTeardown();
    end


    if useParallel
        simOut.simWatcher=simWatcher;
        simOut.out=runCfg.out;
        simOut.ExternalInput=runCfg.SimulationInput.ExternalInput;

        if isfield(runCfg.out,'ExternalInputRunData')
            workerRun=Simulink.sdi.WorkerRun(runCfg.out.ExternalInputRunData.runID);
            localRun=workerRun.getLocalRun();

            if~isempty(localRun)
                simOut.ExternalInputRunDataworkerRun=workerRun;
                Simulink.sdi.sendWorkerRunToClient(localRun.Id);

            end
        end
    end

    simOut.ExternalInput=runCfg.SimulationInput.ExternalInput;
    simOut.ExternalInputRunData=runCfg.out.ExternalInputRunData;



    runObj=Simulink.sdi.getCurrentSimulationRun(modelToRun);
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

    sigLoggingName=get_param(modelToRun,'SignalLoggingName');
    dsmLoggingName=get_param(modelToRun,'DSMLoggingName');
    codeExecutionProfileVarName='';
    if strcmpi(get_param(modelToRun,'CodeExecutionProfiling'),'on')
        codeExecutionProfileVarName=get_param(modelToRun,'CodeExecutionProfileVariable');
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
    h=get_param(modelToRun,'Handle');
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
    if~isempty(preSimRunID)
        simOut.preSimRunID=preSimRunID;
        Simulink.BlockDiagramAssociatedData.unregister(h,dataId);
    end

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