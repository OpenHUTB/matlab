function handlePropertyChange(~,explicitValuesElement,~,~)




    singleParameterSpace=simulink.multisim.internal.getParentContainer(explicitValuesElement,"SingleParameterSpace");

    simulink.multisim.internal.utils.ExplicitValues.updateNumDesignPoints(singleParameterSpace);

    simulink.multisim.internal.updateDesignStudyNumSimulations(singleParameterSpace);
end