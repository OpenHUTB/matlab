classdef First_OrderFilter_class<ConvClass&handle



    properties

        OldParam=struct(...
        'Tc',[],...
        'Ts',[],...
        'Vac_Init',[],...
        'Vdc_Init',[],...
        'FreqRange',[]...
        )


        OldDropdown=struct(...
        'FilterType',[],...
        'Initialize',[],...
        'PlotResponse',[]...
        )


        NewDirectParam=struct(...
        'K',[],...
        'T',[],...
        'Ts',[]...
        )


        NewDerivedParam=struct(...
        )


        NewDropdown=struct(...
        )


        BlockOption={...
        {'FilterType','Lowpass'},'lowpass';...
        {'FilterType','Highpass'},'highpass';...
        }

        OldBlockName=[];
        NewBlockPath=[];
        ConversionType=[];
    end

    properties(Constant)
        OldPath='powerlib_meascontrol/Filters/First-Order Filter'
        NewPath='elec_conv_sl_First_OrderFilter/First_OrderFilter'
    end

    methods
        function obj=objParamMappingDirect(obj)
            obj.NewDirectParam.K=1;
            obj.NewDirectParam.T=obj.OldParam.Tc;
            obj.NewDirectParam.Ts=obj.OldParam.Ts;
        end

        function obj=First_OrderFilter_class()
            if nargin>0
            end
        end

        function obj=objParamMappingDerived(obj)


        end

        function obj=objDropdownMapping(obj)
        end
    end

end
