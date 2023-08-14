classdef(ConstructOnLoad)CustomColormapRequestEventData<event.EventData




    properties
Colormap
VariationMap
        DialogState=1;

    end

    methods
        function data=CustomColormapRequestEventData(colormapNew,variationMap,varargin)
            data.Colormap=colormapNew;
            data.VariationMap=variationMap;
            if nargin>2
                data.DialogState=varargin{1};
            end
        end
    end
end
