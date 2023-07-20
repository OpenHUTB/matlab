classdef VoltageController_DCBus__class<ConvClass&handle



    properties

        OldParam=struct(...
        'ki',[],...
        'kp',[],...
        'fc',[],...
        'Ts',[]...
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
        OldPath='electricdrivelib/Fundamental Drive Blocks/Voltage Controller (DC Bus)'
        NewPath='elec_conv_sl_VoltageController_DCBus_/VoltageController_DCBus_'
    end

    methods
        function obj=objParamMappingDirect(obj)
        end

        function obj=VoltageController_DCBus__class()
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
