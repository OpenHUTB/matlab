classdef PersistenceSpectrum<phased.apps.internal.WaveformViewer.PlotData



    properties
View
Figure
Panel
TopAxes
Layout
    end
    methods
        function self=PersistenceSpectrum(parent)
            self.View=parent;
            self.Figure=self.View.PSpectrumFig;
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
        function pspectrumPlot(self,data)

            self.Figure.HandleVisibility='on';
            self.updatePlot(data)
            grt=groot;
            grt.CurrentFigure=self.Figure;
            pspectrum(self.Wav,self.SampleRate,'persistence');
            set(self.TopAxes,'Tag','PSpectrum');
            k=numel(self.View.Canvas.WaveformList.getSelectedRows);
            if k==1
                self.View.Toolstrip.WaveformScriptPopup.Enabled=true;
            end
            self.Figure.HandleVisibility='off';
            if self.View.Toolstrip.IsAppContainer
                axtoolbar(self.Figure.CurrentAxes,{'export','rotate','datacursor',...
                'pan','zoomin','zoomout','restoreview'});
            end
        end
        function genCode(obj,strWriter)%#ok<INUSL>

            addcr(strWriter,['pspectrum(x,Fs,''persistence'');',newline]);
        end
    end
end