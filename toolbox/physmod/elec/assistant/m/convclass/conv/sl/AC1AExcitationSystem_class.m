classdef AC1AExcitationSystem_class<ConvClass&handle



    properties

        OldParam=struct(...
        'Tr',[],...
        'KaTa',[],...
        'VAminmax',[],...
        'VRminmax',[],...
        'KfTf',[],...
        'TbTc',[],...
        'KeTe',[],...
        'Ve12',[],...
        'SeVe12',[],...
        'Kd',[],...
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
        OldPath='sps_avr/AC1A Excitation System'
        NewPath='elec_conv_sl_AC1AExcitationSystem/AC1AExcitationSystem'
    end

    methods
        function obj=objParamMappingDirect(obj)
        end

        function obj=AC1AExcitationSystem_class()
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
