classdef(ConstructOnLoad)UpdateModelEventData<event.EventData


    properties
UpdateType
Metadata
    end

    methods
        function data=UpdateModelEventData(updateType,metadata)
            data.UpdateType=updateType;
            data.Metadata=metadata;
        end
    end
end

