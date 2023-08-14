classdef MouseEventData<event.EventData


    properties(SetAccess=private)
Point
PointInPixels
IntersectionPoint
HitObject
HitPrimitive
AffectedObject
        SelectionType='normal'

        ControlPressed=false
        ShiftPressed=false
        AltPressed=false
    end

    methods
        function data=MouseEventData(o,e,cp,sp,ap)
            import matlab.graphics.interaction.internal.getPointInPixels

            if(isstruct(e)&&isfield(e,'PointInPixels'))||(isobject(e)&&isprop(e,'PointInPixels'))
                data.PointInPixels=e.PointInPixels;
            else
                data.PointInPixels=getPointInPixels(o,e.Point);
            end


            if~isempty(o)&&((isstruct(o)&&isfield(o,'SelectionType'))||(isobject(o)&&isprop(o,'SelectionType')))
                data.SelectionType=o.SelectionType;
            end

            data.HitObject=e.HitObject;
            data.HitPrimitive=e.HitPrimitive;
            data.Point=e.Point;
            data.IntersectionPoint=e.IntersectionPoint;


            if nargin==5
                data.ControlPressed=cp;
                data.ShiftPressed=sp;
                data.AltPressed=ap;
            end
        end

        function fixIntersectionPoint(eventData)



            import matlab.graphics.interaction.internal.calculateIntersectionPoint

            if all(isnan(eventData.IntersectionPoint))

                if isscalar(eventData.HitPrimitive)
                    hitObject=eventData.HitPrimitive;
                else
                    hitObject=eventData.HitObject;
                end


                hAx=ancestor(hitObject,'matlab.graphics.axis.Axes','node');
                if isscalar(hAx)&&is2D(hAx)

                    pointPixels=eventData.PointInPixels;


                    eventData.IntersectionPoint=calculateIntersectionPoint(pointPixels,hitObject);
                end
            end
        end
    end
end
