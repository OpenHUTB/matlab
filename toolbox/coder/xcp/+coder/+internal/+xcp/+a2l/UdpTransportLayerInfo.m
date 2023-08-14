classdef UdpTransportLayerInfo<coder.internal.xcp.a2l.EthernetTransportLayerInfo







    methods(Access=public)
        function obj=UdpTransportLayerInfo(address,port)
            obj=obj@coder.internal.xcp.a2l.EthernetTransportLayerInfo(address,port);
        end
    end

    methods(Static,Access=public)

        function ret=isUdp()
            ret=true;
        end
    end
end
