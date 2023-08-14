classdef(Hidden)WindowsDeviceEnumerator<matlab.hwmgr.internal.hwconnection.utils.AbstractWindowsDeviceEnumerator





    properties

    end

    methods(Hidden)
        function deviceInfo=getUSBDevices(~,varargin)




            obj=findWindowsUSBDevices.findWindowsUSBDevices;
            if isempty(varargin)

                deviceInfo=obj.GetUSBDevices;
            else

                deviceInfo=obj.GetUSBDevices(varargin{:});
            end
        end

    end

end