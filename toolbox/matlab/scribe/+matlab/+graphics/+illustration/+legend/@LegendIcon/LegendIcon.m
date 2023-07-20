


classdef(Sealed)LegendIcon<matlab.graphics.primitive.world.Group&matlab.graphics.mixin.Selectable

    properties(SetAccess=private,GetAccess=public,Transient=true,DeepCopy=true)
        Transform matlab.graphics.primitive.Transform;
    end

    methods
        function hObj=LegendIcon()
            hObj.HitTest='off';


            hObj.Transform=matlab.graphics.primitive.Transform;
            hObj.Transform.HitTest='off';
            hObj.Transform.SelectionHighlight='off';
            hObj.Transform.Internal=true;
            hObj.Transform.Description='LegendIcon Transform';
            hObj.addNode(hObj.Transform);
        end
    end

    methods(Access='public',Hidden=true)
        function addGraphic(hObj,newObjects)

            delete(hObj.Transform.Children)
            set(newObjects,'Parent',hObj.Transform);




        end
    end
end
