classdef OffDelay_class<ConvClass&handle



    properties

        OldParam=struct(...
        'delay',[],...
        'ic',[],...
        'Ts',[]...
        )


        OldDropdown=struct(...
        'DelayType',[]...
        )


        NewDirectParam=struct(...
        'Td_on',[],...
        'Td_off',[],...
        'IC',[],...
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
        OldPath='powerlib_meascontrol/Logic/Off Delay'
        NewPath='elec_conv_sl_OffDelay/OffDelay'
    end

    methods
        function obj=objParamMappingDirect(obj)
            switch obj.OldDropdown.DelayType
            case 'On delay'
                obj.NewDirectParam.Td_on=obj.OldParam.delay;
                obj.NewDirectParam.Td_off=0;
            case 'Off delay'
                obj.NewDirectParam.Td_on=0;
                obj.NewDirectParam.Td_off=obj.OldParam.delay;
            end
            obj.NewDirectParam.IC=obj.OldParam.ic;
            obj.NewDirectParam.Ts=obj.OldParam.Ts;
        end

        function obj=OffDelay_class()
            if nargin>0
            end
        end

        function obj=objParamMappingDerived(obj)


        end

        function obj=objDropdownMapping(obj)
        end
    end

end
