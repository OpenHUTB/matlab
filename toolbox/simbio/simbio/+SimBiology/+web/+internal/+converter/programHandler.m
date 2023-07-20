function out=programHandler(action,varargin)

    switch(action)
    case 'defineCustomProgram'
        out=defineCustomProgram(varargin{:});
    case 'defineEnsembleRunProgram'
        out=defineEnsembleRunProgram(varargin{:});
    case 'defineFitProgram'
        out=defineFitProgram(varargin{:});
    case 'defineGroupSimulationProgram'
        out=defineGroupSimulationProgram(varargin{:});
    case 'defineNCAProgram'
        out=defineNCAProgram(varargin{:});
    case 'defineSensitivityProgram'
        out=defineSensitivityProgram(varargin{:});
    case 'defineSimulationProgram'
        out=defineSimulationProgram(varargin{:});
    case 'defineScanProgram'
        out=defineScanProgram(varargin{:});
    case 'defineScanWithSensitivitiesProgram'
        out=defineScanWithSensitivitiesProgram(varargin{:});
    case 'getProgramType'
        out=getProgramType(varargin{:});
    end

end

function type=getProgramType(node)


    type=getAttribute(node,'Category');


    if strcmp(type,'Simulation')


        bookmarkNode=getField(node,'Bookmark');
        if~isempty(bookmarkNode)
            type='Search';
        end
    end


    if strcmp(type,'')


        customSettingsNode=getField(node,'CustomSettings');
        if~isempty(customSettingsNode)
            type='Custom';
        end
    end

end

function program=defineCustomProgram(projectConverter,node,modelSessionID,projectVersion)


    program=getProgramStructTemplate;
    program.programName=getAttribute(node,'Name');
    steps={};


    steps{end+1}=getDescriptionStep(node);


    program.programType=11;


    modelStep=getModelStep(node,modelSessionID,projectVersion);
    modelStep.enabled=true;
    modelStep.internal.id=2;
    modelStep.internal.args.supportStatesToLog=false;
    modelStep.internal.args.supportsAccelerate=false;



    modelStep.explorer.sliders=[];


    messagesStep=getMessagesStep;
    messagesStep.internal.id=4;


    customTaskInfo=getCustomTaskInfo(projectConverter,node,modelSessionID,projectVersion);

    steps{end+1}=getCustomDataStep(customTaskInfo.dataNames);
    steps{end+1}=modelStep;
    steps{end+1}=getCustomCodeStep(customTaskInfo);
    steps{end+1}=messagesStep;
    program.steps=steps;

end

function program=defineEnsembleRunProgram(node,modelSessionID,projectVersion)


    program=getProgramStructTemplate;
    program.programName=getAttribute(node,'Name');
    steps={};


    steps{end+1}=getDescriptionStep(node);


    program.programType=5;


    modelStep=getModelStep(node,modelSessionID,projectVersion);
    modelStep.internal.args.supportDose=false;
    modelStep.internal.isSetup=true;
    modelStep.internal.id=1;
    steps{end+1}=modelStep;


    simulationStep=getSimulationStep(node,modelSessionID);
    simulationStep=populateEnsembleRunInfo(simulationStep,node,modelSessionID);
    steps{end+1}=simulationStep;


    messagesStep=getMessagesStep();
    messagesStep.internal.id=3;
    steps{end+1}=messagesStep;

    program.steps=steps;

end

function program=defineFitProgram(projectConverter,node,modelSessionID,projectVersion,externalDataInfo)


    program=getProgramStructTemplate;
    program.programName=getAttribute(node,'Name');
    steps={};


    steps{end+1}=getDescriptionStep(node);


    program.programType=1;


    dataStep=getFitDataStep(node,externalDataInfo);


    modelStep=getModelStep(node,modelSessionID,projectVersion);
    modelStep.enabled=true;




    modelStep=rmfield(modelStep,{'doses','observables','statesToLog','statesToLogAll','statesToLogUseConfigset'});


    modelStep.internal.isSetup=true;
    modelStep.internal.id=2;
    modelStep.internal.args.supportDose=false;
    modelStep.internal.args.supportStatesToLog=true;


    fitStep=getFitStep(projectConverter,node,modelSessionID,externalDataInfo,projectVersion);


    program.runInParallel=fitStep.runInParallel;


    confidenceIntervalStruct=getConfidenceIntervalsStep(node);

    steps{end+1}=dataStep;
    steps{end+1}=modelStep;
    steps{end+1}=fitStep;
    steps{end+1}=confidenceIntervalStruct;


    messagesStep=getMessagesStep;
    messagesStep.internal.id=5;
    steps{end+1}=messagesStep;
    program.steps=steps;

end

function program=defineGroupSimulationProgram(node,modelSessionID,externalDataInfo,projectVersion)


    program=getProgramStructTemplate;
    program.programName=getAttribute(node,'Name');
    steps={};


    steps{end+1}=getDescriptionStep(node);


    program.programType=13;


    dataStep=getGroupSimulationDataStep(node,externalDataInfo,projectVersion);


    modelStep=getModelStep(node,modelSessionID,projectVersion);
    modelStep.enabled=true;


    steps{end+1}=modelStep;
    steps{end+1}=dataStep;
    steps{end+1}=getGroupSimulationStep(node);


    messagesStep=getMessagesStep;
    messagesStep.internal.id=4;
    steps{end+1}=messagesStep;

    program.steps=steps;

end

function program=defineNCAProgram(externalDataNode,externalDataInfo,projectVersion)


    program=getProgramStructTemplate;



    program.programName=sprintf('NCA_Program_%s',getAttribute(externalDataNode,'Name'));
    program.programIcon='icon_simbio_NCA_16';
    program.isActive=true;
    program.programType=7;


    descriptionStep=getDescriptionStep([]);


    dataStep=getNCADataStep(externalDataInfo);


    ncaStep=getNCAStep(externalDataNode,projectVersion);


    messagesStep=getMessagesStep();
    messagesStep.internal.id=3;

    steps=cell(4,1);
    steps{1}=descriptionStep;
    steps{2}=dataStep;
    steps{3}=ncaStep;
    steps{4}=messagesStep;
    program.steps=steps;

end

function program=defineSensitivityProgram(node,modelSessionID,projectVersion)


    program=getProgramStructTemplate;
    program.programName=getAttribute(node,'Name');
    steps={};


    steps{end+1}=getDescriptionStep(node);


    program.programType=2;


    stepInfo=getSimulationProgramSteps(node,modelSessionID,projectVersion);


    steps{end+1}=stepInfo.modelStep;
    steps{end+1}=stepInfo.genSamplesStep;
    steps{end+1}=stepInfo.steadyStateStep;
    steps{end+1}=stepInfo.doseStep;
    steps{end+1}=populateSensitivityInfo(stepInfo.simulationStep,node,modelSessionID);
    steps{end+1}=stepInfo.statisticsStep;
    steps{end+1}=stepInfo.messagesStep;
    program.steps=steps;

end

function program=defineSimulationProgram(node,modelSessionID,projectVersion)


    program=getProgramStructTemplate;
    program.programName=getAttribute(node,'Name');
    steps={};


    steps{end+1}=getDescriptionStep(node);


    program.programType=0;


    stepInfo=getSimulationProgramSteps(node,modelSessionID,projectVersion);


    steps{end+1}=stepInfo.modelStep;
    steps{end+1}=stepInfo.genSamplesStep;
    steps{end+1}=stepInfo.steadyStateStep;
    steps{end+1}=stepInfo.doseStep;
    steps{end+1}=stepInfo.simulationStep;
    steps{end+1}=stepInfo.statisticsStep;
    steps{end+1}=stepInfo.messagesStep;
    program.steps=steps;

end

function program=defineScanProgram(projectConverter,node,modelSessionID,projectVersion)


    program=getProgramStructTemplate;
    program.programName=getAttribute(node,'Name');
    steps={};


    steps{end+1}=getDescriptionStep(node);


    program.programType=3;


    stepInfo=getSimulationProgramSteps(node,modelSessionID,projectVersion);


    steps{end+1}=stepInfo.modelStep;
    genSamplesStep=populateGenerateSamplesTables(projectConverter,node,stepInfo.genSamplesStep,modelSessionID);
    steps{end+1}=genSamplesStep;
    steps{end+1}=stepInfo.steadyStateStep;
    steps{end+1}=stepInfo.doseStep;
    steps{end+1}=stepInfo.simulationStep;
    steps{end+1}=stepInfo.statisticsStep;
    steps{end+1}=stepInfo.messagesStep;
    program.steps=steps;

    program.runInParallel=genSamplesStep.runInParallel;

end

function program=defineScanWithSensitivitiesProgram(projectConverter,node,modelSessionID,projectVersion)


    program=getProgramStructTemplate;
    program.programName=getAttribute(node,'Name');
    steps={};


    steps{end+1}=getDescriptionStep(node);


    program.programType=4;


    stepInfo=getSimulationProgramSteps(node,modelSessionID,projectVersion);


    steps{end+1}=stepInfo.modelStep;
    genSamplesStep=populateGenerateSamplesTables(projectConverter,node,stepInfo.genSamplesStep,modelSessionID);
    steps{end+1}=genSamplesStep;
    steps{end+1}=stepInfo.steadyStateStep;
    steps{end+1}=stepInfo.doseStep;
    steps{end+1}=populateSensitivityInfo(stepInfo.simulationStep,node,modelSessionID);
    steps{end+1}=stepInfo.statisticsStep;
    steps{end+1}=stepInfo.messagesStep;
    program.steps=steps;

    program.runInParallel=genSamplesStep.runInParallel;

end

function steps=getSimulationProgramSteps(node,modelSessionID,projectVersion)

    steps=struct;


    steps.modelStep=getModelStep(node,modelSessionID,projectVersion);
    steps.modelStep.internal.isSetup=true;
    steps.modelStep.internal.id=1;


    genSamplesStep=getGenerateSamplesStepTemplate;
    genSamplesStep.internal.id=2;
    steps.genSamplesStep=genSamplesStep;


    steadyStateStep=getSteadyStateStepTemplate;
    steadyStateStep.internal.id=3;
    steps.steadyStateStep=steadyStateStep;


    doseStep=getDoseStepTemplate();
    doseStep.explorer.type='Dose Explorer';
    doseStep.internal.argField='steadyStateDoses';
    doseStep.internal.argType='dose';
    doseStep.internal.dosesRawTableData=[];
    doseStep.internal.isSetup=true;
    doseStep.internal.id=4;
    steps.doseStep=doseStep;


    simulationStep=getSimulationStep(node,modelSessionID);
    simulationStep.internal.id=5;
    steps.simulationStep=simulationStep;


    statisticsStep=getStatisticsStep(node);
    statisticsStep.internal.id=6;
    steps.statisticsStep=statisticsStep;


    messagesStep=getMessagesStep;
    messagesStep.internal.id=7;
    steps.messagesStep=messagesStep;

end



function step=getConfidenceIntervalsStep(taskNode)

    step=SimBiology.web.internal.converter.confidenceIntervalStepHandler('getConfidenceIntervalsStep',taskNode);

end

function step=getCustomDataStep(dataNames)

    step=SimBiology.web.internal.converter.customStepHandler('getCustomDataStep',dataNames);

end

function step=getCustomCodeStep(customTaskInfo)

    step=SimBiology.web.internal.converter.customStepHandler('getCustomStep',customTaskInfo);

end

function info=getCustomTaskInfo(projectConverter,node,modelSessionID,projectVersion)

    info=SimBiology.web.internal.converter.customStepHandler('getCustomTaskInfo',projectConverter,node,modelSessionID,projectVersion);

end

function step=getFitDataStep(taskNode,externalDataInfo)

    step=SimBiology.web.internal.converter.fitDataStepHandler('getFitDataStep',taskNode,externalDataInfo);

end

function info=getGroupSimulationStep(taskNode)

    info=SimBiology.web.internal.converter.groupSimulationStepHandler('getGroupSimulationStep',taskNode);

end

function info=getGroupSimulationDataStep(taskNode,externalDataInfo,projectVersion)

    info=SimBiology.web.internal.converter.groupSimulationStepHandler('getGroupSimulationDataStep',taskNode,externalDataInfo,projectVersion);

end

function step=getFitStep(obj,taskNode,sessionID,externalDataInfo,projectVersion)

    step=SimBiology.web.internal.converter.fitStepHandler('getFitStep',obj,taskNode,sessionID,externalDataInfo,projectVersion);

end

function step=getModelStep(taskNode,modelSessionID,projectVersion)

    step=SimBiology.web.internal.converter.modelStepHandler('getModelStep',taskNode,modelSessionID,projectVersion);

end

function step=getNCAStep(externalDataNode,projectVersion)

    step=SimBiology.web.internal.converter.ncaStepHandler('getNCAStep',externalDataNode,projectVersion);

end

function step=getNCADataStep(externalDataInfo)

    step=SimBiology.web.internal.converter.ncaStepHandler('getNCADataStep',externalDataInfo);

end

function step=getSimulationStep(taskNode,modelSessionID)

    step=SimBiology.web.internal.converter.simulationStepHandler('getSimulationStep',taskNode,modelSessionID);

end

function step=getStatisticsStep(taskNode)

    step=SimBiology.web.internal.converter.statisticStepHandler('getStatisticsStep',taskNode);

end

function step=populateDataSetInfoTable(taskNode,step,modelSessionID,externalDataInfo,projectVersion)

    step=SimBiology.web.internal.converter.generateSamplesStepHandler('populateDataSetInfoTable',taskNode,step,modelSessionID,externalDataInfo,projectVersion);

end

function step=populateEnsembleRunInfo(step,taskNode,modelSessionID)

    step=SimBiology.web.internal.converter.simulationStepHandler('populateEnsembleRunInfo',step,taskNode,modelSessionID);

end

function step=populateGenerateSamplesTables(obj,taskNode,step,modelSessionID)

    step=SimBiology.web.internal.converter.generateSamplesStepHandler('populateGenerateSamplesTables',obj,taskNode,step,modelSessionID);

end

function step=populateSensitivityInfo(step,taskNode,modelSessionID)

    step=SimBiology.web.internal.converter.simulationStepHandler('populateSensitivityInfo',step,taskNode,modelSessionID);

end

function step=getMessagesStep


    internalStruct=getInternalStructTemplate;
    internalStruct.argType='messages';
    internalStruct.isSetup=true;


    step=struct;
    step.enabled=true;
    step.name='Messages';
    step.type='Messages';
    step.internal=internalStruct;
    step.version=1;

end

function program=getProgramStructTemplate

    program=struct;
    program.action='save';
    program.programIcon='';
    program.programName='';
    program.programType=-1;
    program.runInParallel=false;
    program.steps={};
    program.isActive=false;

end

function step=getDescriptionStep(node)


    step=struct;
    step.name='Program Description';
    step.type='Program Description';
    step.version=1;
    step.enabled=true;

    if~isempty(node)
        step.description=getAttribute(node,'Description');
    else
        step.description='';
    end


    step.internal=getInternalStructTemplate();
    step.internal.argType='program';
    step.internal.id=0;


    step.explorer=getExplorerSectionTemplate();

end

function doseStruct=getDoseStepTemplate

    doseStruct=struct;
    doseStruct.doses=1e-6;
    doseStruct.enabled=false;
    doseStruct.explorer=getExplorerSectionTemplate;
    doseStruct.internal=getInternalStructTemplate;
    doseStruct.name='Dose';
    doseStruct.type='Dose';
    doseStruct.version=1;

end

function generateSamples=getGenerateSamplesStepTemplate

    generateSamples=struct;
    generateSamples.enabled=false;
    generateSamples.internal=getInternalStructTemplate;
    generateSamples.name='Generate Samples';
    generateSamples.parameterSets=getParameterSetTemplate;
    generateSamples.runInParallel=false;
    generateSamples.type='Generate Samples';
    generateSamples.version=1;
    generateSamples.description='';

end

function ssStruct=getSteadyStateStepTemplate

    ssStruct=struct;
    ssStruct.absoluteTolerance=1e-6;
    ssStruct.description='';
    ssStruct.enabled=false;
    ssStruct.internal=getInternalStructTemplate;
    ssStruct.internal.outputArguments={'success','variant'};
    ssStruct.minStopTime=1;
    ssStruct.maxStopTime=100000;
    ssStruct.method='auto';
    ssStruct.name='Steady State';
    ssStruct.relativeTolerance=1e-3;
    ssStruct.type='Steady State';
    ssStruct.version=1;

end

function template=getParameterSetTemplate

    template=SimBiology.web.internal.converter.generateSamplesStepHandler('getParameterSetTemplate');

end

function out=getAttribute(node,attribute,varargin)

    out=SimBiology.web.internal.converter.utilhandler('getAttribute',node,attribute,varargin{:});

end

function out=getExplorerSectionTemplate

    out=SimBiology.web.internal.converter.utilhandler('getExplorerSectionTemplate');

end

function out=getField(node,field)

    out=SimBiology.web.internal.converter.utilhandler('getField',node,field);

end

function out=getInternalStructTemplate

    out=SimBiology.web.internal.converter.utilhandler('getInternalStructTemplate');
end
