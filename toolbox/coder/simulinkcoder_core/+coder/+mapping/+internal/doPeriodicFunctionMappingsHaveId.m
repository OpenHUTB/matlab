function hasId=doPeriodicFunctionMappingsHaveId(periodicFcnMappings)







    hasId=true;
    if isempty(periodicFcnMappings)
        return;
    end

    if periodicFcnMappings(1).Id<0
        hasId=false;
    end
end

