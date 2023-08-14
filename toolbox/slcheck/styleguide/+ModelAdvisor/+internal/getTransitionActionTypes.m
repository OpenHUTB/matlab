function config=getTransitionActionTypes(uddTransitionObj)

    config=struct('hasCondition',false,...
    'hasTransitionAction',false,...
    'hasConditionAction',false,...
    'hasEvent',false);

    if~isa(uddTransitionObj,'Stateflow.Transition')
        return;
    end

    try
        container=Stateflow.Ast.getContainer(uddTransitionObj);
    catch %#ok<CTCH>

        return;
    end
    sections=container.sections;
    for i=1:numel(sections)

        if~config.hasCondition
            config.hasCondition=isa(sections{i},...
            'Stateflow.Ast.ConditionSection');
        end

        if~config.hasTransitionAction
            config.hasTransitionAction=isa(sections{i},...
            'Stateflow.Ast.TransitionActionSection');
        end

        if~config.hasConditionAction
            config.hasConditionAction=isa(sections{i},...
            'Stateflow.Ast.ConditionActionSection');
        end

        if~config.hasEvent
            config.hasEvent=isa(sections{i},...
            'Stateflow.Ast.EventSection');
        end

    end
end