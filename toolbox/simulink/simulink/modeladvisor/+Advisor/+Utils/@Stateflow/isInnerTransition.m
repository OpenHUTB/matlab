function tf=isInnerTransition(trans)
    if isempty(trans.Source)
        tf=false;
    elseif isequal(trans.getParent.Id,trans.Source.Id)||...
        isequal(trans.getParent.Id,trans.Destination.Id)
        tf=true;
    else
        tf=false;
    end
end





