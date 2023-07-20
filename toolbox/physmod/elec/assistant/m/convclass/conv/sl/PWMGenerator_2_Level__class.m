classdef PWMGenerator_2_Level__class<ConvClass&handle



    properties

        OldParam=struct(...
        'Fc',[],...
        'Pc',[],...
        'nF',[],...
        'MinMax',[],...
        'm',[],...
        'Freq',[],...
        'Phase',[],...
        'Ts',[]...
        )


        OldDropdown=struct(...
        'ModulatorType',[],...
        'ModulatorMode',[],...
        'SamplingTechnique',[],...
        'ModulatingSignals',[],...
        'ShowCarrierOutport',[]...
        )


        NewDirectParam=struct(...
        'fsw',[],...
        'Amplitude',[]...
        )


        NewDerivedParam=struct(...
        'SampleTime',[],...
        'Ts',[],...
        'RTSampleTime',[],...
        'Value',[],...
        'Frequency',[],...
        'Phase',[],...
        'Tper',[],...
        'Tdelay',[],...
        'Bias',[],...
        'Gain',[]...
        )


        NewDropdown=struct(...
        'SamplingMode',[]...
        )


        BlockOption={...
        {'ModulatorType','Three-phase bridge (6 pulses)';'ModulatingSignals','on';'ShowCarrierOutport','on'},'ThreePhase_IntMeas';...
        {'ModulatorType','Three-phase bridge (6 pulses)';'ModulatingSignals','on';'ShowCarrierOutport','off'},'ThreePhase_Int';...
        {'ModulatorType','Three-phase bridge (6 pulses)';'ModulatingSignals','off';'ShowCarrierOutport','on'},'ThreePhase_Meas';...
        {'ModulatorType','Three-phase bridge (6 pulses)';'ModulatingSignals','off';'ShowCarrierOutport','off'},'ThreePhase';...
        {'ModulatorType','Single-phase half-bridge (2 pulses)';'ModulatingSignals','on';'ShowCarrierOutport','on'},'HalfBridge2pulses_IntMeas';...
        {'ModulatorType','Single-phase half-bridge (2 pulses)';'ModulatingSignals','on';'ShowCarrierOutport','off'},'HalfBridge2pulses_Int';...
        {'ModulatorType','Single-phase half-bridge (2 pulses)';'ModulatingSignals','off';'ShowCarrierOutport','on'},'HalfBridge2pulses_Meas';...
        {'ModulatorType','Single-phase half-bridge (2 pulses)';'ModulatingSignals','off';'ShowCarrierOutport','off'},'HalfBridge2pulses';...
        {'ModulatorType','Single-phase full-bridge (4 pulses)';'ModulatingSignals','on';'ShowCarrierOutport','on'},'FullBridge4pulses_IntMeas';...
        {'ModulatorType','Single-phase full-bridge (4 pulses)';'ModulatingSignals','on';'ShowCarrierOutport','off'},'FullBridge4pulses_Int';...
        {'ModulatorType','Single-phase full-bridge (4 pulses)';'ModulatingSignals','off';'ShowCarrierOutport','on'},'FullBridge4pulses_Meas';...
        {'ModulatorType','Single-phase full-bridge (4 pulses)';'ModulatingSignals','off';'ShowCarrierOutport','off'},'FullBridge4pulses';...
        {'ModulatorType','Single-phase full-bridge - Bipolar modulation (4 pulses)';'ModulatingSignals','on';'ShowCarrierOutport','on'},'Bipolar_IntMeas';...
        {'ModulatorType','Single-phase full-bridge - Bipolar modulation (4 pulses)';'ModulatingSignals','on';'ShowCarrierOutport','off'},'Bipolar_Int';...
        {'ModulatorType','Single-phase full-bridge - Bipolar modulation (4 pulses)';'ModulatingSignals','off';'ShowCarrierOutport','on'},'Bipolar_Meas';...
        {'ModulatorType','Single-phase full-bridge - Bipolar modulation (4 pulses)';'ModulatingSignals','off';'ShowCarrierOutport','off'},'Bipolar';...
        {},'Blank'
        }

        OldBlockName=[];
        NewBlockPath=[];
        ConversionType=[];
    end

    properties(Constant)
        OldPath='powerlib_meascontrol/Pulse & Signal Generators/PWM Generator (2-Level)'
        NewPath='elec_conv_sl_PWMGenerator_2_Level_/PWMGenerator_2_Level_'
    end

    methods
        function obj=objParamMappingDirect(obj)
            obj.NewDirectParam.fsw=obj.OldParam.Fc;
            obj.NewDirectParam.Amplitude=obj.OldParam.m;
        end

        function obj=PWMGenerator_2_Level__class(MinMax,Phase,Freq,Fc,Pc,ModulatorType,Ts,SamplingTechnique)
            if nargin>0
                obj.OldParam.MinMax=MinMax;
                obj.OldParam.Phase=Phase;
                obj.OldParam.Freq=Freq;
                obj.OldParam.Fc=Fc;
                obj.OldParam.Pc=Pc;
                obj.OldDropdown.ModulatorType=ModulatorType;
                obj.OldParam.Ts=Ts;
                obj.OldDropdown.SamplingTechnique=SamplingTechnique;
            end
        end

        function obj=objParamMappingDerived(obj)

            switch obj.OldDropdown.ModulatorType
            case 'Single-phase half-bridge (2 pulses)'
                obj.NewDerivedParam.Phase=obj.OldParam.Phase*(pi/180);
            case 'Single-phase full-bridge (4 pulses)'
                obj.NewDerivedParam.Phase=obj.OldParam.Phase*(pi/180);
            case 'Single-phase full-bridge - Bipolar modulation (4 pulses)'
                obj.NewDerivedParam.Phase=obj.OldParam.Phase*(pi/180);
            case 'Three-phase bridge (6 pulses)'
                obj.NewDerivedParam.Phase=obj.OldParam.Phase*(pi/180)+[0,-2*pi/3,2*pi/3];
            end
            obj.NewDerivedParam.Value=obj.OldParam.MinMax(2)-obj.OldParam.MinMax(1);
            obj.NewDerivedParam.Frequency=obj.OldParam.Freq*2*pi;
            obj.NewDerivedParam.Tper=1/obj.OldParam.Fc/2;
            obj.NewDerivedParam.Bias=(obj.OldParam.MinMax(1)+obj.OldParam.MinMax(2))/2;
            obj.NewDerivedParam.Gain=(obj.OldParam.MinMax(2)-obj.OldParam.MinMax(1))/2;

            if strcmp(obj.OldDropdown.ModulatorType,'Three-phase bridge (6 pulses)')

                obj.NewDerivedParam.Tdelay=180/180*(1/obj.OldParam.Fc/2);

                if obj.OldParam.Ts==0
                    obj.NewDerivedParam.Ts=1/200/obj.OldParam.Fc;
                    obj.NewDerivedParam.SampleTime=1/200/obj.OldParam.Fc;
                else
                    obj.NewDerivedParam.Ts=obj.OldParam.Ts;
                    obj.NewDerivedParam.SampleTime=obj.OldParam.Ts;
                end

            else

                obj.NewDerivedParam.Tdelay=obj.OldParam.Pc/180*(1/obj.OldParam.Fc/2);

                if obj.OldParam.Ts==0
                    obj.NewDerivedParam.Ts=0;
                    obj.NewDerivedParam.SampleTime=-1;
                else
                    obj.NewDerivedParam.Ts=obj.OldParam.Ts;
                    obj.NewDerivedParam.SampleTime=obj.OldParam.Ts;
                end

                switch obj.OldDropdown.SamplingTechnique
                case 'Natural'
                    obj.NewDerivedParam.RTSampleTime=-1;
                case 'Asymmetrical regular (double edge)'
                    obj.NewDerivedParam.RTSampleTime=[1/obj.OldParam.Fc/2,(180-rem(obj.OldParam.Pc,180))/180*(1/obj.OldParam.Fc/2)];
                case 'Symmetrical regular (single edge)'
                    obj.NewDerivedParam.RTSampleTime=[1/obj.OldParam.Fc,(360-rem(obj.OldParam.Pc,360))/360*(1/obj.OldParam.Fc)];
                end
            end

        end

        function obj=objDropdownMapping(obj)
            logObj=ElecAssistantLog.getInstance();

            if strcmp(obj.OldDropdown.ModulatorType,'Three-phase bridge (6 pulses)')
                logObj.addMessage(obj,'ParameterNotSupported','Initial phase (degrees) in Carrier');
                logObj.addMessage(obj,'CustomMessageNoImport','Only Initial phase (degrees) = 180 is supported');
            end

            switch obj.OldDropdown.ModulatorMode
            case 'Synchronized'
                logObj.addMessage(obj,'OptionNotSupportedNoImport','Mode of operation','Synchronized');
            case 'Unsynchronized'

            end


            if strcmp(obj.OldDropdown.ModulatorType,'Three-phase bridge (6 pulses)')
                switch obj.OldDropdown.SamplingTechnique
                case 'Natural'
                    obj.NewDropdown.SamplingMode='Natural';
                case 'Asymmetrical regular (double edge)'
                    obj.NewDropdown.SamplingMode='Asymmetric';
                case 'Symmetrical regular (single edge)'
                    obj.NewDropdown.SamplingMode='Symmetric';
                end
            end

            if ischar(obj.OldParam.Ts)
                obj.OldParam.Ts=evalin('base',obj.OldParam.Ts);
            end

            if(obj.OldParam.Ts==0)&&strcmp(obj.OldDropdown.ModulatorType,'Three-phase bridge (6 pulses)')
                logObj.addMessage(obj,'ParameterNotSupported','Sample time = 0');
                logObj.addMessage(obj,'CustomMessageNoImport','Sample time is set to 200 times smaller than the Carrier period');
            end

        end
    end

end
