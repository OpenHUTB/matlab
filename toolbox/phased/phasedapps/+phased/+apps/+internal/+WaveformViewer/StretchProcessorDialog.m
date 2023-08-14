classdef StretchProcessorDialog<handle


    properties
Parent
Panel
Layout
        Width=0
        Height=0
Listeners
    end
    properties(Dependent)
ProcessType
ReferenceRange
RangeSpan
RangeFFTLength
RangeWindow
SideLobeAttenuation
Beta
Nbar
    end
    properties
ProcessTypeLabel
ProcessTypeEdit
Title
ReferenceRangeLabel
ReferenceRangeEdit
RangeSpanLabel
RangeSpanEdit
RangeFFTLengthLabel
RangeFFTLengthEdit
SideLobeAttenuationLabel
SideLobeAttenuationEdit
RangeWindowLabel
RangeWindowEdit
BetaLabel
BetaEdit
NbarLabel
NbarEdit
AddButton
DeleteButton
    end
    methods
        function self=StretchProcessorDialog(parent)
            if nargin==0
                parent=figure;
            end
            self.Parent=parent;
            createUIControls(self)
            layoutUIControls(self)
        end
    end
    methods
        function val=get.ProcessType(self)
            if self.Parent.View.Parameters.ElementDialog.WaveformEdit.Value~=1
                val=self.ProcessTypeEdit.String;
            else
                val=self.ProcessTypeEdit.String{self.ProcessTypeEdit.Value};
            end
        end
        function set.ProcessType(self,val)
            if self.Parent.View.Parameters.ElementDialog.WaveformEdit.Value~=1
                self.ProcessTypeEdit.String=val;
            else
                self.ProcessTypeEdit.Value=2;
            end
        end
        function val=get.ReferenceRange(self)
            if~isempty(self.ReferenceRangeEdit.String)
                try
                    val=evalin('base',self.ReferenceRangeEdit.String);
                catch
                    val=self.ReferenceRangeEdit.String;
                end
            else
                val=str2num(self.ReferenceRangeEdit.String);
            end
            if isempty(val)&&~isempty(self.ReferenceRangeEdit.String)
                val='';
            end
        end
        function set.ReferenceRange(self,val)
            self.ReferenceRangeEdit.String=num2str(val);
        end
        function val=get.RangeSpan(self)
            if~isempty(self.RangeSpanEdit.String)
                try
                    val=evalin('base',self.RangeSpanEdit.String);
                catch
                    val=self.RangeSpanEdit.String;
                end
            else
                val=str2num(self.RangeSpanEdit.String);
            end
            if isempty(val)&&~isempty(self.RangeSpanEdit.String)
                val='';
            end
        end
        function set.RangeSpan(self,val)
            self.RangeSpanEdit.String=num2str(val);
        end
        function val=get.RangeFFTLength(self)
            if~isempty(self.RangeFFTLengthEdit.String)
                try
                    val=evalin('base',self.RangeFFTLengthEdit.String);
                catch
                    val=self.RangeFFTLengthEdit.String;
                end
            else
                val=str2num(self.RangeFFTLengthEdit.String);
            end
            if isempty(val)&&~isempty(self.RangeFFTLengthEdit.String)
                val='';
            end
        end
        function val=get.SideLobeAttenuation(self)
            if~isempty(self.SideLobeAttenuationEdit.String)
                try
                    val=evalin('base',self.SideLobeAttenuationEdit.String);
                catch
                    val=self.SideLobeAttenuationEdit.String;
                end
            else
                val=str2num(self.SideLobeAttenuationEdit.String);
            end
            if isempty(val)&&~isempty(self.SideLobeAttenuationEdit.String)
                val='';
            end
        end
        function set.SideLobeAttenuation(self,val)
            self.SideLobeAttenuationEdit.String=num2str(val);
        end
        function val=get.Beta(self)
            if~isempty(self.BetaEdit.String)
                try
                    val=evalin('base',self.BetaEdit.String);
                catch
                    val=self.BetaEdit.String;
                end
            else
                val=str2num(self.BetaEdit.String);
            end
            if isempty(val)&&~isempty(self.BetaEdit.String)
                val='';
            end
        end
        function set.Beta(self,val)
            self.BetaEdit.String=num2str(val);
        end
        function val=get.Nbar(self)
            if~isempty(self.NbarEdit.String)
                try
                    val=evalin('base',self.NbarEdit.String);
                catch
                    val=self.NbarEdit.String;
                end
            else
                val=str2num(self.NbarEdit.String);
            end
            if isempty(val)&&~isempty(self.NbarEdit.String)
                val='';
            end
        end
        function set.Nbar(self,val)
            self.NbarEdit.String=num2str(val);
        end
        function set.RangeFFTLength(self,val)
            self.RangeFFTLengthEdit.String=num2str(val);
        end
        function val=get.RangeWindow(self)
            val=self.RangeWindowEdit.String{self.RangeWindowEdit.Value};
        end
        function set.RangeWindow(self,val)
            if strcmp(val,'None')
                self.RangeWindowEdit.Value=1;
            elseif strcmp(val,'Hamming')
                self.RangeWindowEdit.Value=2;
            elseif strcmp(val,'Chebyshev')
                self.RangeWindowEdit.Value=3;
            elseif strcmp(val,'Hann')
                self.RangeWindowEdit.Value=4;
            elseif strcmp(val,'Kaiser')
                self.RangeWindowEdit.Value=5;
            elseif strcmp(val,'Taylor')
                self.RangeWindowEdit.Value=6;
            end
        end
    end
    methods(Access=private)
        function createUIControls(self)

            if~self.Parent.View.Toolstrip.IsAppContainer
                self.Panel=uipanel(...
                'Parent',self.Parent.View.ParametersFig,...
                'Title','',...
                'BorderType','line',...
                'HighlightColor',[.5,.5,.5],...
                'AutoResizeChildren','off',...
                'Visible','on');
            else
                self.Panel=uipanel(...
                'Parent',self.Parent.View.ParametersFig,...
                'Title','',...
                'BorderType','line',...
                'AutoResizeChildren','off',...
                'Visible','on');
            end
            self.ProcessTypeLabel=uicontrol(...
            'Parent',self.Panel,...
            'Style','text',...
            'FontSize',8,...
            'String',getString(message('phased:apps:waveformapp:ProcessTypeLabel')),...
            'HorizontalAlignment','right');
            self.ProcessTypeEdit=uicontrol(...
            'Parent',self.Panel,...
            'Style','popup',...
            'FontSize',8,...
            'Position',[20,20,40,20],...
            'String',{getString(message('phased:apps:waveformapp:MatchedFilter')),getString(message('phased:apps:waveformapp:StretchProcessor'))},...
            'Value',2,...
            'Tag','ProcessType',...
            'HorizontalAlignment','left',...
            'Callback',@(h,e)processTypeChanged(self));
            self.Parent.View.notify('Componentsadd',phased.apps.internal.WaveformViewer.ComponentsEventData(self.ProcessTypeEdit))
            self.RangeWindowLabel=uicontrol(...
            'Parent',self.Panel,...
            'Style','text',...
            'FontSize',8,...
            'String',getString(message('phased:apps:waveformapp:LabelWithColon','Range Window')),...
            'HorizontalAlignment','right');
            self.RangeWindowEdit=uicontrol(...
            'Parent',self.Panel,...
            'Style','popup',...
            'FontSize',8,...
            'Position',[20,20,40,20],...
            'String',{getString(message('phased:apps:waveformapp:None')),getString(message('phased:apps:waveformapp:Hamming')),getString(message('phased:apps:waveformapp:Chebyshev')),getString(message('phased:apps:waveformapp:Hann')),getString(message('phased:apps:waveformapp:Kaiser')),getString(message('phased:apps:waveformapp:Taylor'))},...
            'Value',1,...
            'Tag','RangeWindow',...
            'HorizontalAlignment','left',...
            'Callback',@(h,e)parameterChanged(self,e));
            self.Parent.View.notify('Componentsadd',phased.apps.internal.WaveformViewer.ComponentsEventData(self.RangeWindowEdit))
            self.RangeSpanLabel=uicontrol(...
            'Parent',self.Panel,...
            'Style','text',...
            'FontSize',8,...
            'String',getString(message('phased:apps:waveformapp:RangeSpanLabel','Range Span')),...
            'HorizontalAlignment','right');
            self.RangeSpanEdit=uicontrol(...
            'Parent',self.Panel,...
            'Style','edit',...
            'FontSize',8,...
            'Position',[20,20,40,20],...
            'String','1',...
            'Tag','RangeSpan',...
            'HorizontalAlignment','left',...
            'Callback',@(h,e)parameterChanged(self,e));
            self.Parent.View.notify('Componentsadd',phased.apps.internal.WaveformViewer.ComponentsEventData(self.RangeSpanEdit))
            self.RangeFFTLengthLabel=uicontrol(...
            'Parent',self.Panel,...
            'Style','text',...
            'FontSize',8,...
            'String',getString(message('phased:apps:waveformapp:LabelWithColon','Range FFT Length')),...
            'HorizontalAlignment','right');
            self.RangeFFTLengthEdit=uicontrol(...
            'Parent',self.Panel,...
            'Style','edit',...
            'String','1',...
            'FontSize',8,...
            'Position',[20,20,40,20],...
            'Tag','RangeFFTLength',...
            'HorizontalAlignment','left',...
            'Callback',@(h,e)parameterChanged(self,e));
            self.Parent.View.notify('Componentsadd',phased.apps.internal.WaveformViewer.ComponentsEventData(self.RangeFFTLengthEdit))
            self.ReferenceRangeLabel=uicontrol(...
            'Parent',self.Panel,...
            'Style','text',...
            'FontSize',8,...
            'String',getString(message('phased:apps:waveformapp:ReferenceRangeLabel','Reference Range')),...
            'HorizontalAlignment','right');
            self.ReferenceRangeEdit=uicontrol(...
            'Parent',self.Panel,...
            'Style','edit',...
            'FontSize',8,...
            'Position',[20,20,40,20],...
            'String','1e8',...
            'Tag','ReferenceRange',...
            'HorizontalAlignment','left',...
            'Callback',@(h,e)parameterChanged(self,e));
            self.Parent.View.notify('Componentsadd',phased.apps.internal.WaveformViewer.ComponentsEventData(self.ReferenceRangeEdit))
            self.SideLobeAttenuationLabel=uicontrol(...
            'Parent',self.Panel,...
            'Style','text',...
            'FontSize',8,...
            'String',getString(message('phased:apps:waveformapp:LabelWithColon','Sidelobe Attenuation')),...
            'HorizontalAlignment','right','Visible','off');
            self.SideLobeAttenuationEdit=uicontrol(...
            'Parent',self.Panel,...
            'Style','edit',...
            'String','30',...
            'FontSize',8,...
            'Position',[20,20,40,20],...
            'Tag','SideLobeAttenuation',...
            'HorizontalAlignment','left','Visible','off',...
            'Callback',@(h,e)parameterChanged(self,e));
            self.Parent.View.notify('Componentsadd',phased.apps.internal.WaveformViewer.ComponentsEventData(self.SideLobeAttenuationEdit))
            self.BetaLabel=uicontrol(...
            'Parent',self.Panel,...
            'Style','text',...
            'FontSize',8,...
            'String',getString(message('phased:apps:waveformapp:LabelWithColon','Beta')),...
            'Visible','off',...
            'HorizontalAlignment','right','Visible','off');
            self.BetaEdit=uicontrol(...
            'Parent',self.Panel,...
            'Style','edit',...
            'String','0.5',...
            'FontSize',8,...
            'Visible','off',...
            'Position',[20,20,40,20],...
            'Tag','Beta',...
            'HorizontalAlignment','left',...
            'Visible','off',...
            'Callback',@(h,e)parameterChanged(self,e));
            self.Parent.View.notify('Componentsadd',phased.apps.internal.WaveformViewer.ComponentsEventData(self.BetaEdit))
            self.NbarLabel=uicontrol(...
            'Parent',self.Panel,...
            'Style','text',...
            'FontSize',8,...
            'String',getString(message('phased:apps:waveformapp:LabelWithColon','Nbar')),...
            'HorizontalAlignment','right','Visible','off');
            self.NbarEdit=uicontrol(...
            'Parent',self.Panel,...
            'Style','edit',...
            'String','4',...
            'FontSize',8,...
            'Position',[20,20,40,20],...
            'Tag','Nbar',...
            'HorizontalAlignment','left',...
            'Visible','off',...
            'Callback',@(h,e)parameterChanged(self,e));
            self.Parent.View.notify('Componentsadd',phased.apps.internal.WaveformViewer.ComponentsEventData(self.NbarEdit))
        end

        function layoutUIControls(self)
            hspacing=0;
            vspacing=1;

            self.Layout=...
            matlabshared.application.layout.GridBagLayout(...
            self.Panel,...
            'VerticalGap',vspacing,...
            'HorizontalGap',hspacing,...
            'VerticalWeights',[0,0,0,0,0,0,0,0,1],...
            'HorizontalWeights',[0,1,0]);
            if isunix
                w1=140;
            else
                w1=130;
            end
            w2=75;
            rowParam=1;
            height=24;
            self.Parent.addText(self.Layout,self.ProcessTypeLabel,rowParam,1,w1,height)
            self.Parent.addPopup(self.Layout,self.ProcessTypeEdit,rowParam,2:3,w2,height)
            rowParam=rowParam+1;
            self.Parent.addText(self.Layout,self.ReferenceRangeLabel,rowParam,1,w1,height)
            self.Parent.addEdit(self.Layout,self.ReferenceRangeEdit,rowParam,2:3,w2,height)

            rowParam=rowParam+1;
            self.Parent.addText(self.Layout,self.RangeSpanLabel,rowParam,1,w1,height)
            self.Parent.addEdit(self.Layout,self.RangeSpanEdit,rowParam,2:3,w2,height)
            rowParam=rowParam+1;

            self.Parent.addText(self.Layout,self.RangeFFTLengthLabel,rowParam,1,w1,height)
            self.Parent.addEdit(self.Layout,self.RangeFFTLengthEdit,rowParam,2:3,w2,height)
            rowParam=rowParam+1;

            self.Parent.addText(self.Layout,self.RangeWindowLabel,rowParam,1,w1,height)
            self.Parent.addEdit(self.Layout,self.RangeWindowEdit,rowParam,2:3,w2,height)
            if(self.RangeWindowEdit.Value==6)
                rowParam=rowParam+1;
                self.Parent.addText(self.Layout,self.SideLobeAttenuationLabel,rowParam,1,w1,height)
                self.Parent.addEdit(self.Layout,self.SideLobeAttenuationEdit,rowParam,2:3,w2,height)
                rowParam=rowParam+1;

                self.Parent.addText(self.Layout,self.NbarLabel,rowParam,1,w1,height)
                self.Parent.addEdit(self.Layout,self.NbarEdit,rowParam,2:3,w2,height)
            elseif(self.RangeWindowEdit.Value==3)
                rowParam=rowParam+1;
                self.Parent.addText(self.Layout,self.SideLobeAttenuationLabel,rowParam,1,w1,height)
                self.Parent.addEdit(self.Layout,self.SideLobeAttenuationEdit,rowParam,2:3,w2,height)
            elseif(self.RangeWindowEdit.Value==5)
                rowParam=rowParam+1;
                self.Parent.addText(self.Layout,self.BetaLabel,rowParam,1,w1,height)
                self.Parent.addEdit(self.Layout,self.BetaEdit,rowParam,2:3,w2,height)
            end
            [~,~,w,height]=getMinimumSize(self.Layout);
            self.Width=sum(w)+self.Layout.HorizontalGap*(numel(w)+1);
            self.Height=max(height(2:end))*numel(height(2:end))+...
            self.Layout.VerticalGap*(numel(height(2:end))+10);
            add(self.Parent.Layout,self.Panel,3,1,...
            'MinimumWidth',self.Width,...
            'Fill','Horizontal',...
            'MinimumHeight',self.Height,...
            'Anchor','North');
        end
        function processTypeChanged(self)

            self.Parent.ProcessTypeChanged=1;
            idx=self.ProcessTypeEdit.Value;
            if(strcmp(self.Parent.ElementDialog.Waveform,getString(message('phased:apps:waveformapp:LinearFM')))||strcmp(self.Parent.ElementDialog.Waveform,getString(message('phased:apps:waveformapp:FMCW'))))
                value=self.ProcessTypeEdit.String{self.ProcessTypeEdit.Value};
            else
                value=self.ProcessTypeEdit.String;
            end
            self.Parent.notify('SystemCompressionView',phased.apps.internal.WaveformViewer.ProcessTypeEventData(idx,value))
            idx=self.Parent.View.Canvas.WaveformList.getSelectedRows();
            self.Parent.notify('CompressParameterChanged',phased.apps.internal.WaveformViewer.CompressParameterChangedEventData(idx))
            self.Parent.View.Parameters.ApplyButton.ApplyButton.Enable='on';
        end
        function parameterChanged(self,e)

            self.Parent.View.Parameters.ApplyButton.ApplyButton.Enable='on';
            self.Parent.View.Canvas.AutoSelect=false;
            idx=self.Parent.View.Canvas.SelectIdx;
            name=e.Source.Tag;
            value=self.(name);
            if numel(self.Parent.View.Canvas.WaveformList.getSelectedRows())>1
                self.Parent.notify('MultiSelectCompressParameterView',phased.apps.internal.WaveformViewer.MultiSelectElementParameterChangedEventData(self.Parent.View,name,value))
            else
                self.Parent.notify('CompressParameterView',phased.apps.internal.WaveformViewer.CompressParameterChangedEventData(idx,name,value))
            end
            remove(self.Layout,2,1);
            if strcmp(name,'RangeWindow')
                layoutUIControls(self);
                self.Beta=0.5;
                self.Nbar=4;
                self.SideLobeAttenuation=30;
                if strcmp(self.RangeWindow,getString(message('phased:apps:waveformapp:Taylor')))
                    self.BetaLabel.Visible='off';
                    self.BetaEdit.Visible='off';
                    self.NbarLabel.Visible='on';
                    self.NbarEdit.Visible='on';
                    self.SideLobeAttenuationLabel.Visible='on';
                    self.SideLobeAttenuationEdit.Visible='on';
                elseif strcmp(self.RangeWindow,getString(message('phased:apps:waveformapp:Chebyshev')))
                    self.SideLobeAttenuationLabel.Visible='on';
                    self.SideLobeAttenuationEdit.Visible='on';
                    self.BetaLabel.Visible='off';
                    self.BetaEdit.Visible='off';
                    self.NbarLabel.Visible='off';
                    self.NbarEdit.Visible='off';
                elseif strcmp(self.RangeWindow,getString(message('phased:apps:waveformapp:Kaiser')))
                    self.SideLobeAttenuationLabel.Visible='off';
                    self.SideLobeAttenuationEdit.Visible='off';
                    self.NbarLabel.Visible='off';
                    self.NbarEdit.Visible='off';
                    self.BetaLabel.Visible='on';
                    self.BetaEdit.Visible='on';
                else
                    self.BetaLabel.Visible='off';
                    self.BetaEdit.Visible='off';
                    self.NbarLabel.Visible='off';
                    self.NbarEdit.Visible='off';
                    self.SideLobeAttenuationLabel.Visible='off';
                    self.SideLobeAttenuationEdit.Visible='off';
                end
            end
            self.Parent.View.Canvas.AutoSelect=true;
        end
    end
end