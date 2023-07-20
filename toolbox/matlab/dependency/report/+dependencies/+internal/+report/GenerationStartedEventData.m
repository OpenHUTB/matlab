classdef(ConstructOnLoad)GenerationStartedEventData<event.EventData

    properties
FileName
    end

    methods
        function obj=GenerationStartedEventData(fileName)
            obj.FileName=fileName;
        end
    end
end

