function addFaultSet(dataModel,parameterSpace,modelHandle)




    txn=dataModel.beginTransaction();
    singleParameterSpace=simulink.multisim.mm.design.SingleParameterSpace(dataModel);
    faultSet=simulink.multisim.mm.design.FaultSet(dataModel);
    exitingParameterSpaces=parameterSpace.ParameterSpaces.toArray();
    existingLabels=arrayfun(@(x)x.Label,exitingParameterSpaces,"UniformOutput",false);
    labelPrefix=message("multisim:SetupGUI:FaultSetLabelPrefix").getString();
    label=string(matlab.lang.makeUniqueStrings(labelPrefix,[existingLabels,labelPrefix]));
    singleParameterSpace.Label=label;
    singleParameterSpace.Type=faultSet;
    singleParameterSpace.ValueType=simulink.multisim.mm.design.ParameterValueType.List;
    singleParameterSpace.Values=simulink.multisim.mm.design.ValuesList(dataModel);

    faults=faultinfo.manager.getSimFaultsTokensForDesignStudy(modelHandle);
    for idx=1:numel(faults)
        it=faults(idx);
        listItem=simulink.multisim.mm.design.ValuesListItem(dataModel);
        listItem.Label=it{1};
        listItem.Selected=true;
        singleParameterSpace.Values.Items.add(listItem);
    end

    parameterSpace.ParameterSpaces.add(singleParameterSpace);
    singleParameterSpace.NumDesignPoints=numel(faults);
    simulink.multisim.internal.updateDesignStudyNumSimulations(singleParameterSpace);
    txn.commit();
end
