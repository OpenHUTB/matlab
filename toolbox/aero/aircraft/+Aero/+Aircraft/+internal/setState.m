function state=setState(state,stateName,value)

    if~iscell(value)
        value=num2cell(value);
    end

    for ii=1:numel(stateName)
        try
            state=setStateHelper(state,stateName(ii),value{ii});
        catch ERR
            throwAsCaller(ERR);
        end
    end

end

function state=setStateHelper(state,stateName,value)

    if any(ismember(string(properties(state)),stateName))
        state.(stateName)=value;
        return
    end


    if any(ismember(string(properties(state.Environment)),stateName))
        state.Environment.(stateName)=value;
        return
    end


    isControl=ismember(state.ControlStateNames,stateName);
    if any(isControl)
        state=state.setControlStatesInternal(find(isControl),value);
        return
    end
end

