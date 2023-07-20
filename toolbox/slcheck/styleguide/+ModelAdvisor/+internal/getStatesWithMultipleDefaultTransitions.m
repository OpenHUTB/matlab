function statesMultiple=getStatesWithMultipleDefaultTransitions(...
    defaultTransitions)
    statesMultiple=[];
    if(size(defaultTransitions,1)<2)
        return;
    end

    statesMultiple=arrayfun(@(x)x.Destination,defaultTransitions);

    if isempty(statesMultiple)
        return;
    end

    [~,uniqueIdx]=unique(statesMultiple);
    statesMultiple(uniqueIdx)=[];
    statesMultiple=unique(statesMultiple);

end