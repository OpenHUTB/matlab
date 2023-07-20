classdef ACVoltageSource_class<ConvClass&handle


    properties

        OldParam=struct(...
        'Amplitude',[],...
        'Phase',[],...
        'Frequency',[],...
        'SampleTime',[],...
        'Pref',[],...
        'Qref',[],...
        'Qmin',[],...
        'Qmax',[]...
        )


        OldDropdown=struct(...
        'Measurements',[],...
        'BusType',[]...
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
        OldPath='powerlib/Electrical Sources/AC Voltage Source'
        NewPath='elec_conv_ACVoltageSource/ACVoltageSource'
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


            if strcmp(obj.OldDropdown.Measurements,'Voltage')
                logObj.addMessage(obj,'OptionNotSupported','Measurements','Voltage');
            end
        end
    end

end
