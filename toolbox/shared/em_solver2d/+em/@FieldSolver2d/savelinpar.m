function savelinpar(obj,l)

    obj.Name=l.Name;
    obj.codeSub=l.codeSub;
    obj.numSub=l.numSub;
    obj.thickSub=l.thickSub;
    obj.epsilonRSub=l.epsilonRSub;
    obj.lossTangentSub=l.lossTangentSub;
    if isfield(l,'hasTraceOnTopLayer')
        obj.hasTraceOnTopLayer=l.hasTraceOnTopLayer;
    end
    obj.numTrace=l.numTrace;
    obj.widthTrace=l.widthTrace;
    obj.thickTrace=l.thickTrace;
    obj.xCoordTrace=l.xCoordTrace;
    obj.yCoordTrace=l.yCoordTrace;
    obj.conductivity=l.conductivity;
    obj.groundPlaneWidth=l.groundPlaneWidth;
    obj.groundPlaneCorner=l.groundPlaneCorner;

end