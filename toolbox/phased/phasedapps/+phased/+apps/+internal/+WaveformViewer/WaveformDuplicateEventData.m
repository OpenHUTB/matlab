classdef WaveformDuplicateEventData<event.EventData



    properties
ScenarioIndex
    end

    methods
        function this=WaveformDuplicateEventData(indx)
            this.ScenarioIndex=indx;
        end
    end
end