classdef abcToDq0_class<ConvClass&handle



    properties

        OldParam=struct(...
        )


        OldDropdown=struct(...
        'Alignment',[]...
        )


        NewDirectParam=struct(...
        )


        NewDerivedParam=struct(...
        )


        NewDropdown=struct(...
        'AxisAlignment',[]...
        )


        BlockOption={...
        }

        OldBlockName=[];
        NewBlockPath=[];
        ConversionType=[];
    end

    properties(Constant)
        OldPath='powerlib_meascontrol/Transformations/abc to dq0'
        NewPath='elec_conv_sl_abcToDq0/abcToDq0'
    end

    methods
        function obj=objParamMappingDirect(obj)
        end

        function obj=abcToDq0_class()
            if nargin>0
            end
        end

        function obj=objParamMappingDerived(obj)


        end

        function obj=objDropdownMapping(obj)

            switch obj.OldDropdown.Alignment
            case 'Aligned with phase A axis'
                obj.NewDropdown.AxisAlignment='D-axis';
            case '90 degrees behind phase A axis'
                obj.NewDropdown.AxisAlignment='Q-axis';
            end

        end
    end

end
