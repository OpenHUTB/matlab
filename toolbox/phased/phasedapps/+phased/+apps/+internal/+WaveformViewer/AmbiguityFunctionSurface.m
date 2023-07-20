classdef AmbiguityFunctionSurface<phased.apps.internal.WaveformViewer.PlotData



    properties
View
Figure
Panel
TopAxes
Layout
    end
    methods
        function self=AmbiguityFunctionSurface(parent)
            self.View=parent;
            self.Figure=self.View.AmbiguityFunctionSurfaceFig;
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
        function surfacePlot(self,data)

            self.updatePlot(data)
            if isa(self.Waveform,'phased.FMCWWaveform')
                PRF=1/self.Waveform.SweepTime;
            else
                PRF=self.Waveform.PRF;
            end
            [m,de,do]=ambgfun(self.Wav,self.SampleRate,PRF);
            [~,de_scale,de_units]=engunits(max(de));
            [~,do_scale,do_units]=engunits(max(do));
            mesh(self.TopAxes,de*de_scale,do*do_scale,m);
            set(self.TopAxes,'Tag','ambgSurface');
            k=numel(self.View.Canvas.WaveformList.getSelectedRows);
            if k==1
                self.View.Toolstrip.WaveformScriptPopup.Enabled=true;
            end
            SurfaceLine=get(self.TopAxes,'Children');
            set(SurfaceLine,'Tag','SurfaceLine');
            set(self.TopAxes,'Tag','ambgSurface');
            ch=colorbar('peer',self.TopAxes);
            setappdata(ch,'zoomable','off');
            if strcmp(de_units,'u')
                de_units='\mu';
            end
            xlabel(self.TopAxes,getString(message('phased:apps:waveformapp:surfaceXLabel',de_units)));
            ylabel(self.TopAxes,{getString(message('phased:apps:waveformapp:surfaceYLabel'));...
            ['(',do_units,'Hz)']});
            zlabel(self.TopAxes,getString(message('phased:apps:waveformapp:surfaceZLabel')));
            title(self.TopAxes,getString(message('phased:apps:waveformapp:surfaceTitle')));
            axis(self.TopAxes,'vis3d');
            h=rotate3d(self.TopAxes);
            h.Enable='on';
            if self.View.Toolstrip.IsAppContainer
                axtoolbar(self.Figure.CurrentAxes,{'export','rotate','datacursor',...
                'pan','zoomin','zoomout','restoreview'});
            end
        end
        function genCode(self,strWriter)

            zlimAFS=get(self.TopAxes,'ZLim');
            zlabelAFS=get(get(self.TopAxes,'Zlabel'),'String');
            self.axesHelper(self.TopAxes)
            addcr(strWriter,['[m, de, do] = ambgfun(x,Fs,prf);'...
            ,newline,'[~, de_scale, de_units] = engunits(max(de));'...
            ,newline,'[~, do_scale, do_units] = engunits(max(do));'...
            ,newline,'mesh(de*de_scale, do*do_scale, m);',newline,'colorbar;'...
            ,newline,'axis([',num2str(self.xlimTopAxes(1)),'  ',num2str(self.xlimTopAxes(2)),' ',num2str(self.ylimTopAxes(1)),' ',num2str(self.ylimTopAxes(2)),' ',num2str(zlimAFS(1)),' ',num2str(zlimAFS(2)),']);'...
            ,newline,'xlabel(''',self.xlabelTopAxes,''');'...
            ,newline,'ylabel(',sprintf('{''%s'';''%s''}',self.ylabelTopAxes{1},self.ylabelTopAxes{2}),');'...
            ,newline,'zlabel(''',zlabelAFS,''');'...
            ,newline,'title(''',self.titleTopAxes,''');',newline]);
        end
    end
end