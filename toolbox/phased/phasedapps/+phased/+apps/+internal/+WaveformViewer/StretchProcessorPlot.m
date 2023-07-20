classdef StretchProcessorPlot<phased.apps.internal.WaveformViewer.PlotData

    properties
View
Figure
Panel
TopAxes
BottomAxes
Layout
    end
    methods
        function self=StretchProcessorPlot(parent)
            self.View=parent;
            self.Figure=self.View.StretchProcessorFig;
            if self.View.Toolstrip.IsAppContainer
                self.Layout=uigridlayout(self.Figure);
                self.Layout.RowHeight={'1x'};
                self.Layout.ColumnWidth={'1x'};
                self.Panel=uipanel(self.Layout);
            else
                self.Layout=...
                matlabshared.application.layout.ScrollableGridBagLayout(...
                self.Figure,...
                'VerticalGap',8,...
                'HorizontalGap',6,...
                'VerticalWeights',[0,1],...
                'HorizontalWeights',1);
                self.Panel=uipanel(...
                'Parent',self.Figure,...
                'Title','',...
                'BorderType','none',...
                'Visible','on');
            end
            self.TopAxes=axes('Parent',self.Panel,'Position',[0.15,0.57,0.8,0.375]);
            self.BottomAxes=axes('Parent',self.Panel,'Position',[0.15,0.11,0.8,0.375]);
            linkaxes([self.TopAxes,self.BottomAxes],'x')
        end
        function stretchProcessor(self,data)

            self.updatePlot(data)
            x=self.Wav;

            y=self.Compression(x(1:(numel(x)/self.Waveform.NumPulses)));
            wincoeff=getWinCoeff(self,data);
            y_1=y.*wincoeff;
            yout=fftshift(fft(y_1,data.compProperties.RangeFFTLength));
            l=(0:length(yout)-1)/self.SampleRate;
            [x,eng_exp,de_units]=engunits(l);
            ind=self.View.Canvas.WaveformList.getSelectedRows;
            k=numel(self.View.Canvas.WaveformList.getSelectedRows);
            if k==1
                self.View.Toolstrip.WaveformScriptPopup.Enabled=true;
            end
            if k>1
                if data.Index~=ind(1)
                    hold(self.TopAxes,'on');
                end
                prevLowerLim=self.TopAxes.YLim(1);
                prevUpperLim=self.TopAxes.YLim(2);
            end
            plot(self.TopAxes,x,abs(yout));
            phased.apps.internal.WaveformViewer.SetLimits(abs(yout),self.TopAxes)
            set(self.TopAxes,'Tag','MagAxes');
            if k>1
                updatedLowerLim=self.TopAxes.YLim(1);
                updatedUpperLim=self.TopAxes.YLim(2);
                if prevLowerLim>=updatedLowerLim&&prevUpperLim>=updatedUpperLim
                    self.TopAxes.YLim=[updatedLowerLim,prevUpperLim];
                elseif prevLowerLim<=updatedLowerLim&&prevUpperLim>=updatedUpperLim
                    self.TopAxes.YLim=[prevLowerLim,prevUpperLim];
                elseif prevLowerLim>=updatedLowerLim&&prevUpperLim<=updatedUpperLim
                    self.TopAxes.YLim=[updatedLowerLim,updatedUpperLim];
                elseif prevLowerLim<=updatedLowerLim&&prevUpperLim<=updatedUpperLim
                    self.TopAxes.YLim=[updatedLowerLim,updatedUpperLim];
                else
                    self.TopAxes.YLim=[prevLowerLim,prevUpperLim];
                end
            end
            if strcmp(de_units,'u')
                de_units='\mu';
            end

            ylabel(self.TopAxes,getString(message('phased:apps:waveformapp:MagnitudePlotYLabel')));
            grid(self.TopAxes,'on');
            hold(self.TopAxes,'off');
            if self.View.Toolstrip.IsAppContainer
                axtoolbar(self.Figure.CurrentAxes,{'export','rotate','datacursor',...
                'pan','zoomin','zoomout','restoreview'});
            end
            if k>1
                if data.Index~=ind(1)
                    hold(self.BottomAxes,'on');
                end
                prevLowerLim=self.BottomAxes.YLim(1);
                prevUpperLim=self.BottomAxes.YLim(2);
            end
            plot(self.BottomAxes,x,angle(yout));
            phased.apps.internal.WaveformViewer.SetLimits(angle(yout),self.BottomAxes)
            set(self.BottomAxes,'Tag','PhaseAxes');
            if k>1
                updatedLowerLim=self.BottomAxes.YLim(1);
                updatedUpperLim=self.BottomAxes.YLim(2);
                if prevLowerLim>=updatedLowerLim&&prevUpperLim>=updatedUpperLim
                    self.BottomAxes.YLim=[updatedLowerLim,prevUpperLim];
                elseif prevLowerLim<=updatedLowerLim&&prevUpperLim>=updatedUpperLim
                    self.BottomAxes.YLim=[prevLowerLim,prevUpperLim];
                elseif prevLowerLim>=updatedLowerLim&&prevUpperLim<=updatedUpperLim
                    self.BottomAxes.YLim=[updatedLowerLim,updatedUpperLim];
                else
                    self.BottomAxes.YLim=[updatedLowerLim,updatedUpperLim];
                end
                if ind(k)==data.Index
                    stringLegend={};
                    legend(self.TopAxes,stringLegend,'Interpreter','none');
                    self.TopAxes.Legend.Visible='off';
                    for i=1:k
                        if self.View.Toolstrip.IsAppContainer
                            stringLegend{end+1}=self.View.Canvas.WaveformList.Data{ind(i)};
                        end
                    end
                    if numel(stringLegend)==numel(self.TopAxes.Legend.String)
                        legend(self.TopAxes,stringLegend,'Interpreter','none');
                        legend(self.BottomAxes,stringLegend,'Interpreter','none');
                    end
                end
            end
            if strcmp(de_units,'u')
                de_units='\mu';
            end
            xlabel(self.BottomAxes,getString(message('phased:apps:waveformapp:RealPlotXLabel',de_units)));
            ylabel(self.BottomAxes,getString(message('phased:apps:waveformapp:PhasePlotYLabel')));
            grid(self.BottomAxes,'on');
            hold(self.BottomAxes,'off');
            if self.View.Toolstrip.IsAppContainer
                axtoolbar(self.TopAxes,{'export','rotate','datacursor',...
                'pan','zoomin','zoomout','restoreview'});
                axtoolbar(self.BottomAxes,{'export','rotate','datacursor',...
                'pan','zoomin','zoomout','restoreview'});
            end
        end

        function winCoeff=getWinCoeff(self,data)%#ok<INUSL>
            num_rng_samples=data.wavProperties.SampleRate/data.wavProperties.PRF;
            rangeWindow=data.compProperties.RangeWindow;
            rangeSidelobeAttenuation=data.compProperties.SideLobeAttenuation;
            Nbar=data.compProperties.Nbar;
            Beta=data.compProperties.Beta;
            switch rangeWindow
            case 'None'
                winCoeff=ones(num_rng_samples,1);
            case 'Hamming'
                winCoeff=hamming(num_rng_samples);
            case 'Hann'
                winCoeff=hann(num_rng_samples);
            case 'Kaiser'
                winCoeff=kaiser(num_rng_samples,Beta);
            case 'Chebyshev'
                winCoeff=chebwin(num_rng_samples,...
                rangeSidelobeAttenuation);
            case 'Taylor'
                winCoeff=taylorwin(num_rng_samples,...
                Nbar,-rangeSidelobeAttenuation);
            end
        end

        function genCode(self,strWriter)
            self.axesHelper(self.TopAxes)
            xlimBottomAxes=get(self.BottomAxes,'XLim');
            ylimBottomAxes=get(self.BottomAxes,'YLim');
            xlabelBottomAxes=get(get(self.BottomAxes,'Xlabel'),'String');
            ylabelBottomAxes=get(get(self.BottomAxes,'Ylabel'),'String');
            addcr(strWriter,['l = (0:length(yout)-1)/Fs;',newline...
            ,'subplot(2,1,1);',newline...
            ,'[x, scale, ~] = engunits(l);',newline...
            ,newline,'plot(x,abs(yout));'...
            ,newline,'axis([',num2str(self.xlimTopAxes(1)),' ',num2str(self.xlimTopAxes(2)),' ',num2str(self.ylimTopAxes(1)),' ',num2str(self.ylimTopAxes(2)),']);'...
            ,newline,'xlabel(''',self.xlabelTopAxes,''');'...
            ,newline,'ylabel(''',self.ylabelTopAxes,''');'...
            ,newline,'grid on;',newline...
            ,'subplot(2,1,2);',newline,'plot(x,angle(yout));'...
            ,newline,'axis([',num2str(xlimBottomAxes(1)),' ',num2str(xlimBottomAxes(2)),' ',num2str(ylimBottomAxes(1)),' ',num2str(ylimBottomAxes(2)),']);'...
            ,newline,'xlabel(''',xlabelBottomAxes,''');'...
            ,newline,'ylabel(''',ylabelBottomAxes,''');'...
            ,newline,'grid on;',newline]);
        end
    end
end