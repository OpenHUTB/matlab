classdef Current_VoltageSimscap_1_class<ConvClass&handle



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
        OldPath='powerlib/Interface Elements/Current-Voltage Simscape Interface (gnd)'
        NewPath='elec_conv_Current_VoltageSimscap_1/Current_VoltageSimscap_1'
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
