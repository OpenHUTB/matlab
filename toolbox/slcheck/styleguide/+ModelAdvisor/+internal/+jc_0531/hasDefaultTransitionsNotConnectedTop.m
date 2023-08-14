
function[result,transitions]=hasDefaultTransitionsNotConnectedTop(...
    defaultTransitions)
    transitions=[];
    result=true;

    if isempty(defaultTransitions)
        result=false;
        return;
    end

    for d=1:size(defaultTransitions,1)
        if(defaultTransitions(d).DestinationOClock>1.4)&&...
            (defaultTransitions(d).DestinationOClock<10.5)
            transitions=[transitions;defaultTransitions(d)];%#ok<AGROW>
        end
    end

    if isempty(transitions)
        result=false;
    end

end