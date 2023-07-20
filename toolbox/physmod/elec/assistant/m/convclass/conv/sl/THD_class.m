classdef THD_class<ConvClass&handle



    properties

        OldParam=struct(...
        'Freq',[],...
        'Ts',[]...
        )


        OldDropdown=struct(...
        )


        NewDirectParam=struct(...
        'f',[],...
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
        OldPath='powerlib_meascontrol/Measurements/THD'
        NewPath='elec_conv_sl_THD/THD'
    end

    methods
        function obj=objParamMappingDirect(obj)
            obj.NewDirectParam.f=obj.OldParam.Freq;
            obj.NewDirectParam.Ts=obj.OldParam.Ts;
        end

        function obj=THD_class()
            if nargin>0
            end
        end

        function obj=objParamMappingDerived(obj)


        end

        function obj=objDropdownMapping(obj)
        end
    end

end
