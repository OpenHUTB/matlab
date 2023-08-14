classdef StairGenerator_class<ConvClass&handle



    properties

        OldParam=struct(...
        't',[],...
        'e',[],...
        'Ts',[]...
        )


        OldDropdown=struct(...
        )


        NewDirectParam=struct(...
        'TimeInput',[],...
        'AmplitudeInput',[],...
        'SampleTime',[]...
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
        OldPath='powerlib_meascontrol/Pulse & Signal Generators/Stair Generator'
        NewPath='elec_conv_sl_StairGenerator/StairGenerator'
    end

    methods
        function obj=objParamMappingDirect(obj)
            obj.NewDirectParam.TimeInput=obj.OldParam.t;
            obj.NewDirectParam.AmplitudeInput=obj.OldParam.e;
            obj.NewDirectParam.SampleTime=obj.OldParam.Ts;
        end

        function obj=StairGenerator_class()
            if nargin>0
            end
        end

        function obj=objParamMappingDerived(obj)


        end

        function obj=objDropdownMapping(obj)
        end
    end

end
