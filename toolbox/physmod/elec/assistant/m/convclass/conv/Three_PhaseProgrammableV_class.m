classdef Three_PhaseProgrammableV_class<ConvClass&handle



    properties

        OldParam=struct(...
        'PositiveSequence',[],...
        'VariationStep',[],...
        'VariationRate',[],...
        'VariationMagnitude',[],...
        'VariationFrequency',[],...
        'VariationTiming',[],...
        'Amplitudes',[],...
        'TimeValues',[],...
        'HarmonicA',[],...
        'HarmonicB',[],...
        'Timing',[],...
        'Pref',[],...
        'Qref',[],...
        'Qmin',[],...
        'Qmax',[]...
        )


        OldDropdown=struct(...
        'VariationEntity',[],...
        'VariationType',[],...
        'VariationTypeAlt',[],...
        'BusType',[],...
        'VariationPhaseA',[],...
        'HarmonicGeneration',[]...
        )


        NewDirectParam=struct(...
        'vline_rms',[],...
        'magn_modu_freq',[],...
        'magn_t1',[],...
        'magn_t2',[],...
        'freq',[],...
        'freq_ramp',[],...
        'freq_step',[],...
        'freq_modu_magn',[],...
        'freq_modu_freq',[],...
        'freq_t1',[],...
        'freq_t2',[],...
        'shift',[],...
        'phase_ramp',[],...
        'phase_step',[],...
        'phase_modu_magn',[],...
        'phase_modu_freq',[],...
        'phase_t1',[],...
        'phase_t2',[],...
        'harmonic_t1',[],...
        'harmonic_t2',[]...
        )


        NewDerivedParam=struct(...
        'magn_ramp',[],...
        'magn_step',[],...
        'magn_modu_magn',[],...
        'harmonic_orders',[],...
        'harmonic_ratios',[],...
        'harmonic_shifts',[],...
        'harmonic_sequences',[]...
        )


        NewDropdown=struct(...
        'magnitude_type',[],...
        'frequency_type',[],...
        'phase_type',[],...
        'harmonic_option',[],...
        'impedance_option',[]...
        )


        BlockOption={...
        }

        OldBlockName=[];
        NewBlockPath=[];
        ConversionType=[];
    end

    properties(Constant)
        OldPath='powerlib/Electrical Sources/Three-Phase Programmable Voltage Source'
        NewPath='elec_conv_Three_PhaseProgrammableV/Three_PhaseProgrammableV'
    end

    methods
        function obj=objParamMappingDirect(obj)
            obj.NewDirectParam.vline_rms=ConvClass.mapDirect(obj.OldParam.PositiveSequence,1);
            obj.NewDirectParam.shift=ConvClass.mapDirect(obj.OldParam.PositiveSequence,2);
            obj.NewDirectParam.freq=ConvClass.mapDirect(obj.OldParam.PositiveSequence,3);
            obj.NewDirectParam.magn_t1=ConvClass.mapDirect(obj.OldParam.VariationTiming,1);
            obj.NewDirectParam.magn_t2=ConvClass.mapDirect(obj.OldParam.VariationTiming,2);
            obj.NewDirectParam.freq_t1=ConvClass.mapDirect(obj.OldParam.VariationTiming,1);
            obj.NewDirectParam.freq_t2=ConvClass.mapDirect(obj.OldParam.VariationTiming,2);
            obj.NewDirectParam.phase_t1=ConvClass.mapDirect(obj.OldParam.VariationTiming,1);
            obj.NewDirectParam.phase_t2=ConvClass.mapDirect(obj.OldParam.VariationTiming,2);
            obj.NewDirectParam.harmonic_t1=ConvClass.mapDirect(obj.OldParam.Timing,1);
            obj.NewDirectParam.harmonic_t2=ConvClass.mapDirect(obj.OldParam.Timing,2);
            obj.NewDirectParam.freq_step=obj.OldParam.VariationStep;
            obj.NewDirectParam.phase_step=obj.OldParam.VariationStep;
            obj.NewDirectParam.freq_ramp=obj.OldParam.VariationRate;
            obj.NewDirectParam.phase_ramp=obj.OldParam.VariationRate;
            obj.NewDirectParam.freq_modu_magn=obj.OldParam.VariationMagnitude;
            obj.NewDirectParam.phase_modu_magn=obj.OldParam.VariationMagnitude;
            obj.NewDirectParam.magn_modu_freq=obj.OldParam.VariationFrequency;
            obj.NewDirectParam.freq_modu_freq=obj.OldParam.VariationFrequency;
            obj.NewDirectParam.phase_modu_freq=obj.OldParam.VariationFrequency;
        end


        function obj=Three_PhaseProgrammableV_class(PositiveSequence,VariationStep,VariationRate,VariationMagnitude,HarmonicA,HarmonicB)
            if nargin>0
                obj.OldParam.PositiveSequence=PositiveSequence;
                obj.OldParam.VariationStep=VariationStep;
                obj.OldParam.VariationRate=VariationRate;
                obj.OldParam.VariationMagnitude=VariationMagnitude;
                obj.OldParam.HarmonicA=HarmonicA;
                obj.OldParam.HarmonicB=HarmonicB;
            end
        end

        function obj=objParamMappingDerived(obj)

            vline_rms=obj.OldParam.PositiveSequence(1);
            obj.NewDerivedParam.magn_step=obj.OldParam.VariationStep*vline_rms;
            obj.NewDerivedParam.magn_ramp=obj.OldParam.VariationRate*vline_rms;
            obj.NewDerivedParam.magn_modu_magn=obj.OldParam.VariationMagnitude*vline_rms;
            obj.NewDerivedParam.harmonic_orders=[obj.OldParam.HarmonicA(1),obj.OldParam.HarmonicB(1)];
            obj.NewDerivedParam.harmonic_ratios=[obj.OldParam.HarmonicA(2),obj.OldParam.HarmonicB(2)];
            obj.NewDerivedParam.harmonic_shifts=[obj.OldParam.HarmonicA(3),obj.OldParam.HarmonicB(3)];
            obj.NewDerivedParam.harmonic_sequences=[obj.OldParam.HarmonicA(4),obj.OldParam.HarmonicB(4)];

        end

        function obj=objDropdownMapping(obj)
            logObj=ElecAssistantLog.getInstance();


            if strcmp(obj.OldDropdown.VariationPhaseA,'on')
                logObj.addMessage(obj,'CheckboxNotSupported','Variation on phase A only');
            end

            switch obj.OldDropdown.VariationEntity
            case 'None'
                obj.NewDropdown.magnitude_type='1';
                obj.NewDropdown.frequency_type='1';
                obj.NewDropdown.phase_type='1';
            case 'Amplitude'
                obj.NewDropdown.frequency_type='1';
                obj.NewDropdown.phase_type='1';
                switch obj.OldDropdown.VariationType
                case 'Step'
                    obj.NewDropdown.magnitude_type='3';
                case 'Ramp'
                    obj.NewDropdown.magnitude_type='2';
                case 'Modulation'
                    obj.NewDropdown.magnitude_type='4';
                case 'Table of time-amplitude pairs'
                    logObj.addMessage(obj,'OptionNotSupportedNoImport','Time variation of amplitude','Table of time-amplitude pairs');
                end
            case 'Phase'
                obj.NewDropdown.frequency_type='1';
                obj.NewDropdown.magnitude_type='1';
                switch obj.OldDropdown.VariationTypeAlt
                case 'Step'
                    obj.NewDropdown.phase_type='3';
                case 'Ramp'
                    obj.NewDropdown.phase_type='2';
                case 'Modulation'
                    obj.NewDropdown.phase_type='4';
                end
            case 'Frequency'
                obj.NewDropdown.phase_type='1';
                obj.NewDropdown.magnitude_type='1';
                switch obj.OldDropdown.VariationTypeAlt
                case 'Step'
                    obj.NewDropdown.frequency_type='3';
                case 'Ramp'
                    obj.NewDropdown.frequency_type='2';
                case 'Modulation'
                    obj.NewDropdown.frequency_type='4';
                end
            end

            switch obj.OldDropdown.HarmonicGeneration
            case 'on'
                obj.NewDropdown.harmonic_option='1';
            case 'off'
                obj.NewDropdown.harmonic_option='0';
            end

        end
    end

end
