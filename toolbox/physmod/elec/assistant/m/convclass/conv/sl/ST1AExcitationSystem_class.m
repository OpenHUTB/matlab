classdef ST1AExcitationSystem_class<ConvClass&handle



    properties

        OldParam=struct(...
        'Tr',[],...
        'KaTa',[],...
        'VIminmax',[],...
        'VAminmax',[],...
        'VRminmax',[],...
        'KfTf',[],...
        'TbTc',[],...
        'KLR',[],...
        'ILR',[],...
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
        OldPath='sps_avr/ST1A Excitation System'
        NewPath='elec_conv_sl_ST1AExcitationSystem/ST1AExcitationSystem'
    end

    methods
        function obj=objParamMappingDirect(obj)
        end

        function obj=ST1AExcitationSystem_class()
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
