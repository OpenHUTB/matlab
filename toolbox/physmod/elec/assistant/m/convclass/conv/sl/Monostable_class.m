classdef Monostable_class<ConvClass&handle



    properties

        OldParam=struct(...
        'PulseDuration',[],...
        'ic',[],...
        'Ts',[]...
        )


        OldDropdown=struct(...
        'EdgeDetect',[]...
        )


        NewDirectParam=struct(...
        'x0',[],...
        'Td',[],...
        'Ts',[]...
        )


        NewDerivedParam=struct(...
        )


        NewDropdown=struct(...
        'ChangeType',[]...
        )


        BlockOption={...
        }

        OldBlockName=[];
        NewBlockPath=[];
        ConversionType=[];
    end

    properties(Constant)
        OldPath='powerlib_meascontrol/Logic/Monostable'
        NewPath='elec_conv_sl_Monostable/Monostable'
    end

    methods
        function obj=objParamMappingDirect(obj)
            obj.NewDirectParam.x0=obj.OldParam.ic;
            obj.NewDirectParam.Td=obj.OldParam.PulseDuration;
            obj.NewDirectParam.Ts=obj.OldParam.Ts;
        end

        function obj=Monostable_class()
            if nargin>0
            end
        end

        function obj=objParamMappingDerived(obj)


        end

        function obj=objDropdownMapping(obj)
            switch obj.OldDropdown.EdgeDetect
            case 'Rising'
                obj.NewDropdown.ChangeType='Rising edge';
            case 'Falling'
                obj.NewDropdown.ChangeType='Falling edge';
            case 'Either'
                obj.NewDropdown.ChangeType='Either edge';
            end
        end
    end

end
