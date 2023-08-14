classdef ControlledCurrentSource_class<ConvClass&handle



    properties

        OldParam=struct(...
        'Amplitude',[],...
        'Phase',[],...
        'Frequency',[]...
        )


        OldDropdown=struct(...
        'Source_Type',[],...
        'Measurements',[],...
        'Initialize',[]...
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
        OldPath='powerlib/Electrical Sources/Controlled Current Source'
        NewPath='elec_conv_ControlledCurrentSource/ControlledCurrentSource'
    end

    methods
        function obj=objParamMappingDirect(obj)
        end

        function obj=objParamMappingDerived(obj)


        end

        function obj=objDropdownMapping(obj)
            logObj=ElecAssistantLog.getInstance();


            if strcmp(obj.OldDropdown.Measurements,'Current')
                logObj.addMessage(obj,'OptionNotSupported','Measurements','Current');
            end

            if strcmp(obj.OldDropdown.Initialize,'on')
                logObj.addMessage(obj,'CheckboxNotSupported','Initialize');
            end
        end
    end

end
