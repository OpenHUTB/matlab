
classdef(ConstructOnLoad)ExportEventData<event.EventData
    properties
Config
ViewerConfig
    end

    methods
        function obj=ExportEventData(config,viewerConfig)
            obj.Config=config;
            obj.ViewerConfig=viewerConfig;
        end
    end
end