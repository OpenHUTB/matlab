classdef AntennaDialogTxRx<handle







    properties
Parent
Panel
Layout
        Width=0
        Height=0
Listeners
TypePopupRx
TypePopupTx
InputFreq
AntImpRx
AntImpTx
        AntObjRx=[]
        AntObjTx=[]
DirectivityRx
DirectivityTx
HaveAntTbx
DesignerButton
        ObjectRx{mustBeNonempty}=0
        ObjectTx{mustBeNonempty}=0
        AppHandleRx=[]
        AppHandleTx=[]
IconSaveRx
IconSaveTx

    end

    properties(Dependent)
Name
TypeRx
TypeTx
        GainRx{mustBeNonempty,mustBeScalarOrEmpty}
        GainTx{mustBeNonempty,mustBeScalarOrEmpty}
        ZRx{mustBeNonempty,mustBeScalarOrEmpty}
        ZTx{mustBeNonempty,mustBeScalarOrEmpty}
        WkSpcRxObj{mustBeNonempty}
        WkSpcTxObj{mustBeNonempty}
DirRx
DirTx
PathLoss

    end

    properties(Access=private)

Title
TitleRx
TitleTx

IconPanRx
IconPanTx
IconRx
IconTx

NameLabel
NameEdit

TypeRxLabel
TypeTxLabel

AntRxLabel
AntTxLabel

GainRxLabel
GainRxEdit
GainRxUnits
GainTxLabel
GainTxEdit
GainTxUnits

ZRxLabel
ZRxEdit
ZRxUnits
ZTxLabel
ZTxEdit
ZTxUnits

PathLossLabel
PathLossEdit
PathLossUnits

WkSpcRxLabel
WkSpcRxEdit
WkSpcTxLabel
WkSpcTxEdit

DirRxLabel
DirRxEdit
DirRxUnits

DirTxLabel
DirTxEdit
DirTxUnits

ApplyLabel

OutputLabel
        IsReturnKey=0
        NameChanged=0
        OtherPropertiesChanged=0

    end

    methods


        function self=AntennaDialogTxRx(parent)




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

            AppHandle=[self.AppHandleTx,self.AppHandleRx];

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

        function val=get.GainRx(self)
            if self.Parent.View.UseAppContainer
                val=self.GainRxEdit.Value;
            else
                val=str2num(self.GainRxEdit.String);%#ok<*ST2NM>
            end
        end
        function val=get.GainTx(self)
            if self.Parent.View.UseAppContainer
                val=self.GainTxEdit.Value;
            else
                val=str2num(self.GainTxEdit.String);%#ok<*ST2NM>
            end
        end

        function set.GainRx(self,val)
            if self.Parent.View.UseAppContainer
                self.GainRxEdit.Value=val;
            else
                self.GainRxEdit.String=num2str(val);
            end
        end
        function set.GainTx(self,val)
            if self.Parent.View.UseAppContainer
                self.GainTxEdit.Value=val;
            else
                self.GainTxEdit.String=num2str(val);
            end
        end

        function val=get.ZRx(self)
            if self.Parent.View.UseAppContainer
                val=self.ZRxEdit.Value;
            else
                val=str2num(self.ZRxEdit.String);
            end
        end
        function val=get.ZTx(self)
            if self.Parent.View.UseAppContainer
                val=self.ZTxEdit.Value;
            else
                val=str2num(self.ZTxEdit.String);
            end
        end

        function set.ZRx(self,val)
            if self.Parent.View.UseAppContainer
                self.ZRxEdit.Value=val;
            else
                self.ZRxEdit.String=num2str(val);
            end
        end
        function set.ZTx(self,val)
            if self.Parent.View.UseAppContainer
                self.ZTxEdit.Value=val;
            else
                self.ZTxEdit.String=num2str(val);
            end
        end


        function val=get.PathLoss(self)
            if self.Parent.View.UseAppContainer
                val=self.PathLossEdit.Value;
            else
                val=str2num(self.PathLossEdit.String);
            end
        end

        function set.PathLoss(self,val)
            if self.Parent.View.UseAppContainer
                self.PathLossEdit.Value=val;
            else
                self.PathLossEdit.String=num2str(val);
            end
        end

        function val=get.WkSpcRxObj(self)
            if self.Parent.View.UseAppContainer
                val=self.WkSpcRxEdit.Value;
            else
                val=self.WkSpcRxEdit.String;
            end
        end
        function val=get.WkSpcTxObj(self)
            if self.Parent.View.UseAppContainer
                val=self.WkSpcTxEdit.Value;
            else
                val=self.WkSpcTxEdit.String;
            end
        end

        function set.WkSpcRxObj(self,val)
            if self.Parent.View.UseAppContainer
                self.WkSpcRxEdit.Value=val;
            else
                self.WkSpcRxEdit.String=val;
            end
        end
        function set.WkSpcTxObj(self,val)
            if self.Parent.View.UseAppContainer
                self.WkSpcTxEdit.Value=val;
            else
                self.WkSpcTxEdit.String=val;
            end
        end
        function val=get.DirRx(self)
            if self.Parent.View.UseAppContainer
                val=str2num(self.DirRxEdit.Value);
            else
                val=str2num(self.DirRxEdit.String);
            end
        end
        function val=get.DirTx(self)
            if self.Parent.View.UseAppContainer
                val=str2num(self.DirTxEdit.Value);
            else
                val=str2num(self.DirTxEdit.String);
            end
        end

        function set.DirRx(self,val)
            if self.Parent.View.UseAppContainer
                self.DirRxEdit.Value=val;
            else
                self.DirRxEdit.String=mat2str(val);
            end
        end
        function set.DirTx(self,val)
            if self.Parent.View.UseAppContainer
                self.DirTxEdit.Value=val;
            else
                self.DirTxEdit.String=mat2str(val);
            end
        end

        function str=get.TypeRx(self)
            if self.Parent.View.UseAppContainer
                str=self.TypePopupRx.Value;
            else
                str=self.TypePopupRx.String{self.TypePopupRx.Value};
            end
        end
        function str=get.TypeTx(self)
            if self.Parent.View.UseAppContainer
                str=self.TypePopupTx.Value;
            else
                str=self.TypePopupTx.String{self.TypePopupTx.Value};
            end
        end

        function set.TypeRx(self,str)
            if self.Parent.View.UseAppContainer
                rf.internal.apps.budget.setValue(self,self,'TypePopupRx',str)
            else
                switch str
                case 'Isotropic Receiver'
                    self.TypePopupRx.Value=1;
                case 'Antenna Designer'
                    self.TypePopupRx.Value=2;
                case 'Antenna Object'
                    self.TypePopupRx.Value=3;
                end
            end
        end
        function set.TypeTx(self,str)
            if self.Parent.View.UseAppContainer
                rf.internal.apps.budget.setValue(self,self,'TypePopupTx',str)
            else
                switch str
                case 'Isotropic Radiator'
                    self.TypePopupTx.Value=1;
                case 'Antenna Designer'
                    self.TypePopupTx.Value=2;
                case 'Antenna Object'
                    self.TypePopupTx.Value=3;
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
            switch self.TypePopupTx.Value
            case{1,'Isotropic Radiator'}
                self.WkSpcRxEdit.(valueString)='';
                self.DirRxEdit.(valueString)='[0 0]';
                self.AntObjTx=[];
                self.IconTx.Visible='off';
            case{3,'Antenna Object'}
                self.WkSpcTxEdit.(valueString)=self.WkSpcTxObj;
            case{2,'Antenna Designer'}
                self.IconTx.(Image)=self.IconSaveTx;
                self.IconTx.Visible='on';
            end
            switch self.TypePopupRx.Value
            case{1,'Isotropic Receiver'}
                self.WkSpcRxEdit.(valueString)='';
                self.DirRxEdit.(valueString)='[0 0]';
                self.AntObjRx=[];
                self.IconRx.Visible='off';
            case{3,'Antenna Object'}
                self.WkSpcRxEdit.(valueString)=self.WkSpcRxObj;
            case{2,'Antenna Designer'}
                self.IconRx.(Image)=self.IconSaveRx;
                self.IconRx.Visible='on';
            end
            self.TypePopupRx.BackgroundColor=whiteColor;
            self.TypePopupTx.BackgroundColor=whiteColor;
            self.GainRxEdit.BackgroundColor=whiteColor;
            self.GainTxEdit.BackgroundColor=whiteColor;
            self.ZRxEdit.BackgroundColor=whiteColor;
            self.ZTxEdit.BackgroundColor=whiteColor;
            self.PathLossEdit.BackgroundColor=whiteColor;
            self.WkSpcRxEdit.BackgroundColor=whiteColor;
            self.WkSpcTxEdit.BackgroundColor=whiteColor;
            self.DirRxEdit.BackgroundColor=whiteColor;
            self.DirTxEdit.BackgroundColor=whiteColor;
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
            self.TypePopupRx.Enable=val;
            self.TypePopupTx.Enable=val;
            self.GainRxEdit.Enable=val;
            self.GainTxEdit.Enable=val;
            self.ZRxEdit.Enable=val;
            self.ZTxEdit.Enable=val;
            self.PathLossEdit.Enable=val;
            self.WkSpcRxEdit.Enable=val;
            self.WkSpcTxEdit.Enable=val;
            self.DirRxEdit.Enable=val;
            self.DirTxEdit.Enable=val;

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

    methods(Static)
        function propUpdate(ant,self)

            icon=imread(ant.iconFilePath);
            i=icon.*255;
            in(:,:,:)=255-i(:,:,:);
            icon(:,:,:)=icon(:,:,:)+in(:,:,:);
            if self.Parent.View.UseAppContainer
                Image='ImageSource';
            else
                Image='CData';
            end
            if strcmpi(self.TypeRx,'Antenna Designer')&&strcmpi(self.DesignerButton,'AntTagRx')
                self.IconSaveRx=icon;
                self.IconRx.(Image)=icon;
                self.IconRx.Visible='on';
                self.AntImpRx=ant.Zin;
                self.ZRx=self.AntImpRx;
                self.AntObjRx=ant.obj;
                self.AntRxLabel.Enable='on';
            end
            if strcmpi(self.TypeTx,'Antenna Designer')&&strcmpi(self.DesignerButton,'AntTagTx')
                self.IconSaveTx=icon;
                self.IconTx.(Image)=icon;
                self.IconTx.Visible='on';
                self.AntImpTx=ant.Zin;
                self.ZTx=self.AntImpTx;
                self.AntObjTx=ant.obj;
                self.AntTxLabel.Enable='on';
            end
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

                self.IconRx=uiimage(...
                'Parent',self.Layout,...
                'Visible','off',...
                'Tag','IconImage');

                self.TitleRx=uilabel(...
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
                'Value','TransmitReceive',...
                'HorizontalAlignment','left');

                self.TypeRxLabel=uilabel(...
                'UserData',userData,...
                'Tag','TypeLabel',...
                'Parent',self.Layout,...
                'Text','Antenna Source',...
                'HorizontalAlignment','right');
                self.TypePopupRx=uidropdown(...
                'UserData',userData,...
                'Tag','TypeDropdown',...
                'Parent',self.Layout,...
                'Items',{'Isotropic Radiator','Antenna Designer','Antenna Object'},...
                'Value','Isotropic Radiator');

                self.GainRxLabel=uilabel(...
                'UserData',userData,...
                'Tag','GainLabel',...
                'Parent',self.Layout,...
                'Text','Gain',...
                'HorizontalAlignment','right');
                self.GainRxEdit=uieditfield(...
                'numeric',...
                'UserData',userData,...
                'Tag','GainEditField',...
                'Parent',self.Layout,...
                'Value',0,...
                'HorizontalAlignment','left');
                self.GainRxUnits=uilabel(...
                'UserData',userData,...
                'Tag','GainUnitsLabel',...
                'Parent',self.Layout,...
                'Text','dBi',...
                'HorizontalAlignment','left');

                self.ZRxLabel=uilabel(...
                'UserData',userData,...
                'Tag','ZLabel',...
                'Parent',self.Layout,...
                'Text',...
                'Z',...
                'HorizontalAlignment','right');
                self.ZRxEdit=uieditfield(...
                'numeric',...
                'UserData',userData,...
                'Tag','ZEditField',...
                'Parent',self.Layout,...
                'Value',50,...
                'Tag',...
                'Z',...
                'HorizontalAlignment','left');
                self.ZRxUnits=uilabel(...
                'UserData',userData,...
                'Tag','ZUnitsLabel',...
                'Parent',self.Layout,...
                'Text','ohm',...
                'HorizontalAlignment','left');

                self.PathLossLabel=uilabel(...
                'UserData',userData,...
                'Tag','PathLossLabel',...
                'Parent',self.Layout,...
                'Text','Path Loss',...
                'HorizontalAlignment','right');
                self.PathLossEdit=uieditfield(...
                'numeric',...
                'UserData',userData,...
                'Tag','PathLossEditField',...
                'Parent',self.Layout,...
                'Value',0,...
                'HorizontalAlignment','left');
                self.PathLossUnits=uilabel(...
                'UserData',userData,...
                'Tag','PathLossUnitsLabel',...
                'Parent',self.Layout,...
                'Text','dB',...
                'HorizontalAlignment','left');

                self.WkSpcRxLabel=uilabel(...
                'UserData',userData,...
                'Tag','WkSpcLabel',...
                'Parent',self.Layout,...
                'Text','Antenna Object',...
                'HorizontalAlignment','right',...
                'Visible','off');
                self.WkSpcRxEdit=uieditfield(...
                'UserData',userData,...
                'Tag','WkSpcEditField',...
                'Parent',self.Layout,...
                'Value','',...
                'HorizontalAlignment','left',...
                'Visible','off');

                self.DirRxLabel=uilabel(...
                'UserData',userData,...
                'Tag','DirLabel',...
                'Parent',self.Layout,...
                'Text','Direction of Arrival',...
                'HorizontalAlignment','right',...
                'Visible','off');
                self.DirRxEdit=uieditfield(...
                'UserData',userData,...
                'Tag','DirEditField',...
                'Parent',self.Layout,...
                'Value','[0 0]',...
                'HorizontalAlignment','left',...
                'Visible','off');
                self.DirRxUnits=uilabel(...
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

                self.AntRxLabel=uibutton(...
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
                'Visible','off');

                self.IconRx=uicontrol('Parent',self.Panel,...
                'Style','checkbox',...
                'Visible','off');
                self.IconTx=uicontrol('Parent',self.Panel,...
                'Style','checkbox',...
                'Visible','off');

                self.Title=uicontrol(...
                'Parent',self.Panel,...
                'Style','text',...
                'String','TransmitReceive Antenna Element',...
                'ForegroundColor',[0,0,0],...
                'BackgroundColor',[.94,.94,.94],...
                'HorizontalAlignment','left');
                self.TitleRx=uicontrol(...
                'Parent',self.Panel,...
                'Style','text',...
                'String','Receiving Antenna Element:',...
                'ForegroundColor',[0,0,0],...
                'BackgroundColor',[.94,.94,.94],...
                'HorizontalAlignment','left');
                self.TitleTx=uicontrol(...
                'Parent',self.Panel,...
                'Style','text',...
                'String','Transmitting Antenna Element:',...
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
                'String','TransmitReceive',...
                'Tag','Name',...
                'HorizontalAlignment','left');

                self.TypeRxLabel=uicontrol(...
                'Parent',self.Panel,...
                'Style','text',...
                'String','Antenna Source',...
                'HorizontalAlignment','right');
                self.TypeTxLabel=uicontrol(...
                'Parent',self.Panel,...
                'Style','text',...
                'String','Antenna Source',...
                'HorizontalAlignment','right');
                self.TypePopupRx=uicontrol(...
                'Parent',self.Panel,...
                'Style','popup',...
                'String',{'Isotropic Receiver','Antenna Designer','Antenna Object'},...
                'Tag','TypeRx',...
                'Value',1,...
                'HorizontalAlignment','left');
                self.TypePopupTx=uicontrol(...
                'Parent',self.Panel,...
                'Style','popup',...
                'String',{'Isotropic Radiator','Antenna Designer','Antenna Object'},...
                'Tag','TypeTx',...
                'Value',1,...
                'HorizontalAlignment','left');

                self.GainRxLabel=uicontrol(...
                'Parent',self.Panel,...
                'Style','text',...
                'String','Gain',...
                'HorizontalAlignment','right');
                self.GainRxEdit=uicontrol(...
                'Parent',self.Panel,...
                'Style','edit',...
                'String','0',...
                'Tag','GainRx',...
                'HorizontalAlignment','left');
                self.GainRxUnits=uicontrol(...
                'Parent',self.Panel,...
                'Style','text',...
                'String','dBi',...
                'HorizontalAlignment','left');
                self.GainTxLabel=uicontrol(...
                'Parent',self.Panel,...
                'Style','text',...
                'String','Gain',...
                'HorizontalAlignment','right');
                self.GainTxEdit=uicontrol(...
                'Parent',self.Panel,...
                'Style','edit',...
                'String','0',...
                'Tag','GainTx',...
                'HorizontalAlignment','left');
                self.GainTxUnits=uicontrol(...
                'Parent',self.Panel,...
                'Style','text',...
                'String','dBi',...
                'HorizontalAlignment','left');

                self.ZRxLabel=uicontrol(...
                'Parent',self.Panel,...
                'Style','text',...
                'String','Antenna Impedance',...
                'HorizontalAlignment','right');
                self.ZRxEdit=uicontrol(...
                'Parent',self.Panel,...
                'Style','edit',...
                'String','50',...
                'Tag','ZRx',...
                'HorizontalAlignment','left');
                self.ZRxUnits=uicontrol(...
                'Parent',self.Panel,...
                'Style','text',...
                'String','ohm',...
                'HorizontalAlignment','left');
                self.ZTxLabel=uicontrol(...
                'Parent',self.Panel,...
                'Style','text',...
                'String','Antenna Impedance',...
                'HorizontalAlignment','right');
                self.ZTxEdit=uicontrol(...
                'Parent',self.Panel,...
                'Style','edit',...
                'String','50',...
                'Tag','ZTx',...
                'HorizontalAlignment','left');
                self.ZTxUnits=uicontrol(...
                'Parent',self.Panel,...
                'Style','text',...
                'String','ohm',...
                'HorizontalAlignment','left');

                self.PathLossLabel=uicontrol(...
                'Parent',self.Panel,...
                'Style','text',...
                'String','Path Loss',...
                'HorizontalAlignment','right');
                self.PathLossEdit=uicontrol(...
                'Parent',self.Panel,...
                'Style','edit',...
                'String','0',...
                'Tag','PathLoss',...
                'HorizontalAlignment','left');
                self.PathLossUnits=uicontrol(...
                'Parent',self.Panel,...
                'Style','text',...
                'String','dB',...
                'HorizontalAlignment','left');

                self.WkSpcRxLabel=uicontrol(...
                'Parent',self.Panel,...
                'Style','text',...
                'String','Antenna Object',...
                'HorizontalAlignment','right',...
                'Visible','off');
                self.WkSpcRxEdit=uicontrol(...
                'Parent',self.Panel,...
                'Style','edit',...
                'String','',...
                'Tag','WkSpcRx',...
                'HorizontalAlignment','left',...
                'Visible','off');
                self.WkSpcTxLabel=uicontrol(...
                'Parent',self.Panel,...
                'Style','text',...
                'String','Antenna Object',...
                'HorizontalAlignment','right',...
                'Visible','off');
                self.WkSpcTxEdit=uicontrol(...
                'Parent',self.Panel,...
                'Style','edit',...
                'String','',...
                'Tag','WkSpcTx',...
                'HorizontalAlignment','left',...
                'Visible','off');

                self.DirRxLabel=uicontrol(...
                'Parent',self.Panel,...
                'Style','text',...
                'String','Direction of Arrival',...
                'HorizontalAlignment','right',...
                'Visible','off');
                self.DirRxEdit=uicontrol(...
                'Parent',self.Panel,...
                'Style','edit',...
                'String','[0 0]',...
                'Tag','ElevationRx',...
                'HorizontalAlignment','left',...
                'Visible','off');
                self.DirRxUnits=uicontrol(...
                'Parent',self.Panel,...
                'Style','text',...
                'String','deg',...
                'HorizontalAlignment','left',...
                'Visible','off');
                self.DirTxLabel=uicontrol(...
                'Parent',self.Panel,...
                'Style','text',...
                'String','Direction of Departure',...
                'HorizontalAlignment','right',...
                'Visible','off');
                self.DirTxEdit=uicontrol(...
                'Parent',self.Panel,...
                'Style','edit',...
                'String','[0 0]',...
                'Tag','ElevationTx',...
                'HorizontalAlignment','left',...
                'Visible','off');
                self.DirTxUnits=uicontrol(...
                'Parent',self.Panel,...
                'Style','text',...
                'String','deg',...
                'HorizontalAlignment','left',...
                'Visible','off');

                self.ApplyLabel=uicontrol(...
                'Parent',self.Panel,...
                'Style','pushbutton',...
                'String','Apply',...
                'Tag','ApplyTag',...
                'HorizontalAlignment','right',...
                'Value',0,...
                'Tooltip','Apply parameters to selected Element (Enter)');

                self.AntRxLabel=uicontrol(...
                'Parent',self.Panel,...
                'Style','pushbutton',...
                'String','Create Antenna',...
                'Tag','AntTagRx',...
                'HorizontalAlignment','right',...
                'Value',0,...
                'Tooltip','Create antenna using Antenna Designer',...
                'Visible','off');
                self.AntTxLabel=uicontrol(...
                'Parent',self.Panel,...
                'Style','pushbutton',...
                'String','Create Antenna',...
                'Tag','AntTagTx',...
                'HorizontalAlignment','right',...
                'Value',0,...
                'Tooltip','Create antenna using Antenna Designer',...
                'Visible','off');
                self.Panel.Visible='on';
                self.Panel.Visible='on';
            end
        end

        function layoutUIControls(self,varargin)




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
                'VerticalWeights',[0,0,1,0,0,0,0,1,0,0,0],...
                'HorizontalWeights',[0,1,0]);

            end

            rowTx=3;
            rowRx=8;
            titleHt=16;
            self.Parent.addTitle(self.Layout,self.Title,1,[1,3],...
            titleHt,hspacing,vspacing,self.Parent.View.UseAppContainer)


            h=24;
            self.Parent.addText(self.Layout,self.NameLabel,2,1,w1,h,...
            self.Parent.View.UseAppContainer)
            self.Parent.addEdit(self.Layout,self.NameEdit,2,2,w2,h,...
            self.Parent.View.UseAppContainer)


            self.Parent.addTitle(self.Layout,self.TitleRx,rowRx,[1,3],...
            titleHt,hspacing,vspacing,self.Parent.View.UseAppContainer)
            self.Parent.addTitle(self.Layout,self.TitleTx,rowTx,[1,3],...
            titleHt,hspacing,vspacing,self.Parent.View.UseAppContainer)


            rowRx=rowRx+1;
            self.Parent.addText(self.Layout,self.TypeRxLabel,rowRx,1,w1,h,...
            self.Parent.View.UseAppContainer)
            self.Parent.addEdit(self.Layout,self.TypePopupRx,rowRx,2,w2,h,...
            self.Parent.View.UseAppContainer)
            rowTx=rowTx+1;
            self.Parent.addText(self.Layout,self.TypeTxLabel,rowTx,1,w1,h,...
            self.Parent.View.UseAppContainer)
            self.Parent.addEdit(self.Layout,self.TypePopupTx,rowTx,2,w2,h,...
            self.Parent.View.UseAppContainer)

            self.HaveAntTbx=builtin('license','test','Antenna_Toolbox')&&...
            ~isempty(ver('antenna'));
            if~self.HaveAntTbx
                self.TypePopupRx.String={'Isotropic Receiver'};
                self.TypePopupTx.String={'Isotropic Radiator'};
            end

            if strcmpi(self.TypeRx,'Isotropic Receiver')

                rowRx=rowRx+1;
                self.Parent.addText(self.Layout,self.GainRxLabel,rowRx,1,w1,h,...
                self.Parent.View.UseAppContainer)
                self.Parent.addEdit(self.Layout,self.GainRxEdit,rowRx,2,w2,h,...
                self.Parent.View.UseAppContainer)
                self.Parent.addText(self.Layout,self.GainRxUnits,rowRx,3,w3,h,...
                self.Parent.View.UseAppContainer)

                rowRx=rowRx+1;
                self.Parent.addText(self.Layout,self.ZRxLabel,rowRx,1,w1,h,...
                self.Parent.View.UseAppContainer)
                self.Parent.addEdit(self.Layout,self.ZRxEdit,rowRx,2,w2,h,...
                self.Parent.View.UseAppContainer)
                self.Parent.addText(self.Layout,self.ZRxUnits,rowRx,3,w3,h,...
                self.Parent.View.UseAppContainer)

                rowRx=rowRx+1;
                self.Parent.addText(self.Layout,self.PathLossLabel,rowRx,1,w1,h,...
                self.Parent.View.UseAppContainer)
                self.Parent.addEdit(self.Layout,self.PathLossEdit,rowRx,2,w2,h,...
                self.Parent.View.UseAppContainer)
                self.Parent.addText(self.Layout,self.PathLossUnits,rowRx,3,w3,h,...
                self.Parent.View.UseAppContainer)

                if self.OtherPropertiesChanged&&strcmpi(varargin{1},'TypeRx')
                    self.GainRxEdit.BackgroundColor=[1,0.96,0.88];
                    self.ZRxEdit.BackgroundColor=[1,0.96,0.88];
                    self.PathLossEdit.BackgroundColor=[1,0.96,0.88];
                end

            elseif strcmpi(self.TypeRx,'Antenna Designer')

                rowRx=rowRx+1;
                self.Parent.addText(self.Layout,self.AntRxLabel,rowRx,2,90,h+5,...
                self.Parent.View.UseAppContainer)

                rowRx=rowRx+1;
                self.Parent.addText(self.Layout,self.IconRx,rowRx,2,75,45,...
                self.Parent.View.UseAppContainer)

                rowRx=rowRx+1;
                self.Parent.addText(self.Layout,self.DirRxLabel,rowRx,1,w1,h,...
                self.Parent.View.UseAppContainer)
                self.Parent.addEdit(self.Layout,self.DirRxEdit,rowRx,2,w2,h,...
                self.Parent.View.UseAppContainer)
                self.Parent.addText(self.Layout,self.DirRxUnits,rowRx,3,w3,h,...
                self.Parent.View.UseAppContainer)

                rowRx=rowRx+1;
                self.Parent.addText(self.Layout,self.PathLossLabel,rowRx,1,w1,h,...
                self.Parent.View.UseAppContainer)
                self.Parent.addEdit(self.Layout,self.PathLossEdit,rowRx,2,w2,h,...
                self.Parent.View.UseAppContainer)
                self.Parent.addText(self.Layout,self.PathLossUnits,rowRx,3,w3,h,...
                self.Parent.View.UseAppContainer)

                self.Parent.View.setStatusBarMsg('Design antenna and set "Direction of Arrival".');
                if self.OtherPropertiesChanged&&strcmpi(varargin{1},'TypeRx')
                    self.DirRxEdit.BackgroundColor=[1,0.96,0.88];
                    self.PathLossEdit.BackgroundColor=[1,0.96,0.88];
                end

            else

                rowRx=rowRx+1;
                self.Parent.addText(self.Layout,self.WkSpcRxLabel,rowRx,1,w1,h,...
                self.Parent.View.UseAppContainer)
                self.Parent.addEdit(self.Layout,self.WkSpcRxEdit,rowRx,2,w2,h,...
                self.Parent.View.UseAppContainer)

                rowRx=rowRx+1;
                self.Parent.addText(self.Layout,self.DirRxLabel,rowRx,1,w1,h,...
                self.Parent.View.UseAppContainer)
                self.Parent.addEdit(self.Layout,self.DirRxEdit,rowRx,2,w2,h,...
                self.Parent.View.UseAppContainer)
                self.Parent.addText(self.Layout,self.DirRxUnits,rowRx,3,w3,h,...
                self.Parent.View.UseAppContainer)

                rowRx=rowRx+1;
                self.Parent.addText(self.Layout,self.PathLossLabel,rowRx,1,w1,h,...
                self.Parent.View.UseAppContainer)
                self.Parent.addEdit(self.Layout,self.PathLossEdit,rowRx,2,w2,h,...
                self.Parent.View.UseAppContainer)
                self.Parent.addText(self.Layout,self.PathLossUnits,rowRx,3,w3,h,...
                self.Parent.View.UseAppContainer)

                self.Parent.View.setStatusBarMsg('Design antenna and set "Direction of Arrival".');
                if self.OtherPropertiesChanged&&strcmpi(varargin{1},'TypeRx')
                    self.WkSpcRxEdit.BackgroundColor=[1,0.96,0.88];
                    self.DirRxEdit.BackgroundColor=[1,0.96,0.88];
                    self.PathLossEdit.BackgroundColor=[1,0.96,0.88];
                end
            end
            if strcmpi(self.TypeTx,'Isotropic Radiator')

                rowTx=rowTx+1;
                self.Parent.addText(self.Layout,self.GainTxLabel,rowTx,1,w1,h,...
                self.Parent.View.UseAppContainer)
                self.Parent.addEdit(self.Layout,self.GainTxEdit,rowTx,2,w2,h,...
                self.Parent.View.UseAppContainer)
                self.Parent.addText(self.Layout,self.GainTxUnits,rowTx,3,w3,h,...
                self.Parent.View.UseAppContainer)

                rowTx=rowTx+1;
                self.Parent.addText(self.Layout,self.ZTxLabel,rowTx,1,w1,h,...
                self.Parent.View.UseAppContainer)
                self.Parent.addEdit(self.Layout,self.ZTxEdit,rowTx,2,w2,h,...
                self.Parent.View.UseAppContainer)
                self.Parent.addText(self.Layout,self.ZTxUnits,rowTx,3,w3,h,...
                self.Parent.View.UseAppContainer)

                if self.OtherPropertiesChanged&&strcmpi(varargin{1},'TypeTx')
                    self.GainTxEdit.BackgroundColor=[1,0.96,0.88];
                    self.ZTxEdit.BackgroundColor=[1,0.96,0.88];
                end

            elseif strcmpi(self.TypeTx,'Antenna Designer')

                rowTx=rowTx+1;
                self.Parent.addText(self.Layout,self.AntTxLabel,rowTx,2,90,h+5,...
                self.Parent.View.UseAppContainer)

                rowTx=rowTx+1;
                self.Parent.addText(self.Layout,self.IconTx,rowTx,2,75,45,...
                self.Parent.View.UseAppContainer)

                rowTx=rowTx+1;
                self.Parent.addText(self.Layout,self.DirTxLabel,rowTx,1,w1,h,...
                self.Parent.View.UseAppContainer)
                self.Parent.addEdit(self.Layout,self.DirTxEdit,rowTx,2,w2,h,...
                self.Parent.View.UseAppContainer)
                self.Parent.addText(self.Layout,self.DirTxUnits,rowTx,3,w3,h,...
                self.Parent.View.UseAppContainer)

                self.Parent.View.setStatusBarMsg('Design antenna and set "Direction of Departure".');
                if self.OtherPropertiesChanged&&strcmpi(varargin{1},'TypeTx')
                    self.DirTxEdit.BackgroundColor=[1,0.96,0.88];
                end

            else

                rowTx=rowTx+1;
                self.Parent.addText(self.Layout,self.WkSpcTxLabel,rowTx,1,w1,h,...
                self.Parent.View.UseAppContainer)
                self.Parent.addEdit(self.Layout,self.WkSpcTxEdit,rowTx,2,w2,h,...
                self.Parent.View.UseAppContainer)

                rowTx=rowTx+1;
                self.Parent.addText(self.Layout,self.DirTxLabel,rowTx,1,w1,h,...
                self.Parent.View.UseAppContainer)
                self.Parent.addEdit(self.Layout,self.DirTxEdit,rowTx,2,w2,h,...
                self.Parent.View.UseAppContainer)
                self.Parent.addText(self.Layout,self.DirTxUnits,rowTx,3,w3,h,...
                self.Parent.View.UseAppContainer)

                self.Parent.View.setStatusBarMsg('Design antenna and set "Direction of Departure".');
                if self.OtherPropertiesChanged&&strcmpi(varargin{1},'TypeTx')
                    self.WkSpcTxEdit.BackgroundColor=[1,0.96,0.88];
                    self.DirTxEdit.BackgroundColor=[1,0.96,0.88];
                end
            end

            rowRx=rowRx+1;
            self.Parent.addText(self.Layout,self.ApplyLabel,rowRx+11,2,w3,h+10,...
            self.Parent.View.UseAppContainer)

            if self.Parent.View.UseAppContainer
                w=500;%#ok<NASGU> 
                h=500;%#ok<NASGU> 
                self.Layout.Visible='on';
            else
                [~,~,w,h]=getMinimumSize(self.Layout);
                self.Width=sum(w)+self.Layout.HorizontalGap*(numel(w)+1);
                self.Height=max(h(2:end-1))*numel(h(2:end))+...
                self.Layout.VerticalGap*(numel(h(2:end-1))+1)+(titleHt+2)-...
                200;
            end

            if strcmpi(self.TypeRx,'Antenna Designer')||strcmpi(self.TypeTx,'Antenna Designer')
                self.Width=self.Width-100;
                self.Height=self.Height-100*5;
            end
        end

        function parameterChanged(self,e)


            i=self.Parent.View.Canvas.SelectIdx;
            if strcmpi(e.EventName,'PostSet')||strcmpi(e.EventName,'ValueChanged')

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
                if any(strcmpi(key,{'leftarrow','uparrow','downarrow','rightarrow'}))

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

            if~strcmp(name,'ApplyButton')&&~strcmp(name,'ApplyTag')
                self.Parent.notify('DisableCanvas',...
                rf.internal.apps.budget.ElementParameterChangedEventData(i,name,'off'));
            end

            if~strcmpi(key,'return')


                switch name
                case{'TypeDropdown','TypeTx','TypeRx'}
                    if strcmpi(self.TypeRx,'Isotropic Receiver')&&...
                        strcmpi(self.TypeTx,'Isotropic Radiator')
                        applyflag=1;
                        self.ApplyLabel.Enable='on';
                    elseif strcmpi(self.TypeRx,'Isotropic Receiver')&&...
                        (isempty(self.WkSpcTxEdit)&&strcmpi(self.TypeRx,'Antenna Object'))
                        applyflag=1;
                        self.ApplyLabel.Enable='on';
                    elseif strcmpi(self.TypeTx,'Isotropic Radiator')&&...
                        (isempty(self.WkSpcRxEdit)&&strcmpi(self.TypeRx,'Antenna Object'))
                        applyflag=1;
                        self.ApplyLabel.Enable='on';
                    else
                        applyflag=0;
                        self.ApplyLabel.Enable='off';
                    end
                    if strcmpi(name,'TypeRx')
                        self.TypePopupRx.BackgroundColor=valueChangedColor;
                    else
                        self.TypePopupTx.BackgroundColor=valueChangedColor;
                    end
                    if strcmpi(name,'TypeRx')
                        self.TypePopupRx.BackgroundColor=[1,0.96,0.88];
                        self.DirRxEdit.String='[0 0]';
                        self.IconRx.CData=[];
                        self.IconRx.Visible='off';
                        self.WkSpcRxEdit.String='';
                        self.GainRxEdit.String=num2str(0);
                        self.ZRxEdit.String=num2str(50);
                        self.PathLossEdit.String=num2str(0);
                        self.AntObjRx=[];
                    elseif strcmpi(name,'TypeTx')
                        self.TypePopupTx.BackgroundColor=[1,0.96,0.88];
                        self.DirTxEdit.String='[0 0]';
                        self.IconTx.CData=[];
                        self.IconTx.Visible='off';
                        self.WkSpcTxEdit.String='';
                        self.GainTxEdit.String=num2str(0);
                        self.ZTxEdit.String=num2str(50);
                        self.AntObjTx=[];
                    end


                    parameterPaneChange(self)
                    layoutUIControls(self,name);
                    add(self.Parent.Layout,self.Panel,2,1,...
                    'MinimumWidth',self.Width,...
                    'Fill','Horizontal',...
                    'MinimumHeight',self.Height,...
                    'Anchor','North')
                case{'NameEditField','Name'}
                    self.NameEdit.BackgroundColor=valueChangedColor;
                case{'GainEditField','GainRx','GainTx'}
                    if strcmpi(self.TypeRx,'Isotropic Receiver')&&strcmpi(name,'GainRx')
                        self.GainRxEdit.BackgroundColor=valueChangedColor;
                    elseif strcmpi(self.TypeTx,'Isotropic Radiator')&&strcmpi(name,'GainTx')
                        self.GainTxEdit.BackgroundColor=valueChangedColor;
                    end
                case{'ZEditField','ZRx','ZTx'}
                    if strcmpi(self.TypeRx,'Isotropic Receiver')&&strcmpi(name,'ZRx')
                        self.ZRxEdit.BackgroundColor=valueChangedColor;
                    elseif strcmpi(self.TypeTx,'Isotropic Radiator')&&strcmpi(name,'ZTx')
                        self.ZTxEdit.BackgroundColor=valueChangedColor;
                    end
                case{'AntTagTx','AntTagRx','AntButton'}
                    self.InputFreq=self.Parent.SystemDialog.InputFrequency;
                    self.DesignerButton=name;
                    self.InputFreq=...
                    self.Parent.View.Results.FriisData.OutputFrequency(self.Parent.SelectedStage);
                    if strcmpi(name,'AntTagTx')
                        self.AppHandleTx=em.internal.antennaExplorer.AntennaDesigner('SourceBlock',self);
                    elseif strcmpi(name,'AntTagRx')
                        self.AppHandleRx=em.internal.antennaExplorer.AntennaDesigner('SourceBlock',self);
                    end
                    if~strcmpi(self.TypeRx,'Isotropic Receiver')&&strcmpi(name,'AntTagRx')
                        self.AntRxLabel.Enable='off';
                    elseif~strcmpi(self.TypeTx,'Isotropic Radiator')&&strcmpi(name,'AntTagTx')
                        self.AntTxLabel.Enable='off';
                    end

                case{'PathLossEditField','PathLoss'}
                    self.PathLossEdit.BackgroundColor=valueChangedColor;
                    if(strcmpi(self.TypeRx,'Antenna Object')&&...
                        isempty(self.WkSpcRxEdit.String))||...
                        (strcmpi(self.TypeTx,'Antenna Object')&&...
                        isempty(self.WkSpcTxEdit.String))
                        applyflag=0;
                    elseif(strcmpi(self.TypeRx,'Antenna Designer')||...
                        strcmpi(self.TypeTx,'Antenna Designer'))&&...
                        (isempty(self.IconRx.CData)||isempty(self.IconTx.CData))
                        applyflag=0;
                    else
                        self.ApplyLabel.Enable='on';
                    end
                case{'WkSpcEditField','WkSpcRx','WkSpcTx'}
                    self.InputFreq=...
                    self.Parent.View.Results.FriisData.OutputFrequency(self.Parent.SelectedStage);
                    if~strcmpi(self.TypeRx,'Isotropic Receiver')&&strcmpi(name,'WkSpcRx')
                        self.WkSpcRxEdit.BackgroundColor=valueChangedColor;
                    elseif~strcmpi(self.TypeTx,'Isotropic Radiator')&&strcmpi(name,'WkSpcTx')
                        self.WkSpcTxEdit.BackgroundColor=valueChangedColor;
                    end
                case{'DirEditField','ElevationRx','ElevationTx'}
                    if(strcmpi(self.TypeRx,'Antenna Object')&&...
                        isempty(self.WkSpcRxEdit.String))||...
                        (strcmpi(self.TypeTx,'Antenna Object')&&...
                        isempty(self.WkSpcTxEdit.String))
                        applyflag=0;
                    elseif(strcmpi(self.TypeRx,'Antenna Designer')||...
                        strcmpi(self.TypeTx,'Antenna Designer'))&&...
                        (isempty(self.IconRx.CData)||isempty(self.IconTx.CData))
                        applyflag=0;
                    else
                        self.ApplyLabel.Enable='on';
                    end
                    if~strcmpi(self.TypeRx,'Isotropic Receiver')&&strcmpi(name,'ElevationRx')
                        self.DirRxEdit.BackgroundColor=valueChangedColor;
                    elseif~strcmpi(self.TypeTx,'Isotropic Radiator')&&strcmpi(name,'ElevationTx')
                        self.DirTxEdit.BackgroundColor=valueChangedColor;
                    end
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
                self.Parent.View.setStatusBarMsg('Click ''Apply'' or hit ''Enter'' to update Antenna parameters.');
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
            self.GainRx=str2num(self.GainRxEdit.(valueString));
            self.GainTx=str2num(self.GainTxEdit.(valueString));
            self.ZRx=str2num(self.ZRxEdit.(valueString));
            self.ZTx=str2num(self.ZTxEdit.(valueString));
            if strcmpi(self.TypeRx,'Antenna Object')
                self.WkSpcRxObj=self.WkSpcRxEdit.(valueString);
            elseif strcmpi(self.TypeTx,'Antenna Object')
                self.WkSpcTxObj=self.WkSpcTxEdit.(valueString);
            end
            if strcmpi(self.TypeRx,'Antenna Designer')
                self.ObjectRx=self.AntObjRx;
            elseif strcmpi(self.TypeTx,'Antenna Designer')
                self.ObjectTx=self.AntObjTx;
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
            AntRx=[];
            if~isempty(self.WkSpcRxEdit.(valueString))&&strcmpi(self.TypeRx,'Antenna Object')
                AntRx=evalin('base',self.WkSpcRxEdit.(valueString));
                if isa(AntRx,'em.Antenna')
                    self.AntObjRx=AntRx;
                    self.ZRx=impedance(self.AntObjRx,self.InputFreq);
                else
                    h=errordlg(getString(message('rf:shared:AntennaVariable')),'Error Dialog','modal');
                    uiwait(h)
                    self.Parent.View.enableActions(true);
                    return;
                end
            end
            AntTx=[];
            if~isempty(self.WkSpcTxEdit.(valueString))&&strcmpi(self.TypeTx,'Antenna Object')
                AntTx=evalin('base',self.WkSpcTxEdit.(valueString));
                if isa(AntTx,'em.Antenna')
                    self.AntObjTx=AntTx;
                    self.ZTx=impedance(self.AntObjTx,self.InputFreq);
                else
                    h=errordlg(getString(message('rf:shared:AntennaVariable')),'Error Dialog','modal');
                    uiwait(h)
                    self.Parent.View.enableActions(true);
                    return;
                end
            end

            idx=self.Parent.View.Canvas.SelectIdx;
            dirRx=[0,0];
            if~isempty(self.DirRxEdit.(valueString))&&~isempty(self.AntObjRx)
                dirRx=str2num(self.DirRxEdit.(valueString));
                if iscolumn(dirRx)
                    dirRx=dirRx';
                end
                validateattributes(dirRx,{'numeric'},...
                {'numel',2,'nonempty','nonnan','finite','real','nonnegative'},'rfantenna','input');
                self.DirectivityRx=pattern(self.AntObjRx,self.InputFreq,dirRx(1),dirRx(2));
                self.GainRx=self.DirectivityRx;
            end
            dirTx=[0,0];
            if~isempty(self.DirTxEdit.(valueString))&&~isempty(self.AntObjTx)
                dirTx=str2num(self.DirTxEdit.(valueString));
                if iscolumn(dirTx)
                    dirTx=dirTx';
                end
                validateattributes(dirTx,{'numeric'},...
                {'numel',2,'nonempty','nonnan','finite','real','nonnegative'},'rfantenna','input');
                self.DirectivityTx=pattern(self.AntObjTx,self.InputFreq,dirTx(1),dirTx(2));
                self.GainTx=self.DirectivityTx;
            end
            antennaObj=rfantenna('Type','TransmitReceive','Name',self.Name,...
            'Gain',[self.GainTx,self.GainRx],'Z',[self.ZTx,self.ZRx],...
            'PathLoss',self.PathLoss,'Frequency',self.InputFreq);

            if self.HaveAntTbx&&(~isempty(self.AntObjRx)||~isempty(self.AntObjTx))
                antennaObj.DirectionAngles=[dirTx,dirRx];
                if strcmpi(self.TypeRx,'Antenna Designer')&&strcmpi(self.TypeTx,'Antenna Designer')

                    antennaObj.AntennaObject={self.AntObjTx,self.AntObjRx};
                elseif strcmpi(self.TypeRx,'Antenna Object')&&strcmpi(self.TypeTx,'Antenna Object')
                    vars=evalin('base','whos');
                    arrRx=zeros(1,length(vars),'logical');
                    arrTx=zeros(1,length(vars),'logical');
                    for i=1:length(vars)
                        arrRx(i)=strcmpi(vars(i).class,class(AntRx));
                        arrTx(i)=strcmpi(vars(i).class,class(AntTx));
                    end
                    if any(arrRx)
                        AntNameRx=vars(arrRx).name;
                    else
                        AntNameRx='';
                    end
                    if any(arrTx)
                        AntNameTx=vars(arrTx).name;
                    else
                        AntNameTx='';
                    end

                    antennaObj.AntennaObject={AntNameTx,AntNameRx};
                    antennaObj.AntennaDesign={AntTx,AntRx};

                elseif strcmpi(self.TypeRx,'Antenna Object')&&strcmpi(self.TypeTx,'Antenna Designer')
                    vars=evalin('base','whos');
                    arrRx=zeros(1,length(vars),'logical');
                    for i=1:length(vars)
                        arrRx(i)=strcmpi(vars(i).class,class(AntRx));
                    end
                    if any(arrRx)
                        AntNameRx=vars(arrRx).name;
                    else
                        AntNameRx='';
                    end
                    antennaObj.AntennaObject={self.AntObjTx,AntNameRx};
                    antennaObj.AntennaDesign={[],AntRx};
                elseif strcmpi(self.TypeRx,'Antenna Designer')&&strcmpi(self.TypeTx,'Antenna Object')
                    vars=evalin('base','whos');
                    arrTx=zeros(1,length(vars),'logical');
                    for i=1:length(vars)
                        arrTx(i)=strcmpi(vars(i).class,class(AntTx));
                    end
                    if any(arrTx)
                        AntNameTx=vars(arrTx).name;
                    else
                        AntNameTx='';
                    end
                    antennaObj.AntennaObject={AntNameTx,self.AntObjRx};
                    antennaObj.AntennaDesign={AntTx,[]};
                else
                    if~isempty(self.AntObjTx)
                        if(strcmpi(self.TypeTx,'Antenna Object'))
                            vars=evalin('base','whos');
                            arrTx=zeros(1,length(vars),'logical');
                            for i=1:length(vars)
                                arrTx(i)=strcmpi(vars(i).class,class(AntTx));
                            end
                            if any(arrTx)
                                AntNameTx=vars(arrTx).name;
                            else
                                AntNameTx='';
                            end
                            antennaObj.AntennaObject={AntNameTx,[]};
                            antennaObj.AntennaDesign={AntTx,[]};
                        else
                            antennaObj.AntennaObject={self.AntObjTx,[]};
                        end
                    elseif~isempty(self.AntObjRx)
                        if(strcmpi(self.TypeRx,'Antenna Object'))
                            vars=evalin('base','whos');
                            arrRx=zeros(1,length(vars),'logical');
                            for i=1:length(vars)
                                arrRx(i)=strcmpi(vars(i).class,class(AntRx));
                            end
                            if any(arrRx)
                                AntNameRx=vars(arrRx).name;
                            else
                                AntNameRx='';
                            end
                            antennaObj.AntennaObject={[],AntNameRx};
                            antennaObj.AntennaDesign={[],AntRx};
                        else
                            antennaObj.AntennaObject={[],self.AntObjRx};
                        end
                    end
                end
            end
            if self.Parent.View.UseAppContainer
                self.Parent.notify('DisableCanvas',...
                rf.internal.apps.budget.ElementParameterChangedEventData(idx,...
                'ApplyButton','inactive'));
            else
                self.Parent.notify('DisableCanvas',...
                rf.internal.apps.budget.ElementParameterChangedEventData(idx,'ApplyTag','inactive'));
            end
            if self.NameChanged&&~self.OtherPropertiesChanged

                self.Parent.notify('ElementParameterChanged',...
                rf.internal.apps.budget.ElementParameterChangedEventData(idx,'Name',self.NameEdit.(valueString)));
            else


                if self.Parent.View.UseAppContainer
                    self.Parent.notify('ElementParameterChanged',...
                    rf.internal.apps.budget.ElementParameterChangedEventData(idx,...
                    'ApplyButton',antennaObj));
                else
                    self.Parent.notify('ElementParameterChanged',...
                    rf.internal.apps.budget.ElementParameterChangedEventData(idx,'ApplyTag',antennaObj));
                end
            end
            whiteColor=[1,1,1];
            self.NameEdit.BackgroundColor=whiteColor;
            self.TypePopupRx.BackgroundColor=whiteColor;
            self.TypePopupTx.BackgroundColor=whiteColor;
            self.GainRxEdit.BackgroundColor=whiteColor;
            self.GainTxEdit.BackgroundColor=whiteColor;
            self.ZRxEdit.BackgroundColor=whiteColor;
            self.ZTxEdit.BackgroundColor=whiteColor;
            self.PathLossEdit.BackgroundColor=whiteColor;
            self.WkSpcRxEdit.BackgroundColor=whiteColor;
            self.WkSpcTxEdit.BackgroundColor=whiteColor;
            self.DirRxEdit.BackgroundColor=whiteColor;
            self.DirTxEdit.BackgroundColor=whiteColor;
            self.ApplyLabel.Enable='off';
            self.Parent.View.setStatusBarMsg('');
            enableIP2(self.Parent.View.Toolstrip,false);
            self.NameChanged=0;
            self.OtherPropertiesChanged=0;
            self.IsReturnKey=0;
            self.Parent.View.enableActions(true);
        end

        function parameterPaneChange(self)

            switch self.TypeRx

            case 'Antenna Designer'

                self.AntRxLabel.Enable='on';
                self.AntRxLabel.Visible='on';

                if~isempty(self.IconRx.CData)
                    self.IconRx.Visible='on';
                else
                    self.ApplyLabel.Enable='off';
                end

                self.GainRxLabel.Visible='off';
                self.GainRxEdit.Visible='off';
                self.GainRxUnits.Visible='off';

                self.ZRxLabel.Visible='off';
                self.ZRxEdit.Visible='off';
                self.ZRxUnits.Visible='off';

                self.PathLossLabel.Visible='on';
                self.PathLossEdit.Visible='on';
                self.PathLossUnits.Visible='on';

                self.WkSpcRxLabel.Visible='off';
                self.WkSpcRxEdit.Visible='off';

                self.DirRxLabel.Visible='on';
                self.DirRxEdit.Visible='on';
                self.DirRxUnits.Visible='on';

                self.ApplyLabel.Enable='off';

            case 'Antenna Object'

                self.AntRxLabel.Enable='off';
                self.AntRxLabel.Visible='off';

                self.IconRx.Visible='off';

                self.GainRxLabel.Visible='off';
                self.GainRxEdit.Visible='off';
                self.GainRxUnits.Visible='off';

                self.ZRxLabel.Visible='off';
                self.ZRxEdit.Visible='off';
                self.ZRxUnits.Visible='off';

                self.PathLossLabel.Visible='on';
                self.PathLossEdit.Visible='on';
                self.PathLossUnits.Visible='on';

                self.WkSpcRxLabel.Visible='on';
                self.WkSpcRxEdit.Visible='on';

                self.DirRxLabel.Visible='on';
                self.DirRxEdit.Visible='on';
                self.DirRxUnits.Visible='on';
            case 'Isotropic Receiver'

                self.AntRxLabel.Enable='off';
                self.AntRxLabel.Visible='off';

                self.IconRx.Visible='off';

                self.WkSpcRxLabel.Visible='off';
                self.WkSpcRxEdit.Visible='off';

                self.DirRxLabel.Visible='off';
                self.DirRxEdit.Visible='off';
                self.DirRxUnits.Visible='off';

                self.GainRxLabel.Visible='on';
                self.GainRxEdit.Visible='on';
                self.GainRxUnits.Visible='on';

                self.ZRxLabel.Visible='on';
                self.ZRxEdit.Visible='on';
                self.ZRxUnits.Visible='on';

                self.PathLossLabel.Visible='on';
                self.PathLossEdit.Visible='on';
                self.PathLossUnits.Visible='on';

            end
            switch self.TypeTx

            case 'Antenna Designer'

                self.AntTxLabel.Enable='on';
                self.AntTxLabel.Visible='on';

                if~isempty(self.IconTx.CData)
                    self.IconTx.Visible='on';
                else
                    self.ApplyLabel.Enable='off';
                end

                self.GainTxLabel.Visible='off';
                self.GainTxEdit.Visible='off';
                self.GainTxUnits.Visible='off';

                self.ZTxLabel.Visible='off';
                self.ZTxEdit.Visible='off';
                self.ZTxUnits.Visible='off';

                self.WkSpcTxLabel.Visible='off';
                self.WkSpcTxEdit.Visible='off';

                self.DirTxLabel.Visible='on';
                self.DirTxEdit.Visible='on';
                self.DirTxUnits.Visible='on';

                self.ApplyLabel.Enable='off';
            case 'Antenna Object'

                self.AntTxLabel.Enable='off';
                self.AntTxLabel.Visible='off';

                self.IconTx.Visible='off';

                self.GainTxLabel.Visible='off';
                self.GainTxEdit.Visible='off';
                self.GainTxUnits.Visible='off';

                self.ZTxLabel.Visible='off';
                self.ZTxEdit.Visible='off';
                self.ZTxUnits.Visible='off';

                self.WkSpcTxLabel.Visible='on';
                self.WkSpcTxEdit.Visible='on';

                self.DirTxLabel.Visible='on';
                self.DirTxEdit.Visible='on';
                self.DirTxUnits.Visible='on';
            case 'Isotropic Radiator'

                self.AntTxLabel.Enable='off';
                self.AntTxLabel.Visible='off';

                self.IconTx.Visible='off';

                self.WkSpcTxLabel.Visible='off';
                self.WkSpcTxEdit.Visible='off';

                self.DirTxLabel.Visible='off';
                self.DirTxEdit.Visible='off';
                self.DirTxUnits.Visible='off';

                self.GainTxLabel.Visible='on';
                self.GainTxEdit.Visible='on';
                self.GainTxUnits.Visible='on';

                self.ZTxLabel.Visible='on';
                self.ZTxEdit.Visible='on';
                self.ZTxUnits.Visible='on';
            end
        end

        function FigKeyEvent(self,ev)

            if isa(self.Parent.ElementDialog,'rf.internal.apps.budget.AntennaDialogTxRx')
                key=ev.Key;
                switch key
                case 'return'
                    self.IsReturnKey=1;

                end
            end
        end

        function FigKeyEventCanvas(self,ev)


            if isa(self.Parent.ElementDialog,'rf.internal.apps.budget.AntennaDialogTxRx')
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
                self.TypePopupRx.ValueChangedFcn=@(h,e)parameterChanged(self,e);
                self.TypePopupRx.ValueChangedFcn=@(h,e)parameterChanged(self,e);
                self.GainRxEdit.ValueChangedFcn=@(h,e)parameterChanged(self,e);
                self.ZRxEdit.ValueChangedFcn=@(h,e)parameterChanged(self,e);
                self.PathLossEdit.ValueChangedFcn=@(h,e)parameterChanged(self,e);
                self.WkSpcRxEdit.ValueChangedFcn=@(h,e)parameterChanged(self,e);
                self.DirRxEdit.ValueChangedFcn=@(h,e)parameterChanged(self,e);
                self.AntRxLabel.ButtonPushedFcn=@(h,e)parameterChanged(self,e);
                self.ApplyLabel.ButtonPushedFcn=@(h,e)parameterChanged(self,e);
            else
                self.NameEdit.KeyPressFcn=@(h,e)parameterChanged(self,e);
                self.Listeners.TypeRx=addlistener(self.TypePopupRx,'Value',...
                'PostSet',@(h,e)parameterChanged(self,e));
                self.Listeners.TypeTx=addlistener(self.TypePopupTx,'Value',...
                'PostSet',@(h,e)parameterChanged(self,e));
                self.TypePopupRx.KeyPressFcn=@(h,e)parameterChanged(self,e);
                self.TypePopupTx.KeyPressFcn=@(h,e)parameterChanged(self,e);
                self.GainRxEdit.KeyPressFcn=@(h,e)parameterChanged(self,e);
                self.GainTxEdit.KeyPressFcn=@(h,e)parameterChanged(self,e);
                self.ZRxEdit.KeyPressFcn=@(h,e)parameterChanged(self,e);
                self.ZTxEdit.KeyPressFcn=@(h,e)parameterChanged(self,e);
                self.PathLossEdit.KeyPressFcn=@(h,e)parameterChanged(self,e);
                self.WkSpcRxEdit.KeyPressFcn=@(h,e)parameterChanged(self,e);
                self.WkSpcTxEdit.KeyPressFcn=@(h,e)parameterChanged(self,e);
                self.DirRxEdit.KeyPressFcn=@(h,e)parameterChanged(self,e);
                self.DirTxEdit.KeyPressFcn=@(h,e)parameterChanged(self,e);
                self.Listeners.AntRx=addlistener(self.AntRxLabel,'Value',...
                'PostSet',@(h,e)parameterChanged(self,e));
                self.Listeners.AntTx=addlistener(self.AntTxLabel,'Value',...
                'PostSet',@(h,e)parameterChanged(self,e));
                self.Listeners.Apply=addlistener(self.ApplyLabel,'Value',...
                'PostSet',@(h,e)parameterChanged(self,e));
            end
        end

    end
end
