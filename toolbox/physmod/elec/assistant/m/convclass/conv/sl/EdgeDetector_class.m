classdef EdgeDetector_class<ConvClass&handle



    properties

        OldParam=struct(...
        'ic',[],...
        'Ts',[]...
        )


        OldDropdown=struct(...
        'model',[]...
        )


        NewDirectParam=struct(...
        'x0',[],...
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
        OldPath='powerlib_meascontrol/Logic/Edge Detector'
        NewPath='elec_conv_sl_EdgeDetector/EdgeDetector'
    end

    methods
        function obj=objParamMappingDirect(obj)
            obj.NewDirectParam.x0=obj.OldParam.ic
            obj.NewDirectParam.Ts=obj.OldParam.Ts
        end

        function obj=EdgeDetector_class()
            if nargin>0
            end
        end

        function obj=objParamMappingDerived(obj)


        end

        function obj=objDropdownMapping(obj)

            switch obj.OldDropdown.model
            case 'Rising'
                obj.NewDropdown.ChangeType='Rising edge'
            case 'Falling'
                obj.NewDropdown.ChangeType='Falling edge'
            case 'Either'
                obj.NewDropdown.ChangeType='Either edge'
            end

        end
    end

end
