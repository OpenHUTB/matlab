function minel=fixMinEdgeLength(obj,s,smin)

    if~isHminUserSpecified(obj)
        if isempty(smin)

            setMeshMinToMaxEdgeRatio(obj,0.75);
            smin=0.75*s;
        elseif smin>s
            smin=s*getMeshMinToMaxRatio(obj);
        end
    end
    minel=smin;
    setMeshMinContourEdgeLength(obj,smin);