classdef NportDialog<handle







    properties
Parent
Panel
Layout
        Width=0
        Height=0
Listeners

SparametersObj
DataSourcePopup
    end

    properties(Dependent)
Name
FileName
DataSource
WkSpcObj
    end

    properties(Access=private)
Title
NameLabel
NameEdit
FileNameLabel
FileNameEdit
FileNameButton


DataSourceLabel

WkSpcLabel
        WkSpcEdit=''

ApplyLabel
        IsReturnKey=0
        NameChanged=0
        OtherPropertiesChanged=0
    end

    methods


        function self=NportDialog(parent)
            if nargin==0
                parent=figure;
            end
            self.Parent=parent;
            createUIControls(self)
            layoutUIControls(self)
            parameterPaneChange(self)
            addListeners(self)
            if self.Parent.View.UseAppContainer
                self.FileNameButton.ButtonPushedFcn=@(~,~)browseAction(self);
            else
                set(self.FileNameButton,'Callback',@(~,~)browseAction(self));
            end
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

        function str=get.FileName(self)
            if self.Parent.View.UseAppContainer
                str=self.FileNameEdit.Value;
            else
                str=self.FileNameEdit.String;
            end
        end

        function set.FileName(self,str)
            if self.Parent.View.UseAppContainer
                self.FileNameEdit.Value=str;
            else
                self.FileNameEdit.String=str;
            end
        end

        function str=get.DataSource(self)
            if self.Parent.View.UseAppContainer
                str=self.DataSourcePopup.Value;
            else
                str=self.DataSourcePopup.String{self.DataSourcePopup.Value};
            end
        end

        function set.DataSource(self,Value)
            str=self.DataSourcePopup.Value;
            if self.Parent.View.UseAppContainer
                self.DataSourcePopup.Value=Value;
            else
                switch str
                case 'File'
                    self.DataSourcePopup.Value=1;
                case 'Object'
                    self.DataSourcePopup.Value=2;
                end
            end
        end

        function val=get.WkSpcObj(self)
            if self.Parent.View.UseAppContainer
                val=self.WkSpcEdit.Value;
            else
                val=self.WkSpcEdit.String;
            end
        end

        function set.WkSpcObj(self,val)
            if self.Parent.View.UseAppContainer
                self.WkSpcEdit.Value=val;
            else
                self.WkSpcEdit.String=val;
            end

        end

        function setListenersEnable(self,val)
            self.Listeners.Name.Enabled=val;
            self.Listeners.FileName.Enabled=val;
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
            self.FileNameEdit.Enable=val;
            self.DataSourcePopup.Enable=val;
            self.WkSpcEdit.Enable=val;
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

    methods

        function browseAction(self)
            touchstoneFiles=...
            'All Touchstone files (*.s2p, *.y2p, *.z2p, *.h2p, *.g2p)';
            [filename,pathname]=uigetfile(...
            {'*.s2p','S-parameter files (*.s2p)';...
            '*.s2p;*.y2p;*.z2p;*.h2p;*.g2p',touchstoneFiles;...
            '*.*','All files (*.*)'},...
            'Select 2-port Touchstone file',pwd);
            wasCanceled=isequal(filename,0)||...
            isequal(pathname,0);
            if wasCanceled
                return;
            end
            self.FileName=[pathname,filename];
            valueChangedColor=[1,0.96,0.88];
            self.FileNameEdit.BackgroundColor=valueChangedColor;
            self.OtherPropertiesChanged=1;
            self.ApplyLabel.Enable='on';
        end

        function resetDialogAccess(self)


            whiteColor=[1,1,1];
            self.NameEdit.BackgroundColor=whiteColor;
            self.FileNameEdit.BackgroundColor=whiteColor;
            self.DataSourcePopup.BackgroundColor=whiteColor;
            self.WkSpcEdit.BackgroundColor=whiteColor;
            self.OtherPropertiesChanged=0;
            self.NameChanged=0;
            self.ApplyLabel.Enable='off';
            self.Parent.View.setStatusBarMsg('');
        end
    end

    methods(Access=private)


        function createUIControls(self)


            userData=struct(...
            'Dialog','nport',...
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
                'Text',' S-parameters Element',...
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
                'Value','Sparams',...
                'HorizontalAlignment','left');
                self.FileNameLabel=uilabel(...
                'UserData',userData,...
                'Tag','FileNameLabel',...
                'Parent',self.Layout,...
                'Text','Touchstone File',...
                'HorizontalAlignment','right');
                self.FileNameEdit=uieditfield(...
                'UserData',userData,...
                'Tag','FileNameEditField',...
                'Parent',self.Layout,...
                'Value','allpass.s2p',...
                'HorizontalAlignment','left');
                self.FileNameButton=uibutton(...
                'UserData',userData,...
                'Tag','FileNameButton',...
                'Parent',self.Layout,...
                'Text',' Browse ');
                self.DataSourceLabel=uilabel(...
                'UserData',userData,...
                'Tag','DataSourceLabel',...
                'Parent',self.Layout,...
                'Text','Data Source',...
                'HorizontalAlignment','right');
                self.DataSourcePopup=uidropdown(...
                'UserData',userData,...
                'Tag','DataSourceDropdown',...
                'Parent',self.Layout,...
                'Items',{'File','Object'},...
                'Value','File');

                self.WkSpcLabel=uilabel(...
                'UserData',userData,...
                'Tag','WkSpcLabel',...
                'Parent',self.Layout,...
                'Text','Network Parameters',...
                'HorizontalAlignment','right',...
                'Visible','off');
                self.WkSpcEdit=matlab.ui.control.internal.model.WorkspaceDropDown('Parent',self.Layout,...
                'Workspace','base',...
                'Visible','off','Tag','WkSpcEditField','Editable','off');
                fn=@(x)(isa(x,'sparameters')||isa(x,'tparameters')||...
                isa(x,'zparameters')||isa(x,'yparameters')||...
                isa(x,'abcdparameters')||isa(x,'hparameters')||...
                isa(x,'gparameters'))&x.NumPorts==2;
                self.WkSpcEdit.FilterVariablesFcn=fn;
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
                'Visible','on');
                self.Title=uicontrol(...
                'UserData',userData,...
                'Parent',self.Panel,...
                'Style','text',...
                'Tag','TitleLabel',...
                'String',' S-parameters Element',...
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
                'String','Sparams',...
                'HorizontalAlignment','left');
                self.FileNameLabel=uicontrol(...
                'UserData',userData,...
                'Parent',self.Panel,...
                'Style','text',...
                'Tag','FileNameLabel',...
                'String','Touchstone File',...
                'HorizontalAlignment','right');
                self.FileNameEdit=uicontrol(...
                'UserData',userData,...
                'Parent',self.Panel,...
                'Style','edit',...
                'Tag','FileName',...
                'String','allpass.s2p',...
                'HorizontalAlignment','left');
                self.FileNameButton=uicontrol(...
                'UserData',userData,...
                'Parent',self.Panel,...
                'Style','pushbutton',...
                'String',' Browse ',...
                'Tag','FileNameButton');
                self.DataSourceLabel=uicontrol(...
                'UserData',userData,...
                'Parent',self.Panel,...
                'Style','text',...
                'String','Data Source',...
                'HorizontalAlignment','right');
                self.DataSourcePopup=uicontrol(...
                'UserData',userData,...
                'Parent',self.Panel,...
                'Style','popup',...
                'String',{'File','Object'},...
                'Tag','DataSource',...
                'Value',1);

                self.WkSpcLabel=uicontrol(...
                'Parent',self.Panel,...
                'Style','text',...
                'String','Network Parameters',...
                'HorizontalAlignment','right',...
                'Visible','off');
                self.WkSpcEdit=uicontrol(...
                'Parent',self.Panel,...
                'Style','edit',...
                'String','',...
                'Tag','WkSpc',...
                'HorizontalAlignment','left',...
                'Visible','off');
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
                'VerticalWeights',[0,0,0,0,0,1],...
                'HorizontalWeights',[0,1,0]);
            end
            row=1;
            self.Parent.addTitle(self.Layout,self.Title,row,[1,3],...
            titleHt,hspacing,vspacing,self.Parent.View.UseAppContainer)
            h=24;
            row=row+1;
            self.Parent.addText(self.Layout,self.NameLabel,row,1,w1,...
            h,self.Parent.View.UseAppContainer)
            self.Parent.addEdit(self.Layout,self.NameEdit,row,2,w2,...
            h,self.Parent.View.UseAppContainer)
            if strcmpi(self.DataSource,'File')

                row=row+1;
                self.Parent.addText(self.Layout,self.DataSourceLabel,row,1,w1,...
                h,self.Parent.View.UseAppContainer)
                self.Parent.addEdit(self.Layout,self.DataSourcePopup,row,2,w2,...
                h,self.Parent.View.UseAppContainer)

                row=row+1;
                self.Parent.addText(self.Layout,self.FileNameLabel,row,1,w1,...
                h,self.Parent.View.UseAppContainer)
                self.Parent.addEdit(self.Layout,self.FileNameEdit,row,2,w2,...
                h,self.Parent.View.UseAppContainer)
                self.Parent.addButton(self.Layout,self.FileNameButton,row,3,w3,...
                h,self.Parent.View.UseAppContainer)
            else

                row=row+1;
                self.Parent.addText(self.Layout,self.DataSourceLabel,row,1,w1,...
                h,self.Parent.View.UseAppContainer)
                self.Parent.addEdit(self.Layout,self.DataSourcePopup,row,2,w2,...
                h,self.Parent.View.UseAppContainer)


                row=row+1;
                self.Parent.addText(self.Layout,self.WkSpcLabel,row,1,w1,h,...
                self.Parent.View.UseAppContainer)
                self.Parent.addEdit(self.Layout,self.WkSpcEdit,row,2,w2,h,...
                self.Parent.View.UseAppContainer)
                self.WkSpcEdit.BackgroundColor=[1,0.96,0.88];
            end
            row=row+1;
            self.Parent.addButton(self.Layout,self.ApplyLabel,row,2,w3,...
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
            if self.Parent.View.UseAppContainer
                valueString='Value';
            else
                valueString='String';
            end

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
                end
            end
            if~strcmpi(key,'return')


                switch name
                case{'NameEditField','Name'}
                    self.NameEdit.BackgroundColor=valueChangedColor;
                case{'FileNameEditField','FileName'}
                    self.FileNameEdit.BackgroundColor=valueChangedColor;
                case{'DataSourceDropdown','DataSource'}

                    if self.Parent.View.UseAppContainer
                        str=self.DataSourcePopup.Value;
                    else
                        str=self.DataSourcePopup.String{self.DataSourcePopup.Value};
                    end

                    if strcmpi(str,'File')
                        if self.Parent.View.UseAppContainer
                            self.FileNameEdit.Value='allpass.s2p';
                            self.DataSourcePopup.Value='File';
                        else
                            self.FileNameEdit.String='allpass.s2p';
                            self.DataSourcePopup.Value=1;
                        end
                        self.FileNameEdit.BackgroundColor=[1,0.96,0.88];
                        self.DataSourcePopup.BackgroundColor=[1,0.96,0.88];
                        self.ApplyLabel.Enable='on';
                    else
                        if self.Parent.View.UseAppContainer
                            self.DataSourcePopup.Value='Object';
                            self.SparametersObj=[];
                            self.WkSpcEdit.(valueString)='select variable';
                            self.ApplyLabel.Enable='off';
                        else
                            self.WkSpcEdit.String=self.Parent.View.Canvas.SelectedElement.VarName;
                            self.DataSourcePopup.Value=2;
                            self.SparametersObj=[];
                        end
                        self.DataSourcePopup.BackgroundColor=[1,0.96,0.88];
                        self.WkSpcEdit.BackgroundColor=[1,0.96,0.88];
                    end
                    self.DataSourcePopup.BackgroundColor=[1,0.96,0.88];

                    parameterPaneChange(self)

                    layoutUIControls(self);
                case{'WkSpcEditField','WkSpc'}
                    self.WkSpcEdit.BackgroundColor=valueChangedColor;
                case{'ApplyButton','ApplyTag'}
                    try
                        applyflag=0;
                        self.applyFunction();
                    catch me
                        if strcmpi(me.identifier,'MATLAB:m_incomplete_statement')||strcmpi(me.identifier,'MATLAB:m_missing_operator')
                            h=errordlg(getString(message('rf:shared:NetworkParametersNotEmpty')),'Error Dialog','modal');
                        else
                            h=errordlg(me.message,'Error Dialog','modal');
                        end
                        uiwait(h)
                        self.Parent.View.enableActions(true);
                    end
                end
            end
            if self.IsReturnKey
                try
                    applyflag=0;
                    self.applyFunction()
                catch me
                    if strcmpi(me.identifier,'MATLAB:m_incomplete_statement')||strcmpi(me.identifier,'MATLAB:m_missing_operator')
                        h=errordlg(getString(message('rf:shared:NetworkParametersNotEmpty')),'Error Dialog','modal');
                    else
                        h=errordlg(me.message,'Error Dialog','modal');
                    end
                    uiwait(h)
                    self.Parent.View.enableActions(true);
                end
            end
            self.IsReturnKey=0;
            if applyflag
                self.ApplyLabel.Enable='on';
                self.Parent.View.setStatusBarMsg(...
                'Click ''Apply'' or hit ''Enter'' to update S-Parameters.');
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
            if self.Parent.View.UseAppContainer
                str=self.DataSourcePopup.Value;
            else
                str=self.DataSourcePopup.String{self.DataSourcePopup.Value};
            end
            if~self.NameChanged&&~self.OtherPropertiesChanged

                self.IsReturnKey=0;
                i=self.Parent.View.Canvas.SelectIdx;
                self.Parent.notify('DisableCanvas',...
                rf.internal.apps.budget.ElementParameterChangedEventData(i,...
                'ApplyButton','inactive'));

                if self.Parent.View.UseAppContainer
                    if strcmpi(self.WkSpcEdit.Value,'select variable')
                        h=errordlg(getString(message('rf:shared:NetworkParametersNotEmpty')),'Error Dialog','modal');
                        uiwait(h)
                        self.Parent.View.enableActions(true);
                    end
                else
                    if isempty(self.WkSpcObj)
                        h=errordlg(getString(message('rf:shared:NetworkParametersNotEmpty')),'Error Dialog','modal');
                        uiwait(h)
                        self.Parent.View.enableActions(true);
                    end
                end
                return;
            end
            self.Parent.View.enableActions(false);
            i=self.Parent.View.Canvas.SelectIdx;

            if self.Parent.View.UseAppContainer
                if strcmpi(str,'File')
                    nportobj=self.simrfV2_nport_design();
                else
                    if strcmpi(self.WkSpcEdit.Value,'select variable')
                        h=errordlg(getString(message('rf:shared:NetworkParametersNotEmpty')),'Error Dialog','modal');
                        uiwait(h)
                        self.Parent.View.enableActions(true);
                        return;
                    else
                        nportobj=self.simrfV2_nport_design();
                    end
                end
            else
                if strcmpi(str,'File')
                    nportobj=self.simrfV2_nport_design();
                else
                    if isempty(self.WkSpcObj)
                        h=errordlg(getString(message('rf:shared:NetworkParametersNotEmpty')),'Error Dialog','modal');
                        uiwait(h)
                        self.Parent.View.enableActions(true);
                        return;
                    else
                        nportobj=self.simrfV2_nport_design();
                    end
                end
            end

            if self.Parent.View.UseAppContainer
                self.Parent.View.Canvas.SelectedElement.VarName=self.WkSpcEdit.Value;
            else
                self.Parent.View.Canvas.SelectedElement.VarName=self.WkSpcEdit.String;
            end
            parameterPaneChange(self)
            layoutUIControls(self)
            if self.Parent.View.UseAppContainer
            else
                add(...
                self.Parent.Layout,self.Panel,2,1,...
                'MinimumWidth',self.Width,...
                'Fill','Horizontal',...
                'MinimumHeight',self.Height,...
                'Anchor','North')
            end

            self.Parent.notify('DisableCanvas',...
            rf.internal.apps.budget.ElementParameterChangedEventData(i,...
            'ApplyButton','inactive'));
            if self.NameChanged&&~self.OtherPropertiesChanged

                self.Parent.notify('ElementParameterChanged',...
                rf.internal.apps.budget.ElementParameterChangedEventData(i,...
                'Name',self.NameEdit.(valueString)));
            else


                self.Parent.notify('ElementParameterChanged',...
                rf.internal.apps.budget.ElementParameterChangedEventData(i,...
                'ApplyButton',nportobj));
            end
            whiteColor=[1,1,1];
            self.NameEdit.BackgroundColor=whiteColor;
            self.FileNameEdit.BackgroundColor=whiteColor;
            self.DataSourcePopup.BackgroundColor=whiteColor;
            self.WkSpcEdit.BackgroundColor=whiteColor;
            self.ApplyLabel.Enable='off';
            self.Parent.View.setStatusBarMsg('');
            self.IsReturnKey=0;
            enableIP2(self.Parent.View.Toolstrip,false);
            self.NameChanged=0;
            self.OtherPropertiesChanged=0;
            self.Parent.View.enableActions(true);
        end

        function parameterPaneChange(self)
            if strcmpi(self.DataSource,'File')


                self.WkSpcLabel.Visible='off';
                self.WkSpcEdit.Visible='off';

                self.FileNameLabel.Visible='on';
                self.FileNameEdit.Visible='on';
                self.FileNameButton.Visible='on';

                self.DataSourceLabel.Visible='on';
                self.DataSourcePopup.Visible='on';
            else

                self.WkSpcLabel.Visible='on';
                self.WkSpcEdit.Visible='on';

                self.FileNameLabel.Visible='off';
                self.FileNameEdit.Visible='off';
                self.FileNameButton.Visible='off';

                self.DataSourceLabel.Visible='on';
                self.DataSourcePopup.Visible='on';
            end
        end

        function FigKeyEvent(self,ev)


            if isa(self.Parent.ElementDialog,'rf.internal.apps.budget.NportDialog')
                key=ev.Key;
                switch key
                case 'return'
                    self.IsReturnKey=1;
                end
            end
        end

        function FigKeyEventCanvas(self,ev)



            if isa(self.Parent.ElementDialog,'rf.internal.apps.budget.NportDialog')
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
                self.NameEdit.ValueChangedFcn=@(h,e)parameterChanged(self,e);
                self.FileNameEdit.ValueChangedFcn=@(h,e)parameterChanged(self,e);
                self.DataSourcePopup.ValueChangedFcn=@(h,e)parameterChanged(self,e);
                self.WkSpcEdit.ValueChangedFcn=@(h,e)parameterChanged(self,e);
                self.ApplyLabel.ButtonPushedFcn=@(h,e)parameterChanged(self,e);
            else
                self.NameEdit.KeyPressFcn=@(h,e)parameterChanged(self,e);
                self.FileNameEdit.KeyPressFcn=@(h,e)parameterChanged(self,e);
                self.WkSpcEdit.KeyPressFcn=@(h,e)parameterChanged(self,e);
                self.Listeners.DataSource=addlistener(self.DataSourcePopup,...
                'Value',...
                'PostSet',@(h,e)parameterChanged(self,e));
                self.Listeners.Apply=addlistener(self.ApplyLabel,...
                'Value',...
                'PostSet',@(h,e)parameterChanged(self,e));
            end
        end

        function nportObj=simrfV2_nport_design(self)

            if strcmpi(self.DataSource,'File')
                nportObj=nport('FileName',self.FileName,'Name',self.Name);
            else
                if self.Parent.View.UseAppContainer
                    sObj=evalin('base',self.WkSpcEdit.Value);
                else
                    sObj=evalin('base',self.WkSpcEdit.String);
                end
                self.SparametersObj=sObj;
                nportObj=nport('Name',self.Name,...
                'NetworkData',self.SparametersObj);
            end
        end

    end
end




