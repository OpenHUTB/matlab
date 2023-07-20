




classdef SimulationRunnerEventData<event.EventData
    properties

Data
    end

    methods
        function obj=SimulationRunnerEventData(eventData)
            obj.Data=eventData;
        end
    end
end