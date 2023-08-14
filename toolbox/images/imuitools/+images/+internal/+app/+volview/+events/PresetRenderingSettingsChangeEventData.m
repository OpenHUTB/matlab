

classdef(ConstructOnLoad)PresetRenderingSettingsChangeEventData<event.EventData
    properties
Config
SettingName
    end

    methods
        function data=PresetRenderingSettingsChangeEventData(settings,tfName)
            data.Config=settings;
            data.SettingName=tfName;
        end
    end
end