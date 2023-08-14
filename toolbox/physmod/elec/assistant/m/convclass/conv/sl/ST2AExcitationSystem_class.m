classdef ST2AExcitationSystem_class<ConvClass&handle



    properties

        OldParam=struct(...
        'Tr',[],...
        'KaTa',[],...
        'VRminmax',[],...
        'KfTf',[],...
        'KeTe',[],...
        'KI',[],...
        'Kp',[],...
        'Xd',[],...
        'Kc',[],...
        'v0',[],...
        'I0',[],...
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
        OldPath='sps_avr/ST2A Excitation System'
        NewPath='elec_conv_sl_ST2AExcitationSystem/ST2AExcitationSystem'
    end

    methods
        function obj=objParamMappingDirect(obj)
        end

        function obj=ST2AExcitationSystem_class()
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
