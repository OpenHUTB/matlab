classdef FMCWDialog < phased.apps.internal.wirelessWaveformGenerator.PhasedWaveformBaseDialog
    % Dialog for Frequency Modulated Continuous Wave parameters
    % Copyright 2022 The MathWorks, Inc.

    properties (Dependent)
        % FMCW Wave Parameters
        SampleRate
        SweepTime
        SweepBandwidth
        SweepDirection
        SweepInterval
        NumSweeps
    end

    properties(Hidden)
        TitleString = getString(message('phased:apps:wirelesswavegenapp:FMCWWaveformTitle'))
        configFcn = @phased.FMCWWaveform
        configGenFcn = @phased.FMCWWaveform
        configGenVar = 'fmcwWaveform'

        SampleRateLabel
        SampleRateType = 'edit'
        SampleRateGUI

        NumSweepsLabel
        NumSweepsType = 'edit'
        NumSweepsGUI

        SweepTimeLabel
        SweepTimeType = 'edit'
        SweepTimeGUI

        SweepBandwidthLabel
        SweepBandwidthType = 'edit'
        SweepBandwidthGUI

        SweepDirectionLabel
        SweepDirectionType = 'popupmenu'
        SweepDirectionDropDown = {'Up','Down','Triangle'}
        SweepDirectionGUI

        SweepIntervalLabel
        SweepIntervalType = 'popupmenu'
        SweepIntervalDropDown = {'Positive','Symmetric'}
        SweepIntervalGUI

    end

    methods
        function self = FMCWDialog(parent)
            self@phased.apps.internal.wirelessWaveformGenerator.PhasedWaveformBaseDialog(parent); % call base constructor
            
            % Callbacks
            self.SampleRateGUI.(self.Callback)      =  @(h,e)SampleRateChanged(self,e);
            self.NumSweepsGUI.(self.Callback)       =  @(h,e)NumSweepsChanged(self,e);
            self.SweepTimeGUI.(self.Callback)       =  @(h,e)SweepTimeChanged(self,e);
            self.SweepBandwidthGUI.(self.Callback)  =  @(h,e)SweepBandwidthChanged(self,e);
            self.SweepDirectionGUI.(self.Callback)  =  @(h,e)SweepDirectionChanged(self,e);
            self.SweepIntervalGUI.(self.Callback)   =  @(h,e)SweepIntervalChanged(self,e);

            % Update Characteristics
            CharacteristicsUpdate(self);
        end

        function restoreDefaults(self)
            % Waveform Defaults
            self.SampleRate     = 1e6;
            self.NumSweeps      = 1;
            self.SweepTime      = 0.0001;
            self.SweepBandwidth = 100000;
            self.SweepDirection = 'Up';
            self.SweepInterval  ='Positive';
        end
    end

    methods

        function sps = getSamplesPerSymbol(~)
            % This is for Spectrum Analyzer update
            sps = 1;
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
                    'finite','positive','nonsparse'},'','Sample Rate')
            catch e
                self.errorFromException(e);
            end
        end

        function val = get.NumSweeps(self)
            val = getEditVal(self, 'NumSweeps');
        end

        function set.NumSweeps(self,val)
            setEditVal(self, 'NumSweeps', val);
        end

        function NumSweepsChanged(self, ~)
            try
                value = self.NumSweeps;
                validateattributes(value,{'double'},{'nonempty','scalar','real', ...
                    'finite','positive','integer','nonsparse'},'','Number of sweeps')
            catch e
                self.errorFromException(e);
            end
        end

        function val = get.SweepTime(self)
            val = getEditVal(self, 'SweepTime');
        end

        function set.SweepTime(self,val)
            setEditVal(self, 'SweepTime', val);
        end

        function SweepTimeChanged(self, ~)
            try
                value = self.SweepTime;
                validateattributes(value,{'double'},{'nonempty','scalar','real', ...
                    'finite','positive','nonsparse'},'','Sweep time')
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

        function SweepBandwidthChanged(self, ~)
            try
                value = self.SweepBandwidth;
                validateattributes(value,{'double'},{'nonempty','scalar','real', ...
                    'finite','positive','nonsparse'},'','Sweep bandwidth')
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

        function SweepDirectionChanged(self, ~)
            try
                value = self.SweepDirection;
                validatestring(value,{'Up','Down','Triangle'});
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

        function SweepIntervalChanged(self, ~)
            try
                value = self.SweepInterval;
                validatestring(value,{'Positive','Symmetric'});
            catch e
                self.errorFromException(e);
            end
        end
      
        function [blockName, maskTitleName, waveNameText] = getMaskTextWaveName(obj)
            % Simulink block update
            blockName = obj.Parent.WaveformGenerator.pCurrentWaveformType;
            maskTitleName = [obj.Parent.WaveformGenerator.pCurrentWaveformType ' Generator'];
            waveNameText = getString(message('phased:apps:wirelesswavegenapp:SimulinkFMCWName'));
        end
    end
end
