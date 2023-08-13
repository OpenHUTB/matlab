classdef ListTransportImpl

    methods(Access=public)
        function output=get(~)
            if isunix&&~ismac
                id="MATLAB:bluetooth:common:unsupportedPlatform";
                throwAsCaller(MException(id,getString(message(id))));
            end

            persistent transport;
            if~isempty(transport)
                output=transport;
                return
            end
            pluginDir=fullfile(toolboxdir('matlab'),'bluetooth','bin',computer('arch'));
            channel=matlabshared.asyncio.internal.Channel(fullfile(pluginDir,'libmwbluetoothlistdevice'),...
            fullfile(pluginDir,'libmwbluetoothmlconverter'),...
            Options=[],...
            StreamLimits=[Inf,0]);
            switch computer('arch')
            case 'win64'
                transport=matlab.bluetooth.internal.WinListTransport(channel);
            case 'maci64'
                transport=matlab.bluetooth.internal.MacListTransport(channel);
            otherwise
            end
            output=transport;
        end
    end
end