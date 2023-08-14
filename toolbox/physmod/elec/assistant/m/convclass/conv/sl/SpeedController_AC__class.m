classdef SpeedController_AC__class<ConvClass&handle



    properties

        OldParam=struct(...
        'Ts',[],...
        'ramp',[],...
        'kp',[],...
        'ki',[],...
        'fc',[],...
        'ctrl_sat',[],...
        'Tsc',[],...
        'fn',[],...
        'p',[],...
        'nf',[]...
        )


        OldDropdown=struct(...
        'ctrlType',[],...
        'SwK',[]...
        )


        NewDirectParam=struct(...
        )


        NewDerivedParam=struct(...
        )


        NewDropdown=struct(...
        )


        BlockOption={...
        }
        OldBlockName=[];
        NewBlockPath=[];
        ConversionType=[];
    end

    properties(Constant)
        OldPath='electricdrivelib/Fundamental Drive Blocks/Speed Controller (AC)'
        NewPath='elec_conv_sl_SpeedController_AC_/SpeedController_AC_'
    end

    methods
        function obj=objParamMappingDirect(obj)
        end

        function obj=SpeedController_AC__class()
            if nargin>0
            end
        end

        function obj=objParamMappingDerived(obj)


        end

        function obj=objDropdownMapping(obj)
            logObj=ElecAssistantLog.getInstance();
            logObj.addMessage(obj,'BlockNotSupported');
        end
    end

end
