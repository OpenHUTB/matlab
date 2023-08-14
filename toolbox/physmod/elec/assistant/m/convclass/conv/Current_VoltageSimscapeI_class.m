classdef Current_VoltageSimscapeI_class<ConvClass&handle



    properties

        OldParam=struct(...
        'T',[],...
        'Ts',[],...
        'i0',[],...
        'v0',[]...
        )


        OldDropdown=struct(...
        'FMode',[],...
        'Sd',[],...
        'DFT',[],...
        'Measurements',[]...
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
        OldPath='powerlib/Interface Elements/Current-Voltage Simscape Interface'
        NewPath='elec_conv_Current_VoltageSimscapeI/Current_VoltageSimscapeI'
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
