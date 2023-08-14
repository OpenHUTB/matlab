classdef PWMGenerator_3_Level__class<ConvClass&handle



    properties

        OldParam=struct(...
        'nF',[],...
        'Fc',[],...
        'm',[],...
        'Freq',[],...
        'Phase',[],...
        'Ts',[]...
        )


        OldDropdown=struct(...
        'ModulatorType',[],...
        'ModulatorMode',[],...
        'ModulatingSignals',[]...
        )


        NewDirectParam=struct(...
        'fsw',[],...
        'Amplitude',[]...
        )


        NewDerivedParam=struct(...
        'Frequency',[],...
        'Phase',[],...
        'Ts',[],...
        'SampleTime',[]...
        )


        NewDropdown=struct(...
        )




        BlockOption={...
        {'ModulatorMode','Unsynchronized';'ModulatorType','Three-phase bridge (12 pulses)';'ModulatingSignals','on'},'Internal';...
        {'ModulatorMode','Unsynchronized';'ModulatorType','Three-phase bridge (12 pulses)';'ModulatingSignals','off'},'External';...
        {},'Blank'
        }

        OldBlockName=[];
        NewBlockPath=[];
        ConversionType=[];
    end

    properties(Constant)
        OldPath='powerlib_meascontrol/Pulse & Signal Generators/PWM Generator (3-Level)'
        NewPath='elec_conv_sl_PWMGenerator_3_Level_/PWMGenerator_3_Level_'
    end

    methods
        function obj=objParamMappingDirect(obj)
            obj.NewDirectParam.fsw=obj.OldParam.Fc;
            obj.NewDirectParam.Amplitude=obj.OldParam.m;
        end

        function obj=PWMGenerator_3_Level__class(Phase,Freq,Ts,Fc)
            if nargin>0
                obj.OldParam.Phase=Phase;
                obj.OldParam.Freq=Freq;
                obj.OldParam.Ts=Ts;
                obj.OldParam.Fc=Fc;
            end
        end

        function obj=objParamMappingDerived(obj)

            obj.NewDerivedParam.Phase=obj.OldParam.Phase*(pi/180)+[0,-2*pi/3,2*pi/3];
            obj.NewDerivedParam.Frequency=obj.OldParam.Freq*2*pi;

            if obj.OldParam.Ts==0
                obj.NewDerivedParam.Ts=1/200/obj.OldParam.Fc;
                obj.NewDerivedParam.SampleTime=1/200/obj.OldParam.Fc;
            else
                obj.NewDerivedParam.Ts=obj.OldParam.Ts;
                obj.NewDerivedParam.SampleTime=obj.OldParam.Ts;
            end

        end

        function obj=objDropdownMapping(obj)
            logObj=ElecAssistantLog.getInstance();
            logObj.addMessage(obj,'CustomMessageNoImport','The carrier has a different phase angle.');

            switch obj.OldDropdown.ModulatorType
            case 'Single-phase half-bridge (4 pulses)'
                logObj.addMessage(obj,'OptionNotSupportedNoImport','Generator type','Single-phase half-bridge (4 pulses)');
            case 'Single-phase full-bridge (8 pulses)'
                logObj.addMessage(obj,'OptionNotSupportedNoImport','Generator type','Single-phase full-bridge (8 pulses)');
            case 'Three-phase bridge (12 pulses)'

            end

            switch obj.OldDropdown.ModulatorMode
            case 'Synchronized'
                logObj.addMessage(obj,'OptionNotSupportedNoImport','Mode of operation','Synchronized');
            case 'Unsynchronized'

            end

            if ischar(obj.OldParam.Ts)
                obj.OldParam.Ts=evalin('base',obj.OldParam.Ts);
            end

            if obj.OldParam.Ts==0
                logObj.addMessage(obj,'ParameterNotSupported','Sample time = 0');
                logObj.addMessage(obj,'CustomMessageNoImport','Sample time is set to be 200 times smaller than the Carrier period.');
            end

        end
    end

end
