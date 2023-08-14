function ret=generateRunCallback(uiModel,modelName)






    ret={};

    try

        backendModel=mf.zero.Model();
        allElements=uiModel.topLevelElements;
        for i=1:length(allElements)
            if~(isa(allElements(i),'ssm.app.SimulationSettings')...
                ||isa(allElements(i),'ssm.app.AgentInstance'))
                createElem(allElements(i),backendModel);
            end
        end




        allElements=backendModel.topLevelElements;

        for i=1:length(allElements)
            if isa(allElements(i),'mf.ssm.ScenarioDescriptor')
                scenarioDescriptor=allElements(i);
                break;
            end
        end


        for i=1:length(allElements)
            if isa(allElements(i),'mf.ssm.AgentType')
                scenarioDescriptor.agentTypes.add(allElements(i));
            elseif isa(allElements(i),'mf.ssm.DataTable')
                scenarioDescriptor.sharedResources.add(allElements(i));
            end
        end


        loggingSettings('clear');


        tempObj=ssm.ScenarioHarnessModel(backendModel);
        tempObj.generate(modelName);
        out=tempObj.simulate();
        tempObj.cleanup();


        assignin('base','out',out);
    catch ME
        ret.errorTitle=message('ssm:genericUI:ErrorGenerateRunCallback').getString;
        ret.error=ME.message;
    end
end

function elem=createElem(origElem,backendModel)
    switch(class(origElem))
    case 'ssm.app.AgentModelType'
        elem=mf.ssm.AgentModelType(backendModel);
        elem.Simulink=origElem.Simulink;
        elem.SystemObject=origElem.SystemObject;

    case 'ssm.app.AgentSimulationMode'
        elem=mf.ssm.AgentSimulationMode(backendModel);
        elem.Interpreted=origElem.Interpreted;
        elem.Accelerated=origElem.Accelerated;

    case 'ssm.app.AgentGeneratorType'
        elem=mf.ssm.AgentGeneratorType(backendModel);
        elem.Specified=origElem.Specified;
        elem.Function=origElem.Function;

    case 'ssm.app.CoSimulationOption'
        elem=mf.ssm.CoSimulationOption(backendModel);
        elem.InModel=origElem.InModel;
        elem.InSession=origElem.InSession;
        elem.LocalSession=origElem.LocalSession;
        elem.RemoteSession=origElem.RemoteSession;

    case 'ssm.app.ScenarioDescriptor'
        elem=mf.ssm.ScenarioDescriptor(backendModel);

        keys=origElem.agentTypes.keys;
        for key=keys
            origChildElem=origElem.agentTypes.getByKey(key{1});
            childElem=createElem(origChildElem,backendModel);
            elem.agentTypes.add(childElem);
        end

        keys=origElem.agentGenerators.keys;
        for key=keys
            origChildElem=origElem.agentGenerators.getByKey(key{1});
            childElem=createElem(origChildElem,backendModel);
            elem.agentGenerators.add(childElem);
        end

        keys=origElem.sharedResources.keys;
        for key=keys
            origChildElem=origElem.sharedResources.getByKey(key{1});
            childElem=createElem(origChildElem,backendModel);
            elem.sharedResources.add(childElem);
        end

        origChildElem=origElem.simulationSettings;
        elem.simulationSettings=createElem(origChildElem,backendModel);

    case 'ssm.app.AgentType'
        elem=mf.ssm.AgentType(backendModel);
        elem.name=origElem.name;
        elem.modelType=origElem.modelType.char;
        elem.artifactLocation=origElem.artifactLocation;
        elem.simulationMode=origElem.simulationMode.char;
        elem.defaultLifespan=origElem.defaultLifespan;

    case 'ssm.app.InstanceParameter'
        elem=mf.ssm.InstanceParameter(backendModel);
        elem.name=origElem.name;
        elem.value=origElem.value;

    case 'ssm.app.AgentInstance'
        elem=mf.ssm.AgentInstance(backendModel);
        elem.birthTime=origElem.birthTime;
        elem.coSimulationOption=origElem.coSimulationOption.char;

        keys=origElem.parameters.keys;
        for key=keys
            origChildElem=origElem.parameters.getByKey(key{1});
            childElem=createElem(origChildElem,backendModel);
            elem.parameters.add(childElem);
        end

    case 'ssm.app.AgentGenerator'
        elem=mf.ssm.AgentGenerator(backendModel);
        elem.name=origElem.name;
        elem.functionName=origElem.functionName;
        elem.agentType=origElem.agentType;

        for i=1:origElem.instances.Size
            origChildElem=origElem.instances(i);
            childElem=createElem(origChildElem,backendModel);
            elem.instances.add(childElem);
        end

    case 'ssm.app.DataTable'
        elem=mf.ssm.DataTable(backendModel);
        elem.name=origElem.name;
        elem.dataType=origElem.dataType;
        elem.busObjLocation=origElem.busObjLocation;
        loggingSettings(elem);

        for i=1:origElem.initialValues.Size
            origChildElem=origElem.initialValues(i);
            childElem=createElem(origChildElem,backendModel);
            elem.initialValues.add(childElem);
        end

    case 'ssm.app.DataTableField'
        elem=mf.ssm.DataTableField(backendModel);
        elem.name=origElem.name;
        elem.value=origElem.value;

    case 'ssm.app.SimulationSettings'
        elem=mf.ssm.SimulationSettings(backendModel);
        elem.synchronizationPeriod=origElem.synchronizationPeriod;
        elem.stopTime=origElem.stopTime;

    case 'ssm.app.VizDebuggerSettings'
        loggingSettings(origElem.pmSettings);
    end
end



function loggingSettings(elem)
    persistent pmSettings dataTableList;
    if isempty(dataTableList)
        dataTableList={};
    end

    switch(class(elem))
    case 'mf.ssm.DataTable'
        if isempty(pmSettings)
            dataTableList{end+1}=elem;
        else
            elem.enableLogging=pmSettings.enableLogging;
        end

    case 'ssm.app.LoggingSettings'
        pmSettings=elem;
        for i=1:length(dataTableList)
            dataTableList{i}.enableLogging=...
            pmSettings.enableLogging;
        end
    case 'char'
        if strcmp(elem,'clear')
            clear pmSettings dataTableList
        end
    end
end
