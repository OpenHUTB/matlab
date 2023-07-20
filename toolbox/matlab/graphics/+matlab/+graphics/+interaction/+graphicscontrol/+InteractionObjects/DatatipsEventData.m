classdef DatatipsEventData<event.EventData


    properties(SetAccess=private)
Point
PointInPixels
IntersectionPoint
HitObject
HitPrimitive
SelectionType
    end

    methods
        function data=DatatipsEventData(HitObject,x,y,SelectionType)
            data.Point=[x,y];
            data.PointInPixels=data.Point;
            data.SelectionType=SelectionType;
            data.HitObject=HitObject;
            data.HitPrimitive=HitObject;
            data.IntersectionPoint=[NaN,NaN,NaN];
        end
    end
end
