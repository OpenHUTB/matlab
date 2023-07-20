classdef Lead_LagFilter_class<ConvClass&handle



    properties

        OldParam=struct(...
        'T1',[],...
        'T2',[],...
        'Vdc_Init',[],...
        'Ts',[]...
        )


        OldDropdown=struct(...
        )


        NewDirectParam=struct(...
        'T1',[],...
        'T2',[],...
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
        OldPath='powerlib_meascontrol/Filters/Lead-Lag Filter'
        NewPath='elec_conv_sl_Lead_LagFilter/Lead_LagFilter'
    end

    methods
        function obj=objParamMappingDirect(obj)
            obj.NewDirectParam.T1=obj.OldParam.T1;
            obj.NewDirectParam.T2=obj.OldParam.T2;
            obj.NewDirectParam.Ts=obj.OldParam.Ts;
        end

        function obj=Lead_LagFilter_class()
            if nargin>0
            end
        end

        function obj=objParamMappingDerived(obj)


        end

        function obj=objDropdownMapping(obj)
        end
    end

end
