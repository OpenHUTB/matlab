classdef DCBus_class<ConvClass&handle



    properties

        OldParam=struct(...
        'Ts',[],...
        'capacitance',[],...
        'inductance',[],...
        'InitialVoltage',[],...
        'Rbrake',[],...
        'frequency',[],...
        'activationVoltage',[],...
        'shutdownVoltage',[]...
        )


        OldDropdown=struct(...
        'busType',[],...
        'Setx0',[]...
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
        OldPath='electricdrivelib/Fundamental Drive Blocks/DC Bus'
        NewPath='elec_conv_DCBus/DCBus'
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
