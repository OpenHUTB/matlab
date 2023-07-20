classdef Mean_class<ConvClass&handle



    properties

        OldParam=struct(...
        'Freq',[],...
        'Vinit',[],...
        'Ts',[]...
        )


        OldDropdown=struct(...
        )


        NewDirectParam=struct(...
        'f',[],...
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
        OldPath='powerlib_meascontrol/Measurements/Mean'
        NewPath='elec_conv_sl_Mean/Mean'
    end

    methods
        function obj=objParamMappingDirect(obj)
            obj.NewDirectParam.f=obj.OldParam.Freq;
            obj.NewDirectParam.x0=obj.OldParam.Vinit;
            obj.NewDirectParam.Ts=obj.OldParam.Ts;
        end

        function obj=Mean_class()
            if nargin>0
            end
        end

        function obj=objParamMappingDerived(obj)


        end

        function obj=objDropdownMapping(obj)
            logObj=ElecAssistantLog.getInstance();
        end
    end

end
