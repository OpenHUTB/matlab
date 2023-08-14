classdef DiscreteVariableTimeDela_class<ConvClass&handle



    properties

        OldParam=struct(...
        'MaxDelay',[],...
        'InitialValue',[],...
        'Ts',[]...
        )


        OldDropdown=struct(...
        'DFT',[]...
        )


        NewDirectParam=struct(...
        'MaximumDelay',[]...
        )


        NewDerivedParam=struct(...
        )


        NewDropdown=struct(...
        'TransDelayFeedthrough',[]...
        )


        BlockOption={...
        }
        OldBlockName=[];
        NewBlockPath=[];
        ConversionType=[];
    end

    properties(Constant)
        OldPath='powerlib_meascontrol/Additional Components/Discrete Variable Time Delay'
        NewPath='elec_conv_sl_DiscreteVariableTimeDela/DiscreteVariableTimeDela'
    end

    methods
        function obj=objParamMappingDirect(obj)
            obj.NewDirectParam.MaximumDelay=obj.OldParam.MaxDelay;
        end

        function obj=DiscreteVariableTimeDela_class()
            if nargin>0
            end
        end

        function obj=objParamMappingDerived(obj)


        end

        function obj=objDropdownMapping(obj)
            obj.NewDropdown.TransDelayFeedthrough=obj.OldDropdown.DFT;
        end
    end

end
