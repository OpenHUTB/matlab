classdef ScrollEventData<matlab.graphics.interaction.uiaxes.MouseEventData


    properties
        VerticalScrollCount;
    end

    methods
        function hObj=ScrollEventData(o,e,vsc)
            hObj=hObj@matlab.graphics.interaction.uiaxes.MouseEventData(o,e);
            if nargin>2
                hObj.VerticalScrollCount=vsc;
            elseif isprop(e,'wheelDelta')
                hObj.VerticalScrollCount=-e.wheelDelta;
            else
                hObj.VerticalScrollCount=e.VerticalScrollCount;
            end
        end
    end
end

