classdef AntennaDialog<handle






    properties
Parent
Panel
Layout
        Width=0
        Height=0
Listeners
TypePopup
InputFreq
AntImp
AntObj
Directivity
        Object{mustBeNonempty}=0
AppHandle
IconSave
    end

    properties(Dependent)
Name
Type
Gain
Z
        WkSpcObj{mustBeNonempty}
Dir
    end

    properties(Access=private)

Title

Icon

EIRP

NameLabel
NameEdit

TypeLabel

AntLabel

GainLabel
GainEdit
GainUnits

ZLabel
ZEdit
ZUnits

WkSpcLabel
WkSpcEdit

DirLabel
DirEdit
DirUnits

ApplyLabel

OutputLabel

        IsReturnKey=0
        NameChanged=0
        OtherPropertiesChanged=0

    end

    methods


        function self=AntennaDialog(parent)




            if nargin==0
                parent=figure;
            end
            self.Parent=parent;

            createUIControls(self)
            layoutUIControls(self)
            addListeners(self)
            self.InputFreq=self.Parent.SystemDialog.InputFrequency;
        end
    end

    methods(Hidden)

        function AppHandle=getAppHandle(self)

            AppHandle=self.AppHandle;
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

        function val=get.Gain(self)
            if self.Parent.View.UseAppContainer
                val=self.GainEdit.Value;
            else
                val=str2num(self.GainEdit.String);%#ok<*ST2NM>
            end
        end

        function set.Gain(self,val)
            if self.Parent.View.UseAppContainer
                self.GainEdit.Value=val;
            else
                self.GainEdit.String=num2str(val);
            end
        end

        function val=get.Z(self)
            if self.Parent.View.UseAppContainer
                val=self.ZEdit.Value;
            else
                val=str2num(self.ZEdit.String);
            end
        end

        function set.Z(self,val)
            if self.Parent.View.UseAppContainer
                self.ZEdit.Value=num2str(val);
            else
                self.ZEdit.String=num2str(val);
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

        function val=get.Dir(self)
            if self.Parent.View.UseAppContainer
                val=str2num(self.DirEdit.Value);
            else
                val=str2num(self.DirEdit.String);
            end
        end

        function set.Dir(self,val)
            if self.Parent.View.UseAppContainer
                self.DirEdit.Value=mat2str(val);
            else
                self.DirEdit.String=mat2str(val);
            end
        end

        function str=get.Type(self)
            if self.Parent.View.UseAppContainer
                str=self.TypePopup.Value;
            else
                str=self.TypePopup.String{self.TypePopup.Value};
            end
        end

        function set.Type(self,str)
            if self.Parent.View.UseAppContainer
                rf.internal.apps.budget.setValue(self,self,'TypePopup',str)
            else
                switch str
                case 'Isotropic Radiator'
                    self.TypePopup.Value=1;
                case 'Antenna Designer'
                    self.TypePopup.Value=2;
                case 'Antenna Object'
                    self.TypePopup.Value=3;
                end
            end
        end

        function resetDialogAccess(self)

            if self.Parent.View.UseAppContainer
                valueString='Value';
                Image='ImageSource';
            else
                valueString='String';
                Image='CData';
            end
            whiteColor=[1,1,1];
            self.NameEdit.BackgroundColor=whiteColor;
            switch self.TypePopup.Value
            case{1,'Isotropic Radiator'}
                self.WkSpcEdit.(valueString)='';
                self.DirEdit.(valueString)='[0 0]';
                self.AntObj=[];
                self.Icon.Visible='off';
            case{3,'Antenna Object'}
                self.WkSpcEdit.(valueString)=self.WkSpcObj;
            case{2,'Antenna Designer'}
                self.Icon.(Image)=self.IconSave;
                self.Icon.Visible='on';
            end
            self.TypePopup.BackgroundColor=whiteColor;
            self.GainEdit.BackgroundColor=whiteColor;
            self.ZEdit.BackgroundColor=whiteColor;
            self.WkSpcEdit.BackgroundColor=whiteColor;
            self.DirEdit.BackgroundColor=whiteColor;
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




            if val==false
                val='off';
            elseif val==true
                val='on';
            end
            self.NameEdit.Enable=val;
            self.TypePopup.Enable=val;
            self.GainEdit.Enable=val;
            self.ZEdit.Enable=val;
            self.WkSpcEdit.Enable=val;
            self.DirEdit.Enable=val;
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

    methods(Static)

        function propUpdate(ant,self)
            icon=imread(ant.iconFilePath);
            i=icon.*255;
            in(:,:,:)=255-i(:,:,:);
            icon(:,:,:)=icon(:,:,:)+in(:,:,:);
            self.IconSave=icon;
            if self.Parent.View.UseAppContainer
                self.Icon.ImageSource=icon;
            else
                self.Icon.CData=icon;
            end
            self.Icon.Visible='on';
            self.AntImp=ant.Zin;
            self.Z=self.AntImp;
            self.AntObj=ant.obj;
            self.OtherPropertiesChanged=1;
            self.ApplyLabel.Enable='on';
        end
    end

    methods(Access=private)


        function createUIControls(self)

            userData=struct(...
            'Dialog','antenna',...
            'Stage',self.Parent.SelectedStage);
            if self.Parent.View.UseAppContainer

                self.Layout=uigridlayout(...
                'Parent',self.Parent.View.ParametersFig.Figure,...
                'Scrollable','on',...
                'Tag','Layout',...
                'RowSpacing',3,...
                'ColumnSpacing',2,...
                'Visible','off');

                self.Icon=uiimage(...
                'Parent',self.Layout,...
                'Visible','off',...
                'Tag','IconImage');

                self.Title=uilabel(...
                'UserData',userData,...
                'Tag','TitleLabel',...
                'Parent',self.Layout,...
                'Text','Antenna Element',...
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
                'Value','Antenna',...
                'HorizontalAlignment','left');

                self.TypeLabel=uilabel(...
                'UserData',userData,...
                'Tag','TypeLabel',...
                'Parent',self.Layout,...
                'Text','Antenna Source',...
                'HorizontalAlignment','right');
                self.TypePopup=uidropdown(...
                'UserData',userData,...
                'Tag','TypeDropdown',...
                'Parent',self.Layout,...
                'Items',{'Isotropic Radiator','Antenna Designer','Antenna Object'},...
                'Value','Isotropic Radiator');

                self.GainLabel=uilabel(...
                'UserData',userData,...
                'Tag','GainLabel',...
                'Parent',self.Layout,...
                'Text','Gain',...
                'HorizontalAlignment','right');
                self.GainEdit=uieditfield(...
                'numeric',...
                'UserData',userData,...
                'Tag','GainEditField',...
                'Parent',self.Layout,...
                'Value',0,...
                'HorizontalAlignment','left');
                self.GainUnits=uilabel(...
                'UserData',userData,...
                'Tag','GainUnitsLabel',...
                'Parent',self.Layout,...
                'Text','dBi',...
                'HorizontalAlignment','left');

                self.ZLabel=uilabel(...
                'UserData',userData,...
                'Tag','ZLabel',...
                'Parent',self.Layout,...
                'Text',...
                'Z',...
                'HorizontalAlignment','right');
                self.ZEdit=uieditfield(...
                "text",...
                'UserData',userData,...
                'Tag','ZEditField',...
                'Parent',self.Layout,...
                'Value','50',...
                'Tag',...
                'ZEditField',...
                'HorizontalAlignment','left');
                self.ZUnits=uilabel(...
                'UserData',userData,...
                'Tag','ZUnitsLabel',...
                'Parent',self.Layout,...
                'Text','ohm',...
                'HorizontalAlignment','left');

                self.WkSpcLabel=uilabel(...
                'UserData',userData,...
                'Tag','WkSpcLabel',...
                'Parent',self.Layout,...
                'Text','Antenna Object',...
                'HorizontalAlignment','right',...
                'Visible','off');
                self.WkSpcEdit=uieditfield(...
                'UserData',userData,...
                'Tag','WkSpcEditField',...
                'Parent',self.Layout,...
                'Value','',...
                'HorizontalAlignment','left',...
                'Visible','off');

                self.DirLabel=uilabel(...
                'UserData',userData,...
                'Tag','DirLabel',...
                'Parent',self.Layout,...
                'Text','Direction of Departure',...
                'HorizontalAlignment','right',...
                'Visible','off');
                self.DirEdit=uieditfield(...
                'UserData',userData,...
                'Tag','DirEditField',...
                'Parent',self.Layout,...
                'Value','[0 0]',...
                'HorizontalAlignment','left',...
                'Visible','off');
                self.DirUnits=uilabel(...
                'UserData',userData,...
                'Tag','DirUnitsLabel',...
                'Parent',self.Layout,...
                'Text','deg',...
                'HorizontalAlignment','left',...
                'Visible','off');

                self.ApplyLabel=uibutton(...
                'Tag','ApplyButton',...
                'Parent',self.Layout,...
                'Text','Apply',...
                'HorizontalAlignment','center',...
                'Tooltip','Apply parameters to selected Element (Enter)');

                self.AntLabel=uibutton(...
                'Tag','AntButton',...
                'Parent',self.Layout,...
                'Text','Create Antenna',...
                'HorizontalAlignment','right',...
                'Tooltip','Create antenna using Antenna Designer',...
                'Visible','off');

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

                self.Icon=uicontrol('Parent',self.Panel,...
                'Style','checkbox',...
                'Tag','Icon',...
                'Visible','off');

                self.Title=uicontrol(...
                'UserData',userData,...
                'Parent',self.Panel,...
                'Style','text',...
                'Tag','TitleLabel',...
                'String','Antenna Element',...
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
                'String','Antenna',...
                'HorizontalAlignment','left');

                self.TypeLabel=uicontrol(...
                'UserData',userData,...
                'Parent',self.Panel,...
                'Style','text',...
                'Tag','TypeLabel',...
                'String','Antenna Source',...
                'HorizontalAlignment','right');
                self.TypePopup=uicontrol(...
                'UserData',userData,...
                'Parent',self.Panel,...
                'Style','popup',...
                'String',{...
                'Isotropic Radiator',...
                'Antenna Designer',...
                'Antenna Object'},...
                'Tag','Type',...
                'Value',1,...
                'HorizontalAlignment','left');

                self.GainLabel=uicontrol(...
                'UserData',userData,...
                'Parent',self.Panel,...
                'Style','text',...
                'Tag','GainLabel',...
                'String','Gain',...
                'HorizontalAlignment','right');
                self.GainEdit=uicontrol(...
                'UserData',userData,...
                'Parent',self.Panel,...
                'Style','edit',...
                'Tag','Gain',...
                'String','0',...
                'HorizontalAlignment','left');
                self.GainUnits=uicontrol(...
                'UserData',userData,...
                'Parent',self.Panel,...
                'Style','text',...
                'Tag','GainUnitsLabel',...
                'String','dBi',...
                'HorizontalAlignment','left');

                self.ZLabel=uicontrol(...
                'UserData',userData,...
                'Parent',self.Panel,...
                'Style','text',...
                'Tag','ZLabel',...
                'String',...
                'Z',...
                'HorizontalAlignment','right');
                self.ZEdit=uicontrol(...
                'UserData',userData,...
                'Parent',self.Panel,...
                'Style','edit',...
                'Tag','Z',...
                'String','50',...
                'Tag',...
                'Z',...
                'HorizontalAlignment','left');
                self.ZUnits=uicontrol(...
                'UserData',userData,...
                'Parent',self.Panel,...
                'Style','text',...
                'Tag','ZUnitsLabel',...
                'String','ohm',...
                'HorizontalAlignment','left');

                self.WkSpcLabel=uicontrol(...
                'UserData',userData,...
                'Parent',self.Panel,...
                'Style','text',...
                'Tag','WkSpcLabel',...
                'String','Antenna Object',...
                'HorizontalAlignment','right',...
                'Visible','off');
                self.WkSpcEdit=uicontrol(...
                'UserData',userData,...
                'Parent',self.Panel,...
                'Style','edit',...
                'Tag','WkSpc',...
                'String','',...
                'HorizontalAlignment','left',...
                'Visible','off');

                self.DirLabel=uicontrol(...
                'UserData',userData,...
                'Parent',self.Panel,...
                'Style','text',...
                'Tag','DirLabel',...
                'String','Direction of Departure',...
                'HorizontalAlignment','right',...
                'Visible','off');
                self.DirEdit=uicontrol(...
                'UserData',userData,...
                'Parent',self.Panel,...
                'Style','edit',...
                'Tag','Elevation',...
                'String','[0 0]',...
                'HorizontalAlignment','left',...
                'Visible','off');
                self.DirUnits=uicontrol(...
                'UserData',userData,...
                'Parent',self.Panel,...
                'Style','text',...
                'Tag','DirUnitsLabel',...
                'String','deg',...
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

                self.AntLabel=uicontrol(...
                'UserData',userData,...
                'Parent',self.Panel,...
                'Style','pushbutton',...
                'String','Create Antenna',...
                'Tag','AntTag',...
                'HorizontalAlignment','right',...
                'Value',0,...
                'Tooltip','Create antenna using Antenna Designer',...
                'Visible','off');
            end
        end


        function layoutUIControls(self)




            hspacing=3;
            vspacing=4;
            w1=rf.internal.apps.budget.SystemParametersSection.Width1;
            w2=rf.internal.apps.budget.SystemParametersSection.Width2;
            w3=rf.internal.apps.budget.SystemParametersSection.Width3;
            if self.Parent.View.UseAppContainer
            else
                self.Layout=...
                matlabshared.application.layout.GridBagLayout(...
                self.Panel,...
                'VerticalGap',vspacing,...
                'HorizontalGap',hspacing,...
                'VerticalWeights',[0,0,0,0,0,0,1],...
                'HorizontalWeights',[0,1,0]);

            end

            row=1;
            titleHt=16;
            self.Parent.addTitle(self.Layout,self.Title,row,[1,3],...
            titleHt,hspacing,vspacing,self.Parent.View.UseAppContainer)

            h=24;
            row=row+1;
            self.Parent.addText(self.Layout,self.NameLabel,row,1,w1,...
            h,self.Parent.View.UseAppContainer)
            self.Parent.addEdit(self.Layout,self.NameEdit,row,2,w2,...
            h,self.Parent.View.UseAppContainer)

            row=row+1;
            self.Parent.addText(self.Layout,self.TypeLabel,row,1,w1,...
            h,self.Parent.View.UseAppContainer)
            self.Parent.addEdit(self.Layout,self.TypePopup,row,2,w2,...
            h,self.Parent.View.UseAppContainer)

            haveAntTbx=builtin('license','test','Antenna_Toolbox')&&...
            ~isempty(ver('antenna'));
            if~haveAntTbx
                if self.Parent.View.UseAppContainer
                    self.TypePopup.Items={'Isotropic Radiator'};
                else
                    self.TypePopup.String={'Isotropic Radiator'};
                end
            end
            if strcmpi(self.Type,'Isotropic Radiator')

                row=row+1;
                self.Parent.addText(self.Layout,self.GainLabel,...
                row,1,w1,...
                h,self.Parent.View.UseAppContainer)
                self.Parent.addEdit(self.Layout,self.GainEdit,...
                row,2,w2,...
                h,self.Parent.View.UseAppContainer)
                self.Parent.addText(self.Layout,self.GainUnits,...
                row,3,w3,...
                h,self.Parent.View.UseAppContainer)

                row=row+1;
                self.Parent.addText(self.Layout,self.ZLabel,...
                row,1,w1,...
                h,self.Parent.View.UseAppContainer)
                self.Parent.addEdit(self.Layout,self.ZEdit,...
                row,2,w2,...
                h,self.Parent.View.UseAppContainer)
                self.Parent.addText(self.Layout,self.ZUnits,...
                row,3,w3,...
                h,self.Parent.View.UseAppContainer)
                if self.OtherPropertiesChanged
                    self.GainEdit.BackgroundColor=[1,0.96,0.88];
                    self.ZEdit.BackgroundColor=[1,0.96,0.88];
                end
            elseif strcmpi(self.Type,'Antenna Designer')

                row=row+1;
                self.Parent.addButton(self.Layout,self.AntLabel,...
                row,2,90,h+5,self.Parent.View.UseAppContainer);

                row=row+1;
                self.Parent.addText(self.Layout,self.Icon,row,2,75,45,self.Parent.View.UseAppContainer);

                row=row+1;
                self.Parent.addText(self.Layout,self.DirLabel,...
                row,1,w1,...
                h,self.Parent.View.UseAppContainer)
                self.Parent.addEdit(self.Layout,self.DirEdit,...
                row,2,w2,...
                h,self.Parent.View.UseAppContainer)
                self.Parent.addText(self.Layout,self.DirUnits,...
                row,3,w3,...
                h,self.Parent.View.UseAppContainer)
                self.DirEdit.BackgroundColor=[1,0.96,0.88];

                self.Parent.View.setStatusBarMsg(...
                'Design antenna and set "Direction of Departure".');
            else
                row=row+1;
                self.Parent.addText(self.Layout,self.WkSpcLabel,...
                row,1,w1,...
                h,self.Parent.View.UseAppContainer)
                self.Parent.addEdit(self.Layout,self.WkSpcEdit,...
                row,2,w2,...
                h,self.Parent.View.UseAppContainer)
                self.WkSpcEdit.BackgroundColor=[1,0.96,0.88];

                row=row+1;
                self.Parent.addText(self.Layout,self.DirLabel,...
                row,1,w1,...
                h,self.Parent.View.UseAppContainer)
                self.Parent.addEdit(self.Layout,self.DirEdit,...
                row,2,w2,...
                h,self.Parent.View.UseAppContainer)
                self.Parent.addText(self.Layout,self.DirUnits,...
                row,3,w3,...
                h,self.Parent.View.UseAppContainer)
                self.DirEdit.BackgroundColor=[1,0.96,0.88];

                self.Parent.View.setStatusBarMsg(...
                'Design antenna and set "Direction of Departure".');
            end

            row=row+1;
            self.Parent.addText(self.Layout,...
            self.ApplyLabel,...
            row,2,w3,h+10,...
            self.Parent.View.UseAppContainer)

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
            if strcmpi(self.Type,'Antenna Designer')
                self.Width=self.Width-100;
                self.Height=self.Height-100;
            end
        end

        function parameterChanged(self,e)


            i=self.Parent.View.Canvas.SelectIdx;
            createAntPushed=false;
            if self.Parent.View.UseAppContainer
                if strcmpi(e.EventName,'ButtonPushed')&&strcmpi(e.Source.Text,'Create Antenna')
                    createAntPushed=true;
                end
            end
            if self.Parent.View.UseAppContainer
                valueString='Value';
                Image='ImageSource';
            else
                valueString='String';
                Image='CData';
            end
            if strcmpi(e.EventName,'PostSet')||...
                strcmpi(e.EventName,'ValueChanged')||...
                strcmpi(e.EventName,'ButtonPushed')||...
createAntPushed

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
            drawnow;

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
                    else
                        if~strcmpi(key,'return')&&~strcmpi(key,'')


                            return;
                        else
                            if strcmpi(key,'')

                                self.OtherPropertiesChanged=1;
                            end
                        end
                    end
                else
                    self.OtherPropertiesChanged=1;
                end
            end
            if~strcmp(name,'ApplyButton')&&~strcmpi(name,'ApplyTag')
                self.Parent.notify('DisableCanvas',...
                rf.internal.apps.budget.ElementParameterChangedEventData(i,...
                name,'off'));
            end
            if~strcmpi(key,'return')


                switch name
                case{'TypeDropdown','Type'}
                    if strcmpi(self.Type,'Isotropic Radiator')
                        applyflag=1;
                        self.ApplyLabel.Enable='on';
                    else
                        applyflag=0;
                        self.ApplyLabel.Enable='off';
                    end
                    self.TypePopup.BackgroundColor=[1,0.96,0.88];
                    self.DirEdit.(valueString)='[0 0]';
                    self.ZEdit.(valueString)=num2str(50);
                    if self.Parent.View.UseAppContainer
                        self.GainEdit.(valueString)=0;
                    else
                        self.Icon.CData=[];
                        self.GainEdit.(valueString)=num2str(0);

                    end

                    self.WkSpcEdit.(valueString)='';
                    self.AntObj=[];

                    parameterPaneChange(self)
                    layoutUIControls(self);
                    self.Icon.Visible='off';
                    if self.Parent.View.UseAppContainer
                    else
                        add(...
                        self.Parent.Layout,self.Panel,2,1,...
                        'MinimumWidth',self.Width,...
                        'Fill','Horizontal',...
                        'MinimumHeight',self.Height,...
                        'Anchor','North')
                    end
                case{'NameEditField','Name'}
                    self.NameEdit.BackgroundColor=valueChangedColor;
                case{'GainEditField','Gain'}
                    self.GainEdit.BackgroundColor=valueChangedColor;
                case{'AntTag','AntButton'}
                    self.InputFreq=...
                    self.Parent.View.Results.FriisData.OutputFrequency(end);
                    if self.Parent.View.UseAppContainer
                        self.AppHandle=em.internal.antennaExplorer.AntennaDesigner('SourceBlock',self,'UseAppContainer',true);
                    else
                        self.AppHandle=em.internal.antennaExplorer.AntennaDesigner('SourceBlock',self);
                    end

                case{'ZEditField','Z'}
                    self.ZEdit.BackgroundColor=valueChangedColor;
                case{'WkSpcEditField','WkSpc'}
                    self.InputFreq=self.Parent.View.Results.FriisData.OutputFrequency(end);
                    if~isempty(self.Parent.ModulatorDialog)
                        if strcmpi(self.Parent.ModulatorDialog.ConverterType,'Up')
                            self.InputFreq=self.InputFreq+self.Parent.ModulatorDialog.LO;
                        else
                            self.InputFreq=self.InputFreq-self.Parent.ModulatorDialog.LO;
                        end
                    end
                    self.WkSpcEdit.BackgroundColor=valueChangedColor;
                case{'DirEditField','Elevation'}
                    if strcmpi(self.Type,'Antenna Object')&&isempty(self.WkSpcEdit.(valueString))
                        applyflag=0;
                    elseif strcmpi(self.Type,'Antenna Designer')&&isempty(self.Icon.(Image))
                        applyflag=0;
                    end
                    self.DirEdit.BackgroundColor=valueChangedColor;
                case{'ApplyButton','ApplyTag'}
                    try
                        applyflag=0;


                        links=feature('hotlinks',0);
                        cleanup=onCleanup(@()feature('hotlinks',links));
                        applyFunction(self);
                    catch me
                        if strcmpi(me.identifier,'MATLAB:validators:mustBeNonempty')
                            message='Error setting property. Value must not be empty';
                            h=errordlg(message,'Error Dialog','modal');
                        else
                            h=errordlg(me.message,'Error Dialog','modal');
                        end
                        uiwait(h)
                        self.Parent.View.enableActions(true);
                        if~feature('hotlinks')
                            feature('hotlinks',1)
                        end
                    end
                end
            end
            if self.IsReturnKey
                try
                    applyflag=0;


                    links=feature('hotlinks',0);
                    cleanup=onCleanup(@()feature('hotlinks',links));
                    self.applyFunction();
                catch me
                    if strcmpi(me.identifier,'MATLAB:validators:mustBeNonempty')
                        message='Error setting property. Value must not be empty';
                        h=errordlg(message,'Error Dialog','modal');
                    else
                        h=errordlg(me.message,'Error Dialog','modal');
                    end
                    uiwait(h)
                    self.Parent.View.enableActions(true);
                    if~feature('hotlinks')
                        feature('hotlinks',1)
                    end
                end
            end
            self.IsReturnKey=0;
            if applyflag
                self.ApplyLabel.Enable='on';
                self.Parent.View.setStatusBarMsg(...
                'Click ''Apply'' or hit ''Enter'' to update Antenna parameters.');
                self.Parent.notify('DisableCanvas',...
                rf.internal.apps.budget.ElementParameterChangedEventData(i,...
                name,'off'));
            end
        end

        function applyFunction(self)



            if self.Parent.View.UseAppContainer
                valueString='Value';
            else
                valueString='String';
            end
            if strcmpi(self.Type,'Antenna Object')
                self.WkSpcObj=self.WkSpcEdit.(valueString);
            elseif strcmpi(self.Type,'Antenna Designer')
                self.Object=self.AntObj;
            end
            if~self.NameChanged&&~self.OtherPropertiesChanged

                self.IsReturnKey=0;
                idx=self.Parent.View.Canvas.SelectIdx;
                if self.Parent.View.UseAppContainer
                    self.Parent.notify('DisableCanvas',...
                    rf.internal.apps.budget.ElementParameterChangedEventData(idx,...
                    'ApplyButton','inactive'));
                else
                    self.Parent.notify('DisableCanvas',...
                    rf.internal.apps.budget.ElementParameterChangedEventData(idx,...
                    'ApplyTag','inactive'));
                end
                return;
            end
            self.Parent.View.enableActions(false);
            Ant=[];
            if~isempty(self.WkSpcEdit.(valueString))&&strcmpi(self.Type,'Antenna Object')
                Ant=evalin('base',self.WkSpcEdit.(valueString));
                if isa(Ant,'em.Antenna')
                    self.AntObj=Ant;
                    self.Z=impedance(self.AntObj,self.InputFreq);
                else
                    h=errordlg(getString(message('rf:shared:AntennaVariable')),'Error Dialog','modal');
                    uiwait(h)
                    self.Parent.View.enableActions(true);
                    return;
                end
            end
            if self.Parent.View.UseAppContainer
                Imp=str2num(self.Z);
            else
                Imp=self.Z;
            end
            idx=self.Parent.View.Canvas.SelectIdx;
            if~isempty(self.DirEdit.(valueString))&&~isempty(self.AntObj)
                dir=str2num(self.DirEdit.(valueString));
                if iscolumn(dir)
                    dir=dir';
                end
                validateattributes(dir,{'numeric'},...
                {'numel',2,'nonempty','nonnan','finite','real','nonnegative'},...
                'rfantenna','input');
                self.Directivity=pattern(self.AntObj,self.InputFreq,dir(1),dir(2));
                self.Gain=self.Directivity;
            end
            haveAntTbx=builtin('license','test','Antenna_Toolbox')&&...
            ~isempty(ver('antenna'));
            if haveAntTbx&&~isempty(self.AntObj)
                if isempty(Ant)
                    antennaObj=rfantenna('Name',self.Name,'Gain',self.Gain,...
                    'Z',Imp,'AntennaObject',self.AntObj,...
                    'Frequency',self.InputFreq,'DirectionAngles',dir);
                else
                    vars=evalin('base','whos');
                    arr=zeros(1,length(vars));
                    for i=1:length(vars)
                        arr(i)=strcmpi(vars(i,1).class,class(Ant));
                    end
                    index=find(arr);
                    AntName=vars(index,1).name;%#ok<FNDSB>
                    antennaObj=rfantenna('Name',self.Name,'Gain',self.Gain,...
                    'Z',Imp,'AntennaObject',AntName,'AntennaDesign',Ant,...
                    'Frequency',self.InputFreq,'DirectionAngles',dir);
                end
            else
                self.InputFreq=self.Parent.SystemDialog.InputFrequency;
                if~isempty(self.Parent.ModulatorDialog)
                    if strcmpi(self.Parent.ModulatorDialog.ConverterType,'Up')
                        self.InputFreq=self.InputFreq+self.Parent.ModulatorDialog.LO;
                    else
                        self.InputFreq=self.InputFreq-self.Parent.ModulatorDialog.LO;
                    end
                end
                antennaObj=rfantenna('Name',self.Name,'Gain',self.Gain,...
                'Z',Imp,'Frequency',self.InputFreq);
            end
            self.Parent.notify('DisableCanvas',...
            rf.internal.apps.budget.ElementParameterChangedEventData(idx,...
            'ApplyButton','inactive'));
            if self.NameChanged&&~self.OtherPropertiesChanged

                self.Parent.notify('ElementParameterChanged',...
                rf.internal.apps.budget.ElementParameterChangedEventData(idx,...
                'Name',self.NameEdit.(valueString)));
            else


                self.Parent.notify('ElementParameterChanged',...
                rf.internal.apps.budget.ElementParameterChangedEventData(idx,...
                'ApplyButton',antennaObj));
            end
            whiteColor=[1,1,1];
            self.NameEdit.BackgroundColor=whiteColor;
            self.TypePopup.BackgroundColor=whiteColor;
            self.GainEdit.BackgroundColor=whiteColor;
            self.ZEdit.BackgroundColor=whiteColor;
            self.WkSpcEdit.BackgroundColor=whiteColor;
            self.DirEdit.BackgroundColor=whiteColor;
            self.ApplyLabel.Enable='off';
            self.Parent.View.setStatusBarMsg('');
            enableIP2(self.Parent.View.Toolstrip,false);
            self.NameChanged=0;
            self.OtherPropertiesChanged=0;
            self.IsReturnKey=0;
            self.Parent.View.enableActions(true);
        end

        function parameterPaneChange(self)
            if self.Parent.View.UseAppContainer
                imageSourceCData='ImageSource';
            else
                imageSourceCData='CData';
            end
            switch self.Type
            case 'Antenna Designer'

                self.AntLabel.Enable='on';
                self.AntLabel.Visible='on';

                if~isempty(self.Icon.(imageSourceCData))
                    self.Icon.Visible='on';
                else
                    self.ApplyLabel.Enable='off';
                end

                self.GainLabel.Visible='off';
                self.GainEdit.Visible='off';
                self.GainUnits.Visible='off';

                self.ZLabel.Visible='off';
                self.ZEdit.Visible='off';
                self.ZUnits.Visible='off';

                self.WkSpcLabel.Visible='off';
                self.WkSpcEdit.Visible='off';

                self.DirLabel.Visible='on';
                self.DirEdit.Visible='on';
                self.DirUnits.Visible='on';

                self.ApplyLabel.Enable='off';
            case 'Antenna Object'

                self.AntLabel.Enable='off';
                self.AntLabel.Visible='off';

                self.Icon.Visible='off';

                self.GainLabel.Visible='off';
                self.GainEdit.Visible='off';
                self.GainUnits.Visible='off';

                self.ZLabel.Visible='off';
                self.ZEdit.Visible='off';
                self.ZUnits.Visible='off';

                self.WkSpcLabel.Visible='on';
                self.WkSpcEdit.Visible='on';

                self.DirLabel.Visible='on';
                self.DirEdit.Visible='on';
                self.DirUnits.Visible='on';
            case 'Isotropic Radiator'

                self.AntLabel.Enable='off';
                self.AntLabel.Visible='off';

                self.Icon.Visible='off';

                self.WkSpcLabel.Visible='off';
                self.WkSpcEdit.Visible='off';

                self.DirLabel.Visible='off';
                self.DirEdit.Visible='off';
                self.DirUnits.Visible='off';

                self.GainLabel.Visible='on';
                self.GainEdit.Visible='on';
                self.GainUnits.Visible='on';

                self.ZLabel.Visible='on';
                self.ZEdit.Visible='on';
                self.ZUnits.Visible='on';
            end
        end

        function FigKeyEvent(self,ev)

            if isa(self.Parent.ElementDialog,'rf.internal.apps.budget.AntennaDialog')
                key=ev.Key;
                switch key
                case 'return'
                    self.IsReturnKey=1;
                end
            end
        end

        function FigKeyEventCanvas(self,ev)


            if isa(self.Parent.ElementDialog,'rf.internal.apps.budget.AntennaDialog')
                key=ev.Key;
                switch key
                case 'return'
                    try
                        self.applyFunction();
                    catch me
                        if strcmpi(me.identifier,'MATLAB:validators:mustBeNonempty')
                            self.IsReturnKey=0;
                            return;
                        else
                            h=errordlg(me.message,'Error Dialog','modal');
                        end
                        uiwait(h)
                        self.Parent.View.enableActions(true);
                    end
                end
            end
        end


        function addListeners(self)



            if self.Parent.View.UseAppContainer
                self.NameEdit.ValueChangedFcn=@(h,e)parameterChanged(self,e);
                self.TypePopup.ValueChangedFcn=@(h,e)parameterChanged(self,e);
                self.TypePopup.ValueChangedFcn=@(h,e)parameterChanged(self,e);
                self.GainEdit.ValueChangedFcn=@(h,e)parameterChanged(self,e);
                self.ZEdit.ValueChangedFcn=@(h,e)parameterChanged(self,e);
                self.WkSpcEdit.ValueChangedFcn=@(h,e)parameterChanged(self,e);
                self.DirEdit.ValueChangedFcn=@(h,e)parameterChanged(self,e);
                self.AntLabel.ButtonPushedFcn=@(h,e)parameterChanged(self,e);
                self.ApplyLabel.ButtonPushedFcn=@(h,e)parameterChanged(self,e);
            else
                self.NameEdit.KeyPressFcn=@(h,e)parameterChanged(self,e);
                self.Listeners.Type=addlistener(self.TypePopup,...
                'Value',...
                'PostSet',@(h,e)parameterChanged(self,e));
                self.TypePopup.KeyPressFcn=@(h,e)parameterChanged(self,e);
                self.GainEdit.KeyPressFcn=@(h,e)parameterChanged(self,e);
                self.ZEdit.KeyPressFcn=@(h,e)parameterChanged(self,e);
                self.WkSpcEdit.KeyPressFcn=@(h,e)parameterChanged(self,e);
                self.DirEdit.KeyPressFcn=@(h,e)parameterChanged(self,e);
                self.Listeners.Ant=addlistener(self.AntLabel,...
                'Value',...
                'PostSet',@(h,e)parameterChanged(self,e));
                self.Listeners.Apply=addlistener(self.ApplyLabel,...
                'Value',...
                'PostSet',@(h,e)parameterChanged(self,e));
            end
        end
    end
end





