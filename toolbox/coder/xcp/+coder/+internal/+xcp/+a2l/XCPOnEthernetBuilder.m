classdef XCPOnEthernetBuilder<handle







    properties(Constant,Access=private)
        VersionDefault=0x0100;
    end

    methods(Access=public)
        function obj=XCPOnEthernetBuilder()



        end

        function obj=build(obj,hostNameOrAddress,port,xcpOnEthernet)

            className=mfilename('class');
            validateattributes(hostNameOrAddress,{'char','string'},{'scalartext'},className,'hostNameOrAddress');
            validateattributes(port,{'numeric'},{'nonnegative','scalar'},className,'port');
            validateattributes(xcpOnEthernet,{'asam.mcd2mc.ifdata.xcp.XCPOnEthernetInfo'},{},className,'xcpOnEthernet');

            xcpOnEthernet.Version=obj.VersionDefault;
            xcpOnEthernet.Port=port;
            xcpOnEthernet.HostNameOrAddress=hostNameOrAddress;
        end
    end
end