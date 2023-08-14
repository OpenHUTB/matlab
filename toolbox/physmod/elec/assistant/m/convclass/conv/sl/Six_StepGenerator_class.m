classdef Six_StepGenerator_class<ConvClass&handle



    properties

        OldParam=struct(...
        'pos_dv',[],...
        'neg_dv',[],...
        'decel_ramp',[],...
        'accel_ramp',[],...
        'minof',[],...
        'maxof',[],...
        'minbv',[],...
        'maxbv',[],...
        'vbhr',[],...
        'zc_time',[],...
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
        OldPath='electricdrivelib/Fundamental Drive Blocks/Six-Step Generator'
        NewPath='elec_conv_sl_Six_StepGenerator/Six_StepGenerator'
    end

    methods
        function obj=objParamMappingDirect(obj)
        end

        function obj=Six_StepGenerator_class()
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
