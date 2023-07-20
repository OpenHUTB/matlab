classdef Bistable_class<ConvClass&handle



    properties

        OldParam=struct(...
        'ic',[],...
        'Ts',[]...
        )


        OldDropdown=struct(...
        'Qpriority',[]...
        )


        NewDirectParam=struct(...
        'Q0',[],...
        'Ts',[]...
        )


        NewDerivedParam=struct(...
        )


        NewDropdown=struct(...
        'UndefState',[]...
        )


        BlockOption={...
        }

        OldBlockName=[];
        NewBlockPath=[];
        ConversionType=[];
    end

    properties(Constant)
        OldPath='powerlib_meascontrol/Logic/Bistable'
        NewPath='elec_conv_sl_Bistable/Bistable'
    end

    methods
        function obj=objParamMappingDirect(obj)
            obj.NewDirectParam.Q0=obj.OldParam.ic
            obj.NewDirectParam.Ts=obj.OldParam.Ts
        end

        function obj=Bistable_class()
            if nargin>0
            end
        end

        function obj=objParamMappingDerived(obj)


        end

        function obj=objDropdownMapping(obj)

            switch obj.OldDropdown.Qpriority
            case 'Reset'
                obj.NewDropdown.UndefState='Reset'
            case 'Set'
                obj.NewDropdown.UndefState='Set'
            end
        end
    end

end
