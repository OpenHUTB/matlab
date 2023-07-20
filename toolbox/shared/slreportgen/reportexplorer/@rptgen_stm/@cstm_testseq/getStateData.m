function getStateData(this,d,sect,states,blockPath)





    nStates=numel(states);
    for i=1:nStates

        getChildren(this,d,sect,states{i},blockPath);
    end
end

function getChildren(this,d,sect,state,blockPath)

    displayData(this,d,sect,state,blockPath);


    nChildren=numel(state.children);
    for c=1:nChildren
        getChildren(this,d,sect,state.children{c},blockPath);
    end
end


function displayData(this,d,sect,state,blockPath)

    if strcmp(this.StepContent,'none')&&isempty(getStateRequirements(this,state))
        return;
    end


    setStateAnchor(this,d,sect,state,blockPath);


    elem=createElement(d,'emphasis',getStateName(this,state));
    setAttribute(elem,'role','bold');
    para=createElement(d,'para',elem);
    appendChild(sect,para);


    if~isempty(getStateDescription(this,state))&&~strcmp(this.StepContent,'actionAndTransitionOnly')&&~strcmp(this.StepContent,'none')
        showStateDescription(this,d,sect,state);
    end

    if~strcmp(this.StepContent,'descriptionOnly')&&~strcmp(this.StepContent,'none')

        if~isempty(getStateAction(this,state))
            showStateAction(this,d,sect,state);
        end


        if~isempty(getStateWhenCondition(this,state))
            showStateWhenCondition(this,d,sect,state);
        end


        if~isempty(getStateTransitions(this,state))
            makeTransitionTable(this,d,sect,state);
        end
    end

    if this.StepRequirements&&~isempty(getStateRequirements(this,state))
        showStateRequirements(this,d,sect,state);
    end

end