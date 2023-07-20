classdef ScrollEventWrapper<matlab.graphics.interaction.uiaxes.ScrollEventData


    properties
Chart
    end

    methods

        function obj=ScrollEventWrapper(e,hChart)
            hFig=ancestor(hChart,'figure');
            obj=obj@matlab.graphics.interaction.uiaxes.ScrollEventData(hFig,e);
            obj.Chart=hChart;
        end

    end
end

