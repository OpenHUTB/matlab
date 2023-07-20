function result=isTransitionHorizontal(transition)
    result=true;
    if isempty(transition)
        return;
    end

    sourcePt=fix(transition.SourceEndpoint);
    destPt=fix(transition.DestinationEndpoint);
    midPt=fix(transition.Midpoint);


    if(destPt(2)~=sourcePt(2))||(destPt(2)~=midPt(2))
        result=false;
        return;
    end
end
