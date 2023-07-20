classdef TargetAddedData<event.EventData




    properties
name
    end

    methods
        function data=TargetAddedData(name)
            data.name=name;
        end
    end
end
