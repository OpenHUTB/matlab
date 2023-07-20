classdef(ConstructOnLoad)GenerationProgressEventData<event.EventData

    properties
Progress
    end

    methods
        function obj=GenerationProgressEventData(progress)
            obj.Progress=progress;
        end
    end
end

