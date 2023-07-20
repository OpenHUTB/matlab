classdef LoadFlowBus_class<ConvClass&handle



    properties

        OldParam=struct(...
        'ID',[],...
        'Vbase',[],...
        'Vref',[],...
        'Vangle',[],...
        'VLF',[],...
        'VLFb',[],...
        'VLFc',[],...
        'angleLF',[],...
        'angleLFb',[],...
        'angleLFc',[]...
        )


        OldDropdown=struct(...
        'Phases',[],...
        'Connectors',[]...
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
        OldPath='powerlib/Measurements/Load Flow Bus'
        NewPath='elec_conv_LoadFlowBus/LoadFlowBus'
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
