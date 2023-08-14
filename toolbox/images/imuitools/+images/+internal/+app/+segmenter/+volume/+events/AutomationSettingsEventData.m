classdef(ConstructOnLoad)AutomationSettingsEventData<event.EventData





    properties

Settings

    end

    methods

        function data=AutomationSettingsEventData(settingsObj)

            data.Settings=settingsObj;

        end

    end

end