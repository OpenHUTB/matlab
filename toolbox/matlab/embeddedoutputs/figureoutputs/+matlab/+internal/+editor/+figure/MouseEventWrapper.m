classdef MouseEventWrapper<matlab.graphics.interaction.uiaxes.MouseEventData


    properties
Chart
    end

    methods

        function obj=MouseEventWrapper(e,hChart)
            hFig=ancestor(hChart,'figure');
            obj=obj@matlab.graphics.interaction.uiaxes.MouseEventData(hFig,e);
            obj.Chart=hChart;
        end

    end
end

