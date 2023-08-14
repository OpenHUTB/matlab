classdef Alpha_Beta_ZeroToAbc_class<ConvClass&handle



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
        OldPath='powerlib_meascontrol/Transformations/Alpha-Beta-Zero to abc'
        NewPath='elec_conv_sl_Alpha_Beta_ZeroToAbc/Alpha_Beta_ZeroToAbc'
    end

    methods
        function obj=objParamMappingDirect(obj)
        end

        function obj=Alpha_Beta_ZeroToAbc_class()
            if nargin>0
            end
        end

        function obj=objParamMappingDerived(obj)


        end

        function obj=objDropdownMapping(obj)

        end
    end

end
