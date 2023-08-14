function stateNameNew=removeSingleQuoteFromStateName(stateName)


    if isempty(stateName)
        stateNameNew=stateName;
    elseif(stateName(1)==''''&&stateName(end)=='''')
        if length(stateName)>2
            stateNameNew=stateName(2:end-1);
        else
            stateNameNew='';
        end
    else
        stateNameNew=stateName;
    end
end
