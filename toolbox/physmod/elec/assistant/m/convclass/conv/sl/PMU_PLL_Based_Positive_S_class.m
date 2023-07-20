classdef PMU_PLL_Based_Positive_S_class<ConvClass&handle



    properties

        OldParam=struct(...
        'reportingFactor',[]...
        )


        OldDropdown=struct(...
        'nominalFrequency',[],...
        'samplingRate',[]...
        )


        NewDirectParam=struct(...
        'k',[]...
        )


        NewDerivedParam=struct(...
        )


        NewDropdown=struct(...
        'frequency',[],...
        'Nsr',[]...
        )


        BlockOption={...
        }
        OldBlockName=[];
        NewBlockPath=[];
        ConversionType=[];
    end

    properties(Constant)
        OldPath='powerlib_meascontrol/Measurements/PMU (PLL-Based, Positive-Sequence)'
        NewPath='elec_conv_sl_PMU_PLL_Based_Positive_S/PMU_PLL_Based_Positive_S'
    end

    methods
        function obj=objParamMappingDirect(obj)
            obj.NewDirectParam.k=obj.OldParam.reportingFactor;
        end

        function obj=PMU_PLL_Based_Positive_S_class()
            if nargin>0
            end
        end

        function obj=objParamMappingDerived(obj)


        end

        function obj=objDropdownMapping(obj)
            obj.NewDropdown.frequency=obj.OldDropdown.nominalFrequency;
            obj.NewDropdown.Nsr=obj.OldDropdown.samplingRate;
        end
    end

end
