classdef(ConstructOnLoad)SimulationFinishedEventData<event.EventData




    properties
RunId
SimulationOutput
    end

    methods
        function data=SimulationFinishedEventData(runId,simOut)
            data.RunId=runId;
            data.SimulationOutput=simOut;
        end
    end
end
