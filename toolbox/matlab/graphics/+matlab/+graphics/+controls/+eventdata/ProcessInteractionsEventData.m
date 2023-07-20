classdef(ConstructOnLoad)ProcessInteractionsEventData<event.EventData


    properties
Canvas
    end

    methods
        function obj=ProcessInteractionsEventData(~,canvas)
            obj.Canvas=canvas;
        end
    end
end