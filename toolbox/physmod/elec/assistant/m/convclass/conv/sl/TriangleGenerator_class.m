classdef TriangleGenerator_class<ConvClass&handle



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
        OldPath='powerlib_meascontrol/Pulse & Signal Generators/Triangle Generator'
        NewPath='elec_conv_sl_TriangleGenerator/TriangleGenerator'
    end

    methods
        function obj=objParamMappingDirect(obj)
            obj.NewDirectParam.Ts=obj.OldParam.Ts;
        end

        function obj=TriangleGenerator_class(Freq,Phase)
            if nargin>0
                obj.OldParam.Freq=Freq;
                obj.OldParam.Phase=Phase;
            end
        end

        function obj=objParamMappingDerived(obj)

            obj.NewDerivedParam.Tper=1/obj.OldParam.Freq/2;
            obj.NewDerivedParam.Tdelay=1/obj.OldParam.Freq/360*obj.OldParam.Phase;

        end

        function obj=objDropdownMapping(obj)
        end
    end

end
