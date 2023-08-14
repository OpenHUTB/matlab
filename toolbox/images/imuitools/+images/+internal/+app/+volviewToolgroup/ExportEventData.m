
classdef(ConstructOnLoad)ExportEventData<event.EventData
    properties
Config
    end

    methods
        function obj=ExportEventData(config)
            obj.Config=config;
        end
    end
end