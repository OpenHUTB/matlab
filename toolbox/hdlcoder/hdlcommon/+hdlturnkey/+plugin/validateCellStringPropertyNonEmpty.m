function validateCellStringPropertyNonEmpty(value,propertyName,example)


    if(iscell(value))
        cellfun(...
        @(x)hdlturnkey.plugin.validateStringPropertyNonEmpty(x,propertyName,example),...
        value);
    else
        hdlturnkey.plugin.validateStringPropertyNonEmpty(...
        value,propertyName,example);
    end

end