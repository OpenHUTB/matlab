classdef Power_3ph_Instantaneous__class<ConvClass&handle



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
        OldPath='powerlib_meascontrol/Measurements/Power (3ph, Instantaneous)'
        NewPath='elec_conv_sl_Power_3ph_Instantaneous_/Power_3ph_Instantaneous_'
    end

    methods
        function obj=objParamMappingDirect(obj)
        end

        function obj=Power_3ph_Instantaneous__class()
            if nargin>0
            end
        end

        function obj=objParamMappingDerived(obj)


        end

        function obj=objDropdownMapping(obj)
        end
    end

end
