function handlePropertyChange(~,valuesListItemElement,~,~)




    simulink.multisim.internal.utils.ValuesList.updateValuesListNumDesignPoints(valuesListItemElement);

    simulink.multisim.internal.updateDesignStudyNumSimulations(valuesListItemElement);
end