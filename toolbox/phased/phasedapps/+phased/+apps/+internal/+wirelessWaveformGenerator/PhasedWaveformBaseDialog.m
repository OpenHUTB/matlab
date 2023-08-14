classdef PhasedWaveformBaseDialog < wirelessWaveformGenerator.waveformConfigurationDialog
    % Dialog for waveform base parameters
    % Copyright 2022 The MathWorks, Inc.


    properties(Abstract)
      % Actually SampleRate can be shared here, but the display order will need to
      % be taken care of, by implementing displayOrder()
      SampleRate
    end

    properties(Hidden)
        % Spectrogram 
        Spectrogramfig
        Spectrogram
        hThresholdtxt
        hThresholdedt
        hThresholdunit
        hReassignededt

    end

    methods (Static)
        function hPropDb = getPropertySet(~)
            hPropDb = extmgr.PropertySet(...
                'Visualizations',   'mxArray', {'Spectrogram'});
        end
    end

    methods
        function self = PhasedWaveformBaseDialog(parent)
            self@wirelessWaveformGenerator.waveformConfigurationDialog(parent); % call base constructor

            className = 'phased.apps.internal.wirelessWaveformGenerator.CharacteristicsDialog';
            if ~isKey(self.Parent.DialogsMap, className)
                self.Parent.DialogsMap(className) = eval([className '(self.Parent)']); %#ok<*EVLDOT>
            end

            % All Waveforms to have the same column width.
            self.SampleRateGUI.Parent.ColumnWidth{1} = 160;
        end
    end

    methods
        function sr = getSampleRate(self)
            % Set the symbol rate, as per the standard
            sr = self.SampleRate;
        end

        function sps = getSamplesPerSymbol(self)
            sps = (self.NumPulses*(self.SampleRate/self.PRF))/30;
        end

        function waveform = generateWaveform(self)
            % Generate Waveform
            spectrum = self.Parent.WaveformGenerator.pSpectrum1;
            release(spectrum);
            spectrum.SampleRate = self.SampleRate; 
            spectrum.RBWSource = 'property';
            spectrum.RBW = 0.02*self.SampleRate;
            waveformObject = getConfiguration(self);
            waveform = waveformObject();

            % Update Characteristics after waveform generation
            CharacteristicsUpdate(self);
        end

        function config = getConfigurationForSave(self)
            config.waveform = self.getConfiguration;
        end

        function cfg = applyConfiguration(self, cfg)
            applyConfiguration@wirelessWaveformGenerator.Dialog(self, cfg);
            CharacteristicsUpdate(self);
        end


        function str = getCatalogPrefix(~)
            str = 'phased:apps:wirelesswavegenapp:';
        end

        function customVisualizations(self, varargin)
            if self.getVisualState(self.visualNames{1})
                if isempty(self.Spectrogram) || isempty(self.Spectrogramfig)
                    self.Spectrogramfig = self.getVisualFig(self.visualNames{1});
                    self.Spectrogram = phased.apps.internal.wirelessWaveformGenerator.VisualizeSpectrogram(self);
                end
                % get waveform configuration
                waveformObj = getConfiguration(self);
                spectrogramPlot(self.Spectrogram,waveformObj);
            end
        end

        function addCustomVisualizationCode(self, sw)
            if self.getVisualState(self.visualNames{1})
                if isempty(self.Spectrogram) || isempty(self.Spectrogramfig)
                    self.Spectrogramfig = self.getVisualFig(self.visualNames{1});
                    self.Spectrogram = phased.apps.internal.wirelessWaveformGenerator.VisualizeSpectrogram(self);
                end
                % Generate Visualization code
                genCode(self.Spectrogram,sw);
            end
        end

        function addSpectrumCustomizations(~, sw)
             addcr(sw, 'spectrum.RBWSource = "property" ;');
             addcr(sw, 'spectrum.RBW = 0.02*Fs ;');
        end

        function b = timeScopeEnabled(~)
            b = true;
        end

        function b = spectrumEnabled(~)
            b = true;
        end

        function [configline, configParam] = getConfigParam(self)
            configline = '';
            configParam = self.configGenVar;
        end

        function addGenerationCode(self, sw)
            % Waveform generation code
            addcr(sw, ['waveform = ' self.configGenVar '();']);
        end

        function CharacteristicsUpdate(self)
            % Waveform Characterisitcs Update
            waveformObj = getConfiguration(self);
            switch true
                case isa(waveformObj,'phased.PhaseCodedWaveform')
                    % Phase coded waveform
                    Bandwidth = bandwidth(waveformObj) ;
                    PRF = waveformObj.PRF;
                    Numpulses = waveformObj.NumPulses;
                    Pulsewidth = waveformObj.ChipWidth*waveformObj.NumChips;
                    Dutycycle = dutycycle(Pulsewidth,PRF);
                case isa(waveformObj,'phased.FMCWWaveform')
                    % FMCW waveform
                    SweepTime = waveformObj.SweepTime;
                    PRF = 1/(waveformObj.SweepTime);
                    Numpulses = waveformObj.NumSweeps;
                    Pulsewidth = 0;
                    Bandwidth = waveformObj.SweepBandwidth;
                otherwise
                    Bandwidth = bandwidth(waveformObj);
                    PRF = waveformObj.PRF;
                    Numpulses = waveformObj.NumPulses;
                    Pulsewidth = waveformObj.PulseWidth;
                    Dutycycle = dutycycle(Pulsewidth,PRF);
            end
            dlg = self.Parent.DialogsMap('phased.apps.internal.wirelessWaveformGenerator.CharacteristicsDialog');
            % Range Resolution
            Propagationspeed = physconst('Lightspeed');
            value = num2str((Propagationspeed/(2*Bandwidth))/1000);
            value = [value,' ','km'];
            dlg.RangeResolution = value;
            % Doppler Resolution
            value = num2str((PRF/Numpulses)/1000);
            value = [value,' ','kHz'];
            dlg.DopplerResolution = value;
            % Minimum Unambiguous Range
            value = num2str((Propagationspeed*Pulsewidth/2)/1000);
            value = [value,' ','km'];
            dlg.MinUnambiguousRange = value;
            % Maximum Unambiguous Range
            value = num2str((Propagationspeed/(2*PRF))/1000);
            value = [value,' ','km'];
            dlg.MaxUnambiguousRange = value;
            % Maximum Doppler
            value = num2str((PRF/2)/1000);
            value = [value,' ','kHz'];
            dlg.MaxDoppler = value;
            if ~isa(waveformObj,'phased.FMCWWaveform')
                % Time Bandwidth Product
                value = num2str(Pulsewidth*Bandwidth);
                dlg.TimeBWProduct = value;

                % Duty Cycle
                value = num2str(Dutycycle*100);
                value = [value,' ','%'];
                dlg.DutyCycle = value;
            else
                % Time Bandwidth Product
                value = num2str(SweepTime*Bandwidth);
                dlg.TimeBWProduct  = value;

                % Duty Cycle
                dlg.DutyCycle = 'N/A';
            end
        end

        function outro(self, newDialog)
            % Executed when moving to a new waveform type (e.g., Radar -> QAM)

            if ~(isa(newDialog, 'phased.apps.internal.wirelessWaveformGenerator.WaveformDialog'))
                % Restore Spectrum Analyzer properties when Radar to any other waveform is selected
                self.Parent.WaveformGenerator.pSpectrum1.RBWSource = 'auto';
            end
        end
        
        function userDataText = getUserDataText(~)
            userDataText = 'configuration';
        end
    end

    methods(Access = 'public')
        function cellDialogs = getDialogsPerColumn(self)
            cellDialogs{1} = {self,self.Parent.DialogsMap('phased.apps.internal.wirelessWaveformGenerator.CharacteristicsDialog')};
        end

        function defaultVisualLayout(self)
            self.setVisualState('Spectrogram', false);
        end
    end
end