classdef Settings<cad.View




    properties
        Parent;
        ParentLayout;


        PvtUnits='mm';
UnitsPanel
UnitsLayout
UnitsText
UnitsLabel
UnitsErrorImage


MetalPanel
        PvtType='PEC';
        PvtConductivity=Inf;
        PvtThickness=0;
        MetalCatalog=MetalCatalog;
MetalLayout
MetalTypeText
MetalDropDown
MetalThicknessText
MetalThicknessEdit
MetalThicknessErrorImage
MetalSizeUnits


MetalConductivityText
MetalConductivityErrorImage
MetalConductivityEdit
MetalConductivityUnits

GridPanel
        PvtSnapToGrid=0;
        PvtGridSize=0.1;
SnapToGridText
SnapToGridCheckbox
GridLayout
GridSizeText
GridSizeErrorImage
GridSizeEdit
GridSizeUnits
OKBtn
CancelBtn
        SettingsChanged=0;

        error1=[
        219,219,219,225,219,219,219,219,219,219,219,219,219,219
        219,219,219,219,219,219,219,219,219,219,219,226,219,219
        219,219,219,219,219,219,255,255,219,219,219,219,226,219
        219,219,219,219,219,219,255,255,219,219,219,219,219,219
        219,219,219,219,219,219,255,255,219,219,219,219,219,224
        219,219,219,219,219,219,255,255,219,219,219,219,219,219
        219,219,219,219,219,219,255,255,219,219,219,219,219,219
        219,219,219,219,219,219,255,255,219,219,219,219,219,219
        219,219,219,219,219,219,219,219,219,219,219,219,219,219
        219,219,219,219,219,219,255,255,219,219,219,219,219,219
        219,219,219,219,219,219,219,219,219,219,219,219,219,219
        219,219,219,217,219,219,219,219,219,219,219,219,219,219
        219,219,219,219,219,219,219,219,219,219,219,219,219,219];


        error2=[
        60,60,60,60,60,60,60,60,60,60,60,60,60,60
        60,60,60,60,60,60,60,60,60,60,60,60,60,60
        60,60,60,60,60,60,255,255,60,60,60,60,60,60
        60,60,60,60,60,60,255,255,60,60,60,60,60,60
        60,60,60,60,60,60,255,255,60,60,60,60,60,60
        60,60,60,60,60,60,255,255,60,60,60,60,60,60
        60,60,60,60,60,60,255,255,60,60,60,60,60,60
        60,60,60,60,60,60,255,255,60,60,60,60,60,60
        60,60,60,60,60,60,60,60,60,60,60,60,60,60
        60,60,60,60,60,60,255,255,60,60,60,60,60,60
        60,60,60,60,60,60,60,60,60,60,60,60,60,60
        60,60,60,60,60,60,60,60,60,60,60,60,60,60
        60,60,60,60,60,60,60,60,60,60,60,60,60,60];


        error3=[
        48,48,48,48,48,48,48,48,48,48,48,48,48,48
        48,48,48,48,48,48,48,48,48,48,48,48,48,48
        48,48,48,48,48,48,255,255,48,48,48,48,48,48
        48,48,48,48,48,48,255,255,48,48,48,48,48,48
        48,48,48,48,48,48,255,255,48,48,48,48,48,48
        48,48,48,48,48,48,255,255,48,48,48,48,48,48
        48,48,48,48,48,48,255,255,48,48,48,48,48,48
        48,48,48,48,48,48,255,255,48,48,48,48,48,48
        48,48,48,48,48,48,48,48,48,48,48,48,48,48
        48,48,48,48,48,48,255,255,48,48,48,48,48,48
        48,48,48,48,48,48,48,48,48,48,48,48,48,48
        48,48,48,48,48,48,48,48,48,48,48,48,48,48
        48,48,48,48,48,48,48,48,48,48,48,48,48,48];

ErrorCData
    end

    properties(Dependent=true)
Units
Type
Conductivity
Thickness
SnapToGrid
GridSize
    end

    methods
        function self=Settings(Parent)
            self.MetalCatalog=MetalCatalog;
            self.Parent=Parent;
            self.ErrorCData=zeros(13,14,3,'uint8');
            self.ErrorCData(:,:,1)=self.error1;
            self.ErrorCData(:,:,2)=self.error2;
            self.ErrorCData(:,:,3)=self.error3;
            createSettingsDialog(self)
        end

        function set.Units(self,val)
            self.PvtUnits=val;
            self.UnitsLabel.Value=val;
            self.GridSizeUnits.Text=val;
        end

        function val=get.Units(self)
            val=self.UnitsLabel.Value;
        end

        function set.Type(self,val)
            self.PvtType=val;
            self.MetalDropDown.Value=val;
        end

        function val=get.Type(self)
            val=self.MetalDropDown.Value;
        end

        function set.Conductivity(self,val)
            self.PvtConductivity=val;
            self.MetalConductivityEdit.Value=num2str(val);
        end

        function val=get.Conductivity(self)
            val=str2num(self.MetalConductivityEdit.Value);
        end

        function set.Thickness(self,val)
            self.PvtThickness=val;
            self.MetalThicknessEdit.Value=num2str(val);
        end

        function val=get.Thickness(self)
            val=str2num(self.MetalThicknessEdit.Value);
        end

        function set.SnapToGrid(self,val)
            self.PvtSnapToGrid=val;
            self.SnapToGridCheckbox.Value=val;
            if self.PvtSnapToGrid
                self.GridSizeEdit.Enable='on';
            else
                self.GridSizeEdit.Enable='off';
            end
        end

        function val=get.SnapToGrid(self)
            val=self.SnapToGridCheckbox.Value;
        end

        function set.GridSize(self,val)
            self.PvtGridSize=val;
            self.GridSizeEdit.Value=num2str(val);
        end

        function val=get.GridSize(self)
            val=str2num(self.GridSizeEdit.Value);
        end

        function showSettingsDialog(self)
            self.SettingsChanged=0;
            self.Conductivity=self.PvtConductivity;
            self.Thickness=self.PvtThickness;
            self.Type=self.PvtType;
            self.SnapToGrid=self.PvtSnapToGrid;
            self.GridSize=self.PvtGridSize;
            self.Units=self.PvtUnits;
            self.MetalConductivityErrorImage.Visible='off';
            self.MetalThicknessErrorImage.Visible='off';
            self.GridSizeErrorImage.Visible='off';
            self.MetalThicknessEdit.BackgroundColor=[1,1,1];
            self.MetalConductivityEdit.BackgroundColor=[1,1,1];
            self.GridSizeEdit.BackgroundColor=[1,1,1];
            self.MetalThicknessEdit.FontColor='k';
            self.MetalConductivityEdit.FontColor='k';
            self.GridSizeEdit.FontColor='k';
            self.Parent.Visible='on';
            self.Parent.WindowStyle='modal';
        end

        function hideSettingsDialog(self)
            self.Parent.Visible='off';
            self.Parent.WindowStyle='normal';
            self.notify('DialogClosed');
        end
        function createSettingsDialog(self)
            self.Parent.Visible='off';

            self.ParentLayout=uigridlayout(self.Parent);


            createGridControlPanel(self);


            self.ParentLayout.RowHeight={'fit','fit','fit'};
            self.ParentLayout.ColumnWidth={'fit','fit','fit'};


            self.GridPanel.Layout.Row=1;
            self.GridPanel.Layout.Column=[1,3];
            self.OKBtn=uibutton(self.ParentLayout,'Text','OK','ButtonPushedFcn',@(src,evt)okcallback(self));
            self.OKBtn.Layout.Row=3;self.OKBtn.Layout.Column=2;
            self.CancelBtn=uibutton(self.ParentLayout,'Text','Cancel','ButtonPushedFcn',@(src,evt)hideSettingsDialog(self));
            self.CancelBtn.Layout.Row=3;self.CancelBtn.Layout.Column=3;

            self.Parent.Name='Canvas Settings';
            self.Parent.Visible='off';
            self.Parent.Position(3:4)=[300,190];
            self.Parent.Position(1:2)=[400,400];
            self.Parent.Resize='off';
            self.Parent.CloseRequestFcn=@(src,evt)hideSettingsDialog(self);
        end

        function okcallback(self)
            Metal=struct('Type',self.Type,'Conductivity',self.Conductivity,...
            'Thickness',self.Thickness);
            Grid=struct('SnapToGrid',self.SnapToGrid,'GridSize',self.GridSize);
            Data=struct('Metal',Metal,'Grid',Grid,'Units',self.Units);
            Data.Property='Model';
            Data.Type='CanvasSettings';
            if self.SettingsChanged
                self.notify('ValueChanged',cad.events.ValueChangedEventData(Data));
            end
            hideSettingsDialog(self);
        end

        function createUnitsPanel(self)
            self.UnitsPanel=uipanel(self.ParentLayout,'Title','Units Settings');
            self.UnitsLayout=uigridlayout(self.UnitsPanel);
            self.UnitsText=uilabel(self.UnitsLayout,'text','Units:',...
            'HorizontalAlignment','right');
            self.UnitsText.Layout.Row=1;
            self.UnitsText.Layout.Column=1;
            self.UnitsLabel=uidropdown(self.UnitsLayout,'Items',{'m','in','cm','mm','mil'},...
            'Value','mm','ValueChangedFcn',@(src,evt)valueChanged(self,src,evt),'Tag','Units',...
            'userdata','Units');
            self.UnitsLabel.Layout.Row=1;
            self.UnitsLabel.Layout.Column=2;
            self.UnitsLayout.RowHeight={'fit'};
            self.UnitsLayout.ColumnWidth={80,100};
        end

        function createMetalPanel(self)
            self.MetalPanel=uipanel(self.ParentLayout,'Title','Metal Settings');
            self.MetalLayout=uigridlayout(self.MetalPanel);
            self.MetalTypeText=uilabel(self.MetalLayout,'text','Metal Type:',...
            'HorizontalAlignment','right');
            self.MetalTypeText.Layout.Row=1;
            self.MetalTypeText.Layout.Column=1;
            self.MetalDropDown=uidropdown(self.MetalLayout,'Items',[{'Custom'};self.MetalCatalog.Materials.Name],...
            'value','PEC','ValueChangedFcn',...
            @(src,evt)valueChanged(self,src,evt),'tag','Type','userData','Metal');
            self.MetalDropDown.Layout.Row=1;
            self.MetalDropDown.Layout.Column=3;
            self.MetalThicknessText=uilabel(self.MetalLayout,'text','Thickness',...
            'HorizontalAlignment','right');
            self.MetalThicknessText.Layout.Row=2;
            self.MetalThicknessText.Layout.Column=1;
            self.MetalThicknessEdit=uieditfield(self.MetalLayout,'Value','0',...
            'HorizontalAlignment','right','ValueChangedFcn',...
            @(src,evt)valueChanged(self,src,evt),'tag','Thickness','UserData','Metal');
            self.MetalThicknessErrorImage=uiimage(self.MetalLayout,'ImageSource',self.ErrorCData,...
            'Visible','off','tag','Thickness');
            self.MetalThicknessErrorImage.Layout.Row=2;
            self.MetalThicknessErrorImage.Layout.Column=2;
            self.MetalThicknessEdit.Layout.Row=2;
            self.MetalThicknessEdit.Layout.Column=3;
            self.MetalSizeUnits=uilabel(self.MetalLayout,'Text','mil',...
            'HorizontalAlignment','left');
            self.MetalSizeUnits.Layout.Row=2;
            self.MetalSizeUnits.Layout.Column=4;
            self.MetalConductivityText=uilabel(self.MetalLayout,'text','Conductivity',...
            'HorizontalAlignment','right');
            self.MetalConductivityText.Layout.Row=3;
            self.MetalConductivityText.Layout.Column=1;
            self.MetalConductivityEdit=uieditfield(self.MetalLayout,'Value','Inf',...
            'HorizontalAlignment','right','ValueChangedFcn',...
            @(src,evt)valueChanged(self,src,evt),'Tag','Conductivity','UserData','Metal');
            self.MetalConductivityErrorImage=uiimage(self.MetalLayout,'ImageSource',self.ErrorCData,...
            'Visible','off','tag','Conductivity');
            self.MetalConductivityErrorImage.Layout.Row=3;
            self.MetalConductivityErrorImage.Layout.Column=2;
            self.MetalConductivityEdit.Layout.Row=3;
            self.MetalConductivityEdit.Layout.Column=3;
            self.MetalConductivityUnits=uilabel(self.MetalLayout,'Text','S/m',...
            'HorizontalAlignment','left');
            self.MetalConductivityUnits.Layout.Row=3;
            self.MetalConductivityUnits.Layout.Column=4;


            self.MetalLayout.RowHeight=[25,25,25];
            self.MetalLayout.ColumnWidth={80,20,100,30};
        end

        function createGridControlPanel(self)
            self.GridPanel=uipanel(self.ParentLayout,'Title','Canvas Settings');
            self.GridLayout=uigridlayout(self.GridPanel);
            self.SnapToGridText=uilabel(self.GridLayout,'text','Snap to Grid',...
            'HorizontalAlignment','right');
            self.SnapToGridText.Layout.Row=1;
            self.SnapToGridText.Layout.Column=1;
            self.SnapToGridCheckbox=uicheckbox(self.GridLayout,'value',0,'text','','ValueChangedFcn',...
            @(src,evt)valueChanged(self,src,evt),'Tag','SnapToGrid','UserData','Grid');
            self.SnapToGridCheckbox.Layout.Row=1;
            self.SnapToGridCheckbox.Layout.Column=3;
            self.GridSizeText=uilabel(self.GridLayout,'text','Grid Size',...
            'HorizontalAlignment','right');
            self.GridSizeText.Layout.Row=2;
            self.GridSizeText.Layout.Column=1;
            self.GridSizeErrorImage=uiimage(self.GridLayout,'ImageSource',self.ErrorCData,...
            'Visible','off','tag','GridSize');
            self.GridSizeErrorImage.Layout.Row=2;
            self.GridSizeErrorImage.Layout.Column=2;
            self.GridSizeEdit=uieditfield(self.GridLayout,'Value','0.1',...
            'HorizontalAlignment','left','Enable','off','ValueChangedFcn',...
            @(src,evt)valueChanged(self,src,evt),'Tag','GridSize','UserData','Grid');

            self.GridSizeEdit.Layout.Row=2;
            self.GridSizeEdit.Layout.Column=3;





            self.UnitsText=uilabel(self.GridLayout,'text','Units',...
            'HorizontalAlignment','right');
            self.UnitsText.Layout.Row=3;
            self.UnitsText.Layout.Column=1;
            self.UnitsLabel=uidropdown(self.GridLayout,'Items',{'m','in','cm','mm','mil'},...
            'Value','mm','ValueChangedFcn',@(src,evt)valueChanged(self,src,evt),'Tag','Units',...
            'userdata','Units');
            self.UnitsLabel.Layout.Row=3;
            self.UnitsLabel.Layout.Column=3;

            self.GridLayout.RowHeight=[25,25,25];
            self.GridLayout.ColumnWidth={80,20,100,20};
        end

        function valueChanged(self,src,evt)






            try
                if strcmpi(src.Tag,'Type')&&~strcmpi(evt.Value,'Custom')
                    idx=strcmpi(self.MetalCatalog.Materials.Name,evt.Value);
                    self.MetalThicknessEdit.Value=num2str(self.MetalCatalog.Materials.Thickness(idx)*getMilsConvertFactor(...
                    self,self.MetalCatalog.Materials.Units{idx}));
                    self.MetalThicknessErrorImage.Visible='off';
                    self.MetalThicknessEdit.BackgroundColor=[1,1,1];
                    self.MetalConductivityEdit.Value=num2str(self.MetalCatalog.Materials.Conductivity(idx));

                    self.MetalConductivityErrorImage.Visible='off';
                    self.MetalConductivityEdit.BackgroundColor=[1,1,1];
                elseif strcmpi(src.Tag,{'Conductivity'})
                    validateattributes(str2num(evt.Value),{'numeric'},...
                    {'nonempty','nonnan','real','positive','scalar'},...
                    'Settings',src.Tag);
                    if str2num(evt.Value)<1e5
                        error(message('antenna:antennaerrors:LowConductivity'));
                    end
                    self.MetalDropDown.Value='Custom';
                elseif strcmpi(src.Tag,{'Thickness'})
                    validateattributes(str2num(evt.Value),{'numeric'},...
                    {'nonempty','nonnan','finite','real','nonnegative','scalar'},...
                    '',src.Tag);
                elseif strcmpi(src.Tag,'GridSize')
                    validateattributes(str2num(evt.Value),{'numeric'},...
                    {'nonempty','nonnan','finite','real','nonnegative','scalar','>=',0.01,'<=',10},...
                    '',src.Tag);
                elseif strcmpi(src.Tag,'SnapToGrid')
                    if~evt.Value
                        self.GridSizeEdit.Enable='off';
                        self.GridSizeEdit.BackgroundColor=[1,1,1];
                        self.GridSizeErrorImage.Visible='off';
                        self.GridSizeEdit.FontColor='k';
                    else
                        self.GridSizeEdit.Enable='on';
                        evttemp.Value=self.GridSizeEdit.Value;
                        valueChanged(self,self.GridSizeEdit,evttemp);
                    end

                end

                self.SettingsChanged=1;
                if strcmpi(src.Tag,'Conductivity')
                    src.BackgroundColor=[1,1,1];
                    src.FontColor='k';
                    self.MetalConductivityErrorImage.Visible='off';
                elseif strcmpi(src.Tag,'thickness')
                    src.BackgroundColor=[1,1,1];
                    src.FontColor='k';
                    self.MetalThicknessErrorImage.Visible='off';
                elseif strcmpi(src.Tag,'gridSize')
                    src.BackgroundColor=[1,1,1];
                    src.FontColor='k';
                    self.GridSizeErrorImage.Visible='off';
                end
            catch me

                if strcmpi(src.Tag,'Conductivity')
                    self.MetalConductivityErrorImage.Visible='on';
                    self.MetalConductivityErrorImage.Tooltip=me.message;
                    src.BackgroundColor=[0.999,0.9,0.9];
                    src.FontColor='r';
                elseif strcmpi(src.Tag,'thickness')
                    self.MetalThicknessErrorImage.Visible='on';
                    self.MetalThicknessErrorImage.Tooltip=me.message;
                    src.BackgroundColor=[0.999,0.9,0.9];
                    src.FontColor='r';
                elseif strcmpi(src.Tag,'gridSize')
                    self.GridSizeErrorImage.Visible='on';
                    self.GridSizeErrorImage.Tooltip=me.message;
                    src.BackgroundColor=[0.999,0.9,0.9];
                    src.FontColor='r';
                end
            end
            if iserror(self)
                self.OKBtn.Enable='off';
            else
                self.OKBtn.Enable='on';
            end

        end

        function errorval=iserror(self)
            errorval=0;
            if strcmpi(self.MetalConductivityErrorImage.Visible,'on')
                errorval=1;
            elseif strcmpi(self.MetalThicknessErrorImage.Visible,'on')
                errorval=1;
            elseif strcmpi(self.GridSizeErrorImage.Visible,'on')
                errorval=1;
            end
        end
        function fact=getMilsConvertFactor(self,val)
            switch val
            case 'mil'
                fact=1;
            case 'm'
                fact=39.37*1000;
            case 'cm'
                fact=39.37*10;
            case 'um'
                fact=39.37*1e-3;
            case 'in'
                fact=1000;
            case 'mm'
                fact=39.37;
            end
        end

        function updateView(self,vm)




            modelInfo=vm.getModelInfo();
            self.Conductivity=modelInfo.Metal.Conductivity;
            self.Thickness=modelInfo.Metal.Thickness;
            self.Type=modelInfo.Metal.Type;
            self.Units=modelInfo.Units;

            self.GridSize=modelInfo.Grid.GridSize;
            self.SnapToGrid=logical(modelInfo.Grid.SnapToGrid);
        end

        function setModel(self,model)
            addlistener(self,'ValueChanged',@(src,evt)settingsChanged(model,evt));
        end

        function delete(self)
            if self.checkValid(self.Parent)
                clf(self.Parent);
                self.MetalCatalog.delete;
                self.Parent.delete;
            end
        end
    end

    events
ValueChanged
    end
end
