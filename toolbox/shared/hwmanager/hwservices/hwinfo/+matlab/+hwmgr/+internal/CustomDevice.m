classdef CustomDevice<matlab.hwmgr.internal.DeviceInfo










    methods

        function obj=CustomDevice(varargin)
            obj@matlab.hwmgr.internal.DeviceInfo(varargin{:});
            obj.Type=char(matlab.hwmgr.internal.CommunicationInterface.Custom);
        end
    end
end