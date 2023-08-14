classdef PhaseshiftDialog<handle







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

PhaseShift

ApplyEnableTag
    end

    properties(Dependent,SetObservable=true)
ApplyValue
    end

    properties(Access=private)
Title

NameLabel
NameEdit

PhaseShiftLabel
PhaseShiftEdit
PhaseShiftUnits

ApplyLabel
        IsReturnKey=0
        NameChanged=0
        OtherPropertiesChanged=0
    end

    methods


        function self=PhaseshiftDialog(parent)






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

        function val=get.PhaseShift(self)
            if self.Parent.View.UseAppContainer
                val=self.PhaseShiftEdit.Value;
            else
                val=str2num(self.PhaseShiftEdit.String);%#ok<*ST2NM>
            end
        end

        function set.PhaseShift(self,val)
            if self.Parent.View.UseAppContainer
                self.PhaseShiftEdit.Value=val;
            else
                self.PhaseShiftEdit.String=num2str(val);
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




            self.NameEdit.BackgroundColor=[1,1,1];
            self.PhaseShiftEdit.BackgroundColor=[1,1,1];

            self.OtherPropertiesChanged=0;
            self.NameChanged=0;
            self.ApplyLabel.Enable='off';

            self.Parent.View.setStatusBarMsg('');
        end

        function setListenersEnable(self,val)

            self.Listeners.Name.Enabled=val;
            self.Listeners.Phaseshift.Enabled=val;
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
            self.PhaseShiftEdit.Enable=val;

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
            'Dialog','phaseshift',...
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
                'Text',' Phase Shift Element',...
                'FontColor',[0,0,0],...
                'BackgroundColor',[.94,.94,.94],...
                'Tag','TitleLabel',...
                'HorizontalAlignment','left');

                self.NameLabel=uilabel(...
                'Parent',self.Layout,...
                'Text','Name',...
                'Tag','NameLabel',...
                'HorizontalAlignment','right');

                self.NameEdit=uieditfield(...
                'Parent',self.Layout,...
                'Value','Phaseshift',...
                'Tag','NameEditField',...
                'HorizontalAlignment','left');

                self.PhaseShiftLabel=uilabel(...
                'Parent',self.Layout,...
                'Text','Phase Shift',...
                'Tag','PhaseShiftLabel',...
                'HorizontalAlignment','right');

                self.PhaseShiftEdit=uieditfield(...
                'numeric',...
                'Parent',self.Layout,...
                'Value',90,...
                'Tag','PhaseShiftEditField',...
                'HorizontalAlignment','left');

                self.PhaseShiftUnits=uilabel(...
                'Parent',self.Layout,...
                'Text','Degrees',...
                'Tag','PhaseShiftUnitsLabel',...
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
                'String',' Phase Shift Element',...
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
                'String','Phaseshift',...
                'Tag','Name',...
                'HorizontalAlignment','left');


                self.PhaseShiftLabel=uicontrol(...
                'Parent',self.Panel,...
                'Style','text',...
                'String','Phase Shift',...
                'HorizontalAlignment','right');

                self.PhaseShiftEdit=uicontrol(...
                'Parent',self.Panel,...
                'Style','edit',...
                'String','90',...
                'Tag','PhaseShift',...
                'HorizontalAlignment','left');

                self.PhaseShiftUnits=uicontrol(...
                'Parent',self.Panel,...
                'Style','text',...
                'String','Degrees',...
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
            self.Parent.addText(self.Layout,self.PhaseShiftLabel,row,1,w1,h,self.Parent.View.UseAppContainer)
            self.Parent.addEdit(self.Layout,self.PhaseShiftEdit,row,2,w2,h,self.Parent.View.UseAppContainer)
            self.Parent.addPopup(self.Layout,self.PhaseShiftUnits,row,3,w3,h,self.Parent.View.UseAppContainer)

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
                if any(strcmpi(key,...
                    {'leftarrow',...
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

                case{'NameEditField','Name'}
                    self.NameEdit.BackgroundColor=[1,0.96,0.88];
                    self.ApplyLabel.Enable='on';
                    self.Parent.View.setStatusBarMsg('Click ''Apply'' or hit ''Enter'' to update Phase Shift parameters.');

                case{'ApplyButton','ApplyTag'}
                    try
                        applyflag=0;
                        self.applyFunction()
                    catch me
                        h=errordlg(me.message,'Error Dialog','modal');
                        uiwait(h)
                        self.Parent.View.enableActions(true);
                    end
                case{'PhaseShift','PhaseShiftEditField'}
                    self.PhaseShiftEdit.BackgroundColor=[1,0.96,0.88];
                    self.ApplyLabel.Enable='on';
                    self.Parent.View.setStatusBarMsg('Click ''Apply'' or hit ''Enter'' to update Phase Shift parameters.');

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
                self.Parent.View.setStatusBarMsg('Click ''Apply'' to update Phase Shift parameters.');
                self.Parent.notify('DisableCanvas',...
                rf.internal.apps.budget.ElementParameterChangedEventData(i,name,'off'));
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

            psObj=simrfV2_phaseshifter_design(self);

            if self.Parent.View.UseAppContainer
                self.Parent.notify('DisableCanvas',...
                rf.internal.apps.budget.ElementParameterChangedEventData(i,'ApplyButton','inactive'));
            else
                self.Parent.notify('DisableCanvas',...
                rf.internal.apps.budget.ElementParameterChangedEventData(i,'ApplyTag','inactive'));
            end
            if self.NameChanged&&~self.OtherPropertiesChanged
                self.Parent.notify('ElementParameterChanged',...
                rf.internal.apps.budget.ElementParameterChangedEventData(i,'Name',self.NameEdit.(valueString)));
            else
                self.Parent.notify('ElementParameterChanged',...
                rf.internal.apps.budget.ElementParameterChangedEventData(i,'ApplyTag',psObj));
            end



            self.NameEdit.BackgroundColor=[1,1,1];
            self.PhaseShiftEdit.BackgroundColor=[1,1,1];

            self.ApplyLabel.Enable='off';
            self.Parent.View.setStatusBarMsg('');
            self.IsReturnKey=0;
            enableIP2(self.Parent.View.Toolstrip,false);
            self.NameChanged=0;
            self.OtherPropertiesChanged=0;
            self.Parent.View.enableActions(true);
        end

        function FigKeyEvent(self,ev)

            if isa(self.Parent.ElementDialog,'rf.internal.apps.budget.PhaseshiftDialog')
                key=ev.Key;
                switch key
                case 'return'
                    self.IsReturnKey=1;
                end
            end
        end

        function FigKeyEventCanvas(self,ev)


            if isa(self.Parent.ElementDialog,'rf.internal.apps.budget.PhaseshiftDialog')

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
                self.PhaseShiftEdit.ValueChangedFcn=@(h,e)parameterChanged(self,e);
                self.ApplyLabel.ButtonPushedFcn=@(h,e)parameterChanged(self,e);
            else
                self.NameEdit.KeyPressFcn=@(h,e)parameterChanged(self,e);
                self.PhaseShiftEdit.KeyPressFcn=@(h,e)parameterChanged(self,e);
                self.Listeners.ApplyLabel=addlistener(self.ApplyLabel,'Value',...
                'PostSet',@(h,e)parameterChanged(self,e));
            end
        end

        function psObj=simrfV2_phaseshifter_design(self)


            psObj=phaseshift(...
            'Name',self.Name,...
            'PhaseShift',self.PhaseShift);
        end
    end
end



