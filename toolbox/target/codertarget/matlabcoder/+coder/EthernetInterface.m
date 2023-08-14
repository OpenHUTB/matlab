classdef(Sealed=true)EthernetInterface<coder.internal.IOInterface













    properties(SetAccess='private',GetAccess='public')

DeviceAddress

        Port=17725;
    end

    methods
        function h=EthernetInterface(interfaceName,deviceAddress,port)
            h.Name=interfaceName;
            if nargin>1
                h.DeviceAddress=deviceAddress;
            end
            if nargin>2
                h.Port=port;
            end
        end

        function set.DeviceAddress(obj,val)
            validateattributes(val,{'char'},{'nonempty','row'},'','DeviceAddress');
            obj.DeviceAddress=strtrim(val);
        end

        function set.Port(obj,val)
            validateattributes(val,{'numeric'},...
            {'>=',1,'<=',65535,'scalar','nonnegative'},...
            '','Port')
            obj.Port=uint16(val);
        end
    end
end
