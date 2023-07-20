classdef(ConstructOnLoad)ComponentsEventData<event.EventData



    properties
figure
    end

    methods
        function data=ComponentsEventData(figure)
            data.figure=figure;
        end
    end
end