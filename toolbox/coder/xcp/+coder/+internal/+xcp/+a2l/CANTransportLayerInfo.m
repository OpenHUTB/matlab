classdef CANTransportLayerInfo<coder.internal.xcp.a2l.TransportLayerInfo








    methods(Access=public)
        function obj=CANTransportLayerInfo()

        end
    end

    methods(Static,Access=public)

        function ret=isCAN()
            ret=true;
        end
    end
end
