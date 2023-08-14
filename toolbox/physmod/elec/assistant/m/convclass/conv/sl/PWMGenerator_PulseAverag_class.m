classdef PWMGenerator_PulseAverag_class<ConvClass&handle



    properties

        OldParam=struct(...
        'Fc',[],...
        'InitialPhase',[],...
        'Ts',[]...
        )


        OldDropdown=struct(...
        'GeneratorType',[]...
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
        OldPath='powerlib_meascontrol/Pulse & Signal Generators/PWM Generator (Pulse Averaging)'
        NewPath='elec_conv_sl_PWMGenerator_PulseAverag/PWMGenerator_PulseAverag'
    end
    methods
        function obj=objParamMappingDirect(obj)
        end

        function obj=PWMGenerator_PulseAverag_class()
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
