classdef SampleAndHold_class<ConvClass&handle



    properties

        OldParam=struct(...
        'ic',[],...
        'Ts',[]...
        )


        OldDropdown=struct(...
        )


        NewDirectParam=struct(...
        'x0',[],...
        'Ts',[]...
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
        OldPath='powerlib_meascontrol/Additional Components/Sample and Hold'
        NewPath='elec_conv_sl_SampleAndHold/SampleAndHold'
    end

    methods
        function obj=objParamMappingDirect(obj)
            obj.NewDirectParam.x0=obj.OldParam.ic;
            obj.NewDirectParam.Ts=obj.OldParam.Ts;
        end

        function obj=SampleAndHold_class()
            if nargin>0
            end
        end

        function obj=objParamMappingDerived(obj)


        end

        function obj=objDropdownMapping(obj)
        end
    end

end
