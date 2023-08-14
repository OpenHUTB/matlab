function defaultTransitions=getDefaultTransitions(context,depth)
    defaultTransitions=[];

    if isempty(context)||...
        (~isa(context,'Stateflow.State')&&...
        ~isa(context,'Stateflow.Chart'))
        return;
    end

    allTransitions=context.find('-isa','Stateflow.Transition',...
    '-depth',depth);

    if isempty(allTransitions)
        return;
    end

    defaultTransitions=allTransitions(arrayfun(@(x)isDefault(x),allTransitions));

end

function value=isDefault(transition)
    value=false;
    if isempty(transition)
        return;
    end
    if~isequal(transition.Source,[])
        return;
    end
    if~isa(transition.Destination,'Stateflow.State')&&...
        ~isa(transition.Destination,'Stateflow.Junction')&&...
        ~isa(transition.Destination,'Stateflow.AtomicSubchart')
        return;
    end
    value=true;
end