function validateCellStringProperty(value,propertyName,example)


    if(iscell(value))
        cellfun(...
        @(x)hdlturnkey.plugin.validateStringProperty(x,propertyName,example),...
        value);
    else
        hdlturnkey.plugin.validateStringProperty(...
        value,propertyName,example);
    end

end