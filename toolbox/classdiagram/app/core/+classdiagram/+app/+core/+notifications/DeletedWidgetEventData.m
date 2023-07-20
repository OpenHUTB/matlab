classdef(ConstructOnLoad)DeletedWidgetEventData<event.EventData
    properties
DwId
    end

    methods
        function data=DeletedWidgetEventData(id)
            data.DwId=id;
        end
    end
end