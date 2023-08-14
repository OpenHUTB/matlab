function handlePropertyChange(dataModel,blockParameterElement,~,~)




    import simulink.multisim.mm.design.*

    if strcmp(blockParameterElement.Name,"ActiveScenario")
        setValuesForSignalEditorActiveScenario(dataModel,blockParameterElement);
        simulink.multisim.internal.updateDesignStudyNumSimulations(blockParameterElement);
    else
        singleParameterSpace=blockParameterElement.Container;
        if singleParameterSpace.ValueType~=ParameterValueType.Explicit
            txn=dataModel.beginTransaction();
            singleParameterSpace.ValueType=ParameterValueType.Explicit;
            destroy(singleParameterSpace.Values);
            singleParameterSpace.Values=ExplicitValues(dataModel);
            singleParameterSpace.NumDesignPoints=0;
            txn.commit();

            simulink.multisim.internal.updateDesignStudyNumSimulations(blockParameterElement);
        end
    end
end

function setValuesForSignalEditorActiveScenario(dataModel,blockParameterElement)
    import simulink.multisim.mm.design.*

    blockPath=blockParameterElement.BlockPath;
    fileName=get_param(blockPath,'FileName');
    datasetNames=Simulink.SimulationData.DatasetRef.getDatasetVariableNames(fileName);
    singleParameterSpace=blockParameterElement.Container;

    txn=dataModel.beginTransaction();
    singleParameterSpace.ValueType=ParameterValueType.List;
    destroy(singleParameterSpace.Values);
    singleParameterSpace.Values=ValuesList(dataModel);

    for i=1:numel(datasetNames)
        item=ValuesListItem(dataModel);
        item.Label=datasetNames{i};
        item.Selected=true;
        singleParameterSpace.Values.Items.add(item);
    end

    singleParameterSpace.NumDesignPoints=numel(datasetNames);
    txn.commit();
end

