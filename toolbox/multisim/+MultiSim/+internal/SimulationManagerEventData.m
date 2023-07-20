




classdef SimulationManagerEventData<event.EventData
    properties

Data
    end

    methods
        function obj=SimulationManagerEventData(eventData)
            obj.Data=eventData;
        end
    end
end