classdef PhaseCodedDialog<handle



    properties
Parent
Panel
Layout
        Width=0
        Height=0
    end

    properties(Dependent)
Waveform
NumPulses
PRF
FrequencyOffset
PropagationSpeed
Code
ChipWidth
NumChips
SequenceIndex
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
CodeLabel
CodeEdit
ChipWidthLabel
ChipWidthEdit
NumChipsLabel
NumChipsEdit
SequenceIndexLabel
SequenceIndexEdit
AddButton
DeleteButton
    end

    methods
        function self=PhaseCodedDialog(parent)
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
            if strcmp(val,getString(message('phased:apps:waveformapp:PhaseCoded')))
                self.WaveformEdit.Value=4;
            end
        end

        function val=get.NumPulses(self)
            if~isempty(self.NumPulsesEdit.String)
                try
                    val=evalin('base',self.NumPulsesEdit.String);%#ok<*ST2NM>
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

        function val=get.SequenceIndex(self)
            if~isempty(self.SequenceIndexEdit.String)
                try
                    val=evalin('base',self.SequenceIndexEdit.String);
                catch
                    val=self.SequenceIndexEdit.String;
                end
            else
                val=str2num(self.SequenceIndexEdit.String);
            end
        end

        function set.SequenceIndex(self,val)
            self.SequenceIndexEdit.String=num2str(val);
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

        function val=get.Code(self)
            val=self.CodeEdit.String{self.CodeEdit.Value};
        end

        function set.Code(self,val)
            if strcmp(val,getString(message('phased:apps:waveformapp:Barker')))
                self.CodeEdit.Value=1;
            elseif strcmp(val,getString(message('phased:apps:waveformapp:Frank')))
                self.CodeEdit.Value=2;
            elseif strcmp(val,getString(message('phased:apps:waveformapp:P1')))
                self.CodeEdit.Value=3;
            elseif strcmp(val,getString(message('phased:apps:waveformapp:P2')))
                self.CodeEdit.Value=4;
            elseif strcmp(val,getString(message('phased:apps:waveformapp:P3')))
                self.CodeEdit.Value=5;
            elseif strcmp(val,getString(message('phased:apps:waveformapp:P4')))
                self.CodeEdit.Value=6;
            elseif strcmp(val,getString(message('phased:apps:waveformapp:Px')))
                self.CodeEdit.Value=7;
            elseif strcmp(val,getString(message('phased:apps:waveformapp:ZadoffChu')))
                self.CodeEdit.Value=8;
            end
        end

        function val=get.ChipWidth(self)
            if~isempty(self.ChipWidthEdit.String)
                try
                    val=evalin('base',self.ChipWidthEdit.String);
                catch
                    val=self.ChipWidthEdit.String;
                end
            else
                val=str2num(self.ChipWidthEdit.String);
            end
            if isempty(val)&&~isempty(self.ChipWidthEdit.String)
                val='';
            end
        end

        function set.ChipWidth(self,val)
            self.ChipWidthEdit.String=num2str(val);
        end

        function val=get.NumChips(self)
            cmp=strcmp(self.Code,getString(message('phased:apps:waveformapp:Barker')));
            if cmp==1
                val=self.NumChipsEdit.String{self.NumChipsEdit.Value};
            else
                if~isempty(self.NumChipsEdit.String)
                    try
                        val=num2str(evalin('base',self.NumChipsEdit.String));
                    catch
                        val=self.NumChipsEdit.String;
                    end
                else
                    val=self.NumChipsEdit.String;
                end
            end
        end

        function set.NumChips(self,val)
            cmp=strcmp(self.Code,getString(message('phased:apps:waveformapp:Barker')));
            if cmp==1
                self.NumChipsEdit.Style='popup';
                self.NumChipsEdit.String={'2','3','4','5','7','11','13'};
                if strcmp(val,'2')
                    self.NumChipsEdit.Value=1;
                elseif strcmp(val,'3')
                    self.NumChipsEdit.Value=2;
                elseif strcmp(val,'4')
                    self.NumChipsEdit.Value=3;
                elseif strcmp(val,'5')
                    self.NumChipsEdit.Value=4;
                elseif strcmp(val,'7')
                    self.NumChipsEdit.Value=5;
                elseif strcmp(val,'11')
                    self.NumChipsEdit.Value=6;
                elseif strcmp(val,'13')
                    self.NumChipsEdit.Value=7;
                end
            else
                self.NumChipsEdit.Style='edit';
                self.NumChipsEdit.String=val;
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
            'Value',4,...
            'Tag','WTDDTag',...
            'HorizontalAlignment','left',...
            'Callback',@(h,e)waveformParameterChanged(self));
            self.Parent.View.notify('Componentsadd',phased.apps.internal.WaveformViewer.ComponentsEventData(self.WaveformEdit))

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
            self.Parent.View.notify('Componentsadd',phased.apps.internal.WaveformViewer.ComponentsEventData(self.PRFEdit))

            self.NumPulsesLabel=uicontrol(...
            'Parent',self.Panel,...
            'Style','text',...
            'FontSize',8,...
            'String',getString(message('phased:apps:waveformapp:LabelWithColon','Number of Pulses')),...
            'HorizontalAlignment','right');
            self.NumPulsesEdit=uicontrol(...
            'Parent',self.Panel,...
            'Style','edit',...
            'FontSize',8,...
            'Position',[20,20,40,20],...
            'String','2',...
            'Tag','NumPulses',...
            'HorizontalAlignment','left',...
            'Callback',@(h,e)parameterChanged(self,e));
            self.Parent.View.notify('Componentsadd',phased.apps.internal.WaveformViewer.ComponentsEventData(self.NumPulsesEdit))

            self.CodeLabel=uicontrol(...
            'Parent',self.Panel,...
            'Style','text',...
            'FontSize',8,...
            'String',getString(message('phased:apps:waveformapp:Code')),...
            'HorizontalAlignment','right');
            self.CodeEdit=uicontrol(...
            'Parent',self.Panel,...
            'Style','popup',...
            'FontSize',8,...
            'Position',[20,20,40,20],...
            'String',{getString(message('phased:apps:waveformapp:Barker')),getString(message('phased:apps:waveformapp:Frank')),getString(message('phased:apps:waveformapp:P1')),getString(message('phased:apps:waveformapp:P2')),getString(message('phased:apps:waveformapp:P3')),getString(message('phased:apps:waveformapp:P4')),getString(message('phased:apps:waveformapp:Px')),getString(message('phased:apps:waveformapp:ZadoffChu'))},...
            'Value',1,...
            'Tag','Code',...
            'HorizontalAlignment','left',...
            'Callback',@(h,e)parameterChanged(self,e));
            self.Parent.View.notify('Componentsadd',phased.apps.internal.WaveformViewer.ComponentsEventData(self.CodeEdit))

            self.ChipWidthLabel=uicontrol(...
            'Parent',self.Panel,...
            'Style','text',...
            'FontSize',8,...
            'String',getString(message('phased:apps:waveformapp:ChipWidthLabel','Chip Width')),...
            'HorizontalAlignment','right');
            self.ChipWidthEdit=uicontrol(...
            'Parent',self.Panel,...
            'Style','edit',...
            'FontSize',8,...
            'Position',[20,20,40,20],...
            'String','1e-6',...
            'Tag','ChipWidth',...
            'HorizontalAlignment','left',...
            'Callback',@(h,e)parameterChanged(self,e));
            self.Parent.View.notify('Componentsadd',phased.apps.internal.WaveformViewer.ComponentsEventData(self.ChipWidthEdit))

            self.NumChipsLabel=uicontrol(...
            'Parent',self.Panel,...
            'Style','text',...
            'FontSize',8,...
            'String',getString(message('phased:apps:waveformapp:LabelWithColon','Number of Chips')),...
            'HorizontalAlignment','right');
            self.NumChipsEdit=uicontrol(...
            'Parent',self.Panel,...
            'Style','popup',...
            'FontSize',8,...
            'Position',[20,20,40,20],...
            'String',{'2','3','4','5','7','11','13'},...
            'Value',3,...
            'Tag','NumChips',...
            'HorizontalAlignment','left',...
            'Callback',@(h,e)parameterChanged(self,e));
            self.Parent.View.notify('Componentsadd',phased.apps.internal.WaveformViewer.ComponentsEventData(self.NumChipsEdit))

            self.PropagationSpeedLabel=uicontrol(...
            'Parent',self.Panel,...
            'Style','text',...
            'FontSize',8,...
            'String',getString(message('phased:apps:waveformapp:PropagationSpeedLabel','Propagation Speed')),...
            'HorizontalAlignment','right');
            self.PropagationSpeedEdit=uicontrol(...
            'Parent',self.Panel,...
            'Style','edit',...
            'String',num2str(physconst('LightSpeed')),...
            'FontSize',8,...
            'Position',[20,20,40,20],...
            'Tag','PropagationSpeed',...
            'HorizontalAlignment','left',...
            'Callback',@(h,e)parameterChanged(self,e));
            self.Parent.View.notify('Componentsadd',phased.apps.internal.WaveformViewer.ComponentsEventData(self.PropagationSpeedEdit))

            self.FrequencyOffsetLabel=uicontrol(...
            'Parent',self.Panel,...
            'Style','text',...
            'FontSize',8,...
            'String',getString(message('phased:apps:waveformapp:FrequencyOffsetLabel','Frequency Offset')),...
            'HorizontalAlignment','right');
            self.FrequencyOffsetEdit=uicontrol(...
            'Parent',self.Panel,...
            'Style','edit',...
            'String','0',...
            'FontSize',8,...
            'Position',[20,20,40,20],...
            'Tag','FrequencyOffset',...
            'HorizontalAlignment','left',...
            'Callback',@(h,e)parameterChanged(self,e));
            self.Parent.View.notify('Componentsadd',phased.apps.internal.WaveformViewer.ComponentsEventData(self.FrequencyOffsetEdit))

            self.SequenceIndexLabel=uicontrol(...
            'Parent',self.Panel,...
            'Style','text',...
            'FontSize',8,...
            'String',getString(message('phased:apps:waveformapp:LabelWithColon','Sequence Index')),...
            'Visible','off',...
            'HorizontalAlignment','right');
            self.SequenceIndexEdit=uicontrol(...
            'Parent',self.Panel,...
            'Style','edit',...
            'FontSize',8,...
            'Position',[20,20,40,20],...
            'String','1',...
            'Tag','SequenceIndex',...
            'Visible','off',...
            'HorizontalAlignment','left',...
            'Callback',@(h,e)parameterChanged(self,e));
            self.Parent.View.notify('Componentsadd',phased.apps.internal.WaveformViewer.ComponentsEventData(self.SequenceIndexEdit))
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
            'VerticalWeights',[0,0,0,0,0,0,0,0,0,0,1],...
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

            self.Parent.addPopup(self.Layout,self.PRFLabel,row,1,w1,height)
            self.Parent.addEdit(self.Layout,self.PRFEdit,row,2:3,w2,height)

            row=row+1;

            self.Parent.addText(self.Layout,self.NumPulsesLabel,row,1,w1,height)
            self.Parent.addEdit(self.Layout,self.NumPulsesEdit,row,2:3,w2,height)

            row=row+1;

            self.Parent.addText(self.Layout,self.CodeLabel,row,1,w1,height)
            self.Parent.addPopup(self.Layout,self.CodeEdit,row,2:3,w2,height)

            row=row+1;

            self.Parent.addText(self.Layout,self.ChipWidthLabel,row,1,w1,height)
            self.Parent.addEdit(self.Layout,self.ChipWidthEdit,row,2:3,w2,height)

            row=row+1;

            self.Parent.addText(self.Layout,self.NumChipsLabel,row,1,w1,height)
            self.Parent.addPopup(self.Layout,self.NumChipsEdit,row,2:3,w2,height)

            row=row+1;

            if isunix
                self.Parent.addText(self.Layout,self.PropagationSpeedLabel,row,1,w1+10,height)
            else
                self.Parent.addText(self.Layout,self.PropagationSpeedLabel,row,1,w1,height)
            end
            self.Parent.addEdit(self.Layout,self.PropagationSpeedEdit,row,2:3,w2,height)

            row=row+1;

            self.Parent.addText(self.Layout,self.FrequencyOffsetLabel,row,1,w1,height)
            self.Parent.addEdit(self.Layout,self.FrequencyOffsetEdit,row,2:3,w2,height)
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
            if strcmp(name,'Code')
                switch self.Code
                case getString(message('phased:apps:waveformapp:Barker'))
                    self.NumChipsEdit.Style='popup';
                    self.NumChipsEdit.String={'2','3','4','5','7','11','13'};
                    if numel(self.Parent.View.Parameters.ElementDialog.Layout.Grid)/3==9
                        remove(self.Layout,9,1);
                        remove(self.Layout,9,2);
                        self.SequenceIndexLabel.Visible='off';
                        self.SequenceIndexEdit.Visible='off';
                    end
                case getString(message('phased:apps:waveformapp:Frank'))
                    self.NumChipsEdit.Style='edit';
                    self.NumChipsEdit.String=4;
                    if numel(self.Parent.View.Parameters.ElementDialog.Layout.Grid)/3==9
                        remove(self.Layout,9,1);
                        remove(self.Layout,9,2);
                        self.SequenceIndexLabel.Visible='off';
                        self.SequenceIndexEdit.Visible='off';
                    end
                case getString(message('phased:apps:waveformapp:P1'))
                    self.NumChipsEdit.Style='edit';
                    self.NumChipsEdit.String=4;
                    if numel(self.Parent.View.Parameters.ElementDialog.Layout.Grid)/3==9
                        remove(self.Layout,9,1);
                        remove(self.Layout,9,2);
                        self.SequenceIndexLabel.Visible='off';
                        self.SequenceIndexEdit.Visible='off';
                    end
                case getString(message('phased:apps:waveformapp:P2'))
                    self.NumChipsEdit.Style='edit';
                    self.NumChipsEdit.String=4;
                    if numel(self.Parent.View.Parameters.ElementDialog.Layout.Grid)/3==9
                        remove(self.Layout,9,1);
                        remove(self.Layout,9,2);
                        self.SequenceIndexLabel.Visible='off';
                        self.SequenceIndexEdit.Visible='off';
                    end
                case getString(message('phased:apps:waveformapp:P3'))
                    self.NumChipsEdit.Style='edit';
                    self.NumChipsEdit.String=4;
                    if numel(self.Parent.View.Parameters.ElementDialog.Layout.Grid)/3==9
                        remove(self.Layout,9,1);
                        remove(self.Layout,9,2);
                        self.SequenceIndexLabel.Visible='off';
                        self.SequenceIndexEdit.Visible='off';
                    end
                case getString(message('phased:apps:waveformapp:P4'))
                    self.NumChipsEdit.Style='edit';
                    self.NumChipsEdit.String=4;
                    if numel(self.Parent.View.Parameters.ElementDialog.Layout.Grid)/3==9
                        remove(self.Layout,9,1);
                        remove(self.Layout,9,2);
                        self.SequenceIndexLabel.Visible='off';
                        self.SequenceIndexEdit.Visible='off';
                    end
                case getString(message('phased:apps:waveformapp:Px'))
                    self.NumChipsEdit.Style='edit';
                    self.NumChipsEdit.String=4;
                    if numel(self.Parent.View.Parameters.ElementDialog.Layout.Grid)/3==9
                        remove(self.Layout,9,1);
                        remove(self.Layout,9,2);
                        self.SequenceIndexLabel.Visible='off';
                        self.SequenceIndexEdit.Visible='off';
                    end
                case getString(message('phased:apps:waveformapp:ZadoffChu'))
                    self.NumChipsEdit.Style='edit';
                    self.NumChipsEdit.String=4;
                    self.Parent.addText(self.Layout,self.SequenceIndexLabel,9,1,130,24)
                    self.Parent.addEdit(self.Layout,self.SequenceIndexEdit,9,2:3,75,24)
                    self.SequenceIndexLabel.Visible='on';
                    self.SequenceIndexEdit.Visible='on';
                end
            end
            self.Parent.View.Canvas.AutoSelect=true;
        end
    end
end