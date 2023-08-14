classdef Voltage_CurrentSimscapeI_class<ConvClass&handle



    properties

        OldParam=struct(...
        'T',[],...
        'Ts',[],...
        'i0',[],...
        'v0',[]...
        )


        OldDropdown=struct(...
        'Fmode',[],...
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
        OldPath='powerlib/Interface Elements/Voltage-Current Simscape Interface'
        NewPath='elec_conv_Voltage_CurrentSimscapeI/Voltage_CurrentSimscapeI'
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
