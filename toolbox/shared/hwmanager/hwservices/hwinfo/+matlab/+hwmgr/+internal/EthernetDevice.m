classdef EthernetDevice<matlab.hwmgr.internal.DeviceInfo










    properties
        IPAddress='';
        Username='';
        Password='';
        Port='';
    end

    methods
        function obj=EthernetDevice(varargin)
            obj@matlab.hwmgr.internal.DeviceInfo(varargin{:});
            obj.Type=char(matlab.hwmgr.internal.CommunicationInterface.Ethernet);
        end
    end


    methods
        function set.IPAddress(obj,val)
            obj.validateStrsAndCharInputs(val);
            obj.IPAddress=val;
        end

        function set.Username(obj,val)
            obj.validateStrsAndCharInputs(val);
            obj.Username=val;
        end

        function set.Password(obj,val)
            obj.validateStrsAndCharInputs(val);
            obj.Password=val;
        end

        function set.Port(obj,val)
            obj.validateStrsAndCharInputs(val);
            obj.Port=val;
        end

    end
end