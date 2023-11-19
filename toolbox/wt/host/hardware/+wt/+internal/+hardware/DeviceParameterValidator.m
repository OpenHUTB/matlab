classdef DeviceParameterValidator<handle


    methods(Static)
        function validateDeviceName(deviceName,funcName,varName)
            validateattributes(deviceName,{'char'},{'nonempty','row'},...
            funcName,varName);
        end

        function validateDeviceParameters(devParams,funcName,varName)


            if~isfield(devParams,'Name')||...
                ~isfield(devParams,'Product')||...
                ~isfield(devParams,'Type')||...
                ~isfield(devParams,'Variant')||...
                ~isfield(devParams,'Network')||...
                ~isfield(devParams,'ImageInfo')
                error(message('wt:radio:InvalidRadioParameters',funcName,varName));
            end
        end
    end
end