function isValid=validateDataForAllVariables(data,channel)
    isValid=false;

    for i=1:numel(channel.KeyType)
        keyTypes=channel.KeyType(i);
        try
            [attrClass,attrType]=matlab.visualize.task.internal.model.DataModel.cleanUpTypeAttributes(keyTypes);

            validateattributes(data,attrClass,attrType);

            isValid=true;
            break;
        catch
        end
    end
    if isValid
        if strcmpi(channel.Name,'X')||strcmpi(channel.Name,'GroupData')
            if isa(data,'tabular')
                isValid=false;
            end
        end
    end
end