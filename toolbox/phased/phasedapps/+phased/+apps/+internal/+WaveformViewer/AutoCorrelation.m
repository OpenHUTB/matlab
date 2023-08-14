classdef AutoCorrelation<phased.apps.internal.WaveformViewer.PlotData



    properties
View
Figure
Panel
TopAxes
Layout
StringLegend
    end
    methods
        function self=AutoCorrelation(parent)
            self.View=parent;
            self.Figure=self.View.AutoCorrelationFig;

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
        function correlationPlot(self,data)

            self.Figure.HandleVisibility='on';
            self.updatePlot(data)
            k=numel(self.View.Canvas.WaveformList.getSelectedRows);
            if k==1
                self.View.Toolstrip.WaveformScriptPopup.Enabled=true;
            end
            if isa(self.Waveform,'phased.FMCWWaveform')
                PRF=1/self.Waveform.SweepTime;
            else
                PRF=self.Waveform.PRF;
            end
            ind=self.View.Canvas.WaveformList.getSelectedRows;
            k=numel(self.View.Canvas.WaveformList.getSelectedRows);
            if(k>1&&data.Index~=ind(1))
                hold(self.TopAxes,'on');
            end
            rootFigure=groot;
            rootFigure.CurrentFigure=self.Figure;
            ambgfun(self.Wav,self.SampleRate,PRF,'Cut','Doppler');
            set(self.TopAxes,'Tag','Autocorr');
            if(k>1&&ind(k)==data.Index)
                stringLegend={};
                legend(self.TopAxes,stringLegend,'Interpreter','none');
                self.TopAxes.Legend.Visible='off';
                for i=1:k
                    stringLegend{end+1}=self.View.Canvas.WaveformList.Data{ind(i)};
                end
                if numel(stringLegend)==numel(self.TopAxes.Legend.String)
                    legend(self.TopAxes,stringLegend,'Interpreter','none');
                end
            end
            hold(self.TopAxes,'off');
            grid(self.TopAxes,'on');
            [strIndx,endIndx]=regexp(self.TopAxes.XLabel.String,'\(\w*\)');%#ok<ASGLU>
            if strcmp(self.TopAxes.XLabel.String(endIndx-2),'u')
                xlabel(self.TopAxes,getString(message('phased:apps:waveformapp:delayinmu2',...
                '{\tau}','(\mus)')));
            end
            title(self.TopAxes,getString(message('phased:apps:waveformapp:ACtitle')));
            ylabel(self.TopAxes,getString(message('phased:apps:waveformapp:surfaceZLabel')));
            self.Figure.HandleVisibility='off';
            if self.View.Toolstrip.IsAppContainer
                axtoolbar(self.Figure.CurrentAxes,{'export','rotate','datacursor',...
                'pan','zoomin','zoomout','restoreview'});
            end
        end
        function genCode(self,strWriter)

            self.axesHelper(self.TopAxes)
            addcr(strWriter,['ambgfun(x,Fs,prf,''Cut'',''Doppler'');'...
            ,newline,'axis([',num2str(self.xlimTopAxes(1)),' ',num2str(self.xlimTopAxes(2)),' ',num2str(self.ylimTopAxes(1)),' ',num2str(self.ylimTopAxes(2)),']);'...
            ,newline,'xlabel(''',self.xlabelTopAxes,''');'...
            ,newline,'ylabel(''',self.ylabelTopAxes,''');'...
            ,newline,'title(''',self.titleTopAxes,''');',newline]);
        end
    end
end