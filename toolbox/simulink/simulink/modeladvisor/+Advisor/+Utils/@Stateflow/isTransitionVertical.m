function result=isTransitionVertical(transition)
    result=true;
    if isempty(transition)
        return;
    end

    sourcePt=fix(transition.SourceEndpoint);
    destPt=fix(transition.DestinationEndpoint);
    midPt=fix(transition.Midpoint);


    if(destPt(1)~=sourcePt(1))||(destPt(1)~=midPt(1))
        result=false;
        return;
    end
end
