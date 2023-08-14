function modelData=getSerializedJob(job)




    validateattributes(job,{'MultiSim.internal.MultiSimJob'},{'scalar'});

    modelData=struct;
    modelData.Version=simulink.simmanager.PartData(version);
    modelData.SimulationInputs=simulink.simmanager.PartData(job.SimulationManager.getOriginalSimulationInputs());
    modelData.SimulationData=simulink.simmanager.PartData(job.SimulationManager.SimulationData);
    modelData.SimulationMetadata=simulink.simmanager.PartData(job.SimulationManager.SimulationMetadata);
    modelData.SimulationMonitorData=simulink.simmanager.PartData(getSimulationMonitorData(job));
    modelData.DesignView=simulink.simmanager.PartData(getDesignView(job));
    modelData.FigureData=getFigureData(job);
    modelData.Layout=simulink.simmanager.PartData(job.Layout);
end

function monitorData=getSimulationMonitorData(job)
    m=mf.zero.Model;
    jobElement=simulink.simmanager.mm.Job(m);
    if~isempty(job.JobStatusDB.StartTime)
        jobElement.StartTime=job.JobStatusDB.StartTime;
    end

    if~isempty(job.JobStatusDB.StopTime)
        jobElement.FinishTime=job.JobStatusDB.StopTime;
    end

    createSimulationRuns(m,job.JobStatusDB.Status);
    jobElement.NumWorkers=job.JobStatusDB.NumWorkers;
    serializer=mf.zero.io.JSONSerializer;
    monitorData=serializer.serializeToString(m);
end

function designView=getDesignView(job)
    m=job.FigureManager.DataModel;
    serializer=mf.zero.io.JSONSerializer;
    designView=serializer.serializeToString(m);
end

function figData=getFigureData(job)
    figData=struct;
    figManager=job.FigureManager;
    for i=1:numel(figManager.FigureObjects)
        fieldName="Figure"+i;
        figObject=figManager.FigureObjects(i);
        m=figObject.DataModel;
        serializer=mf.zero.io.JSONSerializer;
        figProperties=serializer.serializeToString(m);
        figDataI=struct('MATLABFigure',simulink.simmanager.PartData(figObject.MATLABFigure),...
        'FigureProperties',simulink.simmanager.PartData(figProperties));
        figData.(fieldName)=figDataI;
    end
end

function createSimulationRuns(m,simulationRunData)
    simulationRuns=m.topLevelElements.SimulationRuns;
    for i=1:numel(simulationRunData)
        runData=simulationRunData(i);
        simulationRunStruct=struct('RunId',runData.RunId,...
        'State',runData.Status,...
        'StatusString',runData.StatusString,...
        'SimStatus',runData.SimStatus,...
        'Progress',runData.Progress,...
        'SimElapsedWallTime',runData.SimElapsedWallTime,...
        'ETA',runData.ETA,...
        'Machine',runData.Machine);

        simulationRun=simulink.simmanager.mm.SimulationRun(m,simulationRunStruct);
        simulationRuns.add(simulationRun);
    end
end
