




classdef SimulationOutputAvailableEventData<event.EventData
    properties
SimulationOutput
RunId
    end

    methods
        function data=SimulationOutputAvailableEventData(simOut,runId)
            data.SimulationOutput=simOut;
            data.RunId=runId;
        end
    end
end