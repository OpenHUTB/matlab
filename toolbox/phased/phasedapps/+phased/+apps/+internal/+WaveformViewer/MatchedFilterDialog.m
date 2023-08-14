classdef MatchedFilterDialog<handle


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
SpectrumWindow
SideLobeAttenuation
SpectrumRange
Beta
Nbar
    end
    properties
Title
ProcessTypeLabel
ProcessTypeEdit
SpectrumWindowLabel
SpectrumWindowEdit
SideLobeAttenuationLabel
SideLobeAttenuationEdit
SpectrumRangeLabel
SpectrumRangeEdit
BetaLabel
BetaEdit
NbarLabel
NbarEdit
AddButton
DeleteButton
    end
    methods
        function self=MatchedFilterDialog(parent)
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
            if(self.Parent.View.Parameters.ElementDialog.WaveformEdit.Value~=1||self.Parent.View.Parameters.ElementDialog.WaveformEdit.Value~=5)
                val=self.ProcessTypeEdit.String;
            else
                val=self.ProcessTypeEdit.String{self.ProcessTypeEdit.Value};
            end
        end
        function set.ProcessType(self,val)
            if(self.Parent.View.Parameters.ElementDialog.WaveformEdit.Value~=1||self.Parent.View.Parameters.ElementDialog.WaveformEdit.Value~=5)
                self.ProcessTypeEdit.String=val;
            else
                self.ProcessTypeEdit.Value=1;
            end
        end
        function val=get.SpectrumWindow(self)
            val=self.SpectrumWindowEdit.String{self.SpectrumWindowEdit.Value};
        end
        function set.SpectrumWindow(self,val)
            if strcmp(val,'None')
                self.SpectrumWindowEdit.Value=1;
            elseif strcmp(val,'Hamming')
                self.SpectrumWindowEdit.Value=2;
            elseif strcmp(val,'Chebyshev')
                self.SpectrumWindowEdit.Value=3;
            elseif strcmp(val,'Hann')
                self.SpectrumWindowEdit.Value=4;
            elseif strcmp(val,'Kaiser')
                self.SpectrumWindowEdit.Value=5;
            elseif strcmp(val,'Taylor')
                self.SpectrumWindowEdit.Value=6;
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
        function val=get.SpectrumRange(self)
            if~isempty(self.SpectrumRangeEdit.String)
                try
                    val=evalin('base',self.SpectrumRangeEdit.String);
                catch
                    val=str2mat(self.SpectrumRangeEdit.String);
                end
            else
                val=str2mat(self.SpectrumRangeEdit.String);
            end
            if isempty(val)&&~isempty(self.SpectrumRangeEdit.String)
                val='';
            end
        end
        function set.SpectrumRange(self,val)
            self.SpectrumRangeEdit.String=mat2str(val);
        end
        function setListenersEnable(self,val)
            self.Listeners.Coefficients.Enabled=val;
            self.Listeners.SpectrumWindow.Enabled=val;
            self.Listeners.Attenuation.Enabled=val;
            self.Listeners.SpectrumRange.Enabled=val;
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
            if(self.Parent.ElementDialog.WaveformEdit.Value==1)
                self.ProcessTypeEdit=uicontrol(...
                'Parent',self.Panel,...
                'Style','popup',...
                'FontSize',8,...
                'String',{getString(message('phased:apps:waveformapp:MatchedFilter')),getString(message('phased:apps:waveformapp:StretchProcessor'))},...
                'Value',1,...
                'Tag','ProcessType',...
                'Position',[20,20,40,20],...
                'HorizontalAlignment','left',...
                'Callback',@(h,e)processTypeChanged(self));
            else
                self.ProcessTypeEdit=uicontrol(...
                'Parent',self.Panel,...
                'Style','text',...
                'FontSize',8,...
                'String',getString(message('phased:apps:waveformapp:MatchedFilter')),...
                'Position',[20,20,40,20],...
                'Tag','ProcessType',...
                'HorizontalAlignment','left',...
                'Callback',@(h,e)processTypeChanged(self));
            end
            self.Parent.View.notify('Componentsadd',phased.apps.internal.WaveformViewer.ComponentsEventData(self.ProcessTypeEdit))
            self.SpectrumWindowLabel=uicontrol(...
            'Parent',self.Panel,...
            'Style','text',...
            'FontSize',8,...
            'String',getString(message('phased:apps:waveformapp:LabelWithColon','Spectrum Window')),...
            'HorizontalAlignment','right');
            self.SpectrumWindowEdit=uicontrol(...
            'Parent',self.Panel,...
            'Style','popup',...
            'FontSize',8,...
            'Position',[20,20,40,20],...
            'String',{getString(message('phased:apps:waveformapp:None')),getString(message('phased:apps:waveformapp:Hamming')),getString(message('phased:apps:waveformapp:Chebyshev')),getString(message('phased:apps:waveformapp:Hann')),getString(message('phased:apps:waveformapp:Kaiser')),getString(message('phased:apps:waveformapp:Taylor'))},...
            'Value',1,...
            'Tag','SpectrumWindow',...
            'HorizontalAlignment','left',...
            'Callback',@(h,e)parameterChanged(self,e));
            self.Parent.View.notify('Componentsadd',phased.apps.internal.WaveformViewer.ComponentsEventData(self.SpectrumWindowEdit))
            self.SideLobeAttenuationLabel=uicontrol(...
            'Parent',self.Panel,...
            'Style','text',...
            'Visible','off',...
            'FontSize',8,...
            'String',getString(message('phased:apps:waveformapp:LabelWithColon','Sidelobe Attenuation')),...
            'HorizontalAlignment','right');
            self.SideLobeAttenuationEdit=uicontrol(...
            'Parent',self.Panel,...
            'Style','edit',...
            'String','30',...
            'FontSize',8,...
            'Position',[20,20,40,20],...
            'Visible','off',...
            'Tag','SideLobeAttenuation',...
            'HorizontalAlignment','left',...
            'Callback',@(h,e)parameterChanged(self,e));
            self.Parent.View.notify('Componentsadd',phased.apps.internal.WaveformViewer.ComponentsEventData(self.SideLobeAttenuationEdit))
            self.BetaLabel=uicontrol(...
            'Parent',self.Panel,...
            'Style','text',...
            'FontSize',8,...
            'String',getString(message('phased:apps:waveformapp:LabelWithColon','Beta')),...
            'Visible','off',...
            'HorizontalAlignment','right');
            self.BetaEdit=uicontrol(...
            'Parent',self.Panel,...
            'Style','edit',...
            'String','0.5',...
            'FontSize',8,...
            'Visible','off',...
            'Position',[20,20,40,20],...
            'Tag','Beta',...
            'HorizontalAlignment','left',...
            'Callback',@(h,e)parameterChanged(self,e));
            self.Parent.View.notify('Componentsadd',phased.apps.internal.WaveformViewer.ComponentsEventData(self.BetaEdit))
            self.NbarLabel=uicontrol(...
            'Parent',self.Panel,...
            'Style','text',...
            'FontSize',8,...
            'Visible','off',...
            'String',getString(message('phased:apps:waveformapp:LabelWithColon','Beta')),...
            'HorizontalAlignment','right');
            self.NbarEdit=uicontrol(...
            'Parent',self.Panel,...
            'Style','edit',...
            'String','4',...
            'FontSize',8,...
            'Position',[20,20,40,20],...
            'Visible','off',...
            'Tag','Nbar',...
            'HorizontalAlignment','left',...
            'Callback',@(h,e)parameterChanged(self,e));
            self.Parent.View.notify('Componentsadd',phased.apps.internal.WaveformViewer.ComponentsEventData(self.NbarEdit))
            self.SpectrumRangeLabel=uicontrol(...
            'Parent',self.Panel,...
            'Style','text',...
            'FontSize',8,...
            'Visible','off',...
            'String',getString(message('phased:apps:waveformapp:LabelWithColon','Spectrum Range')),...
            'HorizontalAlignment','right');
            self.SpectrumRangeEdit=uicontrol(...
            'Parent',self.Panel,...
            'Style','edit',...
            'FontSize',8,...
            'Position',[20,20,40,20],...
            'String','[0 100000]',...
            'Visible','off',...
            'Tag','SpectrumRange',...
            'HorizontalAlignment','left',...
            'Callback',@(h,e)parameterChanged(self,e));
            self.Parent.View.notify('Componentsadd',phased.apps.internal.WaveformViewer.ComponentsEventData(self.SpectrumRangeEdit))
        end

        function layoutUIControls(self)
            hspacing=1;
            vspacing=2;
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
            if strcmp(self.Parent.ElementDialog.Waveform,getString(message('phased:apps:waveformapp:LinearFM')))
                self.Parent.addText(self.Layout,self.ProcessTypeLabel,rowParam,1,w1,height)
                self.Parent.addPopup(self.Layout,self.ProcessTypeEdit,rowParam,2:3,w2,height)
            else
                self.Parent.addText(self.Layout,self.ProcessTypeLabel,rowParam,1,w1,height)
                self.Parent.addText(self.Layout,self.ProcessTypeEdit,rowParam,2:3,w2+40,height)
            end
            if(self.SpectrumWindowEdit.Value==6)

                rowParam=rowParam+1;
                self.Parent.addText(self.Layout,self.SpectrumWindowLabel,rowParam,1,w1,height)
                self.Parent.addPopup(self.Layout,self.SpectrumWindowEdit,rowParam,2:3,w2,height)

                rowParam=rowParam+1;
                self.Parent.addText(self.Layout,self.SpectrumRangeLabel,rowParam,1,w1,height)
                self.Parent.addEdit(self.Layout,self.SpectrumRangeEdit,rowParam,2:3,w2,height)

                rowParam=rowParam+1;
                self.Parent.addText(self.Layout,self.SideLobeAttenuationLabel,rowParam,1,w1,height)
                self.Parent.addEdit(self.Layout,self.SideLobeAttenuationEdit,rowParam,2:3,w2,height)
                rowParam=rowParam+1;

                self.Parent.addText(self.Layout,self.NbarLabel,rowParam,1,w1,height)
                self.Parent.addEdit(self.Layout,self.NbarEdit,rowParam,2:3,w2,height)
            elseif(self.SpectrumWindowEdit.Value==3)

                rowParam=rowParam+1;
                self.Parent.addText(self.Layout,self.SpectrumWindowLabel,rowParam,1,w1,height)
                self.Parent.addPopup(self.Layout,self.SpectrumWindowEdit,rowParam,2:3,w2,height)

                rowParam=rowParam+1;
                self.Parent.addText(self.Layout,self.SpectrumRangeLabel,rowParam,1,w1,height)
                self.Parent.addEdit(self.Layout,self.SpectrumRangeEdit,rowParam,2:3,w2,height)

                rowParam=rowParam+1;
                self.Parent.addText(self.Layout,self.SideLobeAttenuationLabel,rowParam,1,w1,height)
                self.Parent.addEdit(self.Layout,self.SideLobeAttenuationEdit,rowParam,2:3,w2,height)
            elseif(self.SpectrumWindowEdit.Value==5)

                rowParam=rowParam+1;
                self.Parent.addText(self.Layout,self.SpectrumWindowLabel,rowParam,1,w1,height)
                self.Parent.addPopup(self.Layout,self.SpectrumWindowEdit,rowParam,2:3,w2,height)

                rowParam=rowParam+1;
                self.Parent.addText(self.Layout,self.SpectrumRangeLabel,rowParam,1,w1,height)
                self.Parent.addEdit(self.Layout,self.SpectrumRangeEdit,rowParam,2:3,w2,height)

                rowParam=rowParam+1;
                self.Parent.addText(self.Layout,self.BetaLabel,rowParam,1,w1,height)
                self.Parent.addEdit(self.Layout,self.BetaEdit,rowParam,2:3,w2,height)
            elseif(self.SpectrumWindowEdit.Value==1)
                rowParam=rowParam+1;
                self.Parent.addText(self.Layout,self.SpectrumWindowLabel,rowParam,1,w1,height)
                self.Parent.addPopup(self.Layout,self.SpectrumWindowEdit,rowParam,2:3,w2,height)
            else

                rowParam=rowParam+1;
                self.Parent.addText(self.Layout,self.SpectrumWindowLabel,rowParam,1,w1,height)
                self.Parent.addPopup(self.Layout,self.SpectrumWindowEdit,rowParam,2:3,w2,height)

                rowParam=rowParam+1;
                self.Parent.addText(self.Layout,self.SpectrumRangeLabel,rowParam,1,w1,height)
                self.Parent.addEdit(self.Layout,self.SpectrumRangeEdit,rowParam,2:3,w2,height)
            end
            [~,~,w,height]=getMinimumSize(self.Layout);
            self.Width=sum(w)+self.Layout.HorizontalGap*(numel(w)+1);
            self.Height=max(height(2:end))*numel(height(2:end))+...
            self.Layout.VerticalGap*(numel(height(2:end))+10);
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
            if strcmp(name,'SpectrumWindow')
                layoutUIControls(self);
                add(self.Parent.Layout,self.Panel,3,1,...
                'MinimumWidth',self.Width,...
                'Fill','Horizontal',...
                'MinimumHeight',self.Height,...
                'Anchor','North');
                self.Beta=0.5;
                self.Nbar=4;
                self.SpectrumRange=[0,100000];
                self.SideLobeAttenuation=30;
                if strcmp(self.SpectrumWindow,getString(message('phased:apps:waveformapp:Taylor')))
                    self.BetaLabel.Visible='off';
                    self.BetaEdit.Visible='off';
                    self.NbarLabel.Visible='on';
                    self.NbarEdit.Visible='on';
                    self.SideLobeAttenuationLabel.Visible='on';
                    self.SideLobeAttenuationEdit.Visible='on';
                    self.SpectrumRangeEdit.Visible='on';
                    self.SpectrumRangeLabel.Visible='on';
                elseif strcmp(self.SpectrumWindow,getString(message('phased:apps:waveformapp:Chebyshev')))
                    self.SideLobeAttenuationLabel.Visible='on';
                    self.SideLobeAttenuationEdit.Visible='on';
                    self.BetaLabel.Visible='off';
                    self.BetaEdit.Visible='off';
                    self.NbarLabel.Visible='off';
                    self.NbarEdit.Visible='off';
                    self.SpectrumRangeEdit.Visible='on';
                    self.SpectrumRangeLabel.Visible='on';
                elseif strcmp(self.SpectrumWindow,getString(message('phased:apps:waveformapp:Kaiser')))
                    self.SideLobeAttenuationLabel.Visible='off';
                    self.SideLobeAttenuationEdit.Visible='off';
                    self.NbarLabel.Visible='off';
                    self.NbarEdit.Visible='off';
                    self.BetaLabel.Visible='on';
                    self.BetaEdit.Visible='on';
                    self.SpectrumRangeEdit.Visible='on';
                    self.SpectrumRangeLabel.Visible='on';
                elseif~strcmp(self.SpectrumWindow,getString(message('phased:apps:waveformapp:None')))
                    self.BetaLabel.Visible='off';
                    self.BetaEdit.Visible='off';
                    self.NbarLabel.Visible='off';
                    self.NbarEdit.Visible='off';
                    self.SideLobeAttenuationLabel.Visible='off';
                    self.SideLobeAttenuationEdit.Visible='off';
                    self.SpectrumRangeEdit.Visible='on';
                    self.SpectrumRangeLabel.Visible='on';
                else
                    self.BetaLabel.Visible='off';
                    self.BetaEdit.Visible='off';
                    self.NbarLabel.Visible='off';
                    self.NbarEdit.Visible='off';
                    self.SideLobeAttenuationLabel.Visible='off';
                    self.SideLobeAttenuationEdit.Visible='off';
                    self.SpectrumRangeEdit.Visible='off';
                    self.SpectrumRangeLabel.Visible='off';
                end
            end
            self.Parent.View.Canvas.AutoSelect=true;
        end
    end
end