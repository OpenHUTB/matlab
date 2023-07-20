classdef RectangularDialog<handle



    properties
Parent
Panel
Layout
        Width=0
        Height=0
    end

    properties(Dependent)
Waveform
SampleRate
NumPulses
PRF
FrequencyOffset
PropagationSpeed
PulseWidth
    end

    properties
WaveformLabel
WaveformEdit
WaveformListener
Title
NumPulsesLabel
NumPulsesEdit
PRFLabel
PRFEdit
FrequencyOffsetLabel
FrequencyOffsetEdit
PropagationSpeedLabel
PropagationSpeedEdit
PulseWidthLabel
PulseWidthEdit
AddButton
DeleteButton
    end

    methods
        function self=RectangularDialog(parent)
            if nargin==0
                parent=figure;
            end
            self.Parent=parent;
            createUIControls(self)
            layoutUIControls(self)
        end
    end

    methods
        function val=get.Waveform(self)
            val=self.WaveformEdit.String{self.WaveformEdit.Value};
        end
        function set.Waveform(self,val)
            if strcmp(val,getString(message('phased:apps:waveformapp:Rectangular')))
                self.WaveformEdit.Value=2;
            end
        end

        function val=get.NumPulses(self)
            if~isempty(self.NumPulsesEdit.String)
                try
                    val=evalin('base',self.NumPulsesEdit.String);
                catch
                    val=self.NumPulsesEdit.String;
                end
            else
                val=str2num(self.NumPulsesEdit.String);
            end
            if isempty(val)&&~isempty(self.NumPulsesEdit.String)
                val='';
            end
        end

        function set.NumPulses(self,val)
            self.NumPulsesEdit.String=num2str(val);
        end

        function val=get.PRF(self)
            if~isempty(self.PRFEdit.String)
                try
                    val=evalin('base',self.PRFEdit.String);
                catch
                    val=self.PRFEdit.String;
                end
            else
                val=str2num(self.PRFEdit.String);
            end
            if get(self.PRFLabel,'Value')==2
                if~isempty(val)&&numel(val)==1&&~issparse(val)
                    val=1/val;
                end
            end
            if isempty(val)&&~isempty(self.PRFEdit.String)
                val='';
            end
        end

        function set.PRF(self,val)
            if self.Parent.View.Canvas.SelectIdx>numel(self.Parent.PRFPRIIndex)
                self.Parent.PRFPRIIndex(self.Parent.View.Canvas.SelectIdx)=1;
            end
            if self.Parent.PRFPRIIndex(self.Parent.View.Canvas.SelectIdx)==2
                self.PRFLabel.Value=2;
            else
                self.PRFLabel.Value=1;
            end
            if get(self.PRFLabel,'Value')==2
                val=1/val;
            end
            self.PRFEdit.String=num2str(val);
        end

        function val=get.FrequencyOffset(self)
            if~isempty(self.FrequencyOffsetEdit.String)
                try
                    val=evalin('base',self.FrequencyOffsetEdit.String);
                catch
                    val=self.FrequencyOffsetEdit.String;
                end
            else
                val=str2num(self.FrequencyOffsetEdit.String);
            end

            if isempty(val)&&~isempty(self.FrequencyOffsetEdit.String)
                val='';
            end
        end

        function set.FrequencyOffset(self,val)
            self.FrequencyOffsetEdit.String=num2str(val);
        end

        function val=get.PropagationSpeed(self)
            if~isempty(self.PropagationSpeedEdit.String)
                try
                    val=evalin('base',self.PropagationSpeedEdit.String);
                catch
                    val=self.PropagationSpeedEdit.String;
                end
            else
                val=str2num(self.PropagationSpeedEdit.String);
            end
            if isempty(val)&&~isempty(self.PropagationSpeedEdit.String)
                val='';
            end
        end

        function set.PropagationSpeed(self,val)
            self.PropagationSpeedEdit.String=num2str(val);
        end

        function val=get.PulseWidth(self)
            if~isempty(self.PulseWidthEdit.String)
                try
                    val=evalin('base',self.PulseWidthEdit.String);
                catch
                    val=self.PulseWidthEdit.String;
                end
            else
                val=str2num(self.PulseWidthEdit.String);
            end
            if isempty(val)&&~isempty(self.PulseWidthEdit.String)
                val='';
            end
        end

        function set.PulseWidth(self,val)
            self.PulseWidthEdit.String=num2str(val);
        end

        function setListenersEnable(self,val)
            self.Listeners.Waveform.Enabled=val;
            self.Listeners.NumPulses.Enabled=val;
            self.Listeners.PulseWidth.Enabled=val;
            self.Listeners.PRF.Enabled=val;
            self.Listeners.FrequencyOffset.Enabled=val;
            self.Listeners.PropagationSpeed.Enabled=val;
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
            self.WaveformLabel=uicontrol(...
            'Parent',self.Panel,...
            'Style','text',...
            'FontSize',8,...
            'String',getString(message('phased:apps:waveformapp:WaveformLabel')),...
            'HorizontalAlignment','right');
            self.WaveformEdit=uicontrol(...
            'Parent',self.Panel,...
            'Style','popup',...
            'FontSize',8,...
            'Position',[20,20,40,20],...
            'String',{getString(message('phased:apps:waveformapp:LinearFM')),getString(message('phased:apps:waveformapp:Rectangular'))...
            ,getString(message('phased:apps:waveformapp:SteppedFM')),getString(message('phased:apps:waveformapp:PhaseCoded'))...
            ,getString(message('phased:apps:waveformapp:FMCW'))},...
            'Value',2,...
            'Tag','WTDDTag',...
            'HorizontalAlignment','left',...
            'Callback',@(h,e)waveformParameterChanged(self));

            self.PRFLabel=uicontrol(...
            'Parent',self.Panel,...
            'Style','popup',...
            'FontSize',8,...
            'String',{getString(message('phased:apps:waveformapp:PRF','PRF')),getString(message('phased:apps:waveformapp:PRI','PRI'))},...
            'Tag','PRFPopupTag',...
            'HorizontalAlignment','right',...
            'Callback',@(h,e)prfCallback(self));

            self.PRFEdit=uicontrol(...
            'Parent',self.Panel,...
            'Style','edit',...
            'FontSize',8,...
            'Position',[20,20,40,20],...
            'String','10000',...
            'Tag','PRF',...
            'HorizontalAlignment','left',...
            'Callback',@(h,e)parameterChanged(self,e));

            self.NumPulsesLabel=uicontrol(...
            'Parent',self.Panel,...
            'Style','text',...
            'FontSize',8,...
            'String',getString(message('phased:apps:waveformapp:LabelWithColon','Number of Pulses')),...
            'HorizontalAlignment','right');
            self.NumPulsesEdit=uicontrol(...
            'Parent',self.Panel,...
            'Style','edit',...
            'String','1',...
            'FontSize',8,...
            'Position',[20,20,40,20],...
            'Tag','NumPulses',...
            'HorizontalAlignment','left',...
            'Callback',@(h,e)parameterChanged(self,e));

            self.PulseWidthLabel=uicontrol(...
            'Parent',self.Panel,...
            'Style','text',...
            'FontSize',8,...
            'String',getString(message('phased:apps:waveformapp:PulseWidthLabel','Pulse Width')),...
            'HorizontalAlignment','right');
            self.PulseWidthEdit=uicontrol(...
            'Parent',self.Panel,...
            'Style','edit',...
            'FontSize',8,...
            'Position',[20,20,40,20],...
            'String','5e-5',...
            'Tag','PulseWidth',...
            'HorizontalAlignment','left',...
            'Callback',@(h,e)parameterChanged(self,e));

            self.PropagationSpeedLabel=uicontrol(...
            'Parent',self.Panel,...
            'Style','text',...
            'FontSize',8,...
            'String',getString(message('phased:apps:waveformapp:PropagationSpeedLabel','Propagation Speed')),...
            'HorizontalAlignment','right');
            self.PropagationSpeedEdit=uicontrol(...
            'Parent',self.Panel,...
            'Style','edit',...
            'FontSize',8,...
            'Position',[20,20,40,20],...
            'String',num2str(physconst('LightSpeed')),...
            'Tag','PropagationSpeed',...
            'HorizontalAlignment','left',...
            'Callback',@(h,e)parameterChanged(self,e));

            self.FrequencyOffsetLabel=uicontrol(...
            'Parent',self.Panel,...
            'Style','text',...
            'FontSize',8,...
            'String',getString(message('phased:apps:waveformapp:FrequencyOffsetLabel','Frequency Offset')),...
            'HorizontalAlignment','right');
            self.FrequencyOffsetEdit=uicontrol(...
            'Parent',self.Panel,...
            'Style','edit',...
            'FontSize',8,...
            'Position',[20,20,40,20],...
            'String','0',...
            'Tag','FrequencyOffset',...
            'HorizontalAlignment','left',...
            'Callback',@(h,e)parameterChanged(self,e));
        end
        function prfCallback(self)

            applybtnstate=self.Parent.View.Parameters.ApplyButton.ApplyButton.Enable;

            self.PRFEdit.String=num2str(1/str2num(self.PRFEdit.String));
            if self.PRFLabel.Value==2
                self.Parent.PRFPRIIndex(self.Parent.View.Canvas.SelectIdx)=2;
            else
                self.Parent.PRFPRIIndex(self.Parent.View.Canvas.SelectIdx)=1;
            end

            self.Parent.View.Parameters.ApplyButton.ApplyButton.Enable=applybtnstate;
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
            self.Parent.addText(self.Layout,self.WaveformLabel,rowParam,1,w1,height)
            self.Parent.addEdit(self.Layout,self.WaveformEdit,rowParam,2:3,w2,height)

            rowParam=rowParam+1;

            self.Parent.addPopup(self.Layout,self.PRFLabel,rowParam,1,w1,height)
            self.Parent.addEdit(self.Layout,self.PRFEdit,rowParam,2:3,w2,height)

            rowParam=rowParam+1;

            self.Parent.addText(self.Layout,self.NumPulsesLabel,rowParam,1,w1,height)
            self.Parent.addEdit(self.Layout,self.NumPulsesEdit,rowParam,2:3,w2,height)

            rowParam=rowParam+1;

            self.Parent.addText(self.Layout,self.PulseWidthLabel,rowParam,1,w1,height)
            self.Parent.addEdit(self.Layout,self.PulseWidthEdit,rowParam,2:3,w2,height)

            rowParam=rowParam+1;

            if isunix
                self.Parent.addText(self.Layout,self.PropagationSpeedLabel,rowParam,1,w1+10,height)
            else
                self.Parent.addText(self.Layout,self.PropagationSpeedLabel,rowParam,1,w1,height)
            end
            self.Parent.addEdit(self.Layout,self.PropagationSpeedEdit,rowParam,2:3,w2,height)

            rowParam=rowParam+1;

            self.Parent.addText(self.Layout,self.FrequencyOffsetLabel,rowParam,1,w1,height)
            self.Parent.addEdit(self.Layout,self.FrequencyOffsetEdit,rowParam,2:3,w2,height)


            [~,~,w,height]=getMinimumSize(self.Layout);
            self.Width=sum(w)+self.Layout.HorizontalGap*(numel(w)+1);
            self.Height=max(height(2:end))*numel(height(2:end))+...
            self.Layout.VerticalGap*(numel(height(2:end))+10);
        end

        function waveformParameterChanged(self)

            self.Parent.WaveformChanged=1;
            value=self.Waveform;
            idx=self.Parent.View.Canvas.SelectIdx;
            self.Parent.notify('SystemParameterView',phased.apps.internal.WaveformViewer.WaveformParameterEventData(idx,value))
            if strcmp(self.Waveform,getString(message('phased:apps:waveformapp:FMCW')))
                self.Parent.View.Parameters.DechirpDialog=phased.apps.internal.WaveformViewer.DechirpDialog(self.Parent.View.Parameters);
            else
                self.Parent.View.Parameters.MatchedFilterDialog=phased.apps.internal.WaveformViewer.MatchedFilterDialog(self.Parent.View.Parameters);
            end
            idx=self.Parent.View.Parameters.ProcessDialog.ProcessTypeEdit.Value;
            if strcmp(self.Waveform,getString(message('phased:apps:waveformapp:LinearFM')))
                value=self.Parent.View.Parameters.MatchedFilterDialog.ProcessType{1};
            elseif strcmp(self.Waveform,getString(message('phased:apps:waveformapp:FMCW')))
                value=self.Parent.View.Parameters.DechirpDialog.ProcessType;
            else
                value=self.Parent.View.Parameters.MatchedFilterDialog.ProcessType;
            end
            self.Parent.View.Parameters.notify('SystemCompressionView',phased.apps.internal.WaveformViewer.ProcessTypeEventData(idx,value))
            self.Parent.View.Parameters.ApplyButton.ApplyButton.Enable='on';
        end

        function parameterChanged(self,e)

            self.Parent.View.Parameters.ApplyButton.ApplyButton.Enable='on';
            self.Parent.View.Canvas.AutoSelect=false;
            idx=self.Parent.View.Canvas.SelectIdx;
            name=e.Source.Tag;
            value=self.(name);
            if numel(self.Parent.View.Canvas.WaveformList.getSelectedRows())>1
                self.Parent.notify('MultiSelectElementParameterView',phased.apps.internal.WaveformViewer.MultiSelectElementParameterChangedEventData(self.Parent.View,name,value))
            else
                self.Parent.notify('ElementParameterView',phased.apps.internal.WaveformViewer.ElementParameterChangedEventData(idx,name,value))
            end
            self.Parent.View.Canvas.AutoSelect=true;
        end
    end
end