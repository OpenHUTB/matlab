classdef ConnectionPort_class<ConvClass&handle



    properties

        OldParam=struct(...
        'Port',[]...
        )


        OldDropdown=struct(...
        'Side',[]...
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
        OldPath='powerlib/Elements/Connection Port'
        NewPath='elec_conv_ConnectionPort/ConnectionPort'
    end
    methods
        function obj=objParamMappingDirect(obj)
        end

        function obj=objParamMappingDerived(obj)


        end

        function obj=objDropdownMapping(obj)
        end
    end

end
