classdef VisualizeSpectrogram < handle
% Visualize Spectrogram Plot
    % Copyright 2022 The MathWorks, Inc.

    properties
        % Waveform Parameters Dialog
        waveformDialog

        % Spectrogram Figure
        SpectrogramFigure

        % Panel for spectrogram figure
        SpectrogramPanel

        % Panel for Threshold and Reassigned properties
        AttributesPanel

        % Axes to plot spectrogram data
        Axes
        xlimAxes
        ylimAxes
        titleAxes
        xlabelAxes
        ylabelAxes

        % Threshold Plots
        ThresholdLabel
        ThresholdGUI
        ThresholdUnit
        ReassignedGUI

        % Layout
        SpectrogramFigureLayout

        % Waveform
        Waveform

        % ThresholdDefault
        ThresholdDefault = '-100';
    end
    methods
        function self = VisualizeSpectrogram(parent)% constructor
            self.waveformDialog = parent;

            % Create figure
            self.SpectrogramFigure = self.waveformDialog.Spectrogramfig;
            
            % Creating new panel for threshold and reassigned
            self.SpectrogramFigureLayout = uigridlayout(self.SpectrogramFigure);
            self.SpectrogramFigureLayout.RowHeight = {'6x','1x'};
            self.SpectrogramFigureLayout.ColumnWidth = {'1x'};

            % Create Panel
            self.SpectrogramPanel = uipanel(self.SpectrogramFigureLayout);
            self.SpectrogramPanel.Layout.Row = 1;
            self.SpectrogramPanel.Layout.Column = 1;

            % Create Panel_2
            self.AttributesPanel = uipanel(self.SpectrogramFigureLayout);
            self.AttributesPanel.Layout.Row = 2;
            self.AttributesPanel.Layout.Column = 1;

            % Create ReassignedCheckBox
            self.ReassignedGUI = uicheckbox(self.AttributesPanel);
            self.ReassignedGUI.Text = getString(message('phased:apps:wirelesswavegenapp:Reassigned'));
            self.ReassignedGUI.Position = [13 10 100 22];
            self.ReassignedGUI.Tag = 'Reassigned';
            self.ReassignedGUI.Value = true;
            self.ReassignedGUI.ValueChangedFcn = @(h,e)spectrogramPlot(self,self.Waveform);

            % Create ThresholdEditFieldLabel
            self.ThresholdLabel = uilabel(self.AttributesPanel);
            self.ThresholdLabel.HorizontalAlignment = 'right';
            self.ThresholdLabel.Position = [123 10 59 22];
            self.ThresholdLabel.Text = getString(message('phased:apps:wirelesswavegenapp:Threshold'));

            % Create ThresholdEditField
            self.ThresholdGUI = uieditfield(self.AttributesPanel, 'text');
            self.ThresholdGUI.Position = [197 10 100 22];
            self.ThresholdGUI.Value = self.ThresholdDefault;
            self.ThresholdGUI.Tag = 'ThresholdEdit';
            self.ThresholdGUI.ValueChangedFcn =  @(h,e)thresholdCallback(self);
            self.Axes = axes('Parent',self.SpectrogramPanel);

            axtoolbar(self.SpectrogramFigure.CurrentAxes,{'export','rotate','datacursor',...
                'pan','zoomin','zoomout','restoreview'});
        end
        function spectrogramPlot(self,waveformObj)
            % Update spectrogram plot
            self.Waveform = waveformObj();
            
            if self.ReassignedGUI.Value == 1
                reassignedFlag = {'reassigned'};
                win = kaiser(floor(length(self.Waveform)/16),38);
            else
                reassignedFlag = {};
                win = floor(length(self.Waveform)/16);
            end

            if isempty(self.ThresholdGUI.Value)
                self.ThresholdGUI.Value = '-100' ;
            end

            Threshold = evalin('base',self.ThresholdGUI.Value);

            % Update Spectrogram Plot
            if isreal(self.Waveform)
                fin = self.waveformDialog.SampleRate*(-1/2:1/256:127/256);
                [~,f,t,c] = spectrogram(self.Waveform,win,floor(length(self.Waveform)/17),fin,self.waveformDialog.SampleRate,'yaxis','MinThreshold',Threshold,reassignedFlag{:});
            else
                [~,f,t,c] = spectrogram(self.Waveform,win,floor(length(self.Waveform)/17),256,self.waveformDialog.SampleRate,'yaxis','MinThreshold',Threshold,reassignedFlag{:});

            end

            [~, bx, cx] = engunits(max(t));
            [~, by, cy] = engunits(max(f));
            xa = t*bx;
            c(c<eps) = eps;

            if isreal(self.Waveform)
                ya = f*by;
                surf(self.Axes,xa,ya,(10*log10(abs(c))),'EdgeColor','none');
            else
                ya = (f-self.waveformDialog.SampleRate/2)*by;
                surf(self.Axes,xa,ya,fftshift(10*log10(abs(c)),1),'EdgeColor','none');
            end

            set(self.Axes,'Tag','Spectrogram');
            SpectrogramLine = get(self.Axes, 'Children');
            set(SpectrogramLine, 'Tag', 'SpectromgramLine');
            axis(self.Axes,'xy');
            view(self.Axes,2);
            if strcmp(cx,'u')
                cx = '\mu';
            end

            % Update Labels
            xlabel(self.Axes, getString(message('phased:apps:wirelesswavegenapp:SpectrogramPlotXLabel',cx)));
            ylabel(self.Axes, getString(message('phased:apps:wirelesswavegenapp:SpectrogramPlotYLabel', cy)));
            title(self.Axes, getString(message('phased:apps:wirelesswavegenapp:SpectrogramPlotTitle')));

            % Update Color bar
            ch = colorbar('peer',self.Axes);
            ylabel(ch, 'dB');
            axis(self.Axes,[xa(1) xa(end) ya(1) ya(end)]);
            setappdata(ch, 'zoomable', 'off');
            
        end
        function genCode(self,sw)
            % Generate MATLAB script for spectrogram
            self.axesHelper(self.Axes)
            Threshold = self.ThresholdGUI.Value;

            if self.ReassignedGUI.Value == 1
                add(sw,[newline 'win = kaiser(floor(length(waveform)/16),38);']);
                reassignedStr = ', ''reassigned''';
            else
                add(sw,[newline 'win = floor(length(waveform)/16);']);
                reassignedStr = '';
            end

            add(sw,[newline 'Threshold = ' num2str(Threshold) ';']);

            if isreal(self.Waveform)
                addcr(sw,[ newline 'fin = Fs*(-1/2:1/256:127/256);'...
                    newline '[~,f,t,p] = spectrogram(waveform,win,floor(length(waveform)/17),fin,Fs,''yaxis'',''MinThreshold'',Threshold' reassignedStr ');' ...
                    newline '[~, t_scale, t_Units] = engunits(max(t));' ...
                    newline '[~, f_scale, f_Units] = engunits(max(f));' ...
                    newline '%set all 0 with next smallest value;' ...
                    newline 'p(p<eps) = eps;']);
                addcr(sw,'ya = f*f_scale;')
                addcr(sw,'surf(t*t_scale, ya,(10*log10(abs(p))),''EdgeColor'',''none'');');
            else
                addcr(sw,[ ...
                    newline '[~,f,t,p] = spectrogram(waveform,win,floor(length(waveform)/17),256,Fs,''yaxis'',''MinThreshold'',Threshold' reassignedStr ');' ...
                    newline '[~, t_scale, t_Units] = engunits(max(t));' ...
                    newline '[~, f_scale, f_Units] = engunits(max(f));' ...
                    newline '%set all 0 with next smallest value;' ...
                    newline 'p(p<eps) = eps;']);
                addcr(sw,'ya = (f-Fs/2)*f_scale;');
                addcr(sw,'surf(t*t_scale,ya,fftshift(10*log10(abs(p)),1),''EdgeColor'',''none'');')
            end

            addcr(sw,'axis([t(1)*t_scale t(end)*t_scale f(1)*f_scale f(end)*f_scale]);');

            addcr(sw,['axis([' num2str(self.xlimAxes(1)),' ',num2str(self.xlimAxes(2)),' ', num2str(self.ylimAxes(1)),' ',num2str(self.ylimAxes(2)) ']);' ...
                newline 'xlabel(''' self.xlabelAxes ''');' ...
                newline 'ylabel(''' self.ylabelAxes ''');' ...
                newline 'title(''' self.titleAxes ''');']);
            addcr(sw,['axis xy;' ...
                newline 'view(2);' ...
                newline 'ch = colorbar;' ...
                newline 'ylabel(ch, ''dB'');' newline]);

        end

        function axesHelper(self,Axes)
            self.xlimAxes = get(Axes,'XLim');
            self.ylimAxes = get(Axes,'YLim');
            self.titleAxes =  getString(message('phased:apps:wirelesswavegenapp:SpectrogramPlotTitle'));
            self.xlabelAxes = get(get(Axes,'Xlabel'),'String');
            self.ylabelAxes = get(get(Axes,'Ylabel'),'String');
            if isempty(self.xlabelAxes) && isempty(self.ylabelAxes)
                % Click on export to script without clicking on generate
                self.xlabelAxes = getString(message('phased:apps:wirelesswavegenapp:SpectrogramPlotXLabel','/mu'));
                self.ylabelAxes = getString(message('phased:apps:wirelesswavegenapp:SpectrogramPlotYLabel','k'));
                self.xlimAxes = [0 100];
                self.ylimAxes = [-500 500];
            end
        end

        function thresholdCallback(self)
            % validate and update threshold parameter in spectrogram
            try
                spectrogramPlot(self,self.Waveform);

                value = evalin('base',self.ThresholdGUI.Value);
                if isempty(value) && ~isempty(self.ThresholdGUI.Value)
                    value = '';
                end
                validateattributes(value,{'numeric'}, ...
                    {'nonempty','scalar','real','finite'},'','Threshold')
                self.ThresholdDefault = self.ThresholdGUI.Value;
            catch me
                dlg = errordlg(me.message, getString(message('comm:waveformGenerator:DialogTitle')), 'modal' );
                uiwait(dlg);
                self.ThresholdGUI.Value = self.ThresholdDefault;
                return
            end
        end
    end
end