classdef LCLadderDialog<handle







    properties
Parent
Panel
Layout
        Width=0
        Height=0
Listeners
    end

    properties(Dependent)

Name

Topology

Inductances

Capacitances

ApplyEnableTag
    end

    properties(Dependent,SetObservable=true)
ApplyValue
    end

    properties(Access=private)
Title

NameLabel
NameEdit

TopologyLabel
TopologyPopup

InductancesLabel
InductancesEdit
InductancesUnits

CapacitancesLabel
CapacitancesEdit
CapacitancesUnits

ApplyLabel
        IsReturnKey=0
        NameChanged=0
        OtherPropertiesChanged=0
    end

    properties(Access=private)

        DefaultInductances_lpt=[1.3324,1.3324]*1e-5
        DefaultCapacitances_lpt=1.1327e-9


        DefaultInductances_lpp=3.1800e-08
        DefaultCapacitances_lpp=[6.3700,6.3700]*1e-12


        DefaultInductances_hpt=5.5907e-6
        DefaultCapacitances_hpt=[4.7524,4.7524]*1e-10


        DefaultInductances_hpp=[1.1881,1.1881]*1e-6
        DefaultCapacitances_hpp=2.2363e-9


        DefaultInductances_bpt=[2.7812e-8,3.013e-9,2.7812e-8]
        DefaultCapacitances_bpt=[1.8587e-12,1.7157e-11,1.8587e-12]


        DefaultInductances_bpp=[1.4446e-9,4.3949e-8,1.4446e-9]
        DefaultCapacitances_bpp=[3.5785e-11,1.1762e-12,3.5785e-11]


        DefaultInductances_bst=[2.7908e-9,4.9321e-8,2.7908e-9]
        DefaultCapacitances_bst=[1.8523e-11,1.0481e-12,1.8523e-11]


        DefaultInductances_bsp=[2.8091e-8,2.2603e-9,2.8091e-8]
        DefaultCapacitances_bsp=[1.8403e-12,2.2871e-11,1.8403e-12]

    end

    methods


        function self=LCLadderDialog(parent)






            if nargin==0
                parent=figure;
            end
            self.Parent=parent;

            createUIControls(self)
            layoutUIControls(self)
            addListeners(self)
        end

    end

    methods


        function str=get.Name(self)
            if self.Parent.View.UseAppContainer
                str=self.NameEdit.Value;
            else
                str=self.NameEdit.String;
            end
        end

        function set.Name(self,str)
            if self.Parent.View.UseAppContainer
                self.NameEdit.Value=str;
            else
                self.NameEdit.String=str;
            end
        end

        function str=get.Topology(self)
            if self.Parent.View.UseAppContainer
                str=self.TopologyPopup.Value;
            else
                str=self.TopologyPopup.String{self.TopologyPopup.Value};
            end
        end

        function set.Topology(self,str)
            if self.Parent.View.UseAppContainer
                switch str
                case 'lowpasstee'
                    self.TopologyPopup.Value='Lowpass Tee';
                case 'lowpasspi'
                    self.TopologyPopup.Value='Lowpass Pi';
                case 'highpasstee'
                    self.TopologyPopup.Value='Highpass Tee';
                case 'highpasspi'
                    self.TopologyPopup.Value='Highpass Pi';
                case 'bandpasstee'
                    self.TopologyPopup.Value='Bandpass Tee';
                case 'bandpasspi'
                    self.TopologyPopup.Value='Bandpass Pi';
                case 'bandstoptee'
                    self.TopologyPopup.Value='Bandstop Tee';
                case 'bandstoppi'
                    self.TopologyPopup.Value='Bandstop Pi';
                end
            else
                switch str
                case 'lowpasstee'
                    self.TopologyPopup.Value=1;
                case 'lowpasspi'
                    self.TopologyPopup.Value=2;
                case 'highpasstee'
                    self.TopologyPopup.Value=3;
                case 'highpasspi'
                    self.TopologyPopup.Value=4;
                case 'bandpasstee'
                    self.TopologyPopup.Value=5;
                case 'bandpasspi'
                    self.TopologyPopup.Value=6;
                case 'bandstoptee'
                    self.TopologyPopup.Value=7;
                case 'bandstoppi'
                    self.TopologyPopup.Value=8;
                end
            end
        end

        function val=get.Inductances(self)
            if self.Parent.View.UseAppContainer
                val=str2num(self.InductancesEdit.Value);
            else
                val=str2num(self.InductancesEdit.String);%#ok<*ST2NM>
            end
        end

        function set.Inductances(self,val)
            if self.Parent.View.UseAppContainer
                self.InductancesEdit.Value=mat2str(val);
            else
                self.InductancesEdit.String=mat2str(val);
            end
        end

        function val=get.Capacitances(self)
            if self.Parent.View.UseAppContainer
                val=str2num(self.CapacitancesEdit.Value);
            else
                val=str2num(self.CapacitancesEdit.String);
            end
        end

        function set.Capacitances(self,val)
            if self.Parent.View.UseAppContainer
                self.CapacitancesEdit.Value=mat2str(val);
            else
                self.CapacitancesEdit.String=mat2str(val);
            end
        end

        function set.ApplyValue(self,val)
            if self.Parent.View.UseAppContainer
            else
                self.ApplyLabel.Value=val;
            end
        end

        function val=get.ApplyValue(self)
            if self.Parent.View.UseAppContainer
                val=-1;
            else
                val=self.ApplyLabel.Value;
            end
        end

        function val=get.ApplyEnableTag(self)
            val=self.ApplyLabel.Enable;
        end

        function resetDialogAccess(self)


            whiteColor=[1,1,1];

            self.NameEdit.BackgroundColor=whiteColor;
            self.InductancesEdit.BackgroundColor=whiteColor;
            self.CapacitancesEdit.BackgroundColor=whiteColor;
            self.TopologyPopup.BackgroundColor=whiteColor;

            self.OtherPropertiesChanged=0;
            self.NameChanged=0;
            self.ApplyLabel.Enable='off';

            self.Parent.View.setStatusBarMsg('');
        end

        function setListenersEnable(self,val)

            self.Listeners.Name.Enabled=val;
            self.Listeners.Topology.Enabled=val;
            self.Listeners.Inductances.Enabled=val;
            self.Listeners.Capacitances.Enabled=val;
        end

        function setFigureKeyPress(self)




            if self.Parent.View.UseAppContainer
                set(self.Parent.View.ParametersFig.Figure,...
                'KeyPressFcn',@(h,e)FigKeyEventCanvas(self,e));
                self.Listeners.KeyPress=addlistener(...
                self.Parent.View.ParametersFig.Figure,...
                'WindowKeyPress',@(h,e)FigKeyEvent(self,e));
            else
                set(self.Parent.View.ParametersFig,...
                'KeyPressFcn',@(h,e)FigKeyEventCanvas(self,e));
                self.Listeners.KeyPress=addlistener(...
                self.Parent.View.ParametersFig,...
                'WindowKeyPress',@(h,e)FigKeyEvent(self,e));
            end
        end

        function enableUIControls(self,val)




            if~val
                val='off';
            else
                val='on';
            end
            self.NameEdit.Enable=val;
            self.CapacitancesEdit.Enable=val;
            self.InductancesEdit.Enable=val;
            self.TopologyPopup.Enable=val;
            if strcmpi(val,'on')
                if self.OtherPropertiesChanged||self.NameChanged
                    self.ApplyLabel.Enable='on';
                else
                    self.ApplyLabel.Enable='off';
                end
            else
                self.ApplyLabel.Enable='off';
            end
        end
    end

    methods(Access=private)


        function createUIControls(self)


            userData=struct(...
            'Dialog','lcladder',...
            'Stage',self.Parent.SelectedStage);
            if self.Parent.View.UseAppContainer

                self.Layout=uigridlayout(...
                'Parent',self.Parent.View.ParametersFig.Figure,...
                'Scrollable','on',...
                'Tag','Layout',...
                'RowSpacing',3,...
                'ColumnSpacing',2,...
                'Visible','off');

                self.Title=uilabel(...
                'Parent',self.Layout,...
                'Text',' LC Ladder Element',...
                'FontColor',[0,0,0],...
                'Tag','TitleLabel',...
                'BackgroundColor',[.94,.94,.94],...
                'HorizontalAlignment','left');

                self.NameLabel=uilabel(...
                'Parent',self.Layout,...
                'Text','Name',...
                'Tag','NameLabel',...
                'HorizontalAlignment','right');

                self.NameEdit=uieditfield(...
                'Parent',self.Layout,...
                'Value','LC Ladder',...
                'Tag','NameEditField',...
                'HorizontalAlignment','left');

                self.TopologyLabel=uilabel(...
                'Parent',self.Layout,...
                'Text','Topology',...
                'Tag','TopolgyLabel',...
                'HorizontalAlignment','right');

                self.TopologyPopup=uidropdown(...
                'Parent',self.Layout,...
                'Items',{'Lowpass Tee','Lowpass Pi','Highpass Tee',...
                'Highpass Pi','Bandpass Tee','Bandpass Pi','Bandstop Tee',...
                'Bandstop Pi'},...
                'Tag','TopologyDropdown',...
                'Value','Lowpass Tee');

                self.InductancesLabel=uilabel(...
                'Parent',self.Layout,...
                'Text','Inductances',...
                'Tag','InductancesLabel',...
                'HorizontalAlignment','right');

                self.InductancesEdit=uieditfield(...
                'Parent',self.Layout,...
                'Value','3.1800e-08',...
                'Tag','InductancesEditField',...
                'HorizontalAlignment','left');

                self.InductancesUnits=uilabel(...
                'Parent',self.Layout,...
                'Text','H',...
                'Tag','InductancesUnitsLabel',...
                'HorizontalAlignment','left');

                self.CapacitancesLabel=uilabel(...
                'Parent',self.Layout,...
                'Text','Capacitances',...
                'Tag','CapacitancesLabel',...
                'HorizontalAlignment','right');

                self.CapacitancesEdit=uieditfield(...
                'Parent',self.Layout,...
                'Value','[6.3700e-12 6.3700e-12]',...
                'Tag','CapacitancesEditField',...
                'HorizontalAlignment','left');

                self.CapacitancesUnits=uilabel(...
                'Parent',self.Layout,...
                'Text','F',...
                'Tag','CapacitancesUnitsLabel',...
                'HorizontalAlignment','left');

                self.ApplyLabel=uibutton(...
                'Parent',self.Layout,...
                'Text','Apply',...
                'Tag','ApplyButton',...
                'HorizontalAlignment','center',...
                'Tooltip','Apply parameters to selected Element (Enter)');

                for i=1:length(self.Layout.RowHeight)
                    self.Layout.RowHeight{i}=29;
                end
            else

                self.Panel=uipanel(...
                'Parent',self.Parent.View.ParametersFig,...
                'Title','',...
                'BorderType','line',...
                'HighlightColor',[.5,.5,.5],...
                'Visible','on');

                self.Title=uicontrol(...
                'Parent',self.Panel,...
                'Style','text',...
                'String',' LC Ladder Element',...
                'ForegroundColor',[0,0,0],...
                'BackgroundColor',[.94,.94,.94],...
                'HorizontalAlignment','left');

                self.NameLabel=uicontrol(...
                'Parent',self.Panel,...
                'Style','text',...
                'String','Name',...
                'HorizontalAlignment','right');

                self.NameEdit=uicontrol(...
                'Parent',self.Panel,...
                'Style','edit',...
                'String','LC Ladder',...
                'Tag','Name',...
                'HorizontalAlignment','left');

                self.TopologyLabel=uicontrol(...
                'Parent',self.Panel,...
                'Style','text',...
                'String','Topology',...
                'HorizontalAlignment','right');

                self.TopologyPopup=uicontrol(...
                'Parent',self.Panel,...
                'Style','popup',...
                'String',{'Lowpass Tee','Lowpass Pi','Highpass Tee',...
                'Highpass Pi','Bandpass Tee','Bandpass Pi','Bandstop Tee',...
                'Bandstop Pi'},...
                'Tag','Topology',...
                'Value',1,...
                'HorizontalAlignment','left');

                self.InductancesLabel=uicontrol(...
                'Parent',self.Panel,...
                'Style','text',...
                'String','Inductances',...
                'HorizontalAlignment','right');

                self.InductancesEdit=uicontrol(...
                'Parent',self.Panel,...
                'Style','edit',...
                'String','3.1800e-08',...
                'Tag','Inductances',...
                'HorizontalAlignment','left');

                self.InductancesUnits=uicontrol(...
                'Parent',self.Panel,...
                'Style','text',...
                'String','H',...
                'HorizontalAlignment','left');

                self.CapacitancesLabel=uicontrol(...
                'Parent',self.Panel,...
                'Style','text',...
                'String','Capacitances',...
                'HorizontalAlignment','right');

                self.CapacitancesEdit=uicontrol(...
                'Parent',self.Panel,...
                'Style','edit',...
                'String','[6.3700e-12 6.3700e-12]',...
                'Tag','Capacitances',...
                'HorizontalAlignment','left');

                self.CapacitancesUnits=uicontrol(...
                'Parent',self.Panel,...
                'Style','text',...
                'String','F',...
                'HorizontalAlignment','left');

                self.ApplyLabel=uicontrol(...
                'Parent',self.Panel,...
                'Style','pushbutton',...
                'String','Apply',...
                'Tag','ApplyTag',...
                'HorizontalAlignment','right',...
                'Value',0,...
                'Tooltip','Apply parameters to selected Element (Enter)');
            end
        end


        function layoutUIControls(self,~)


            hspacing=3;
            vspacing=4;
            w1=rf.internal.apps.budget.SystemParametersSection.Width1;
            w2=rf.internal.apps.budget.SystemParametersSection.Width2;
            w3=rf.internal.apps.budget.SystemParametersSection.Width3;
            titleHt=16;
            if self.Parent.View.UseAppContainer
            else
                self.Layout=...
                matlabshared.application.layout.GridBagLayout(...
                self.Panel,...
                'VerticalGap',vspacing,...
                'HorizontalGap',hspacing,...
                'HorizontalWeights',[0,1,0]);
            end

            row=1;
            self.Parent.addTitle(self.Layout,self.Title,row,[1,3],...
            titleHt,hspacing,vspacing,self.Parent.View.UseAppContainer)

            h=24;
            row=row+1;
            self.Parent.addText(self.Layout,self.NameLabel,row,1,w1,h,self.Parent.View.UseAppContainer)
            self.Parent.addEdit(self.Layout,self.NameEdit,row,2,w2,h,self.Parent.View.UseAppContainer)

            row=row+1;
            self.Parent.addText(self.Layout,self.TopologyLabel,row,1,w1,h,self.Parent.View.UseAppContainer)
            self.Parent.addPopup(self.Layout,self.TopologyPopup,row,2,w2,h,self.Parent.View.UseAppContainer)

            row=row+1;
            self.Parent.addText(self.Layout,self.InductancesLabel,row,1,w1,h,self.Parent.View.UseAppContainer)
            self.Parent.addEdit(self.Layout,self.InductancesEdit,row,2,w2,h,self.Parent.View.UseAppContainer)
            self.Parent.addPopup(self.Layout,self.InductancesUnits,row,3,w3,h,self.Parent.View.UseAppContainer)

            row=row+1;
            self.Parent.addText(self.Layout,self.CapacitancesLabel,row,1,w1,h,self.Parent.View.UseAppContainer)
            self.Parent.addEdit(self.Layout,self.CapacitancesEdit,row,2,w2,h,self.Parent.View.UseAppContainer)
            self.Parent.addText(self.Layout,self.CapacitancesUnits,row,3,w3,h,self.Parent.View.UseAppContainer)

            row=row+1;
            self.Parent.addButton(self.Layout,self.ApplyLabel,row,2,w3,h+10,self.Parent.View.UseAppContainer)

            if self.Parent.View.UseAppContainer
                w=500;
                h=500;
                self.Width=sum(w);
                self.Height=max(h(2:end-1))*numel(h(2:end))+(titleHt+2)+10;
                self.Layout.Visible='on';
            else
                [~,~,w,h]=getMinimumSize(self.Layout);
                self.Width=sum(w)+self.Layout.HorizontalGap*(numel(w)+1);
                self.Height=max(h(2:end-1))*numel(h(2:end))+...
                self.Layout.VerticalGap*(numel(h(2:end-1))+1)+(titleHt+2)+10;
            end
        end

        function parameterChanged(self,e)


            i=self.Parent.View.Canvas.SelectIdx;
            if strcmpi(e.EventName,'PostSet')||...
                strcmpi(e.EventName,'ValueChanged')||...
                strcmpi(e.EventName,'ButtonPushed')

                if self.Parent.View.UseAppContainer
                    name=e.Source.Tag;
                    uiObject=e.Source;
                    uiObjectType=class(uiObject);
                else
                    name=e.AffectedObject.Tag;
                    uiObject=e.AffectedObject;
                    uiObjectType=uiObject.Style;
                end
                key='';
            elseif strcmpi(e.EventName,'KeyPress')

                name=e.Source.Tag;
                uiObject=e.Source;
                if self.Parent.View.UseAppContainer
                    a=get(self.Parent.View.ParametersFig.Figure,'CurrentCharacter');
                    uiObjectType=class(uiObject);
                else
                    a=get(self.Parent.View.ParametersFig,'CurrentCharacter');
                    uiObjectType=uiObject.Style;
                end
                if isempty(a)


                    return
                end
                key=e.Key;
                if any(strcmpi(key,{'leftarrow',...
                    'uparrow',...
                    'downarrow',...
                    'rightarrow'}))

                    return
                end
            end
            drawnow;
            applyflag=1;

            if~strcmpi(name,'ApplyButton')||~strcmpi(name,'ApplyTag')
                if~any(strcmpi(uiObjectType,{'popupmenu','matlab.ui.control.DropDown'}))

                    if~strcmpi(key,'return')



                        if strcmpi(name,'NameEditField')||strcmpi(name,'Name')
                            self.NameChanged=1;
                        else
                            self.OtherPropertiesChanged=1;
                        end
                    end
                else
                    if~strcmpi(key,'return')&&~strcmpi(key,'')


                        return;
                    else
                        if strcmpi(key,'')

                            self.OtherPropertiesChanged=1;
                        end
                    end
                end
            end

            if~strcmpi(key,'return')
                switch name
                case{'Topology','TopologyDropdown'}
                    self.TopologyPopup.BackgroundColor=[1,0.96,0.88];
                    self.ApplyLabel.Enable='on';
                    self.Parent.View.setStatusBarMsg('Click ''Apply'' or hit ''Enter'' to update lcladder parameters.');


                    newStr=lower(regexprep(self.Topology,'ow|igh|and|ass |top |i|ee',''));
                    self.Inductances=self.(['DefaultInductances_',newStr]);
                    self.InductancesEdit.BackgroundColor=[1,0.96,0.88];
                    self.Capacitances=self.(['DefaultCapacitances_',newStr]);
                    self.CapacitancesEdit.BackgroundColor=[1,0.96,0.88];

                case{'NameEditField','Name'}
                    self.NameEdit.BackgroundColor=[1,0.96,0.88];
                    self.ApplyLabel.Enable='on';
                    self.Parent.View.setStatusBarMsg('Click ''Apply'' or hit ''Enter'' to update lcladder parameters.');



                case{'ApplyButton','ApplyTag'}
                    try
                        applyflag=0;
                        self.applyFunction()
                    catch me
                        h=errordlg(me.message,'Error Dialog','modal');
                        uiwait(h)
                        self.Parent.View.enableActions(true);
                    end
                case{'InductancesEditField','Inductances'}
                    self.InductancesEdit.BackgroundColor=[1,0.96,0.88];
                    self.ApplyLabel.Enable='on';
                    self.Parent.View.setStatusBarMsg('Click ''Apply'' or hit ''Enter'' to update lcladder parameters.');



                case{'CapacitancesEditField','Capacitances'}
                    self.CapacitancesEdit.BackgroundColor=[1,0.96,0.88];
                    self.ApplyLabel.Enable='on';
                    self.Parent.View.setStatusBarMsg('Click ''Apply'' or hit ''Enter'' to update lcladder parameters.');



                end
            end

            if self.IsReturnKey
                try
                    applyflag=0;
                    self.applyFunction();
                catch me
                    h=errordlg(me.message,'Error Dialog','modal');
                    uiwait(h)
                    self.Parent.View.enableActions(true);
                end
            end
            self.IsReturnKey=0;
            if applyflag
                self.ApplyLabel.Enable='on';
                self.Parent.View.setStatusBarMsg('Click ''Apply'' to update lcladder parameters.');
                if self.Parent.View.UseAppContainer
                    self.Parent.notify('DisableCanvas',...
                    rf.internal.apps.budget.ElementParameterChangedEventData(i,...
                    'ApplyButton','off'));
                else
                    self.Parent.notify('DisableCanvas',...
                    rf.internal.apps.budget.ElementParameterChangedEventData(i,...
                    'ApplyTag','off'));
                end
            end
        end

        function applyFunction(self)


            if self.Parent.View.UseAppContainer
                valueString='Value';
            else
                valueString='String';
            end
            if~self.NameChanged&&~self.OtherPropertiesChanged
                self.IsReturnKey=0;
                i=self.Parent.View.Canvas.SelectIdx;
                if self.Parent.View.UseAppContainer
                    self.Parent.notify('DisableCanvas',...
                    rf.internal.apps.budget.ElementParameterChangedEventData(i,'ApplyButton','inactive'));
                else
                    self.Parent.notify('DisableCanvas',...
                    rf.internal.apps.budget.ElementParameterChangedEventData(i,'ApplyTag','inactive'));
                end
                return;
            end
            self.Parent.View.enableActions(false);
            i=self.Parent.View.Canvas.SelectIdx;

            ladderObj=simrfV2_lcladder_design(self);

            if self.Parent.View.UseAppContainer
                self.Parent.notify('DisableCanvas',...
                rf.internal.apps.budget.ElementParameterChangedEventData(i,'ApplyButton','inactive'));
            else
                self.Parent.notify('DisableCanvas',...
                rf.internal.apps.budget.ElementParameterChangedEventData(i,'ApplyTag','inactive'));
            end
            if self.NameChanged&&~self.OtherPropertiesChanged
                self.Parent.notify('ElementParameterChanged',...
                rf.internal.apps.budget.ElementParameterChangedEventData(i,...
                'Name',self.NameEdit.(valueString)));
            else
                if self.Parent.View.UseAppContainer
                    self.Parent.notify('ElementParameterChanged',...
                    rf.internal.apps.budget.ElementParameterChangedEventData(i,...
                    'ApplyButton',ladderObj));
                else
                    self.Parent.notify('ElementParameterChanged',...
                    rf.internal.apps.budget.ElementParameterChangedEventData(i,...
                    'ApplyTag',ladderObj));
                end
            end

            str=lower(regexprep(self.Topology,' +',''));
            self.Parent.notify('IconUpdate',...
            rf.internal.apps.budget.ElementParameterChangedEventData(i,...
            'Topology',str));


            self.NameEdit.BackgroundColor=[1,1,1];
            self.TopologyPopup.BackgroundColor=[1,1,1];
            self.InductancesEdit.BackgroundColor=[1,1,1];
            self.CapacitancesEdit.BackgroundColor=[1,1,1];

            self.ApplyLabel.Enable='off';
            self.Parent.View.setStatusBarMsg('');
            self.IsReturnKey=0;
            enableIP2(self.Parent.View.Toolstrip,false);
            self.NameChanged=0;
            self.OtherPropertiesChanged=0;
            self.Parent.View.enableActions(true);
        end

        function FigKeyEvent(self,ev)

            if isa(self.Parent.ElementDialog,'rf.internal.apps.budget.LCLadderDialog')
                key=ev.Key;
                switch key
                case 'return'
                    self.IsReturnKey=1;
                end
            end
        end

        function FigKeyEventCanvas(self,ev)


            if isa(self.Parent.ElementDialog,'rf.internal.apps.budget.LCLadderDialog')

                key=ev.Key;
                if strcmpi(key,'return')
                    try
                        self.applyFunction();
                    catch me
                        h=errordlg(me.message,'Error Dialog','modal');
                        uiwait(h)
                        self.Parent.View.enableActions(true);
                    end
                end
            end
        end


        function addListeners(self)


            if self.Parent.View.UseAppContainer
                self.NameEdit.ValueChangedFcn=@(h,e)parameterChanged(self,e);
                self.TopologyPopup.ValueChangedFcn=@(h,e)parameterChanged(self,e);
                self.InductancesEdit.ValueChangedFcn=@(h,e)parameterChanged(self,e);
                self.CapacitancesEdit.ValueChangedFcn=@(h,e)parameterChanged(self,e);
                self.ApplyLabel.ButtonPushedFcn=@(h,e)parameterChanged(self,e);
            else
                self.NameEdit.KeyPressFcn=@(h,e)parameterChanged(self,e);
                self.Listeners.Topology=addlistener(self.TopologyPopup,'Value',...
                'PostSet',@(h,e)parameterChanged(self,e));
                self.TopologyPopup.KeyPressFcn=@(h,e)parameterChanged(self,e);
                self.InductancesEdit.KeyPressFcn=@(h,e)parameterChanged(self,e);
                self.CapacitancesEdit.KeyPressFcn=@(h,e)parameterChanged(self,e);

                self.Listeners.ApplyLabel=addlistener(self.ApplyLabel,'Value',...
                'PostSet',@(h,e)parameterChanged(self,e));
            end
        end

        function ladderObj=simrfV2_lcladder_design(self)


            str=lower(regexprep(self.Topology,' +',''));
            ladderObj=lcladder(str,...
            self.Inductances,...
            self.Capacitances,...
            self.Name);
        end
    end
end




