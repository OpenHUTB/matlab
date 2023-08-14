classdef(Hidden)AbstractMacDeviceEnumerator






    properties

    end

    methods(Abstract)
        dev_list=getUSBDevices(varargin)
        dev_path=getSerialPort(varargin)
        output=getDiskUtilList(varargin)
        mountpoint=getDiskUtilInfo(varargin)
    end

end