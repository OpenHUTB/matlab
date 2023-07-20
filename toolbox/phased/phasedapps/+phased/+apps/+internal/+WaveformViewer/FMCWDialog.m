classdef FMCWDialog<handle



    properties
Parent
Panel
Layout
        Width=0
        Height=0
Listeners
    end

    properties(Dependent)
Waveform
SweepTime
SweepBandwidth
SweepDirection
SweepInterval
NumSweeps
PropagationSpeed
    end

    properties
WaveformLabel
WaveformEdit
WaveformListener
Title
NumSweepsLabel
NumSweepsEdit
SweepTimeLabel
SweepTimeEdit
PropagationSpeedLabel
PropagationSpeedEdit
SweepBandwidthLabel
SweepBandwidthEdit
SweepDirectionLabel
SweepDirectionEdit
SweepIntervalLabel
SweepIntervalEdit
    end

    methods
        function self=FMCWDialog(parent)
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
            if strcmp(val,getString(message('phased:apps:waveformapp:FMCW')))
                self.WaveformEdit.Value=5;
            end
        end

        function val=get.NumSweeps(self)
            if~isempty(self.NumSweepsEdit.String)
                try
                    val=evalin('base',self.NumSweepsEdit.String);
                catch
                    val=self.NumSweepsEdit.String;
                end
            else
                val=str2num(self.NumSweepsEdit.String);
            end
            if isempty(val)&&~isempty(self.NumSweepsEdit.String)
                val='';
            end
        end

        function set.NumSweeps(self,val)
            self.NumSweepsEdit.String=num2str(val);
        end

        function val=get.SweepTime(self)
            if~isempty(self.SweepTimeEdit.String)
                try
                    val=evalin('base',self.SweepTimeEdit.String);
                catch
                    val=self.SweepTimeEdit.String;
                end
            else
                val=str2num(self.SweepTimeEdit.String);
            end
            if isempty(val)&&~isempty(self.SweepTimeEdit.String)
                val='';
            end
        end

        function set.SweepTime(self,val)
            self.SweepTimeEdit.String=num2str(val);
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

        function val=get.SweepBandwidth(self)
            if~isempty(self.SweepBandwidthEdit.String)
                try
                    val=evalin('base',self.SweepBandwidthEdit.String);
                catch
                    val=self.SweepBandwidthEdit.String;
                end
            else
                val=str2num(self.SweepBandwidthEdit.String);
            end
            if isempty(val)&&~isempty(self.SweepBandwidthEdit.String)
                val='';
            end
        end

        function set.SweepBandwidth(self,val)
            self.SweepBandwidthEdit.String=num2str(val);
        end

        function val=get.SweepDirection(self)
            val=self.SweepDirectionEdit.String{self.SweepDirectionEdit.Value};
        end

        function set.SweepDirection(self,val)
            if strcmp(val,getString(message('phased:apps:waveformapp:up')))
                self.SweepDirectionEdit.Value=1;
            elseif strcmp(val,getString(message('phased:apps:waveformapp:dwn')))
                self.SweepDirectionEdit.Value=2;
            elseif strcmp(val,getString(message('phased:apps:waveformapp:triangle')))
                self.SweepDirectionEdit.Value=3;
            end
        end

        function val=get.SweepInterval(self)
            val=self.SweepIntervalEdit.String{self.SweepIntervalEdit.Value};
        end

        function set.SweepInterval(self,val)
            if strcmp(val,getString(message('phased:apps:waveformapp:positive')))
                self.SweepIntervalEdit.Value=1;
            elseif strcmp(val,getString(message('phased:apps:waveformapp:symmetric')))
                self.SweepIntervalEdit.Value=2;
            end
        end

        function setListenersEnable(self,val)
            self.Listeners.Waveform.Enabled=val;
            self.Listeners.NumSweeps.Enabled=val;
            self.Listeners.SweepTime.Enabled=val;
            self.Listeners.PropagationSpeed.Enabled=val;
            self.Listeners.SweepBandwidth.Enabled=val;
            self.Listeners.SweepDirection.Enabled=val;
            self.Listeners.SweepInterval.Enabled=val;
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
            'Value',5,...
            'Tag','WTDDTag',...
            'HorizontalAlignment','left',...
            'Callback',@(h,e)waveformParameterChanged(self));
            self.Parent.View.notify('Componentsadd',phased.apps.internal.WaveformViewer.ComponentsEventData(self.WaveformEdit))
            self.SweepTimeLabel=uicontrol(...
            'Parent',self.Panel,...
            'Style','text',...
            'FontSize',8,...
            'String',getString(message('phased:apps:waveformapp:SweepTimeLabel','Sweep Time')),...
            'HorizontalAlignment','right');
            self.SweepTimeEdit=uicontrol(...
            'Parent',self.Panel,...
            'Style','edit',...
            'FontSize',8,...
            'Position',[20,20,40,20],...
            'String','0.0001',...
            'Tag','SweepTime',...
            'HorizontalAlignment','left',...
            'Callback',@(h,e)parameterChanged(self,e));
            self.Parent.View.notify('Componentsadd',phased.apps.internal.WaveformViewer.ComponentsEventData(self.SweepTimeEdit))

            self.SweepBandwidthLabel=uicontrol(...
            'Parent',self.Panel,...
            'Style','text',...
            'FontSize',8,...
            'String',getString(message('phased:apps:waveformapp:SweepBandwidthLabel','Sweep Bandwidth')),...
            'HorizontalAlignment','right');
            self.SweepBandwidthEdit=uicontrol(...
            'Parent',self.Panel,...
            'Style','edit',...
            'FontSize',8,...
            'Position',[20,20,40,20],...
            'String','100000',...
            'Tag','SweepBandwidth',...
            'HorizontalAlignment','left',...
            'Callback',@(h,e)parameterChanged(self,e));
            self.Parent.View.notify('Componentsadd',phased.apps.internal.WaveformViewer.ComponentsEventData(self.SweepBandwidthEdit))

            self.SweepDirectionLabel=uicontrol(...
            'Parent',self.Panel,...
            'Style','text',...
            'FontSize',8,...
            'String',getString(message('phased:apps:waveformapp:LabelWithColon','Sweep Direction')),...
            'HorizontalAlignment','right');
            self.SweepDirectionEdit=uicontrol(...
            'Parent',self.Panel,...
            'Style','popup',...
            'FontSize',8,...
            'Position',[20,20,40,20],...
            'String',{getString(message('phased:apps:waveformapp:up')),getString(message('phased:apps:waveformapp:dwn')),getString(message('phased:apps:waveformapp:triangle'))},...
            'Tag','SweepDirection',...
            'HorizontalAlignment','left',...
            'Callback',@(h,e)parameterChanged(self,e));
            self.Parent.View.notify('Componentsadd',phased.apps.internal.WaveformViewer.ComponentsEventData(self.SweepDirectionEdit))

            self.SweepIntervalLabel=uicontrol(...
            'Parent',self.Panel,...
            'Style','text',...
            'FontSize',8,...
            'String',getString(message('phased:apps:waveformapp:LabelWithColon','Sweep Interval')),...
            'HorizontalAlignment','right');
            self.SweepIntervalEdit=uicontrol(...
            'Parent',self.Panel,...
            'Style','popup',...
            'FontSize',8,...
            'Position',[20,20,40,20],...
            'String',{getString(message('phased:apps:waveformapp:positive')),getString(message('phased:apps:waveformapp:symmetric'))},...
            'Tag','SweepInterval',...
            'HorizontalAlignment','left',...
            'Callback',@(h,e)parameterChanged(self,e));
            self.Parent.View.notify('Componentsadd',phased.apps.internal.WaveformViewer.ComponentsEventData(self.SweepIntervalEdit))

            self.NumSweepsLabel=uicontrol(...
            'Parent',self.Panel,...
            'Style','text',...
            'FontSize',8,...
            'String',getString(message('phased:apps:waveformapp:LabelWithColon','Number of Sweeps')),...
            'HorizontalAlignment','right');
            self.NumSweepsEdit=uicontrol(...
            'Parent',self.Panel,...
            'Style','edit',...
            'FontSize',8,...
            'Position',[20,20,40,20],...
            'String','1',...
            'Tag','NumSweeps',...
            'HorizontalAlignment','left',...
            'Callback',@(h,e)parameterChanged(self,e));
            self.Parent.View.notify('Componentsadd',phased.apps.internal.WaveformViewer.ComponentsEventData(self.NumSweepsEdit))

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
            self.Parent.View.notify('Componentsadd',phased.apps.internal.WaveformViewer.ComponentsEventData(self.PropagationSpeedEdit))
        end
        function layoutUIControls(self)
            hspacing=0;
            vspacing=1;

            self.Layout=...
            matlabshared.application.layout.GridBagLayout(...
            self.Panel,...
            'VerticalGap',vspacing,...
            'HorizontalGap',hspacing,...
            'VerticalWeights',[0,0,0,0,0,0,0,0,0,0,0,1],...
            'HorizontalWeights',[0,1,0]);
            if isunix
                w1=140;
            else
                w1=130;
            end
            w2=75;
            row=1;
            height=24;
            self.Parent.addText(self.Layout,self.WaveformLabel,row,1,w1,height)
            self.Parent.addEdit(self.Layout,self.WaveformEdit,row,2:3,w2,height)

            row=row+1;

            self.Parent.addText(self.Layout,self.SweepTimeLabel,row,1,w1,height)
            self.Parent.addEdit(self.Layout,self.SweepTimeEdit,row,2:3,w2,height)

            row=row+1;

            self.Parent.addText(self.Layout,self.SweepBandwidthLabel,row,1,w1,height)
            self.Parent.addEdit(self.Layout,self.SweepBandwidthEdit,row,2:3,w2,height)

            row=row+1;

            self.Parent.addText(self.Layout,self.SweepDirectionLabel,row,1,w1,height)
            self.Parent.addEdit(self.Layout,self.SweepDirectionEdit,row,2:3,w2,height)

            row=row+1;

            self.Parent.addText(self.Layout,self.SweepIntervalLabel,row,1,w1,height)
            self.Parent.addEdit(self.Layout,self.SweepIntervalEdit,row,2:3,w2,height)

            row=row+1;

            self.Parent.addText(self.Layout,self.NumSweepsLabel,row,1,w1,height)
            self.Parent.addEdit(self.Layout,self.NumSweepsEdit,row,2:3,w2,height)

            row=row+1;

            if isunix
                self.Parent.addText(self.Layout,self.PropagationSpeedLabel,row,1,w1+10,height)
            else
                self.Parent.addText(self.Layout,self.PropagationSpeedLabel,row,1,w1,height)
            end
            self.Parent.addEdit(self.Layout,self.PropagationSpeedEdit,row,2:3,w2,height)
            [~,~,w,height]=getMinimumSize(self.Layout);
            self.Width=sum(w)+self.Layout.HorizontalGap*(numel(w)+1);
            self.Height=max(height(2:end))*numel(height(2:end))+...
            self.Layout.VerticalGap*(numel(height(2:end))+10);
        end

        function waveformParameterChanged(self)

            self.Parent.View.Parameters.WaveformChanged=1;
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

        function addListeners(self)

            self.Listeners.NumSweeps=addlistener(self.NumSweepsEdit,'String',...
            'PostSet',@(h,e)parameterChanged(self,e));
            self.Listeners.SweepTime=addlistener(self.SweepTimeEdit,'String',...
            'PostSet',@(h,e)parameterChanged(self,e));
            self.Listeners.PropagationSpeed=addlistener(self.PropagationSpeedEdit,'String',...
            'PostSet',@(h,e)parameterChanged(self,e));
            self.Listeners.SweepBandwidth=addlistener(self.SweepBandwidthEdit,'String',...
            'PostSet',@(h,e)parameterChanged(self,e));
            self.Listeners.SweepDirection=addlistener(self.SweepDirectionEdit,'Value',...
            'PostSet',@(h,e)parameterChanged(self,e));
            self.Listeners.SweepInterval=addlistener(self.SweepIntervalEdit,'Value',...
            'PostSet',@(h,e)parameterChanged(self,e));
        end
    end
end