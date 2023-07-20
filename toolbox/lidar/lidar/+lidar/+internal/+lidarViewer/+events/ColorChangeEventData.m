classdef(ConstructOnLoad)ColorChangeEventData<event.EventData





    properties


        ColorMap=0;
        ColorMapVal=0;
        ColorVariation=0;

    end

    methods

        function data=ColorChangeEventData(colormap,colormapVal,varargin)
            data.ColorMap=colormap;
            data.ColorMapVal=colormapVal;
            if nargin>2
                data.ColorVariation=varargin{1};
            else
                data.ColorVariation=0;
            end
        end
    end

end
