classdef SerialDevice<matlab.hwmgr.internal.DeviceInfo










    properties
        COMPort='';
        VendorID='';
        ProductID='';
        SerialNumber='';
        Manufacturer='';
    end

    methods

        function obj=SerialDevice(varargin)
            obj@matlab.hwmgr.internal.DeviceInfo(varargin{:});
            obj.Type=char(matlab.hwmgr.internal.CommunicationInterface.Serial);
        end
    end



    methods
        function set.COMPort(obj,val)
            obj.validateStrsAndCharInputs(val);
            obj.COMPort=val;
        end

        function set.VendorID(obj,val)
            obj.validateStrsAndCharInputs(val);
            obj.VendorID=val;
        end

        function set.ProductID(obj,val)
            obj.validateStrsAndCharInputs(val);
            obj.ProductID=val;
        end

        function set.SerialNumber(obj,val)
            obj.validateStrsAndCharInputs(val);
            obj.SerialNumber=val;
        end

        function set.Manufacturer(obj,val)
            obj.validateStrsAndCharInputs(val);
            obj.Manufacturer=val;
        end
    end


end