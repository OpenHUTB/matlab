classdef CustomSettings<handle

    methods(Static)

        function bss=getCustomConfig()
            bss=lutdesigner.config.internal.getBlockSupportSettings();
        end

        function setCustomConfig(bss)
            lutdesigner.config.internal.setBlockSupportSettings(bss);
        end

        function loadCustomConfigSettingsFromFile(jsonFileName)

            customConfig=jsondecode(fileread(jsonFileName));

            lutdesigner.config.CustomSettings.setCustomConfig(customConfig);
        end

        function saveCustomConfigSettingsToFile(jsonFileName)

            customConfig=lutdesigner.config.CustomSettings.getCustomConfig();

            fp=fopen(jsonFileName,'w');
            fprintf(fp,jsonencode(customConfig));
            fclose(fp);
        end

        function retrieveCustomConfigFromPrefToSettings()
            lutdesigner.config.internal.retrieveBlockSupportFromPrefToSettings();
        end

        function retrieveCustomConfigFromPrefToFile(jsonFileName)


            retrieveCustomConfigFromPrefToSettings();
            saveCustomConfigSettingsToFile(jsonFileName);
        end
    end
end
