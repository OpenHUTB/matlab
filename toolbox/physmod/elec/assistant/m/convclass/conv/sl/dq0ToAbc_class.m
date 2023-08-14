classdef dq0ToAbc_class<ConvClass&handle



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
        OldPath='powerlib_meascontrol/Transformations/dq0 to abc'
        NewPath='elec_conv_sl_dq0ToAbc/dq0ToAbc'
    end

    methods
        function obj=objParamMappingDirect(obj)
        end

        function obj=dq0ToAbc_class()
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
