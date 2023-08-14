classdef PWMGenerator_DC_DC__class<ConvClass&handle



    properties

        OldParam=struct(...
        'Fsw',[],...
        'Ts',[]...
        )


        OldDropdown=struct(...
        )


        NewDirectParam=struct(...
        'Ts',[]...
        )


        NewDerivedParam=struct(...
        'Tper',[]...
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
        OldPath='powerlib_meascontrol/Pulse & Signal Generators/PWM Generator (DC-DC)'
        NewPath='elec_conv_sl_PWMGenerator_DC_DC_/PWMGenerator_DC_DC_'
    end

    methods
        function obj=objParamMappingDirect(obj)
            obj.NewDirectParam.Ts=obj.OldParam.Ts;
        end

        function obj=PWMGenerator_DC_DC__class(Fsw)
            if nargin>0
                obj.OldParam.Fsw=Fsw;
            end
        end

        function obj=objParamMappingDerived(obj)

            obj.NewDerivedParam.Tper=1/obj.OldParam.Fsw;

        end

        function obj=objDropdownMapping(obj)
        end
    end

end
