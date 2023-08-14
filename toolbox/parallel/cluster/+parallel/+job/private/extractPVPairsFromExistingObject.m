function pvPairs=extractPVPairsFromExistingObject(obj,propertyNames)




    pvPairs=cellfun(@(x){x,obj.(x)},propertyNames,'UniformOutput',false);
    pvPairs=[pvPairs{:}];
end
