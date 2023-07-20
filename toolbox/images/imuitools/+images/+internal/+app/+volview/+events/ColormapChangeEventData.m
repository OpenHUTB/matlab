

classdef(ConstructOnLoad)ColormapChangeEventData<event.EventData
    properties
Colormap
        ColorControlPoints=[];
    end

    methods
        function data=ColormapChangeEventData(colormapNew,colorCP)
            data.Colormap=colormapNew;
            if nargin==2&&~isempty(colorCP)
                data.ColorControlPoints=colorCP;
            end
        end
    end
end