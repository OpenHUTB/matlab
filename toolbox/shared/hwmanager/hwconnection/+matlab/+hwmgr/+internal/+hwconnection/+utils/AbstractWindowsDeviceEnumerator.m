classdef(Hidden)AbstractWindowsDeviceEnumerator







    properties

    end
    methods(Abstract)
        deviceInfo=getUSBDevices(varargin)
    end
end