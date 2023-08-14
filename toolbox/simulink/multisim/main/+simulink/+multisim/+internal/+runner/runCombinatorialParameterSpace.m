function out=runCombinatorialParameterSpace(modelHandle,designStudy)

    import simulink.multisim.internal.*;

    if simulink.multisim.internal.anyBlockDialogOpenForModel(modelHandle)
        error(message("multisim:SetupGUI:CloseBlockDialogs"));
    end

    throwErrorOnDuplicateParameterSpecification(designStudy);
    validateDesignStudy(designStudy);

    oldStatusString=get_param(modelHandle,"StatusString");
    cleanup=onCleanup(@()set_param(modelHandle,"StatusString",oldStatusString));
    set_param(modelHandle,"StatusString",getString(message("multisim:SetupGUI:MultiSimSettingUpSim")));

    paramSpaceSampler=sampler.CombinatorialParameterSpace(designStudy.ParameterSpace);
    designPoints=paramSpaceSampler.createDesignPoints();

    if isempty(designPoints)
        error(message("multisim:SetupGUI:EmptyDesignStudy",designStudy.Label));
    end

    modelName=get_param(modelHandle,"Name");
    if designStudy.RunOptions.UseParallel
        errorOutIfModelIsDirty(modelName);
    end
    simInputs=createSimulationInputsFromDesignPoints(modelName,designPoints);

    forRunAll=true;
    simMgr=Simulink.SimulationManager(simInputs,forRunAll);

    simMgr.Options.UseParallel=designStudy.RunOptions.UseParallel;
    simMgr.Options.TransferBaseWorkspaceVariables=true;

    dataId=simulink.multisim.internal.blockDiagramAssociatedDataId();
    bdData=Simulink.BlockDiagramAssociatedData.get(modelHandle,dataId);

    multiSimManager=MultiSim.internal.MultiSimManager.getMultiSimManager;

    if isJobViewerMarkedForReuse(multiSimManager)
        bdData.JobViewer=multiSimManager.addJob(simMgr);
        bdData.SimulationJob=bdData.JobViewer.Job;
    elseif isfield(bdData,"JobViewer")&&~isempty(bdData.JobViewer)
        bdData.JobViewer.updateJob(simMgr);
        bdData.SimulationJob=bdData.JobViewer.Job;
    else
        bdData.JobViewer=[];
        bdData.SimulationJob=MultiSim.internal.MultiSimJob(simMgr);
    end
    bdData.IsSimulationJobActive=true;
    Simulink.BlockDiagramAssociatedData.set(modelHandle,dataId,bdData);

    simMgr.Options.ShowSimulationManager=true;
    simMgr.Options.ShowProgress=false;

    fastRestart=matlab.lang.OnOffSwitchState(get_param(modelHandle,"FastRestart"));
    simMgr.Options.UseFastRestart=logical(fastRestart);

    delete(cleanup);

    out=simMgr.run();
end

function errorOutIfModelIsDirty(modelName)
    isModelDirty=strcmp(get_param(modelName,"Dirty"),'on');
    if isModelDirty
        error(message('Simulink:Commands:ParsimUnsavedChanges',modelName));
    end
end

function TF=isJobViewerMarkedForReuse(multiSimManager)
    isJobWindowSet=~isempty(multiSimManager.JobWindow);
    TF=isJobWindowSet&&multiSimManager.JobWindow.ReuseWindowForNextJob;
end