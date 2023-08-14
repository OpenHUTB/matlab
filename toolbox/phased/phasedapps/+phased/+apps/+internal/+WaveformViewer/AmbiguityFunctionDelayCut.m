classdef AmbiguityFunctionDelayCut<phased.apps.internal.WaveformViewer.PlotData



    properties
View
Figure
Panel
TopAxes
AttributesPanel
CutValueLabel
CutValueEdit
CutValueUnits
Layout
        CutPre='0'
StringLegend
    end
    methods
        function self=AmbiguityFunctionDelayCut(parent)
            self.View=parent;
            self.Figure=self.View.AmbiguityFunctionDelayCutFig;

            if~self.View.Toolstrip.IsAppContainer
                if isunix
                    self.AttributesPanel=uipanel('Parent',self.Figure,...
                    'Title','','FontSize',8,...
                    'BorderType','none',...
                    'HighlightColor',[.5,.5,.5],...
                    'Visible','on');
                else
                    self.AttributesPanel=uipanel('Parent',self.Figure,...
                    'Title','',...
                    'BorderType','none',...
                    'HighlightColor',[.5,.5,.5],...
                    'Visible','on');
                end
                self.CutValueLabel=uicontrol(...
                'Parent',self.AttributesPanel,...
                'Style','text','FontSize',8,...
                'String',getString(message('phased:apps:waveformapp:CutValue')),...
                'HorizontalAlignment','right');
                self.CutValueEdit=uicontrol(...
                'Parent',self.AttributesPanel,...
                'Style','edit',...
                'String','0',...
                'Tag','DelayCutValueTag',...
                'HorizontalAlignment','left');

                addlistener(self.CutValueEdit,'String',...
                'PostSet',@(h,e)addplotAction(self.View,'ambiguity function-delay cut'));
                self.CutValueUnits=uicontrol(...
                'Parent',self.AttributesPanel,...
                'Style','text',...
                'String','us',...
                'HorizontalAlignment','left');
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
                    'HorizontalWeights',[0.2,0,0,1]);
                    height=24;
                    self.View.Parameters.addText(self.Layout,self.CutValueLabel,1,1,70,height)
                else
                    self.Layout=...
                    matlabshared.application.layout.ScrollableGridBagLayout(...
                    self.AttributesPanel,...
                    'VerticalGap',vspacing,...
                    'HorizontalGap',hspacing,...
                    'VerticalWeights',1,...
                    'HorizontalWeights',[0,0,0,1]);
                    height=24;
                    self.View.Parameters.addText(self.Layout,self.CutValueLabel,1,1,60,height)
                end
                self.View.Parameters.addEdit(self.Layout,self.CutValueEdit,1,2,60,height)
                self.View.Parameters.addText(self.Layout,self.CutValueUnits,1,3,30,height)
                self.View.Parameters.addText(self.Layout,Duplicate,1,4,30,height)

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
                self.Layout.RowHeight={'9x',40};
                self.Layout.ColumnWidth={'1x'};


                self.Panel=uipanel(self.Layout);
                self.Panel.Layout.Row=1;
                self.Panel.Layout.Column=1;


                self.AttributesPanel=uipanel(self.Layout);
                self.AttributesPanel.Layout.Row=2;
                self.AttributesPanel.Layout.Column=1;


                self.CutValueLabel=uilabel(self.AttributesPanel);
                self.CutValueLabel.HorizontalAlignment='right';
                self.CutValueLabel.Position=[33,9,70,22];
                self.CutValueLabel.Text=getString(message('phased:apps:waveformapp:CutValue'));


                self.CutValueEdit=uieditfield(self.AttributesPanel,'text');
                self.CutValueEdit.Position=[112,9,58,22];
                self.CutValueEdit.Value='0';
                self.CutValueEdit.Tag='DelayCutValueTag';
                self.CutValueEdit.HorizontalAlignment='left';
                self.CutValueEdit.ValueChangedFcn=@(h,e)addplotAction(self.View,'ambiguity function-delay cut');

                self.CutValueUnits=uilabel(self.AttributesPanel);
                self.CutValueUnits.Position=[184,9,25,22];
                self.CutValueUnits.Text='us';
                self.CutValueUnits.HorizontalAlignment='left';

                self.TopAxes=axes('Parent',self.Panel);
            end
        end
        function delayCutPlot(self,data)

            self.Figure.HandleVisibility='on';
            self.updatePlot(data)
            self.CutValueEdit.Enable='on';
            k=numel(self.View.Canvas.WaveformList.getSelectedRows);
            if k==1
                self.View.Toolstrip.WaveformScriptPopup.Enabled=true;
            end
            if isa(self.Waveform,'phased.FMCWWaveform')
                PRF=1/self.Waveform.SweepTime;
            else
                PRF=self.Waveform.PRF;
            end
            if~self.View.Toolstrip.IsAppContainer
                try
                    cutValues=evalin('base',self.CutValueEdit.String);
                    self.CutValueEdit.String=mat2str(cutValues);
                    if isempty(cutValues)&&~isempty(self.CutValueEdit.String)
                        cutValues='';
                    end

                    validateattributes(cutValues,{'double'},...
                    {'nonempty','real','finite'},'',getString(message('phased:apps:waveformapp:errorCutValue')))
                catch me
                    figure(self.Figure);
                    throwError(self.View,getString(message('phased:apps:waveformapp:errorCutValueTitle')),me);
                    self.CutValueEdit.String=self.CutPre;
                    self.StringLegend={};
                    cutValues=str2num(self.CutValueEdit.String);%#ok<ST2NM>
                end
            else
                try
                    cutValues=evalin('base',self.CutValueEdit.Value);
                    self.CutValueEdit.Value=mat2str(cutValues);
                    if isempty(cutValues)&&~isempty(self.CutValueEdit.Value)
                        cutValues='';
                    end

                    validateattributes(cutValues,{'double'},...
                    {'nonempty','real','finite'},'',getString(message('phased:apps:waveformapp:errorCutValue')))
                catch me
                    throwError(self.View,getString(message('phased:apps:waveformapp:errorCutValueTitle')),me);
                    self.CutValueEdit.Value=self.CutPre;
                    self.StringLegend={};
                    cutValues=str2num(self.CutValueEdit.Value);%#ok<ST2NM>
                end
            end
            numCutVal=length(cutValues);
            rootFigure=groot;
            rootFigure.CurrentFigure=self.Figure;
            for i=1:numCutVal
                cutvalue=cutValues(i);
                xlen=numel(self.Wav(:));
                k=((xlen-1)*1e6)/self.SampleRate;
                if(cutvalue>k||cutvalue<-k)
                    try
                        ambgfun(self.Wav,self.SampleRate,PRF,'Cut','Delay','CutValue',cutvalue*1e-6);
                    catch
                        figure(self.Figure);
                        if~self.View.Toolstrip.IsAppContainer
                            dlg=errordlg(getString(message('phased:apps:waveformapp:CutValueRangeDelay',sprintf('%0.2f',k),sprintf('%0.2f',-k))),getString(message('phased:apps:waveformapp:errorCutValueTitle')),'modal');
                            uiwait(dlg);
                            self.CutValueEdit.String=self.CutPre;
                            cutValues=str2num(self.CutValueEdit.String);%#ok<ST2NM>
                        else
                            uialert(self.View.Toolstrip.AppContainer,getString(message('phased:apps:waveformapp:CutValueRangeDelay',sprintf('%0.2f',k),sprintf('%0.2f',-k))),getString(message('phased:apps:waveformapp:errorCutValueTitle')));
                            self.CutValueEdit.Value=self.CutPre;
                            cutValues=str2num(self.CutValueEdit.Value);%#ok<ST2NM>
                        end
                        numCutVal=length(cutValues);
                        self.StringLegend={};
                    end
                    break;
                end
            end
            for i=1:numCutVal


                cutVal=cutValues(i);
                idx=self.View.Canvas.WaveformList.getSelectedRows;
                k=numel(self.View.Canvas.WaveformList.getSelectedRows);
                if(k>1&&data.Index~=idx(1))
                    hold(self.TopAxes,'on');
                end
                ambgfun(self.Wav,self.SampleRate,PRF,'Cut','Delay','CutValue',cutVal*1e-6);
                set(self.TopAxes,'Tag','ambgDelCut');
                if self.View.Toolstrip.IsAppContainer
                    self.CutPre=self.CutValueEdit.Value;
                else
                    self.CutPre=self.CutValueEdit.String;
                end
                wavename=self.View.Canvas.WaveformList.Data{data.Index};
                if(k>1&&data.Index==idx(1)&&i==1)
                    self.StringLegend={};
                    self.StringLegend{end+1}=strcat(wavename,' (',num2str(cutVal),getString(message('phased:apps:waveformapp:usec')),')');
                elseif(k>1&&i~=1)
                    self.StringLegend{end+1}=strcat(wavename,' (',num2str(cutVal),getString(message('phased:apps:waveformapp:usec')),')');
                    legend(self.TopAxes,self.StringLegend,'Interpreter','none');
                elseif(k==1&&i==1)
                    self.StringLegend={};

                    self.StringLegend{end+1}=strcat(wavename,' (',num2str(cutVal),getString(message('phased:apps:waveformapp:usec')),')');
                    legend(self.TopAxes,self.StringLegend,'Interpreter','none');
                elseif(k==1&&i~=1)
                    self.StringLegend{end+1}=strcat(wavename,' (',num2str(cutVal),getString(message('phased:apps:waveformapp:usec')),')');
                    legend(self.TopAxes,self.StringLegend,'Interpreter','none');
                else
                    self.StringLegend{end+1}=strcat(wavename,' (',num2str(cutVal),getString(message('phased:apps:waveformapp:usec')),')');
                    legend(self.TopAxes,self.StringLegend,'Interpreter','none');
                end
                hold(self.TopAxes,'on');
            end
            ylabel(self.TopAxes,getString(message('phased:apps:waveformapp:surfaceZLabel')));
            title(self.TopAxes,getString(message('phased:apps:waveformapp:DelayCutTitle')));
            grid(self.TopAxes,'on');
            hold(self.TopAxes,'off');
            self.Figure.HandleVisibility='off';
            if self.View.Toolstrip.IsAppContainer
                axtoolbar(self.Figure.CurrentAxes,{'export','rotate','datacursor',...
                'pan','zoomin','zoomout','restoreview'});
            end
        end
        function genCode(self,strWriter)

            self.axesHelper(self.TopAxes)
            if self.View.Toolstrip.IsAppContainer
                cutValue=self.CutValueEdit.Value;
            else
                cutValue=self.CutValueEdit.String;
            end
            val=str2num(cutValue);%#ok<ST2NM> 
            if length(val)>1

                addcr(strWriter,['val = ',mat2str(val),';'...
                ,newline,'legend_str = cell(1,length(val));'...
                ,newline,'for i = 1:length(val)'...
                ,newline,'ambgfun(x,Fs,prf,''Cut'',''Delay'',''CutValue'', val(i)*1e-6);'...
                ,newline,'hold all;'...
                ,newline,'legend_str{i} = [num2str(val(i)) ''',getString(message('phased:apps:waveformapp:usec')),'''];'...
                ,newline,'end'...
                ,newline,'legend(legend_str);']);

            else

                addcr(strWriter,['val = ',mat2str(val),';'...
                ,newline,'ambgfun(x,Fs,prf,''Cut'',''Delay'',''CutValue'', val*1e-6);']);
                leg=strcat(cutValue,getString(message('phased:apps:waveformapp:usec')));
                addcr(strWriter,['legend(''',leg,''');']);
            end

            addcr(strWriter,['axis([',num2str(self.xlimTopAxes(1)),' ',num2str(self.xlimTopAxes(2)),' ',num2str(self.ylimTopAxes(1)),' ',num2str(self.ylimTopAxes(2)),']);'...
            ,newline,'xlabel(''',self.xlabelTopAxes,''');'...
            ,newline,'ylabel(''',self.ylabelTopAxes,''');'...
            ,newline,'title(''',self.titleTopAxes,''');',newline]);
        end
    end
end