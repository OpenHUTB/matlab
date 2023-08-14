classdef TabCompletionHelper





    methods(Static,Access=public)
        function identifiers=getFoundSPPDevices
            cache=matlab.bluetooth.internal.SPPDevicesCache.getInstance;
            identifiers=getDevices(cache);
        end

        function channel=getChannel(identifier)
            cache=matlab.bluetooth.internal.SPPDevicesCache.getInstance;
            channel=getChannel(cache,identifier);
        end

        function choices=getSupportedByteOrder
            choices=["little-endian","big-endian"];
        end

        function choices=getSupportedPrecisions
            choices=matlabshared.transportlib.internal.client.GenericClient.PrecisionOptions;
        end

        function choices=getSupportedBuffers
            choices=["input","output"];
        end

        function choices=getSupportedTerminators
            choices=["LF","CR","CR/LF"];
        end
    end
end