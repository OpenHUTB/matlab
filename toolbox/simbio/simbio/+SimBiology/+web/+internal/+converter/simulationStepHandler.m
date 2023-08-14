function out=simulationStepHandler(action,varargin)

    switch(action)
    case 'getSimulationStep'
        out=getSimulationStep(varargin{:});
    case 'populateEnsembleRunInfo'
        out=populateEnsembleRunInfo(varargin{:});
    case 'populateSensitivityInfo'
        out=populateSensitivityInfo(varargin{:});
    end

end

function simulationStep=getSimulationStep(taskNode,modelSessionID)


    stopTimeNode=getField(taskNode,'StopTime');


    simulationStep=struct;
    simulationStep.description='';
    simulationStep.enabled=true;
    simulationStep.internal=getInternalStructTemplate;
    simulationStep.name='Simulation';
    simulationStep.sensitivityDefined=false;
    simulationStep.stopTime=getAttribute(stopTimeNode,'TaskTime');
    simulationStep.stopTimeUnits=getAttribute(stopTimeNode,'TaskUnits');
    simulationStep.stopTimeUseConfigset=~getAttribute(stopTimeNode,'TaskSpecific');
    simulationStep.type='Simulation';
    simulationStep.version=1;


    if isempty(simulationStep.stopTimeUnits)
        model=getModelFromSessionID(modelSessionID);
        if~isempty(model)
            cs=getconfigset(model,'default');
            simulationStep.stopTimeUnits=cs.TimeUnits;
        end
    end

end

function simulationStep=populateSensitivityInfo(simulationStep,taskNode,modelSessionID)


    simulationStep.sensitivityDefined=true;
    simulationStep.type='Sensitivity';


    simulationStep.internal.id=5;
    simulationStep.internal.lastSensitivityDefined=false;
    simulationStep.internal.outputArguments={'results'};


    sensitivityNode=getField(taskNode,'SASettings');
    simulationStep.normalization=getAttribute(sensitivityNode,'Normalization');


    simulationStep.sensitivity=getSensitivityTableInfo(taskNode,modelSessionID);

end

function sensitivityInfo=getSensitivityTableInfo(taskNode,sessionID)

    sensitivityNodes=getField(taskNode.SensitivityTable,'SensitivityRow');

    if isempty(sensitivityNodes)
        sensitivityInfo=[];
        return;
    end


    model=getModelFromSessionID(sessionID);


    template=getSensitivityRowTemplate;
    sensitivityInfo=repmat(template,1,numel(sensitivityNodes));

    for i=1:numel(sensitivityNodes)
        sensitivityInfo(i).name=getAttribute(sensitivityNodes(i),'Name');
        sensitivityInfo(i).input=getAttribute(sensitivityNodes(i),'Input');
        sensitivityInfo(i).output=getAttribute(sensitivityNodes(i),'Output');

        obj=getObject(model,sensitivityInfo(i).name);
        if~isempty(obj)
            sensitivityInfo(i).sessionID=obj.sessionID;
            sensitivityInfo(i).UUID=obj.UUID;
            sensitivityInfo(i).type=obj.Type;
        end
    end

end

function out=getSensitivityRowTemplate

    out.input=false;
    out.isChild=[];
    out.isUndefined=false;
    out.message={};
    out.name='';
    out.output=false;
    out.sessionID=-1;
    out.UUID=-1;
    out.type='';

end

function simulationStep=populateEnsembleRunInfo(simulationStep,taskNode,modelSessionID)

    cs=getconfigsetFromModelSessionID(modelSessionID);


    simulationStep.name='Ensemble Run';
    simulationStep.type='Ensemble Run';


    simulationStep.internal.id=2;
    simulationStep.internal.outputArguments={'results'};
    simulationStep.internal.solverTypeInit=true;


    erNode=getField(taskNode,'ERSettings');
    simulationStep.interpolation=getAttribute(erNode,'Interpolation');
    simulationStep.numberOfRuns=getAttribute(erNode,'NumOfRuns');


    logDecimation=getField(taskNode,'LogDecimation');
    simulationStep.logDecimationUseConfigset=true;
    simulationStep.logDecimation=1;


    if~isempty(logDecimation)
        simulationStep.logDecimationUseConfigset=~getAttribute(logDecimation,'TaskSpecific');
        simulationStep.logDecimation=getAttribute(logDecimation,'TaskLogDecimation');



        if simulationStep.logDecimationUseConfigset&&~isempty(cs)&&ismember(cs.SolverType,{'ssa','expltau','impltau'})
            simulationStep.logDecimation=cs.SolverOptions.LogDecimation;
        end
    end


    solverNode=getField(taskNode,'Solver');
    solverType.taskSolver=getAttribute(solverNode,'TaskSolver');
    solverType.taskSpecific=getAttribute(solverNode,'TaskSpecific');


    if~isempty(cs)

        if isempty(solverType)
            solverType.taskSolver=cs.SolverType;
        else
            if~solverType.taskSpecific
                solverType.taskSolver=cs.SolverType;
            end
        end
    else
        solverType.taskSolver='';
    end


    simulationStep.solverType=getEnsembleRunSolverType(solverType.taskSolver);

end






function solverType=getEnsembleRunSolverType(descriptionStr)

    switch descriptionStr
    case{'explicit tau','expltau'}
        solverType='expltau';
    case{'implicit tau','impltau'}
        solverType='impltau';
    case 'stochastic'
        solverType='ssa';
    otherwise
        solverType='ssa';
    end

end

function out=getAttribute(node,attribute,varargin)

    out=SimBiology.web.internal.converter.utilhandler('getAttribute',node,attribute,varargin{:});

end

function cs=getconfigsetFromModelSessionID(modelSessionID)

    model=getModelFromSessionID(modelSessionID);
    if~isempty(model)
        cs=getconfigset(model,'default');
    else
        cs=[];
    end

end

function out=getField(node,field)

    out=SimBiology.web.internal.converter.utilhandler('getField',node,field);

end

function out=getInternalStructTemplate

    out=SimBiology.web.internal.converter.utilhandler('getInternalStructTemplate');

end

function model=getModelFromSessionID(sessionID)

    model=SimBiology.web.modelhandler('getModelFromSessionID',sessionID);

end

function obj=getObject(model,name)

    obj=SimBiology.web.internal.converter.utilhandler('getObject',model,name);

end
