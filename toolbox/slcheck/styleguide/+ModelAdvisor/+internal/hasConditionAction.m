function res=hasConditionAction(transition)
    res=false;
    if~isa(transition,'Stateflow.Transition')
        return;
    end
    if isempty(transition.LabelString)
        return;
    end
    str=regexprep(transition.LabelString,'\s+','');
    res=~isempty(regexp(str,'(?<!\/){','once'));
end