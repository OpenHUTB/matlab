classdef AsyncIOChannelImpl

    methods(Access=public)
        function output=get(~)
            pluginDir=fullfile(toolboxdir("matlab"),"bluetooth","bin",computer("arch"));
            output.DevicePlugin=fullfile(pluginDir,"libmwbluetoothdevice");
            output.ConverterPlugin=fullfile(pluginDir,"libmwbluetoothmlconverter");
        end
    end
end