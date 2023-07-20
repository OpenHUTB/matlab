classdef ExcitationSystem_1_class<ConvClass&handle



    properties

        OldParam=struct(...
        'tr',[],...
        'reg',[],...
        'exc',[],...
        'tgr',[],...
        'damp',[],...
        'sat',[],...
        'lim',[],...
        'v0',[]...
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
        OldPath='powerlib/Machines/Excitation System'
        NewPath='elec_conv_sl_ExcitationSystem_1/ExcitationSystem_1'
    end

    methods
        function obj=objParamMappingDirect(obj)
        end

        function obj=ExcitationSystem_1_class()
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
