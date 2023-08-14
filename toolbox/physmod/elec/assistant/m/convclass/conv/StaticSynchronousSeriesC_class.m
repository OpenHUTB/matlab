classdef StaticSynchronousSeriesC_class<ConvClass&handle



    properties

        OldParam=struct(...
        'SystemNominal',[],...
        'SeriesNominal',[],...
        'RL',[],...
        'Iinit',[],...
        'VnomDC',[],...
        'C_DC',[],...
        'Vqref',[],...
        'MaxRateVqRef',[],...
        'Par_VacReg',[],...
        'Par_VdcReg',[]...
        )


        OldDropdown=struct(...
        'ExternalByPass',[],...
        'ExternalVqref',[]...
        )


        NewDirectParam=struct(...
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
        OldPath='factslib/Power-Electronics Based FACTS/Static Synchronous Series Compensator (Phasor Type)'
        NewPath='elec_conv_StaticSynchronousSeriesC/StaticSynchronousSeriesC'
    end
    methods
        function obj=objParamMappingDirect(obj)
        end

        function obj=objParamMappingDerived(obj)


        end

        function obj=objDropdownMapping(obj)
            logObj=ElecAssistantLog.getInstance();
            logObj.addMessage(obj,'BlockNotSupported');
        end
    end

end
