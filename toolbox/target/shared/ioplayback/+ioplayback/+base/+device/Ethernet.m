classdef Ethernet<handle





%#codegen

    properties(Abstract)
        MACAddress;
        SubnetMask;
        GatewayAddress;
        ResolveAddressWithDHCP;
        LocalAddress;
    end

    methods
        function obj=Ethernet()
            coder.allowpcode('plain');
        end

        function ret=getMACAddress(obj)
            coder.internal.prefer_const(obj.MACAddress);
            if~isempty(obj.MACAddress)
                validateattributes(obj.MACAddress,{'char'},{'nonempty'},'getMACAddress','MAC address');
                ret=obj.MACAddress;
            else
                ret='';
            end
        end

        function ret=getSubnetMask(obj)
            coder.internal.prefer_const(obj.SubnetMask);
            if~isempty(obj.SubnetMask)
                validateattributes(obj.SubnetMask,{'char'},{'nonempty'},'getSubNetAddress','Subnet mask');
                ret=obj.SubnetMask;
            else
                ret='';
            end
        end

        function ret=getGatewayAddress(obj)
            coder.internal.prefer_const(obj.GatewayAddress);
            if~isempty(obj.GatewayAddress)
                validateattributes(obj.GatewayAddress,{'char'},{'nonempty'},'getGatewayAddress','Gateway address');
                ret=obj.GatewayAddress;
            else
                ret='';
            end
        end

        function ret=getLocalAddress(obj)
            coder.internal.prefer_const(obj.LocalAddress);

            if~isempty(obj.LocalAddress)
                validateattributes(obj.LocalAddress,{'char'},{'nonempty'},'getLocalAddress','Local IP address');
                ret=obj.LocalAddress;
            else
                ret='';
            end
        end

        function ret=getResolveAddressWithDHCP(obj)
            coder.internal.prefer_const(obj.ResolveAddressWithDHCP);
            if~isempty(obj.ResolveAddressWithDHCP)
                validateattributes(obj.ResolveAddressWithDHCP,{'numeric','logical'},{'nonempty','nonnan','finite','binary','scalar'},'getResolveAddressWithDHCP','Resolve address with DHCP');
                ret=obj.ResolveAddressWithDHCP;
            else
                ret=false;
            end
        end

        function ret=getMaximumNumberOfTCPConnections(~)
            ret=20;
        end

        function ret=getMaximumNumberOfUDPConnections(~)
            ret=20;
        end
    end
end
