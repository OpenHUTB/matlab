classdef DC2AExcitationSystem_class<ConvClass&handle



    properties

        OldParam=struct(...
        'Tr',[],...
        'KaTa',[],...
        'VRminmax',[],...
        'KfTf',[],...
        'TbTc',[],...
        'KeTe',[],...
        'Efd12',[],...
        'SeEfd12',[],...
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
        OldPath='sps_avr/DC2A Excitation System'
        NewPath='elec_conv_sl_DC2AExcitationSystem/DC2AExcitationSystem'
    end

    methods
        function obj=objParamMappingDirect(obj)
        end

        function obj=DC2AExcitationSystem_class()
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
