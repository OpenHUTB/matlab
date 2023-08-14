classdef SerialTransportLayerInfo<coder.internal.xcp.a2l.TransportLayerInfo







    properties(SetAccess=immutable,GetAccess=public)
        BaudRate(1,:)uint32;
    end

    methods(Access=public)
        function obj=SerialTransportLayerInfo(baudRate)
            obj.BaudRate=baudRate;
        end
    end

    methods(Static,Access=public)

        function ret=isSerial()
            ret=true;
        end
    end
end
