

classdef(ConstructOnLoad)ImportFromFileEventData<event.EventData
    properties
Filename
VolType
    end

    methods
        function data=ImportFromFileEventData(filename,volType)
            data.Filename=filename;
            data.VolType=volType;
        end
    end
end