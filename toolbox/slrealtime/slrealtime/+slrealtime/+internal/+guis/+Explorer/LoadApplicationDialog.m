classdef LoadApplicationDialog<matlab.apps.AppBase





    properties(Access=public)
        LoadRealTimeApplicationUIFigure matlab.ui.Figure
        GridLayout matlab.ui.container.GridLayout
        LoadApplicationPanel matlab.ui.container.Panel
        PanelGridLayout matlab.ui.container.GridLayout
        ApplicationNameGridLayout matlab.ui.container.GridLayout
        ApplicationnameLabel matlab.ui.control.Label
        ApplicationNameEditField matlab.ui.control.EditField
        ButtonGridLayout matlab.ui.container.GridLayout
        LoadButton matlab.ui.control.Button
        CancelButton matlab.ui.control.Button
        ListBoxGridLayout matlab.ui.container.GridLayout
        ListBox matlab.ui.control.ListBox
        FileSelectorGridLayout matlab.ui.container.GridLayout
        FileSelectorButton matlab.ui.control.Button
        LabelGridLayout matlab.ui.container.GridLayout
        ApplicationsontargetcomputerLabel matlab.ui.control.Label
        ApplicationonhostcomputerLabel matlab.ui.control.Label
    end

    properties(Access=private)
Icons
CallingApp

selectedTargetName
finishLoadButtonPushedFcn

        loadFromTarget=false
        applicationName=''
        applicationPath=''
    end


    methods(Access=public)


        function this=LoadApplicationDialog(hCallingApp,selectedTargetName,finishLoadButtonPushedFcn)









            this.CallingApp=hCallingApp;
            this.selectedTargetName=selectedTargetName;
            this.finishLoadButtonPushedFcn=finishLoadButtonPushedFcn;

            if isa(this.CallingApp,'slrealtime.internal.guis.Explorer.AppExplorer')
                window=this.CallingApp.App.WindowBounds;
            else
                window=this.CallingApp.Position;
            end

            width=640;
            height=400;

            center=window(1)+window(3)/2;
            left=center-width/2;
            center=window(2)+window(4)/2;
            up=center-height/2;


            this.LoadRealTimeApplicationUIFigure=uifigure('Visible','off');
            this.LoadRealTimeApplicationUIFigure.Position=[left,up,width,height];
            this.LoadRealTimeApplicationUIFigure.Name=getString(message('slrealtime:explorer:loadRealTimeApplication'));
            this.LoadRealTimeApplicationUIFigure.CloseRequestFcn=@this.LoadRealTimeApplicationUIFigureCloseRequest;
            this.LoadRealTimeApplicationUIFigure.WindowStyle='modal';


            this.Icons=slrealtime.internal.guis.Explorer.Icons;


            createComponents(this)


            this.ListBox.Value={};
            this.loadFromTarget=false;
            this.applicationName='';
            this.applicationPath='';

            apps=slrealtime.internal.guis.Explorer.StaticUtils.getSLRTInstalledApps(this.selectedTargetName);
            if~isempty(apps)
                this.ListBox.Items=apps;
            else
                this.ListBox.Items={};
            end
















            this.LoadRealTimeApplicationUIFigure.Visible='on';

        end


        function delete(app)
            app.CallingApp=[];

            delete(app.LoadRealTimeApplicationUIFigure)
        end
    end


    methods(Access=private)


        function ListBoxValueChanged(this,event)
            value=event.Value;

            this.ApplicationNameEditField.Value=sprintf('%s : %s',this.selectedTargetName,value);
            this.LoadButton.Enable='on';
            this.loadFromTarget=true;
            this.applicationName=value;
            this.applicationPath='';

        end


        function LoadButtonPushed(this,event)


            lft=this.loadFromTarget;
            an=this.applicationName;
            ap=this.applicationPath;
            finishLoadButtonPushedFcn=this.finishLoadButtonPushedFcn;


            this.LoadRealTimeApplicationUIFigureCloseRequest();


            finishLoadButtonPushedFcn(lft,an,ap);
        end


        function CancelButtonPushed(this,event)
            this.LoadRealTimeApplicationUIFigureCloseRequest();
        end


        function FileSelectorButtonPushed(this,event)
            [filename,pathname]=uigetfile(...
            {'*.mldatx',getString(message('slrealtime:explorer:allTargetApplicationFiles'))},...
            getString(message('slrealtime:explorer:selectSlrtTargetApplicationFile')));

            if isa(this.CallingApp,'slrealtime.internal.guis.Explorer.AppExplorer')
                this.CallingApp.App.bringToFront();
            end
            this.LoadRealTimeApplicationUIFigure.Visible='off';
            this.LoadRealTimeApplicationUIFigure.Visible='on';
            if filename
                [~,name,~]=fileparts(filename);

                this.ApplicationNameEditField.Value=fullfile(pathname,name);
                this.LoadButton.Enable='on';
                this.ListBox.Value={};
                this.loadFromTarget=false;
                this.applicationName=name;
                this.applicationPath=pathname;

            end

        end


        function LoadRealTimeApplicationUIFigureCloseRequest(this,fig,event)

            if isa(this.CallingApp,'slrealtime.internal.guis.Explorer.AppExplorer')
                isExplorer=true;

                window=this.CallingApp.App;

                this.CallingApp.TargetManager.LoadApplicationUIFigure=[];
            else
                isExplorer=false;
                window=this.CallingApp;
            end


            delete(this)


            if isExplorer
                window.bringToFront();
            else
                figure(window);
            end

        end

    end


    methods(Access=private)


        function createComponents(this)


            this.GridLayout=uigridlayout(this.LoadRealTimeApplicationUIFigure);
            this.GridLayout.ColumnWidth={'1x'};
            this.GridLayout.RowHeight={'1x'};


            this.LoadApplicationPanel=uipanel(this.GridLayout);
            this.LoadApplicationPanel.Title=getString(message('slrealtime:explorer:loadApplication'));
            this.LoadApplicationPanel.Layout.Row=1;
            this.LoadApplicationPanel.Layout.Column=1;
            this.LoadApplicationPanel.FontWeight='bold';
            this.LoadApplicationPanel.FontSize=16;


            this.PanelGridLayout=uigridlayout(this.LoadApplicationPanel);
            this.PanelGridLayout.ColumnWidth={'1x'};
            this.PanelGridLayout.RowHeight={25,'1x',25,25};
            this.PanelGridLayout.ColumnSpacing=1;
            this.PanelGridLayout.RowSpacing=3;


            this.ApplicationNameGridLayout=uigridlayout(this.PanelGridLayout);
            this.ApplicationNameGridLayout.ColumnWidth={'1x','4x'};
            this.ApplicationNameGridLayout.RowHeight={'1x'};
            this.ApplicationNameGridLayout.ColumnSpacing=1;
            this.ApplicationNameGridLayout.RowSpacing=1;
            this.ApplicationNameGridLayout.Padding=[1,1,1,1];
            this.ApplicationNameGridLayout.Layout.Row=3;
            this.ApplicationNameGridLayout.Layout.Column=1;


            this.ApplicationnameLabel=uilabel(this.ApplicationNameGridLayout);
            this.ApplicationnameLabel.HorizontalAlignment='right';
            this.ApplicationnameLabel.Layout.Row=1;
            this.ApplicationnameLabel.Layout.Column=1;
            this.ApplicationnameLabel.Text=[getString(message('slrealtime:explorer:applicationName')),':'];


            this.ApplicationNameEditField=uieditfield(this.ApplicationNameGridLayout,'text');
            this.ApplicationNameEditField.Editable='off';
            this.ApplicationNameEditField.Layout.Row=1;
            this.ApplicationNameEditField.Layout.Column=2;


            this.ButtonGridLayout=uigridlayout(this.PanelGridLayout);
            this.ButtonGridLayout.ColumnWidth={'1x',100,100};
            this.ButtonGridLayout.RowHeight={'1x'};
            this.ButtonGridLayout.RowSpacing=1;
            this.ButtonGridLayout.Padding=[1,1,1,1];
            this.ButtonGridLayout.Layout.Row=4;
            this.ButtonGridLayout.Layout.Column=1;


            this.LoadButton=uibutton(this.ButtonGridLayout,'push');
            this.LoadButton.ButtonPushedFcn=createCallbackFcn(this,@LoadButtonPushed,true);
            this.LoadButton.Layout.Row=1;
            this.LoadButton.Layout.Column=2;
            this.LoadButton.Text=getString(message('slrealtime:explorer:load'));
            this.LoadButton.Enable='off';


            this.CancelButton=uibutton(this.ButtonGridLayout,'push');
            this.CancelButton.ButtonPushedFcn=createCallbackFcn(this,@CancelButtonPushed,true);
            this.CancelButton.Layout.Row=1;
            this.CancelButton.Layout.Column=3;
            this.CancelButton.Text=getString(message('slrealtime:explorer:cancel'));


            this.ListBoxGridLayout=uigridlayout(this.PanelGridLayout);
            this.ListBoxGridLayout.RowHeight={'1x'};
            this.ListBoxGridLayout.Padding=[1,1,1,1];
            this.ListBoxGridLayout.Layout.Row=2;
            this.ListBoxGridLayout.Layout.Column=1;


            this.ListBox=uilistbox(this.ListBoxGridLayout);
            this.ListBox.ValueChangedFcn=createCallbackFcn(this,@ListBoxValueChanged,true);
            this.ListBox.Layout.Row=1;
            this.ListBox.Layout.Column=1;


            this.FileSelectorGridLayout=uigridlayout(this.ListBoxGridLayout);
            this.FileSelectorGridLayout.ColumnWidth={'1x','1x','1x'};
            this.FileSelectorGridLayout.RowHeight={'1x','1x','1x'};
            this.FileSelectorGridLayout.Layout.Row=1;
            this.FileSelectorGridLayout.Layout.Column=2;


            this.FileSelectorButton=uibutton(this.FileSelectorGridLayout,'push');
            this.FileSelectorButton.ButtonPushedFcn=createCallbackFcn(this,@FileSelectorButtonPushed,true);
            this.FileSelectorButton.Layout.Row=2;
            this.FileSelectorButton.Layout.Column=2;
            this.FileSelectorButton.Text=getString(message('slrealtime:explorer:fileSelector'));
            this.FileSelectorButton.Icon=this.Icons.openIcon;
            this.FileSelectorButton.IconAlignment='top';


            this.LabelGridLayout=uigridlayout(this.PanelGridLayout);
            this.LabelGridLayout.RowHeight={'1x'};
            this.LabelGridLayout.Padding=[1,1,1,1];
            this.LabelGridLayout.Layout.Row=1;
            this.LabelGridLayout.Layout.Column=1;


            this.ApplicationsontargetcomputerLabel=uilabel(this.LabelGridLayout);
            this.ApplicationsontargetcomputerLabel.Layout.Row=1;
            this.ApplicationsontargetcomputerLabel.Layout.Column=1;
            this.ApplicationsontargetcomputerLabel.Text=getString(message('slrealtime:explorer:applicationsOnTargetComputer'));


            this.ApplicationonhostcomputerLabel=uilabel(this.LabelGridLayout);
            this.ApplicationonhostcomputerLabel.Layout.Row=1;
            this.ApplicationonhostcomputerLabel.Layout.Column=2;
            this.ApplicationonhostcomputerLabel.Text=getString(message('slrealtime:explorer:applicationsOnHostComputer'));


        end
    end


end
