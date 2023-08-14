classdef TcpTransportLayerInfo<coder.internal.xcp.a2l.EthernetTransportLayerInfo







    methods(Access=public)
        function obj=TcpTransportLayerInfo(address,port)
            obj=obj@coder.internal.xcp.a2l.EthernetTransportLayerInfo(address,port);
        end
    end

    methods(Static,Access=public)

        function ret=isTcp()
            ret=true;
        end
    end
end
