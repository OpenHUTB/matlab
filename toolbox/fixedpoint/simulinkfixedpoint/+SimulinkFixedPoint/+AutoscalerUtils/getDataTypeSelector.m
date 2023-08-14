function dataTypeSelector=getDataTypeSelector(proposalSettings)




    dataTypeSelector=fixed.DataTypeSelector();
    if proposalSettings.isAutoSignedness
        dataTypeSelector.Signedness='Auto';
    else
        dataTypeSelector.Signedness='Lock';
    end

    if proposalSettings.isWLSelectionPolicy
        dataTypeSelector.WordLength='Auto';
        dataTypeSelector.Scaling='Lock';
    end
end
