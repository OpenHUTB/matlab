classdef FigureChangeEventData<event.EventData



    properties
Figure



ForceSet
    end

    methods
        function data=FigureChangeEventData(hFig,forceSet)
            data.Figure=hFig;
            data.ForceSet=forceSet;
        end
    end
end