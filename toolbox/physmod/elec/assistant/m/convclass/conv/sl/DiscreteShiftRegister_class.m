classdef DiscreteShiftRegister_class<ConvClass&handle



    properties

        OldParam=struct(...
        'NSamples',[],...
        'InitialValue',[],...
        'Ts',[]...
        )


        OldDropdown=struct(...
        )


        NewDirectParam=struct(...
        'N',[],...
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
        OldPath='powerlib_meascontrol/Additional Components/Discrete Shift Register'
        NewPath='elec_conv_sl_DiscreteShiftRegister/DiscreteShiftRegister'
    end

    methods
        function obj=objParamMappingDirect(obj)
            obj.NewDirectParam.N=obj.OldParam.NSamples;
            obj.NewDirectParam.IC=obj.OldParam.InitialValue;
            obj.NewDirectParam.Ts=obj.OldParam.Ts;
        end

        function obj=DiscreteShiftRegister_class()
            if nargin>0
            end
        end

        function obj=objParamMappingDerived(obj)


        end

        function obj=objDropdownMapping(obj)
        end
    end

end
