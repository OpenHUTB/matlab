classdef PhaseCodedDialog < phased.apps.internal.wirelessWaveformGenerator.PhasedWaveformBaseDialog
    % Dialog for phase-coded waveform parameters
    % Copyright 2022 The MathWorks, Inc.

    properties (Dependent)
        % Waveform Parameters
        SampleRate
        PRF
        NumPulses
        Code
        ChipWidth
        NumberChipsBarker
        NumberChips
        SequenceIndex
    end

    properties(Hidden)
        TitleString = getString(message('phased:apps:wirelesswavegenapp:PhaseCodedWaveformTitle'))
        configFcn = @phased.PhaseCodedWaveform
        configGenFcn = @phased.PhaseCodedWaveform
        configGenVar = 'phaseCodedWaveform'

        SampleRateLabel
        SampleRateType = 'edit'
        SampleRateGUI

        NumPulsesLabel
        NumPulsesType = 'edit'
        NumPulsesGUI

        PRFLabel
        PRFType = 'edit'
        PRFGUI

        CodeLabel
        CodeType = 'popupmenu'
        CodeDropDown = {'Barker','Frank','P1','P2','P3','P4','Px','Zadoff-Chu'}
        CodeGUI

        ChipWidthLabel
        ChipWidthType = 'edit'
        ChipWidthGUI

        NumberChipsBarkerLabel
        NumberChipsBarkerType = 'popupmenu'
        NumberChipsBarkerDropDown = {'4','2','3','5','7','11','13'}
        NumberChipsBarkerGUI

        NumberChipsLabel
        NumberChipsType = 'edit'
        NumberChipsGUI

        SequenceIndexLabel
        SequenceIndexType = 'edit'
        SequenceIndexGUI
    end

    methods
        function self = PhaseCodedDialog(parent)
            self@phased.apps.internal.wirelessWaveformGenerator.PhasedWaveformBaseDialog(parent); % call base constructor

            % Update Visibility
            self.SequenceIndexGUI.Visible   = false;
            self.SequenceIndexLabel.Visible = false;
            self.NumberChipsGUI.Visible     = false;
            self.NumberChipsLabel.Visible   = false;

            % Callbacks
            self.SampleRateGUI.(self.Callback)        =  @(h,e)SampleRateChanged(self,e);
            self.NumPulsesGUI.(self.Callback)         =  @(h,e)NumberPulsesChanged(self,e);
            self.PRFGUI.(self.Callback)               =  @(h,e)PRFChanged(self,e);
            self.CodeGUI.(self.Callback)              =  @(h,e)CodeChanged(self,e);
            self.ChipWidthGUI.(self.Callback)         =  @(h,e)ChipWidthChanged(self,e);
            self.NumberChipsBarkerGUI.(self.Callback) =  @(h,e)NumberChipsBarkerChanged(self,e);
            self.NumberChipsGUI.(self.Callback)       =  @(h,e)NumberChipsChanged(self,e);
            self.SequenceIndexGUI.(self.Callback)     =  @(h,e)SequenceIndexChanged(self,e);

            % Waveform Characteristics Update
            CharacteristicsUpdate(self)
        end

        function restoreDefaults(self)
            % Phase Coded Waveform Defaults
            self.SampleRate        =  1e6;
            self.NumPulses         =  1;
            self.PRF               =  1e4;
            self.Code              =  'Barker';
            self.ChipWidth         =  1e-6;
            self.NumberChipsBarker =  '4';
            self.NumberChips       =  4 ;
            self.SequenceIndex     =  1;
        end
    end

    methods

        function props = props2ExcludeFromConfig(~)
            props = {'SequenceIndex','NumberChipsBarker','NumberChips'};
        end

        function props = props2ExcludeFromConfigGeneration(~)
            props = {'SequenceIndex','NumberChipsBarker','NumberChips'};
        end

        function config = getConfiguration(self)
            config = getConfiguration@wirelessWaveformGenerator.waveformConfigurationDialog(self);
            if strcmp(self.Code,'Zadoff-Chu')
                config.SequenceIndex = self.SequenceIndex;
                config.NumChips = self.NumberChips;
            elseif strcmp(self.Code,'Barker')
                config.NumChips = eval(self.NumberChipsBarker);
            else
                config.NumChips = self.NumberChips;
            end
        end

        function config = getConfigurationForSave(self)
            % Save Waveform Config
            config = getConfigurationForSave@phased.apps.internal.wirelessWaveformGenerator.PhasedWaveformBaseDialog(self);
            if strcmp(self.Code, 'Barker')
                config.waveform.NumChips = eval(self.NumberChipsBarker);
            elseif strcmp(self.Code,'Zadoff-Chu')
                config.waveform.SequenceIndex = self.SequenceIndex;
                config.waveform.NumChips = self.NumberChips;
            else
               config.waveform.NumChips = self.NumberChips;
            end
        end

        function val = get.SampleRate(self)
            val = getEditVal(self, 'SampleRate');
        end

        function set.SampleRate(self,val)
            setEditVal(self, 'SampleRate', val);
        end

        function SampleRateChanged(self,~)
            try
                val = self.SampleRate;
                validateattributes(val,{'double'},{'nonempty','scalar', ...
                    'real','finite','positive','nonsparse'},'','Sample rate')
            catch e
                self.errorFromException(e);
            end
        end

        function val = get.NumPulses(self)
            val = getEditVal(self, 'NumPulses');
        end

        function set.NumPulses(self,val)
            setEditVal(self, 'NumPulses', val);
        end

        function NumberPulsesChanged(self, ~)
            try
                val = self.NumPulses;
                validateattributes(val,{'double'},{'nonempty','scalar','real', ...
                    'finite','positive','integer','nonnan','nonsparse'},'','Number of pulses')
            catch e
                self.errorFromException(e);
            end
        end

        function val = get.PRF(self)
            val = getEditVal(self, 'PRF');
        end

        function set.PRF(self,val)
            setEditVal(self, 'PRF', val);
        end

        function PRFChanged(self,~)
            try
                val = self.PRF;
                validateattributes(val,{'double'},{'nonempty','scalar','real', ...
                    'finite','positive','nonsparse'},'','Pulse repetition frequency')
            catch e
                self.errorFromException(e);
            end
        end

        function val = get.NumberChips(self)
            val = getEditVal(self, 'NumberChips');
        end

        function set.NumberChips(self,val)
            setEditVal(self, 'NumberChips', val);
        end

        function NumberChipsChanged(self,~)
            try
                value = self.NumberChips;
                validateattributes(value,{'double'},{'nonempty','scalar','real', ...
                    'finite','positive','integer','nonsparse'},'','Number of chips')
                self.NumberChips = value;
            catch e
                self.errorFromException(e);
            end
        end

        function val = get.NumberChipsBarker(self)
            val = getDropdownVal(self, 'NumberChipsBarker');
        end

        function set.NumberChipsBarker(self,val)
            setDropdownVal(self, 'NumberChipsBarker', val);
        end

        function NumberChipsBarkerChanged(self,~)
            try
                value = self.NumberChipsBarker;
                validatestring(value,{'2','3','4','5','7','11','13'});
                self.NumberChipsBarker = value;
            catch e
                self.errorFromException(e);
            end
        end

        function val = get.ChipWidth(self)
            val = getEditVal(self, 'ChipWidth');
        end

        function set.ChipWidth(self,val)
            setEditVal(self, 'ChipWidth', val);
        end

        function ChipWidthChanged(self,~)
            try
                value = self.ChipWidth;
                validateattributes(value,{'double'},{'nonempty','scalar','real', ...
                    'finite','positive','nonsparse'},'','Chip width')
                self.ChipWidth = value;
            catch e
                self.errorFromException(e);
            end
        end

        function val = get.Code(self)
            val = getDropdownVal(self, 'Code');
        end

        function set.Code(self,val)
            setDropdownVal(self, 'Code', val);
        end

        function CodeChanged(self,~)
            try
                value = self.Code;

                value = validatestring(value,{'Barker', ...
                    'Frank','P1','P2','P3','P4','Px','Zadoff-Chu'});

                % Properties visibility based on code selected
                set([self.NumberChipsBarkerGUI self.NumberChipsBarkerLabel], 'Visible', uiservices.logicalToOnOff(strcmp(value, 'Barker')));
                set([self.NumberChipsGUI self.NumberChipsLabel], 'Visible', uiservices.logicalToOnOff(~strcmp(value, 'Barker')));
                set([self.SequenceIndexGUI self.SequenceIndexLabel], 'Visible', uiservices.logicalToOnOff(strcmp(value, 'Zadoff-Chu')));
                
                % layout UI controls
                self.layoutUIControls;

                self.Code = value;
            catch e
                self.errorFromException(e);
            end
        end

        function val = get.SequenceIndex(self)
            val = getEditVal(self, 'SequenceIndex');
        end

        function set.SequenceIndex(self,val)
            setEditVal(self, 'SequenceIndex', val);
        end

        function SequenceIndexChanged(self,~)
            try
                value = self.SequenceIndex;
                validateattributes(value,{'double'},{'nonempty','scalar',...
                    'real','finite','positive','integer','nonsparse'},'','SequenceIndex');
            catch e
                self.errorFromException(e);
            end
        end

        function addConfigCode(self, sw)
            % Generate MATLAB script
            addConfigCode@wirelessWaveformGenerator.waveformConfigurationDialog(self, sw);
            addcr(sw);
            if strcmp(self.Code,'Zadoff-Chu')
                add(sw, [self.configGenVar '.SequenceIndex = ' num2str(self.SequenceIndex) ';'])
                addcr(sw);
                add(sw, [self.configGenVar '.NumChips = ' num2str(self.NumberChips) ';'])
                addcr(sw);
            elseif strcmp(self.Code,'Barker')
                add(sw, [self.configGenVar '.NumChips = ' num2str(self.NumberChipsBarker) ';'])
                addcr(sw);
            else
                add(sw, [self.configGenVar '.NumChips = ' num2str(self.NumberChips) ';'])
                addcr(sw);
            end
        end
        
        function [blockName, maskTitleName, waveNameText] = getMaskTextWaveName(obj)
            % Update Simulink Block
            blockName = obj.Parent.WaveformGenerator.pCurrentWaveformType;
            maskTitleName = [obj.Parent.WaveformGenerator.pCurrentWaveformType ' Generator'];
            waveNameText = getString(message('phased:apps:wirelesswavegenapp:SimulinkPhaseCodedName'));
        end
    end
end
