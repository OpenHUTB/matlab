classdef Mean_VariableFrequency__class<ConvClass&handle



    properties

        OldParam=struct(...
        'Finit',[],...
        'Fmin',[],...
        'Vinit',[],...
        'Ts',[]...
        )


        OldDropdown=struct(...
        )


        NewDirectParam=struct(...
        'f0',[],...
        'fmin',[],...
        'x0',[],...
        'Ts',[]...
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
        OldPath='powerlib_meascontrol/Measurements/Mean (Variable Frequency)'
        NewPath='elec_conv_sl_Mean_VariableFrequency_/Mean_VariableFrequency_'
    end

    methods
        function obj=objParamMappingDirect(obj)
            obj.NewDirectParam.f0=obj.OldParam.Finit;
            obj.NewDirectParam.fmin=obj.OldParam.Fmin;
            obj.NewDirectParam.x0=obj.OldParam.Vinit;
            obj.NewDirectParam.Ts=obj.OldParam.Ts;
        end

        function obj=Mean_VariableFrequency__class()
            if nargin>0
            end
        end

        function obj=objParamMappingDerived(obj)


        end

        function obj=objDropdownMapping(obj)
            logObj=ElecAssistantLog.getInstance();
        end
    end

end
