classdef SawtoothGenerator_class<ConvClass&handle



    properties

        OldParam=struct(...
        'Freq',[],...
        'Phase',[],...
        'Ts',[]...
        )


        OldDropdown=struct(...
        )


        NewDirectParam=struct(...
        'Ts',[]...
        )


        NewDerivedParam=struct(...
        'Tper',[],...
        'Tdelay',[]...
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
        OldPath='powerlib_meascontrol/Pulse & Signal Generators/Sawtooth Generator'
        NewPath='elec_conv_sl_SawtoothGenerator/SawtoothGenerator'
    end

    methods
        function obj=objParamMappingDirect(obj)
            obj.NewDirectParam.Ts=obj.OldParam.Ts;
        end

        function obj=SawtoothGenerator_class(Freq,Phase)
            if nargin>0
                obj.OldParam.Freq=Freq;
                obj.OldParam.Phase=Phase;
            end
        end

        function obj=objParamMappingDerived(obj)

            obj.NewDerivedParam.Tper=1/obj.OldParam.Freq;
            obj.NewDerivedParam.Tdelay=obj.OldParam.Phase/360/obj.OldParam.Freq;

        end

        function obj=objDropdownMapping(obj)
        end
    end

end
