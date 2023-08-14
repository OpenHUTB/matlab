




classdef SimulationAbortedEventData<event.EventData
    properties
Cancelled

RunIds
    end

    methods
        function data=SimulationAbortedEventData(cancelled,runIds)
            data.Cancelled=cancelled;
            data.RunIds=runIds;
        end
    end
end