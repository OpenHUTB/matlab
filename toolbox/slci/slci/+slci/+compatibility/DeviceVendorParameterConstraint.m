

classdef DeviceVendorParameterConstraint<slci.compatibility.NegativeModelParameterConstraint

    methods
        function obj=DeviceVendorParameterConstraint(aFatal,aParameterName,varargin)
            obj=obj@slci.compatibility.NegativeModelParameterConstraint(aFatal,aParameterName,varargin{:});
            obj.setEnum('HardwareImplementationPane');
        end

        function[SubTitle,Information,StatusText,RecAction]=getSpecificMAStrings(aObj,status,varargin)
            [SubTitle,Information,StatusText,RecAction]=getSpecificMAStrings@slci.compatibility.NegativeModelParameterConstraint(aObj,status,varargin{:});
            if~status
                RecAction=[RecAction,' ',DAStudio.message('Slci:compatibility:SLCIHardwareSettingNote')];
            end
        end

        function out=hasAutoFix(~)
            out=true;
        end

        function out=fix(aObj,~)
            out=false;
            defaultSupportedValue='Custom Processor->Custom';

            parameterName=aObj.getParameterName();
            try
                aObj.ParentModel().setParam(parameterName,defaultSupportedValue);
                out=true;
            catch
            end
        end

    end
end
