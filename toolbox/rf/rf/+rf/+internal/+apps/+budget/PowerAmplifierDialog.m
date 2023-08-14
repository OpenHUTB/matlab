classdef PowerAmplifierDialog<handle






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
CoefficientMatrix
Rin
Rout
    end

    properties(Access=private)

Title

NameLabel
NameEdit

CoefficientMatrixLabel
CoefficientMatrixEdit
CoefficientMatrixUnits

RinLabel
RinEdit
RinUnits

RoutLabel
RoutEdit
RoutUnits

ApplyLabel

        IsReturnKey=0
        NameChanged=0
        OtherPropertiesChanged=0
    end

    methods




        function self=PowerAmplifierDialog(parent)






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

        function val=get.CoefficientMatrix(self)
            if self.Parent.View.UseAppContainer
                val=str2num(self.CoefficientMatrixEdit.Value);
            else
                val=str2num(self.CoefficientMatrixEdit.String);%#ok<*ST2NM>
            end
        end

        function set.CoefficientMatrix(self,val)
            if self.Parent.View.UseAppContainer
                self.CoefficientMatrixEdit.Value=mat2str(val);
            else
                self.CoefficientMatrixEdit.String=mat2str(val);
            end
        end

        function val=get.Rin(self)
            if self.Parent.View.UseAppContainer
                val=self.RinEdit.Value;
            else
                val=str2num(self.RinEdit.String);
            end
        end

        function set.Rin(self,val)
            if self.Parent.View.UseAppContainer
                self.RinEdit.Value=val;
            else
                self.RinEdit.String=num2str(val);
            end
        end

        function val=get.Rout(self)
            if self.Parent.View.UseAppContainer
                val=self.RoutEdit.Value;
            else
                val=str2num(self.RoutEdit.String);
            end
        end

        function set.Rout(self,val)
            if self.Parent.View.UseAppContainer
                self.RoutEdit.Value=val;
            else
                self.RoutEdit.String=num2str(val);
            end
        end
        function resetDialogAccess(self)

            whiteColor=[1,1,1];
            self.NameEdit.BackgroundColor=whiteColor;
            self.CoefficientMatrixEdit.BackgroundColor=whiteColor;
            self.RinEdit.BackgroundColor=whiteColor;
            self.RoutEdit.BackgroundColor=whiteColor;


            self.OtherPropertiesChanged=0;
            self.NameChanged=0;
            self.ApplyLabel.Enable='off';
            self.Parent.View.setStatusBarMsg('');
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
            self.CoefficientMatrixEdit.Enable=val;
            self.RinEdit.Enable=val;
            self.RoutEdit.Enable=val;

            if strcmpi(val,'on')
                if self.OtherPropertiesChanged||...
                    self.NameChanged
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
            'Dialog','powerAmplifier',...
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
                'UserData',userData,...
                'Tag','TitleLabel',...
                'Parent',self.Layout,...
                'Text',' Power Amplifier Element',...
                'FontColor',[0,0,0],...
                'BackgroundColor',[.94,.94,.94],...
                'HorizontalAlignment','left');

                self.NameLabel=uilabel(...
                'UserData',userData,...
                'Tag','NameLabel',...
                'Parent',self.Layout,...
                'Text','Name',...
                'HorizontalAlignment','right');
                self.NameEdit=uieditfield(...
                'UserData',userData,...
                'Tag','NameEditField',...
                'Parent',self.Layout,...
                'Value','Power Amplifier',...
                'HorizontalAlignment','left');

                self.CoefficientMatrixLabel=uilabel(...
                'UserData',userData,...
                'Tag','CoefficientMatrixLabel',...
                'Parent',self.Layout,...
                'Text','Coefficient Matrix',...
                'HorizontalAlignment','right');
                self.CoefficientMatrixEdit=uieditfield(...
                'text',...
                'UserData',userData,...
                'Tag','CoefficientMatrixEditField',...
                'Parent',self.Layout,...
                'Value','1',...
                'HorizontalAlignment','left');
                self.CoefficientMatrixUnits=uilabel(...
                'UserData',userData,...
                'Tag','CoefficientMatrixUnitsLabel',...
                'Parent',self.Layout,...
                'Text','',...
                'HorizontalAlignment','left');

                self.RinLabel=uilabel(...
                'UserData',userData,...
                'Tag','RinLabel',...
                'Parent',self.Layout,...
                'Text','Input Resistance',...
                'HorizontalAlignment','right');
                self.RinEdit=uieditfield(...
                'numeric',...
                'UserData',userData,...
                'Tag','RinEditField',...
                'Parent',self.Layout,...
                'Value',50,...
                'Tag',...
                'Rin',...
                'HorizontalAlignment','left');
                self.RinUnits=uilabel(...
                'UserData',userData,...
                'Tag','RinUnitsLabel',...
                'Parent',self.Layout,...
                'Text','Ohm',...
                'HorizontalAlignment','left');

                self.RoutLabel=uilabel(...
                'UserData',userData,...
                'Tag','RoutLabel',...
                'Parent',self.Layout,...
                'Text','Output Resistance',...
                'HorizontalAlignment','right');
                self.RoutEdit=uieditfield(...
                'numeric',...
                'UserData',userData,...
                'Tag','RoutEditField',...
                'Parent',self.Layout,...
                'Value',50,...
                'Tag',...
                'Rout',...
                'HorizontalAlignment','left');
                self.RoutUnits=uilabel(...
                'UserData',userData,...
                'Tag','RoutUnitsLabel',...
                'Parent',self.Layout,...
                'Text','Ohm',...
                'HorizontalAlignment','left');

                self.ApplyLabel=uibutton(...
                'Tag','ApplyButton',...
                'Parent',self.Layout,...
                'Text','Apply',...
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
                'Visible','on',...
                'AutoResizeChildren','off');

                self.Title=uicontrol(...
                'UserData',userData,...
                'Parent',self.Panel,...
                'Style','text',...
                'Tag','TitleLabel',...
                'String',' PowerAmplifier Element',...
                'ForegroundColor',[0,0,0],...
                'BackgroundColor',[.94,.94,.94],...
                'HorizontalAlignment','left');

                self.NameLabel=uicontrol(...
                'UserData',userData,...
                'Parent',self.Panel,...
                'Style','text',...
                'Tag','NameLabel',...
                'String','Name',...
                'HorizontalAlignment','right');
                self.NameEdit=uicontrol(...
                'UserData',userData,...
                'Parent',self.Panel,...
                'Style','edit',...
                'Tag','Name',...
                'String','PowerAmplifier',...
                'HorizontalAlignment','left');

                self.CoefficientMatrixLabel=uicontrol(...
                'UserData',userData,...
                'Parent',self.Panel,...
                'Style','text',...
                'Tag','CoefficientMatrixLabel',...
                'String','Coefficient Matrix',...
                'HorizontalAlignment','right');
                self.CoefficientMatrixEdit=uicontrol(...
                'UserData',userData,...
                'Parent',self.Panel,...
                'Style','edit',...
                'Tag','CoefficientMatrix',...
                'String','1',...
                'HorizontalAlignment','left');
                self.CoefficientMatrixUnits=uicontrol(...
                'UserData',userData,...
                'Parent',self.Panel,...
                'Style','text',...
                'Tag','CoefficientMatrixUnitsLabel',...
                'HorizontalAlignment','left');


                self.RinLabel=uicontrol(...
                'UserData',userData,...
                'Parent',self.Panel,...
                'Style','text',...
                'Tag','RinLabel',...
                'String','Input Resistance',...
                'HorizontalAlignment','right');
                self.RinEdit=uicontrol(...
                'UserData',userData,...
                'Parent',self.Panel,...
                'Style','edit',...
                'Tag','Rin',...
                'String','50',...
                'HorizontalAlignment','left');
                self.RinUnits=uicontrol(...
                'UserData',userData,...
                'Parent',self.Panel,...
                'Style','text',...
                'Tag','RinUnitsLabel',...
                'String','Ohm',...
                'HorizontalAlignment','left');

                self.RoutLabel=uicontrol(...
                'UserData',userData,...
                'Parent',self.Panel,...
                'Style','text',...
                'Tag','RoutLabel',...
                'String','Output Resistance',...
                'HorizontalAlignment','right');
                self.RoutEdit=uicontrol(...
                'UserData',userData,...
                'Parent',self.Panel,...
                'Style','edit',...
                'Tag','Rout',...
                'String','50',...
                'HorizontalAlignment','left');
                self.RoutUnits=uicontrol(...
                'UserData',userData,...
                'Parent',self.Panel,...
                'Style','text',...
                'Tag','RoutUnitsLabel',...
                'String','Ohm',...
                'HorizontalAlignment','left');


                self.ApplyLabel=uicontrol(...
                'UserData',userData,...
                'Parent',self.Panel,...
                'Style','pushbutton',...
                'String','Apply',...
                'Tag','ApplyTag',...
                'HorizontalAlignment','center',...
                'Tooltip','Apply parameters to selected Element (Enter)');
            end
        end


        function layoutUIControls(self)


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
                'VerticalWeights',[0,0,0,1],...
                'HorizontalWeights',[0,1,0]);
            end

            row=1;
            self.Parent.addTitle(self.Layout,self.Title,row,[1,3],...
            titleHt,hspacing,vspacing,self.Parent.View.UseAppContainer)

            h=24;
            row=row+1;
            self.Parent.addText(self.Layout,self.NameLabel,...
            row,1,w1,...
            h,self.Parent.View.UseAppContainer)
            self.Parent.addEdit(self.Layout,self.NameEdit,...
            row,2,w2,...
            h,self.Parent.View.UseAppContainer)


            row=row+1;
            self.Parent.addText(self.Layout,self.CoefficientMatrixLabel,...
            row,1,w1,...
            h,self.Parent.View.UseAppContainer)
            self.Parent.addEdit(self.Layout,self.CoefficientMatrixEdit,...
            row,2,w2,...
            h,self.Parent.View.UseAppContainer)
            self.Parent.addText(self.Layout,self.CoefficientMatrixUnits,...
            row,3,w3,...
            h,self.Parent.View.UseAppContainer)


            row=row+1;
            self.Parent.addText(self.Layout,self.RinLabel,...
            row,1,w1,...
            h,self.Parent.View.UseAppContainer)
            self.Parent.addEdit(self.Layout,self.RinEdit,...
            row,2,w2,...
            h,self.Parent.View.UseAppContainer)
            self.Parent.addText(self.Layout,self.RinUnits,...
            row,3,w3,...
            h,self.Parent.View.UseAppContainer)

            row=row+1;
            self.Parent.addText(self.Layout,self.RoutLabel,...
            row,1,w1,...
            h,self.Parent.View.UseAppContainer)
            self.Parent.addEdit(self.Layout,self.RoutEdit,...
            row,2,w2,...
            h,self.Parent.View.UseAppContainer)
            self.Parent.addText(self.Layout,self.RoutUnits,...
            row,3,w3,...
            h,self.Parent.View.UseAppContainer)


            row=row+1;
            self.Parent.addText(self.Layout,self.ApplyLabel,...
            row,2,w3,...
            h+10,self.Parent.View.UseAppContainer)

            if self.Parent.View.UseAppContainer
                w=500;
                h=500;


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
            drawnow;
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
                uiObjectType=uiObject.Style;
                a=get(self.Parent.View.ParametersFig,'CurrentCharacter');
                if isempty(a)


                    return;
                end
                key=e.Key;
                if any(strcmpi(key,{'leftarrow',...
                    'uparrow',...
                    'downarrow',...
                    'rightarrow'}))

                    return;
                end
            end

            applyflag=1;
            valueChangedColor=[1,0.96,0.88];














            if~strcmpi(name,'ApplyButton')||~strcmpi(name,'ApplyTag')
                if~any(strcmpi(uiObjectType,{'popupmenu','matlab.ui.control.DropDown'}))
                    if~strcmpi(key,'return')



                        if strcmpi(name,'NameEditField')||strcmpi(name,'Name')
                            self.NameChanged=1;
                        elseif~strcmpi(name,'ApplyButton')||~strcmpi(name,'ApplyTag')
                            self.OtherPropertiesChanged=1;
                        end
                    end
                else
                    if~strcmpi(key,'return')&&~strcmpi(key,'')


                        return;
                    elseif strcmpi(key,'')

                        self.OtherPropertiesChanged=1;
                    end
                end
            end
            if~strcmpi(key,'return')


                switch name
                case{'NameEditField','Name'}
                    self.NameEdit.BackgroundColor=valueChangedColor;
                case{'CoefficientMatrixEditField','CoefficientMatrix'}
                    self.CoefficientMatrixEdit.BackgroundColor=valueChangedColor;
                case{'RinEditField','Rin'}
                    self.RinEdit.BackgroundColor=valueChangedColor;
                case{'RoutEditField','Rout'}
                    self.RoutEdit.BackgroundColor=valueChangedColor;





                case{'ApplyButton','ApplyTag'}
                    try
                        applyflag=0;
                        applyFunction(self);
                    catch me
                        h=errordlg(me.message,'Error Dialog','modal');
                        uiwait(h)
                        self.Parent.View.enableActions(true);
                    end
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

                self.Parent.View.setStatusBarMsg(...
                'Click ''Apply'' or hit ''Enter'' to update Power Amplifier parameters.');
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
            PAobj=self.simrfV2_poweramplifier_design();













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
                    'ApplyButton',PAobj));
                else
                    self.Parent.notify('ElementParameterChanged',...
                    rf.internal.apps.budget.ElementParameterChangedEventData(i,...
                    'ApplyTag',PAobj));
                end
            end
            whiteColor=[1,1,1];
            self.NameEdit.BackgroundColor=whiteColor;
            self.CoefficientMatrixEdit.BackgroundColor=whiteColor;
            self.RinEdit.BackgroundColor=whiteColor;
            self.RoutEdit.BackgroundColor=whiteColor;
            self.CoefficientMatrixEdit.BackgroundColor=whiteColor;

            self.ApplyLabel.Enable='off';
            self.Parent.View.setStatusBarMsg('');
            enableIP2(self.Parent.View.Toolstrip,false);
            self.NameChanged=0;
            self.OtherPropertiesChanged=0;
            self.IsReturnKey=0;
            self.Parent.View.enableActions(true);
        end

















        function FigKeyEvent(self,ev)


            if isa(self.Parent.ElementDialog,'rf.internal.apps.budget.PowerAmplifierDialog')
                key=ev.Key;
                switch key
                case 'return'
                    self.IsReturnKey=1;
                end
            end
        end

        function FigKeyEventCanvas(self,ev)


            if isa(self.Parent.ElementDialog,'rf.internal.apps.budget.PowerAmplifierDialog')
                key=ev.Key;
                switch key
                case 'return'
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
                callbackFcn='ValueChangedFcn';
                self.ApplyLabel.ButtonPushedFcn=@(h,e)parameterChanged(self,e);
                self.NameEdit.(callbackFcn)=@(h,e)parameterChanged(self,e);
                self.RinEdit.(callbackFcn)=@(h,e)parameterChanged(self,e);
                self.RoutEdit.(callbackFcn)=@(h,e)parameterChanged(self,e);
                self.CoefficientMatrixEdit.(callbackFcn)=@(h,e)parameterChanged(self,e);



            else
                callbackFcn='KeyPressFcn';
                self.Listeners.Apply=addlistener(self.ApplyLabel,...
                'Value',...
                'PostSet',@(h,e)parameterChanged(self,e));
                self.NameEdit.(callbackFcn)=@(h,e)parameterChanged(self,e);
                self.CoefficientMatrixEdit.(callbackFcn)=@(h,e)parameterChanged(self,e);

                self.RinEdit.(callbackFcn)=@(h,e)parameterChanged(self,e);
                self.RoutEdit.(callbackFcn)=@(h,e)parameterChanged(self,e);

            end
        end

        function PAobj=simrfV2_poweramplifier_design(self)

            PAobj=powerAmplifier(...
            'Name',self.Name,...
            'CoefficientMatrix',self.CoefficientMatrix,...
            'Rin',self.Rin,...
            'Rout',self.Rout);
        end
    end
end




