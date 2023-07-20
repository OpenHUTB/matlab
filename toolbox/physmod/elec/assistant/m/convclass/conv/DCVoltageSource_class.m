classdef DCVoltageSource_class<ConvClass&handle



    properties

        OldParam=struct(...
        'Amplitude',[]...
        )


        OldDropdown=struct(...
        'Measurements',[]...
        )


        NewDirectParam=struct(...
        'v0',[]...
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
        OldPath='powerlib/Electrical Sources/DC Voltage Source'
        NewPath='elec_conv_DCVoltageSource/DCVoltageSource'
    end

    methods
        function obj=objParamMappingDirect(obj)
            obj.NewDirectParam.v0=obj.OldParam.Amplitude;
        end

        function obj=objParamMappingDerived(obj)


        end

        function obj=objDropdownMapping(obj)
            logObj=ElecAssistantLog.getInstance();


            if strcmp(obj.OldDropdown.Measurements,'Voltage')
                logObj.addMessage(obj,'OptionNotSupported','Measurements','Voltage');
            end
        end
    end

end
