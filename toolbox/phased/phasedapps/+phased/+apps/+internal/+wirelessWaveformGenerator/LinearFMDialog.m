classdef LinearFMDialog < phased.apps.internal.wirelessWaveformGenerator.PhasedWaveformBaseDialog
    % Dialog for linear FM waveform parameters
    % Copyright 2022 The MathWorks, Inc.

    properties (Dependent)
        % Linear FM wave parameters
        SampleRate
        PRF
        NumPulses
        PulseWidth
        SweepBandwidth
        SweepDirection
        SweepInterval
        Envelope
    end

    properties(Hidden)

        TitleString = getString(message('phased:apps:wirelesswavegenapp:LinearFMWaveformTitle'))
        configFcn = @phased.LinearFMWaveform
        configGenFcn = @phased.LinearFMWaveform
        configGenVar = 'linearFMwaveform'
        
        SampleRateLabel
        SampleRateType = 'edit'
        SampleRateGUI

        NumPulsesLabel
        NumPulsesType = 'edit'
        NumPulsesGUI

        PRFLabel
        PRFType = 'edit'
        PRFGUI

        PulseWidthLabel
        PulseWidthType = 'edit'
        PulseWidthGUI

        SweepBandwidthLabel
        SweepBandwidthType = 'edit'
        SweepBandwidthGUI

        SweepDirectionLabel
        SweepDirectionType = 'popupmenu'
        SweepDirectionDropDown = {'Up','Down'}
        SweepDirectionGUI

        SweepIntervalLabel
        SweepIntervalType = 'popupmenu'
        SweepIntervalDropDown = {'Positive','Symmetric'}
        SweepIntervalGUI

        EnvelopeLabel
        EnvelopeType = 'popupmenu'
        EnvelopeDropDown = {'Rectangular','Gaussian'}
        EnvelopeGUI
    end

    methods
        function self = LinearFMDialog(parent)
            self@phased.apps.internal.wirelessWaveformGenerator.PhasedWaveformBaseDialog(parent); % call base constructor

            % Callbacks
            self.SampleRateGUI.(self.Callback)      =  @(h,e)SampleRateChanged(self,e);
            self.NumPulsesGUI.(self.Callback)       =  @(h,e)NumberPulsesChanged(self,e);
            self.PRFGUI.(self.Callback)             =  @(h,e)PRFChanged(self,e);
            self.PulseWidthGUI.(self.Callback)      =  @(h,e)PulseWidthChanged(self,e);
            self.SampleRateGUI.(self.Callback)      =  @(h,e)SampleRateChanged(self,e);
            self.SweepBandwidthGUI.(self.Callback)  =  @(h,e)SweepBandwidthChanged(self,e);
            self.SweepDirectionGUI.(self.Callback)  =   @(h,e)SweepDirectionChanged(self,e);
            self.SweepIntervalGUI.(self.Callback)   =   @(h,e)SweepIntervalChanged(self,e);
            self.EnvelopeGUI.(self.Callback)        =   @(h,e)EnvelopeChanged(self,e);
            
            %Update Characteristics
            CharacteristicsUpdate(self);

        end


        function restoreDefaults(self)
            % Waveform Parameter defaults
            self.SampleRate     = 1e6;
            self.NumPulses      = 1;
            self.PRF            = 1e4;
            self.PulseWidth     = 5e-05;
            self.SweepBandwidth = 100000;
            self.SweepDirection = 'Up';
            self.SweepInterval  = 'Positive';
            self.Envelope       = 'Rectangular';
        end
    end

    methods
        function sr = getSampleRate(self)
            % Set the symbol rate, as per the standard
           sr = self.SampleRate;
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
                validateattributes(val,{'double'},{'nonempty','scalar','real', ...
                    'finite','positive','nonsparse'},'','Sample rate')
            catch e
                self.errorFromException(e);
            end
        end
        
        function val = get.PulseWidth(self)
            val = getEditVal(self, 'PulseWidth');
        end

        function set.PulseWidth(self,val)
            setEditVal(self, 'PulseWidth',val);
        end

        function PulseWidthChanged(self,~)
            try
                val = self.PulseWidth;
                validateattributes(val,{'double'},{'nonempty','scalar','real', ...
                    'finite','positive','nonsparse'},'','Pulse width');
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

        function val = get.SweepBandwidth(self)
            val = getEditVal(self, 'SweepBandwidth');
        end

        function set.SweepBandwidth(self,val)
            setEditVal(self, 'SweepBandwidth', val);
        end

        function SweepBandwidthChanged(self,~)
            try
                value = self.SweepBandwidth;
                validateattributes(value,{'double'},{'nonempty','scalar','real', ...
                    'finite','positive','nonsparse'},'','Sweep bandwidth')
                self.SweepBandwidth = value;
            catch e
                self.errorFromException(e);
            end
        end

        function val = get.SweepDirection(self)
            val = getDropdownVal(self, 'SweepDirection');
        end

        function set.SweepDirection(self,val)
            setDropdownVal(self, 'SweepDirection', val);
        end

        function SweepDirectionChanged(self,~)
            try
                value = self.SweepDirection;
                value = validatestring(value,{'Up','Down'});
                self.SweepDirection = value;
            catch e
                self.errorFromException(e);
            end
        end

        function val = get.SweepInterval(self)
            val = getDropdownVal(self, 'SweepInterval');
        end

        function set.SweepInterval(self,val)
            setDropdownVal(self, 'SweepInterval', val);
        end

        function SweepIntervalChanged(self,~)
            try
                value = self.SweepInterval;
                value = validatestring(value,{'Positive','Symmetric'});
                self.SweepInterval = value;
            catch e
                self.errorFromException(e);
            end
        end

        function val = get.Envelope(self)
            val = getDropdownVal(self, 'Envelope');
        end

        function set.Envelope(self,val)
            setDropdownVal(self, 'Envelope', val);
        end

        function EnvelopeChanged(self,~)
            try
                value = self.Envelope;
                value = validatestring(value,{'Rectangular','Gaussian'});
                self.Envelope = value;
            catch e
                self.errorFromException(e);
            end
        end

        function [blockName, maskTitleName, waveNameText] = getMaskTextWaveName(obj)
            % Simulink Block Update
            blockName = obj.Parent.WaveformGenerator.pCurrentWaveformType;
            maskTitleName = [obj.Parent.WaveformGenerator.pCurrentWaveformType ' Generator'];
            waveNameText = getString(message('phased:apps:wirelesswavegenapp:SimulinkLinearFMName'));
        end
    end
end