classdef RectangularDialog < phased.apps.internal.wirelessWaveformGenerator.PhasedWaveformBaseDialog
    % Dialog for rectangular waveform parameters
    % Copyright 2022 The MathWorks, Inc.    
    
    properties (Dependent)
        % Waveform parameters
        SampleRate
        PRF
        NumPulses
        PulseWidth
    end
    
    properties(Hidden)
        TitleString = getString(message('phased:apps:wirelesswavegenapp:RectWaveformTitle'))
        configFcn = @phased.RectangularWaveform
        configGenFcn = @phased.RectangularWaveform
        configGenVar = 'rectWaveform'
      
        SampleRateLabel
        SampleRateType = 'edit'
        SampleRateGUI

        PulseWidthLabel
        PulseWidthType = 'edit'
        PulseWidthGUI

        NumPulsesLabel
        NumPulsesType = 'edit'
        NumPulsesGUI

        PRFLabel
        PRFType = 'edit'
        PRFGUI

    end
    
    methods
        function self = RectangularDialog(parent)
            self@phased.apps.internal.wirelessWaveformGenerator.PhasedWaveformBaseDialog(parent); % call base constructor
            
            % Callbacks
            self.SampleRateGUI.(self.Callback) =  @(h,e)SampleRateChanged(self,e);
            self.NumPulsesGUI.(self.Callback)  =  @(h,e)NumberPulsesChanged(self,e);
            self.PRFGUI.(self.Callback)        =  @(h,e)PRFChanged(self,e);
            self.PulseWidthGUI.(self.Callback) =  @(h,e)PulseWidthChanged(self,e);

            % Waveform Characteristics Update
            CharacteristicsUpdate(self);
        end

        function restoreDefaults(self)
            % Waveform default parameters
            self.SampleRate = 1e6;
            self.NumPulses  = 1;
            self.PRF        = 1e4;
            self.PulseWidth = 50e-6;
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
                validateattributes(val,{'double'},{'nonempty','scalar', ...
                    'real','finite','positive','nonsparse'},'','Sample rate')
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
                validateattributes(val,{'double'},{'nonempty','scalar', ...
                    'real','finite','positive','nonsparse'},'','Pulse width');
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
                validateattributes(val,{'double'},{'nonempty','scalar','real','finite','positive','integer', ...
                    'nonnan','nonsparse'},'','Number of pulses');
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
                validateattributes(val,{'double'},{'nonempty','scalar', ...
                    'real','finite','positive','nonsparse'},'','Pulse repetition frequency')
            catch e
                self.errorFromException(e);
            end
        end

        function [blockName, maskTitleName, waveNameText] = getMaskTextWaveName(self)
            % Simulink Block Update
            blockName = self.Parent.WaveformGenerator.pCurrentWaveformType;
            maskTitleName = [self.Parent.WaveformGenerator.pCurrentWaveformType ' Generator'];
            waveNameText =  getString(message('phased:apps:wirelesswavegenapp:SimulinkRectangularName'));
        end
    end
end