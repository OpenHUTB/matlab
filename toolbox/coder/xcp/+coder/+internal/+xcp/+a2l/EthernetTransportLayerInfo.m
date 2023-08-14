classdef(Abstract)EthernetTransportLayerInfo<coder.internal.xcp.a2l.TransportLayerInfo









    properties(SetAccess=immutable,GetAccess=public)
        Address(1,:)char;
        Port(1,1)uint32;
    end

    methods(Access=public)
        function obj=EthernetTransportLayerInfo(address,port)
            obj.Address=address;
            obj.Port=port;
        end
    end

end
