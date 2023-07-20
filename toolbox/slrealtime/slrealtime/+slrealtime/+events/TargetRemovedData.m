classdef TargetRemovedData<event.EventData




    properties
name
    end

    methods
        function data=TargetRemovedData(name)
            data.name=name;
        end
    end
end
