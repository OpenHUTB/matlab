function tf=isSuperTransitionFromSource(trans)
    if Advisor.Utils.Stateflow.isDefaultTransition(trans)
        tf=false;
    elseif Advisor.Utils.Stateflow.isInnerTransition(trans)
        tf=false;
    elseif~isequal(trans.getParent.Id,trans.Source.getParent.Id)
        tf=true;
    else
        tf=false;
    end
end

