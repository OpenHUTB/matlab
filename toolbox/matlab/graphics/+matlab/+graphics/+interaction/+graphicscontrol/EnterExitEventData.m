classdef EnterExitEventData<event.EventData




    properties
enterexit
    end

    methods
        function data=EnterExitEventData(enterexit)
            data.enterexit=enterexit;
        end
    end
end
