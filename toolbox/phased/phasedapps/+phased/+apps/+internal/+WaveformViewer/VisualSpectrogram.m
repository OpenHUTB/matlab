classdef VisualSpectrogram<phased.apps.internal.WaveformViewer.PlotData



    properties
View
Figure
Panel
TopAxes
AttributesPanel
hThresholdtxt
hThresholdedt
hThresholdunit
hReassignedtxt
hReassignededt
Layout
        thresholdpre='-100';
    end
    methods
        function self=VisualSpectrogram(parent)
            self.View=parent;
            self.Figure=self.View.SpectrogramFig;

            if~self.View.Toolstrip.IsAppContainer
                self.AttributesPanel=uipanel('Parent',self.Figure,...
                'Title','',...
                'BorderType','none',...
                'HighlightColor',[.5,.5,.5],...
                'Visible','on');

                if isunix
                    self.hThresholdtxt=uicontrol('Parent',self.AttributesPanel,...
                    'Style','text',...
                    'String',getString(message('phased:apps:waveformapp:Threshold')),...
                    'Visible','on',...
                    'HorizontalAlignment','left',...
                    'Tag','thresholdtxt','FontSize',8,'Position',[20,20,100,20]);
                else
                    self.hThresholdtxt=uicontrol('Parent',self.AttributesPanel,...
                    'Style','text',...
                    'String',getString(message('phased:apps:waveformapp:Threshold')),...
                    'Visible','on',...
                    'HorizontalAlignment','right',...
                    'Tag','thresholdtxt');
                end

                self.hThresholdedt=uicontrol('Parent',self.AttributesPanel,...
                'Style','edit',...
                'String',-100,...
                'Visible','on',...
                'HorizontalAlignment','left',...
                'Tag','Threshold');
                addlistener(self.hThresholdedt,'String','PostSet',...
                @(h,e)thresholdCallback(self.View,'spectrogram'));
                self.hThresholdunit=uicontrol('Parent',self.AttributesPanel,...
                'Style','text',...
                'String','dB',...
                'Visible','on',...
                'HorizontalAlignment','left',...
                'Tag','thresholdunit');
                if isunix
                    self.hReassignededt=uicontrol('Parent',self.AttributesPanel,...
                    'Style','checkbox',...
                    'String',getString(message('phased:apps:waveformapp:Reassigned')),...
                    'Value',1,...
                    'Visible','on',...
                    'HorizontalAlignment','left',...
                    'Tag','Reassigned','FontSize',8,'Position',[20,20,90,20]);
                else
                    self.hReassignededt=uicontrol('Parent',self.AttributesPanel,...
                    'Style','checkbox',...
                    'String',getString(message('phased:apps:waveformapp:Reassigned')),...
                    'Value',1,...
                    'Visible','on',...
                    'HorizontalAlignment','left',...
                    'Tag','Reassigned');
                end
                addlistener(self.hReassignededt,'Value','PostSet',...
                @(h,e)addplotAction(self.View,'spectrogram'));
                Duplicate=uicontrol('Parent',self.AttributesPanel,...
                'String','text',...
                'String','',...
                'Visible','off',...
                'HorizontalAlignment','left',...
                'Tag','Duplicate');
                hspacing=3;
                vspacing=4;
                if isunix
                    self.Layout=...
                    matlabshared.application.layout.ScrollableGridBagLayout(...
                    self.AttributesPanel,...
                    'VerticalGap',vspacing,...
                    'HorizontalGap',hspacing,...
                    'VerticalWeights',1,...
                    'HorizontalWeights',[0.5,0.5,0,0,1]);
                    height=24;
                    self.View.Parameters.addText(self.Layout,self.hThresholdtxt,1,2,70,height)
                else
                    self.Layout=...
                    matlabshared.application.layout.ScrollableGridBagLayout(...
                    self.AttributesPanel,...
                    'VerticalGap',vspacing,...
                    'HorizontalGap',hspacing,...
                    'VerticalWeights',1,...
                    'HorizontalWeights',[0,0,0,0,1]);
                    height=24;
                    self.View.Parameters.addText(self.Layout,self.hThresholdtxt,1,2,60,height)
                end
                self.View.Parameters.addEdit(self.Layout,self.hReassignededt,1,1,90,height)
                self.View.Parameters.addEdit(self.Layout,self.hThresholdedt,1,3,60,height)
                self.View.Parameters.addText(self.Layout,self.hThresholdunit,1,4,30,height)
                self.View.Parameters.addText(self.Layout,Duplicate,1,5,30,height)

                self.Layout=...
                matlabshared.application.layout.ScrollableGridBagLayout(...
                self.Figure,...
                'VerticalGap',8,...
                'HorizontalGap',6,...
                'VerticalWeights',[1,0],...
                'HorizontalWeights',1);
                self.Panel=uipanel(...
                'Parent',self.Figure,...
                'Title','',...
                'BorderType','none',...
                'Visible','on');
                self.TopAxes=axes('Parent',self.Panel);
                add(self.Layout,self.Panel,1,1,...
                'Fill','Both',...
                'Anchor','North')
                drawnow;
                add(self.Layout,self.AttributesPanel,2,1,...
                'Fill','Horizontal',...
                'MinimumHeight',30,...
                'Anchor','North')
            else
                self.Layout=uigridlayout(self.Figure);
                self.Layout.RowHeight={'6x',40};
                self.Layout.ColumnWidth={'1x'};


                self.Panel=uipanel(self.Layout);
                self.Panel.Layout.Row=1;
                self.Panel.Layout.Column=1;


                self.AttributesPanel=uipanel(self.Layout);
                self.AttributesPanel.Layout.Row=2;
                self.AttributesPanel.Layout.Column=1;


                self.hReassignededt=uicheckbox(self.AttributesPanel);
                self.hReassignededt.Text=getString(message('phased:apps:waveformapp:Reassigned'));
                self.hReassignededt.Position=[13,9,85,22];
                self.hReassignededt.Value=true;
                self.hReassignededt.ValueChangedFcn=@(h,e)addplotAction(self.View,'spectrogram');


                self.hThresholdtxt=uilabel(self.AttributesPanel);
                self.hThresholdtxt.HorizontalAlignment='right';
                self.hThresholdtxt.Position=[123,9,59,22];
                self.hThresholdtxt.Text=getString(message('phased:apps:waveformapp:Threshold'));


                self.hThresholdedt=uieditfield(self.AttributesPanel,'text');
                self.hThresholdedt.Position=[197,9,100,22];
                self.hThresholdedt.Value='-100';
                self.hThresholdedt.ValueChangedFcn=@(h,e)thresholdCallback(self.View,'spectrogram');
                self.TopAxes=axes('Parent',self.Panel);
            end
        end
        function spectrogramPlot(self,data)

            self.updatePlot(data)
            if self.hReassignededt.Value==1
                reassignedFlag={'reassigned'};
                win=kaiser(floor(length(self.Wav)/16),38);
            else
                reassignedFlag={};
                win=floor(length(self.Wav)/16);
            end
            if~self.View.Toolstrip.IsAppContainer
                if isempty(self.hThresholdedt.String)
                    self.hThresholdedt.String='-100';
                end
            else
                if isempty(self.hThresholdedt.Value)
                    self.hThresholdedt.Value='-100';
                end
            end
            try
                if~self.View.Toolstrip.IsAppContainer
                    Threshold=evalin('base',self.hThresholdedt.String);
                    self.hThresholdedt.String=Threshold;
                else
                    Threshold=evalin('base',self.hThresholdedt.Value);
                end
                if isreal(self.Wav)
                    fin=self.SampleRate*(-1/2:1/256:127/256);
                    [~,f,t,c]=spectrogram(self.Wav,win,floor(length(self.Wav)/17),fin,self.SampleRate,'yaxis','MinThreshold',Threshold,reassignedFlag{:});
                else
                    [~,f,t,c]=spectrogram(self.Wav,win,floor(length(self.Wav)/17),256,self.SampleRate,'yaxis','MinThreshold',Threshold,reassignedFlag{:});
                end
            catch me
                figure(self.Figure);
                self.View.Toolstrip.WaveformScriptPopup.Enabled=false;
                throwError(self.View,getString(message('MATLAB:uistring:popupdialogs:ErrorDialogTitle')),me);
                return
            end
            self.View.Toolstrip.WaveformScriptPopup.Enabled=true;
            self.hThresholdedt.Enable='on';
            self.hReassignededt.Enable='on';
            [~,bx,cx]=engunits(max(t));
            [~,by,cy]=engunits(max(f));
            xa=t*bx;
            c(c<eps)=eps;
            if isreal(self.Wav)
                ya=f*by;
                surf(self.TopAxes,xa,ya,(10*log10(abs(c))),'EdgeColor','none');
            else
                ya=(f-self.SampleRate/2)*by;
                surf(self.TopAxes,xa,ya,fftshift(10*log10(abs(c)),1),'EdgeColor','none');
            end
            set(self.TopAxes,'Tag','Spectrogram');
            SpectrogramLine=get(self.TopAxes,'Children');
            set(SpectrogramLine,'Tag','SpectromgramLine');
            axis(self.TopAxes,'xy');
            view(self.TopAxes,2);
            if strcmp(cx,'u')
                cx='\mu';
            end
            xlabel(self.TopAxes,getString(message('phased:apps:waveformapp:RealPlotXLabel',cx)));
            ylabel(self.TopAxes,getString(message('phased:apps:waveformapp:SpectrumPlotXLabel',cy)));
            title(self.TopAxes,getString(message('phased:apps:waveformapp:SpectrogramPlotTitle')));
            ch=colorbar('peer',self.TopAxes);
            ylabel(ch,'dB');
            axis(self.TopAxes,[xa(1),xa(end),ya(1),ya(end)]);
            setappdata(ch,'zoomable','off');
            if self.View.Toolstrip.IsAppContainer
                axtoolbar(self.Figure.CurrentAxes,{'export','rotate','datacursor',...
                'pan','zoomin','zoomout','restoreview'});
            end
        end
        function genCode(self,strWriter)

            self.axesHelper(self.TopAxes)
            if self.View.Toolstrip.IsAppContainer
                Threshold=str2double(self.hThresholdedt.Value);
            else
                Threshold=str2double(self.hThresholdedt.String);
            end
            if self.hReassignededt.Value==1
                add(strWriter,[newline,'win = kaiser(floor(length(x)/16),38);']);
                reassignedStr=', ''reassigned''';
            else
                add(strWriter,[newline,'win = floor(length(x)/16);']);
                reassignedStr='';
            end

            add(strWriter,[newline,'Threshold = ',num2str(Threshold),';']);
            if isreal(self.Wav)
                addcr(strWriter,[newline,'fin = Fs*(-1/2:1/256:127/256);'...
                ,newline,'[~,f,t,p] = spectrogram(x,win,floor(length(x)/17),fin,Fs,''yaxis'',''MinThreshold'',Threshold',reassignedStr,');'...
                ,newline,'[~, t_scale, t_Units] = engunits(max(t));'...
                ,newline,'[~, f_scale, f_Units] = engunits(max(f));'...
                ,newline,'%set all 0 with next smallest value;'...
                ,newline,'p(p<eps) = eps;']);
                addcr(strWriter,'ya = f*f_scale;')
                addcr(strWriter,'surf(t*t_scale, ya,(10*log10(abs(p))),''EdgeColor'',''none'');');
            else
                addcr(strWriter,[...
                newline,'[~,f,t,p] = spectrogram(x,win,floor(length(x)/17),256,Fs,''yaxis'',''MinThreshold'',Threshold',reassignedStr,');'...
                ,newline,'[~, t_scale, t_Units] = engunits(max(t));'...
                ,newline,'[~, f_scale, f_Units] = engunits(max(f));'...
                ,newline,'%set all 0 with next smallest value;'...
                ,newline,'p(p<eps) = eps;']);
                addcr(strWriter,'ya = (f-Fs/2)*f_scale;');
                addcr(strWriter,'surf(t*t_scale,ya,fftshift(10*log10(abs(p)),1),''EdgeColor'',''none'');')
            end
            addcr(strWriter,'axis([t(1)*t_scale t(end)*t_scale f(1)*f_scale f(end)*f_scale]);');

            addcr(strWriter,['axis([',num2str(self.xlimTopAxes(1)),' ',num2str(self.xlimTopAxes(2)),' ',num2str(self.ylimTopAxes(1)),' ',num2str(self.ylimTopAxes(2)),']);'...
            ,newline,'xlabel(''',self.xlabelTopAxes,''');'...
            ,newline,'ylabel(''',self.ylabelTopAxes,''');'...
            ,newline,'title(''',self.titleTopAxes,''');']);
            addcr(strWriter,['axis xy;'...
            ,newline,'view(2);'...
            ,newline,'ch = colorbar;'...
            ,newline,'ylabel(ch, ''dB'');',newline]);

        end
    end
end