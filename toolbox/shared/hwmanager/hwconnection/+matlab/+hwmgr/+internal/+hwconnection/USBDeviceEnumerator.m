classdef USBDeviceEnumerator<handle



































    properties(Constant,Hidden)
        enum_getAttachedDevices=0;
        enum_getSerialPorts=1;
        enum_getMountPoints=2;
    end

    properties(SetAccess=private,Hidden,GetAccess=public)
        getMethodIndex;
    end

    methods(Access=public)
        function obj=USBDeviceEnumerator

            if ispc
                if NET.isNETSupported
                    NET.addAssembly(fullfile(matlabroot,'bin',computer('arch'),'findWindowsUSBDevices.dll'));
                else
                    error(message('hwconnection:setup:NETVersion'));
                end
            end
        end

        function deviceInfo=getAttachedDevices(obj)















            obj.getMethodIndex=obj.enum_getAttachedDevices;
            deviceInfo=obj.getUSBDeviceInfo();
            rmfields={'SerialPort','MountPoint'};
            if~isempty(deviceInfo)
                deviceInfo=rmfield(deviceInfo,rmfields);
            end
        end

        function[serialPorts,deviceInfo]=getSerialPorts(obj,varargin)




















































            retreiveField='SerialPort';
            obj.getMethodIndex=obj.enum_getSerialPorts;
            [serialPorts,deviceInfo]=obj.extractSerialMountInfo(retreiveField,varargin{:});
        end

        function[mountPoints,deviceInfo]=getMountPoints(obj,varargin)
















































            retreiveField='MountPoint';
            obj.getMethodIndex=obj.enum_getMountPoints;
            [mountPoints,deviceInfo]=obj.extractSerialMountInfo(retreiveField,varargin{:});
        end

    end

    methods(Access=private)
        function[retSerialMount,deviceInfo]=extractSerialMountInfo(obj,retreiveField,varargin)



            retSerialMount={};
            deviceInfo=matlab.hwmgr.internal.hwconnection.utils.structureInit();
            tmpDeviceInfo=obj.getUSBDeviceInfo(varargin{:});
            if~isempty(tmpDeviceInfo)
                if~isempty(char(tmpDeviceInfo.(retreiveField)))
                    [retSerialMount,sortIndexArray]=sort({tmpDeviceInfo.(retreiveField)});
                    serialMountIndex=~cellfun(@isempty,retSerialMount);
                    retSerialMount=retSerialMount(serialMountIndex);
                    rmfields={'SerialPort','MountPoint'};
                    deviceInfo=rmfield(tmpDeviceInfo(sortIndexArray(serialMountIndex)),rmfields);
                end
            end
        end

        function usbdeviceinfo=getUSBDeviceInfo(obj,varargin)





            if~isempty(varargin)
                inputParams=matlab.hwmgr.internal.hwconnection.utils.validateInputs(varargin{:});
            else
                inputParams={};
            end

            if ispc
                usbdeviceinfo=matlab.hwmgr.internal.hwconnection.utils.getUSBDevicesInWindows(obj,inputParams);
            elseif ismac
                usbdeviceinfo=matlab.hwmgr.internal.hwconnection.utils.getUSBDevicesInMac(obj,inputParams);
            else
                usbdeviceinfo=matlab.hwmgr.internal.hwconnection.utils.getUSBDevicesInLinux(obj,inputParams);
            end
        end

    end

end