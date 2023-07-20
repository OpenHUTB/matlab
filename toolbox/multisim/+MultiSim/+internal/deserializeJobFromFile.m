function job=deserializeJobFromFile(fileName)
    r=simulink.simmanager.FileReader(fileName);

    simInputs=r.getPart('/SimulationInputs',false);
    simData=r.getPart('/SimulationData',false);
    simMetadata=r.getPart('/SimulationMetadata',false);

    if(isempty(simInputs)||isempty(simData)||isempty(simMetadata))
        error(message("multisim:FileIO:CorruptFile",string(fileName)));
    end
    simMgr=Simulink.SimulationManager(simInputs);
    simMgr.setSimulationData(simData);
    simMgr.setSimulationMetadata(simMetadata);

    job=MultiSim.internal.MultiSimJob(simMgr,false);
    simMonitorDataString=r.getPart('/SimulationMonitorData',false);
    parser=mf.zero.io.JSONParser;
    parser.parseString(simMonitorDataString);
    simMonitorData=parser.Model.topLevelElements;
    addMonitorDataToJob(job,simMonitorData,simMetadata);

    designView=r.getPart('/DesignView',false);
    updateDesignView(r,job,designView);

    layout=r.getPart('/Layout',false);
    job.Layout=layout;

    job.IsDirty=false;
end

function addMonitorDataToJob(job,simMonitorData,simMetadata)
    job.JobStatusDB.updateData(simMonitorData,simMetadata);
end

function updateDesignView(r,job,designView)
    parser=mf.zero.io.JSONParser;
    parser.RemapUuids=true;
    parser.parseString(designView);
    job.FigureManager.updateDataModel(parser.Model);

    figureElements=parser.Model.topLevelElements.Figures;
    numFigures=figureElements.Size;

    for i=1:numFigures
        basePartName=['/FigureData/Figure',num2str(i)];
        MATLABFigure=r.getPart([basePartName,'/MATLABFigure'],false);
        figProperties=r.getPart([basePartName,'/FigureProperties'],false);
        job.FigureManager.addFigureWithProperties(i,MATLABFigure,figProperties);
    end
end