classdef AC4AExcitationSystem_class<ConvClass&handle



    properties

        OldParam=struct(...
        'Tr',[],...
        'KaTa',[],...
        'VIminmax',[],...
        'VRminmax',[],...
        'TbTc',[],...
        'Kc',[],...
        'v0',[],...
        'TsBlock',[]...
        )


        OldDropdown=struct(...
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
        OldPath='sps_avr/AC4A Excitation System'
        NewPath='elec_conv_sl_AC4AExcitationSystem/AC4AExcitationSystem'
    end

    methods
        function obj=objParamMappingDirect(obj)
        end

        function obj=AC4AExcitationSystem_class()
            if nargin>0
            end
        end

        function obj=objParamMappingDerived(obj)


        end

        function obj=objDropdownMapping(obj)
            logObj=ElecAssistantLog.getInstance();
            logObj.addMessage(obj,'BlockNotSupported');
        end
    end

end
