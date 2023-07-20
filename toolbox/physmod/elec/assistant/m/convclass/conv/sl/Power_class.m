classdef Power_class<ConvClass&handle



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
        OldPath='powerlib_meascontrol/Measurements/Power'
        NewPath='elec_conv_sl_Power/Power'
    end

    methods
        function obj=objParamMappingDirect(obj)
            obj.NewDirectParam.F=obj.OldParam.Freq;
            obj.NewDirectParam.Ts=obj.OldParam.Ts;
        end

        function obj=Power_class()
            if nargin>0
            end
        end

        function obj=objParamMappingDerived(obj)


        end

        function obj=objDropdownMapping(obj)
        end
    end

end
