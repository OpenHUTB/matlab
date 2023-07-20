function tf=isSelfTransition(trans)
    if Advisor.Utils.Stateflow.isDefaultTransition(trans)
        tf=0;
    elseif isempty(trans.Destination)
        tf=0;
    elseif isequal(trans.Source.Id,trans.Destination.Id)
        tf=1;
    else
        tf=0;
    end
end