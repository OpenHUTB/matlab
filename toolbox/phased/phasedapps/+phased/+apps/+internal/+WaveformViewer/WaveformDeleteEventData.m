classdef WaveformDeleteEventData<event.EventData



    properties
ScenarioIndex
    end

    methods
        function this=WaveformDeleteEventData(indx)
            this.ScenarioIndex=indx;
        end
    end
end