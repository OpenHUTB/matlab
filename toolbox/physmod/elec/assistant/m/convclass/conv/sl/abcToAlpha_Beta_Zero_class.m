classdef abcToAlpha_Beta_Zero_class<ConvClass&handle



    properties

        OldParam=struct(...
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
        OldPath='powerlib_meascontrol/Transformations/abc to Alpha-Beta-Zero'
        NewPath='elec_conv_sl_abcToAlpha_Beta_Zero/abcToAlpha_Beta_Zero'
    end

    methods
        function obj=objParamMappingDirect(obj)
        end

        function obj=abcToAlpha_Beta_Zero_class()
            if nargin>0
            end
        end

        function obj=objParamMappingDerived(obj)


        end

        function obj=objDropdownMapping(obj)
        end
    end

end
