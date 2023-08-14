classdef(Hidden)AbstractLinuxDeviceEnumerator






    properties

    end

    methods(Abstract)
        dev_list=getUSBDevices(varargin)
        output=getPartitions(varargin)
        mount=mountDevice(varargin)
        lsblk_output=listBlock(varargin)
    end
end