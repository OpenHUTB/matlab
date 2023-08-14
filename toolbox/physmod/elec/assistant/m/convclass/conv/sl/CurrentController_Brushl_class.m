classdef CurrentController_Brushl_class<ConvClass&handle



    properties

        OldParam=struct(...
        'nb_p',[],...
        'fluxConstant',[],...
        'voltageConstant',[],...
        'torqueConstant',[],...
        'flat',[],...
        'freq_max',[],...
        'Ts_vect',[],...
        'h',[]...
        )


        OldDropdown=struct(...
        'detailLevel',[],...
        'machineConstant',[]...
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
        OldPath='electricdrivelib/Fundamental Drive Blocks/Current Controller (Brushless DC)'
        NewPath='elec_conv_sl_CurrentController_Brushl/CurrentController_Brushl'
    end

    methods
        function obj=objParamMappingDirect(obj)
        end

        function obj=CurrentController_Brushl_class()
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
