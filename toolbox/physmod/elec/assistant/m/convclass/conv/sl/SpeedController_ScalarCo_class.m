classdef SpeedController_ScalarCo_class<ConvClass&handle



    properties

        OldParam=struct(...
        'kp',[],...
        'ki',[],...
        'vbhr',[],...
        'zc_time',[],...
        'Tsc',[],...
        'bs',[],...
        'ramp',[],...
        'fc',[],...
        'ctrl_freq',[],...
        'ctrl_volt',[],...
        'ctrl_sat',[],...
        'p',[],...
        'Ts',[]...
        )


        OldDropdown=struct(...
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
        OldPath='electricdrivelib/Fundamental Drive Blocks/Speed Controller (Scalar Control)'
        NewPath='elec_conv_sl_SpeedController_ScalarCo/SpeedController_ScalarCo'
    end

    methods
        function obj=objParamMappingDirect(obj)
        end

        function obj=SpeedController_ScalarCo_class()
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
