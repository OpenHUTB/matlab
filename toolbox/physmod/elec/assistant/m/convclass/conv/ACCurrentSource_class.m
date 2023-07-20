classdef ACCurrentSource_class<ConvClass&handle



    properties

        OldParam=struct(...
        'Amplitude',[],...
        'Phase',[],...
        'Frequency',[],...
        'SampleTime',[]...
        )


        OldDropdown=struct(...
        'Measurements',[]...
        )


        NewDirectParam=struct(...
        'amp',[],...
        'shift',[],...
        'frequency',[]...
        )


        NewDerivedParam=struct(...
        )


        NewDropdown=struct(...
        )

        OldBlockName=[];
        NewBlockPath=[];
        ConversionType=[];
    end

    properties(Constant)
        OldPath='powerlib/Electrical Sources/AC Current Source'
        NewPath='elec_conv_ACCurrentSource/ACCurrentSource'
    end

    methods
        function obj=objParamMappingDirect(obj)
            obj.NewDirectParam.amp=obj.OldParam.Amplitude;
            obj.NewDirectParam.shift=obj.OldParam.Phase;
            obj.NewDirectParam.frequency=obj.OldParam.Frequency;
        end

        function obj=objParamMappingDerived(obj)


        end

        function obj=objDropdownMapping(obj)
            logObj=ElecAssistantLog.getInstance();


            if strcmp(obj.OldDropdown.Measurements,'Current')
                logObj.addMessage(obj,'OptionNotSupported','Measurements','Current');
            end
        end
    end

end
