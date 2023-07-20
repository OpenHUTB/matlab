

classdef(ConstructOnLoad)VolumeRenderingSettingsChangeEventData<event.EventData
    properties
Config
    end

    methods
        function data=VolumeRenderingSettingsChangeEventData(config)
            data.Config=config;
        end
    end
end