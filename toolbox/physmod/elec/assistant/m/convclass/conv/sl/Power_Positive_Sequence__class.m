classdef Power_Positive_Sequence__class<ConvClass&handle



    properties

        OldParam=struct(...
        'Freq',[],...
        'Vinit',[],...
        'Iinit',[],...
        'Ts',[]...
        )


        OldDropdown=struct(...
        )


        NewDirectParam=struct(...
        'F',[],...
        'K',[],...
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
        OldPath='powerlib_meascontrol/Measurements/Power (Positive-Sequence)'
        NewPath='elec_conv_sl_Power_Positive_Sequence_/Power_Positive_Sequence_'
    end

    methods
        function obj=objParamMappingDirect(obj)
            obj.NewDirectParam.Ts=obj.OldParam.Ts;
            obj.NewDirectParam.F=obj.OldParam.Freq;
            obj.NewDirectParam.K=1;
        end

        function obj=Power_Positive_Sequence__class()
            if nargin>0
            end
        end

        function obj=objParamMappingDerived(obj)


        end

        function obj=objDropdownMapping(obj)
        end
    end

end
