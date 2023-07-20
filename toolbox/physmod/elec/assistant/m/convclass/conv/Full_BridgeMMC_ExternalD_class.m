classdef Full_BridgeMMC_ExternalD_class<ConvClass&handle



    properties

        OldParam=struct(...
        'n',[],...
        'Ron',[],...
        'Rs',[],...
        'Cs',[],...
        'Ron_Diode',[],...
        'Rs_Diode',[],...
        'Cs_Diode',[],...
        'Vf_Diode',[],...
        'Rs_CurrentSource',[],...
        'Ts',[]...
        )


        OldDropdown=struct(...
        'ModelType',[]...
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
        OldPath='powerlib/Power Electronics/Full-Bridge MMC (External DC Links)'
        NewPath='elec_conv_Full_BridgeMMC_ExternalD/Full_BridgeMMC_ExternalD'
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
