classdef Spectrum<phased.apps.internal.WaveformViewer.PlotData



    properties
View
Figure
Panel
TopAxes
Layout
    end
    methods
        function self=Spectrum(parent)
            self.View=parent;
            self.Figure=self.View.SpectrumFig;
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
            self.TopAxes=axes('Parent',self.Panel);
        end
        function spectrumPlot(self,data)

            self.updatePlot(data)
            [X,f]=pwelch(self.Wav,[],[],[],self.SampleRate,'centered');
            X=pow2db(X);
            k=numel(self.View.Canvas.WaveformList.getSelectedRows);
            if k==1
                self.View.Toolstrip.WaveformScriptPopup.Enabled=true;
            end
            [~,bx,cx]=engunits(max(f));

            ind=self.View.Canvas.WaveformList.getSelectedRows;
            k=numel(self.View.Canvas.WaveformList.getSelectedRows);
            if k>1&&data.Index~=ind(1)
                hold(self.TopAxes,'on');
            end
            plot(self.TopAxes,f*bx,X);
            set(self.TopAxes,'Tag','Spectrum');

            if k>1&&data.Index==ind(1)
                legend(self.TopAxes,self.View.Canvas.WaveformList.Data{data.Index});
            end
            xlabel(self.TopAxes,getString(message('phased:apps:waveformapp:SpectrumPlotXLabel',cx)));
            ylabel(self.TopAxes,getString(message('phased:apps:waveformapp:SpectrumPlotYLabel')));
            title(self.TopAxes,getString(message('phased:apps:waveformapp:SpectrumPlotTitle')));
            if k>1&&ind(k)==data.Index
                stringLegend={};
                legend(self.TopAxes,stringLegend,'Interpreter','none');
                self.TopAxes.Legend.Visible='off';
                for i=1:k
                    stringLegend{end+1}=self.View.Canvas.WaveformList.Data{ind(i)};
                end
                if numel(stringLegend)<=numel(self.TopAxes.Legend.String)
                    legend(self.TopAxes,stringLegend,'Interpreter','none');
                end
            end
            grid(self.TopAxes,'on');
            hold(self.TopAxes,'off');
            if self.View.Toolstrip.IsAppContainer
                axtoolbar(self.Figure.CurrentAxes,{'export','rotate','datacursor',...
                'pan','zoomin','zoomout','restoreview'});
            end
        end
        function genCode(self,strWriter)

            self.axesHelper(self.TopAxes)
            addcr(strWriter,['pwelch(x, [], [], [], Fs, ''centered'');'...
            ,newline,'xlabel(''',self.xlabelTopAxes,''');'...
            ,newline,'ylabel(''',self.ylabelTopAxes,''');'...
            ,newline,'title(''',self.titleTopAxes,''');',newline]);
        end
    end
end