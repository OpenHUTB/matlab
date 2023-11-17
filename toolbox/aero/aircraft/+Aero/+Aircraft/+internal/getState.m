function value=getState(state,stateName)
    value=arrayfun(@(s)getStateHelper(state,s),stateName,'UniformOutput',false);

    if isscalar(value)||all(cellfun(@isscalar,value),'all')
        value=reshape([value{:}],size(stateName));
    end
end

function value=getStateHelper(state,stateName)

    try
        value=state.(stateName);
        return
    catch

    end


    try
        value=state.Environment.(stateName);
        return
    catch

    end


    isControl=ismember(state.ControlStateNames,stateName);
    if any(isControl)
        tmpCtrl=state.ControlStates(find(isControl));


        if(tmpCtrl.DependsOn(1)=="")
            value=state.ControlStates(find(isControl)).Position;
        else


            value=diff(state.getState(tmpCtrl.DependsOn));
        end
        return
    end
end

