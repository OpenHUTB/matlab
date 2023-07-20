classdef(Sealed=true)TCPIPIOInterface<codertarget.attributes.IOInterface



    properties
        IPAddress=struct('value','10.10.10.1','visible','true')
        Port=struct('value','22','visible','true')
        Verbose=struct('value','false','visible','true')
    end
    methods(Access={?codertarget.attributes.ExternalModeInfo})
        function h=TCPIPIOInterface(structVal)
            if isstruct(structVal)
                h.initializeIOInterface(structVal)
                if isfield(structVal,'ipaddress')
                    h.IPAddress=structVal.ipaddress;
                end
                if isfield(structVal,'port')
                    h.Port=structVal.port;
                end
                if isfield(structVal,'verbose')
                    h.Verbose=structVal.verbose;
                end
            end
        end
    end
    methods
        function obj=set.IPAddress(obj,val)
            val=codertarget.attributes.IOInterface.refineTransportSubField(val,'IPAddress');
            obj.IPAddress=val;
        end
        function obj=set.Port(obj,val)
            val=codertarget.attributes.IOInterface.refineTransportSubField(val,'Port');
            obj.Port=val;
        end
        function obj=set.Verbose(obj,val)
            val=codertarget.attributes.IOInterface.refineTransportSubField(val,'Verbose');
            val.value=~isequal(val.value,'false')&&~isequal(val.value,'0');
            obj.Verbose=val;
        end
    end
end