classdef AmbiguityFunctionContour<phased.apps.internal.WaveformViewer.PlotData



    properties
View
Figure
Panel
TopAxes
Layout
    end
    methods
        function self=AmbiguityFunctionContour(parent)
            self.View=parent;
            self.Figure=self.View.AmbiguityFunctionContourFig;
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
        function contourPlot(self,data)

            self.Figure.HandleVisibility='on';
            self.updatePlot(data)
            if isa(self.Waveform,'phased.FMCWWaveform')
                PRF=1/self.Waveform.SweepTime;
            else
                PRF=self.Waveform.PRF;
            end
            rootFigure=groot;
            rootFigure.CurrentFigure=self.Figure;
            ambgfun(self.Wav,self.SampleRate,PRF)
            set(self.TopAxes,'Tag','ambgContour');
            k=numel(self.View.Canvas.WaveformList.getSelectedRows);
            if k==1
                self.View.Toolstrip.WaveformScriptPopup.Enabled=true;
            end
            [strIndx,endIndx]=regexp(self.TopAxes.XLabel.String,'\(\w*\)');%#ok<ASGLU>
            if strcmp(self.TopAxes.XLabel.String(endIndx-2),'u')
                xlabel(self.TopAxes,getString(message('phased:apps:waveformapp:delayinmu2',...
                '{\tau}','(\mus)')));
            end
            grid(self.TopAxes,'on');
            self.Figure.HandleVisibility='off';
            if self.View.Toolstrip.IsAppContainer
                axtoolbar(self.Figure.CurrentAxes,{'export','rotate','datacursor',...
                'pan','zoomin','zoomout','restoreview'});
            end
        end
        function genCode(self,strWriter)

            self.axesHelper(self.TopAxes)
            addcr(strWriter,['ambgfun(x,Fs,prf);'...
            ,newline,'axis([',num2str(self.xlimTopAxes(1)),' ',num2str(self.xlimTopAxes(2)),' ',num2str(self.ylimTopAxes(1)),' ',num2str(self.ylimTopAxes(2)),']);'...
            ,newline,'xlabel(''',self.xlabelTopAxes,''');'...
            ,newline,'ylabel(''',self.ylabelTopAxes,''');'...
            ,newline,'title(''',self.titleTopAxes,''');',newline]);

        end
    end
end