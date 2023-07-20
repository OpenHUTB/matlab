classdef(ConstructOnLoad)FileSavedEventData<event.EventData




    properties
FileName
    end

    methods
        function data=FileSavedEventData(newState)
            data.FileName=newState;
        end
    end
end
