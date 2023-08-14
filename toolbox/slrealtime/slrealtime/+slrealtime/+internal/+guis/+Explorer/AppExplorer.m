classdef AppExplorer<handle




    properties(Access=public)
        App(1,1)matlab.ui.container.internal.AppContainer;
    end

    properties(Hidden=true)
Icons
Tooltips
Messages


        SystemLogViewerDocument matlab.ui.internal.FigureDocument
        SignalsDocument matlab.ui.internal.FigureDocument
        ParametersDocument matlab.ui.internal.FigureDocument
        TargetConfigurationDocument matlab.ui.internal.FigureDocument
        TETMonitorDocument matlab.ui.internal.FigureDocument

TargetsTree
ApplicationTree
SignalsPanel
SignalsTab
ParametersPanel
ParametersTab
TargetConfiguration
SystemLogTab
TETMonitorTab

TargetManager
UpdateApp
EventCallBack

TargetsTreePanel
ApplicationTreePanel
StatusBar


        CompletelyOpened=false
    end

    properties(Access=private)
appStateListener
    end

    methods
        function this=AppExplorer(varargin)


            if nargin==0
                tabToFocusStr='';
            elseif nargin==1
                tabToFocusStr=varargin{1};
            end


            this.Icons=slrealtime.internal.guis.Explorer.Icons;
            this.Messages=slrealtime.internal.guis.Explorer.Messages;
            this.Tooltips=slrealtime.internal.guis.Explorer.Tooltips;


            this.createContainer();


            this.UpdateApp=slrealtime.internal.guis.Explorer.UpdateApp(this);
            this.EventCallBack=slrealtime.internal.guis.Explorer.EventCallBack(this);


            this.addToolstripTabs();


            this.addTargetsPanel();
            this.addApplicationPanel();


            this.StatusBar=slrealtime.internal.guis.Explorer.StatusBar(this);


            this.addDocumentGroups();


            this.TargetManager=slrealtime.internal.guis.Explorer.TargetManager(this);


            this.addSignalsDocument();
            this.addParametersDocument();
            this.addTargetConfigurationDocument();
            this.addSystemLogViewerDocument();


            defaultTargetName=slrealtime.internal.guis.Explorer.StaticUtils.getSLRTDefaultTargetName();
            this.UpdateApp.ForSelectedTarget(defaultTargetName);
            this.UpdateApp.ForTargetApplicationFilterButton();
            this.UpdateApp.ForTargetApplicationSignalsFilterContents();
            this.UpdateApp.ForTargetApplicationParametersFilterContents();

            this.App.WindowBounds=[100,100,1200,800];
            this.App.Visible=true;

            this.appStateListener=addlistener(this.App,'StateChanged',...
            @(app,eventData)this.handleStateChanged(app,eventData,tabToFocusStr));
        end

        function delete(this)


            if~isempty(this.appStateListener)
                delete(this.appStateListener);
                this.appStateListener=[];
            end
        end

        function cleanup(this)


            if~isempty(this.SignalsTab)

                delete(this.SignalsTab);
                this.SignalsTab=[];
            end
            if~isempty(this.TargetManager)

                delete(this.TargetManager);
                this.TargetManager=[];
            end
            if~isempty(this.TargetConfiguration)

                delete(this.TargetConfiguration);
                this.TargetConfiguration=[];
            end
            if~isempty(this.ParametersTab)

                delete(this.ParametersTab);
                this.ParametersTab=[];
            end
        end
    end




    methods(Access=private)

        function createContainer(this)

            import matlab.ui.container.internal.appcontainer.BorderOptions;
            options.Tag="AppExplorer";
            options.Title=getString(message(this.Messages.slrtExplorerTitleMsgId));
            this.App=matlab.ui.container.internal.AppContainer(options);

            this.App.CanCloseFcn=@this.ExplorerCanCloseFcn;
        end


        function addToolstripTabs(this)


            import matlab.ui.internal.toolstrip.*


            globalTabGroup=TabGroup();
            globalTabGroup.Tag="ExplorerTabGroup";
            globalTabGroup.add(this.createTargetTab());
            this.App.add(globalTabGroup);

            targetTab=globalTabGroup.getChildByTag("targetTab");

            globalTabGroup.SelectedTab=targetTab;

        end

        function tab=createTargetTab(this)

            import matlab.ui.internal.toolstrip.*

            tab=Tab(getString(message(this.Messages.targetMsgId)));
            tab.Tag="targetTab";





            section=tab.addSection(getString(message(this.Messages.connectToTargetComputerSectionMsgId)));
            section.Tag="connectToTargetComputerSection";

            column=Column('HorizontalAlignment','left','Width',150);
            column.Tag="connectToTargetComputerColumn";

            section.add(column);

            values='TargetPC1';
            label=matlab.ui.internal.toolstrip.Label(values);
            label.Tag="targetComputerLabel";
            column.add(label);










            button=Button(getString(message(this.Messages.connectMsgId)),this.Icons.disconnectedIcon);
            button.Tag="connectDisconnectButton";
            button.Description=getString(message(this.Messages.connectToTargetMsgId));
            column.add(button);




            section=tab.addSection(getString(message(this.Messages.prepareSectionMsgId)));
            section.Tag="prepareSection";

            column=section.addColumn();
            column.Tag="loadColumn";
            button=Button(getString(message('slrealtime:explorer:loadAppButton')),this.Icons.loadIcon);
            button.Tag="loadApplicationButton";
            button.Description=getString(message(this.Messages.loadApplicationDescriptionMsgId));
            column.add(button);




            section=tab.addSection(getString(message(this.Messages.runOnTargetSectionMsgId)));
            section.Tag="runOnTargetSection";

            column=Column('HorizontalAlignment','center','Width',75);
            column.Tag="startStopColumn";
            section.add(column)

            button=SplitButton(getString(message(this.Messages.startMsgId)),this.Icons.runIcon);
            item1=matlab.ui.internal.toolstrip.ListItemWithCheckBox(...
            getString(message('slrealtime:explorer:ReloadOnStopOption')),...
            getString(message('slrealtime:explorer:ReloadOnStopDescription')),...
            true);
            item2=matlab.ui.internal.toolstrip.ListItemWithCheckBox(...
            getString(message('slrealtime:explorer:AutoImportFileLogOption')),...
            getString(message('slrealtime:explorer:AutoImportFileLogDescription')),...
            true);
            item1.Tag="startButtonReloadOnStop";
            item2.Tag="startButtonAutoImportFileLog";
            popup=matlab.ui.internal.toolstrip.PopupList();
            popup.add(item1);
            popup.add(item2);
            button.Popup=popup;
            button.Tag="startStopButton";
            button.Description=getString(message('slrealtime:explorer:startButtonTooltip'));
            column.add(button);

            column=Column('Width',75);
            column.Tag="stopTimeColumn";
            section.add(column)
            label=Label(getString(message(this.Messages.stopTimeLabelMsgId)));
            column.add(label);
            editfield=EditField('10');
            editfield.Tag="stopTimeField";
            column.add(editfield);



            section=tab.addSection(getString(message('slrealtime:explorer:tuneParameters')));
            section.Tag="tuneParametersSection";

            column=section.addColumn('HorizontalAlignment','center','Width',75);
            column.Tag="holdColumn";

            button=ToggleButton(getString(message('slrealtime:explorer:holdUpdate')),this.Icons.holdParamIcon);
            button.Tag="holdUpdatesButton";
            button.Description=getString(message('slrealtime:explorer:holdUpdatesDescription'));
            button.Enabled=true;
            column.add(button);

            column=section.addColumn('HorizontalAlignment','center','Width',75);
            column.Tag="updateParamColumn";

            button=Button(getString(message('slrealtime:explorer:updateParams')),this.Icons.updateParamIcon);
            button.Tag="updateParamButton";
            button.Description=getString(message('slrealtime:explorer:updateParamsDescription'));
            button.Enabled=false;
            column.add(button);



            section=tab.addSection(getString(message(this.Messages.reviewResultsSectionMsgId)));
            section.Tag="reviewResultsSection";

            column=Column('HorizontalAlignment','center','Width',75);
            column.Tag="SDIColumn";
            section.add(column)

            button=Button(getString(message(this.Messages.sdiButtonMsgId)),this.Icons.openSDIIcon);
            button.Tag="sdiButton";
            button.Description=getString(message(this.Messages.dataInspectorDescriptionMsgId));
            button.ButtonPushedFcn=@(~,~,~)Simulink.sdi.view;
            button.Enabled=true;
            column.add(button);

            column=Column('HorizontalAlignment','center','Width',75);
            column.Tag="recordingControlColumn";
            section.add(column)

            button=Button(getString(message('slrealtime:explorer:startRecording')),this.Icons.startRecordingIcon);
            button.Tag="recordingControlButton";
            button.Description=getString(message('slrealtime:explorer:startRecordingDescription'));
            button.Enabled=false;
            column.add(button);

            column=Column('HorizontalAlignment','center','Width',75);
            column.Tag="tetMonitorColumn";
            section.add(column)

            button=Button(getString(message(this.Messages.tetMonitorButtonMsgId)),this.Icons.tetIcon);
            button.Tag="tetMonitorButton";
            button.Description=getString(message(this.Messages.tetMonitorDescriptionMsgId));
            button.ButtonPushedFcn=@(~,~,~)this.openTETMonitorDocument;
            button.Enabled=true;
            column.add(button);

            column=Column('HorizontalAlignment','center','Width',75);
            column.Tag="importFileLogColumn";
            section.add(column);

            button=Button(getString(message(this.Messages.importFileLogButtonMsgId)),this.Icons.import24Icon);
            button.Tag="importFileLogButton";
            button.Description=getString(message(this.Messages.importFileLogDescriptionMsgId));
            button.Enabled=true;
            column.add(button);

            if slrealtime.internal.feature('CANExplorer')&&...
                exist('canExplorer.m','file')
                column=Column('HorizontalAlignment','center','Width',75);
                column.Tag="canExplorerColumn";
                section.add(column);

                button=Button(getString(message('slrealtime:explorer:canExplorer')),this.Icons.canExplorerIcon);
                button.Tag="canExplorerButton";
                button.Description=getString(message('slrealtime:explorer:canExplorerDescription'));
                button.ButtonPushedFcn=@(~,~,~)canExplorer;
                button.Enabled=true;
                column.add(button);
            end

            if slrealtime.internal.feature('CANExplorer')&&...
                exist('canFDExplorer.m','file')
                column=Column('HorizontalAlignment','center','Width',75);
                column.Tag="canFDExplorerColumn";
                section.add(column);

                button=Button(getString(message('slrealtime:explorer:canFDExplorer')),this.Icons.canFDExplorerIcon);
                button.Tag="canFDExplorerButton";
                button.Description=getString(message('slrealtime:explorer:canFDExplorerDescription'));
                button.ButtonPushedFcn=@(~,~,~)canFDExplorer;
                button.Enabled=true;
                column.add(button);
            end
        end


        function addTargetsPanel(this)



            options.Tag="targetsTreePanel";
            options.Title=getString(message(this.Messages.targetsTreePanelTitleMsgId));
            options.Region="left";
            options.Resizable=true;
            options.PermissibleRegions=["left","right"];

            this.TargetsTreePanel=matlab.ui.internal.FigurePanel(options);
            this.App.add(this.TargetsTreePanel);

            this.TargetsTree=slrealtime.internal.guis.Explorer.TargetsTree(this);
        end


        function addApplicationPanel(this)



            options.Tag="zapplicationTreePanel";
            options.Title=getString(message(this.Messages.applicationTreePanelTitleMsgId));
            options.Region="left";
            options.Resizable=true;
            options.PermissibleRegions=["left","right"];

            this.ApplicationTreePanel=matlab.ui.internal.FigurePanel(options);
            this.App.add(this.ApplicationTreePanel);

            this.ApplicationTree=slrealtime.internal.guis.Explorer.ApplicationTree(this);
        end

        function addDocumentGroups(this)


            options.Tag="explorerDocumentGroup";
            options.Title="Explorer Document Group";
            options.Context=matlab.ui.container.internal.appcontainer.ContextDefinition();
            group=matlab.ui.internal.FigureDocumentGroup(options);
            this.App.add(group);

        end

        function addSignalsDocument(this)


            group=this.App.getDocumentGroup("explorerDocumentGroup");

            figOptions.Title=getString(message(this.Messages.signalsTabTitleMsgId));
            figOptions.DocumentGroupTag=group.Tag;
            figOptions.Closable=false;
            document=matlab.ui.internal.FigureDocument(figOptions);

            this.SignalsPanel=slrealtime.internal.guis.Explorer.SignalsPanel(this,document.Figure);
            this.SignalsTab=slrealtime.internal.guis.Explorer.SignalsTab(this);

            document.UserData=this.SignalsPanel;
            this.App.add(document);

            this.SignalsDocument=document;
        end

        function addParametersDocument(this)


            group=this.App.getDocumentGroup("explorerDocumentGroup");

            figOptions.Title=getString(message(this.Messages.parametersTabTitleMsgId));
            figOptions.DocumentGroupTag=group.Tag;
            figOptions.Closable=false;
            document=matlab.ui.internal.FigureDocument(figOptions);

            this.ParametersPanel=slrealtime.internal.guis.Explorer.ParametersPanel(this,document.Figure);
            this.ParametersTab=slrealtime.internal.guis.Explorer.ParametersTab(this);

            document.UserData=this.ParametersPanel;
            this.App.add(document);

            this.ParametersDocument=document;
        end

        function addTargetConfigurationDocument(this,varargin)


            group=this.App.getDocumentGroup("explorerDocumentGroup");

            figOptions.Title=getString(message(this.Messages.targetConfigurationTabTitleMsgId));
            figOptions.DocumentGroupTag=group.Tag;
            figOptions.Closable=false;
            document=matlab.ui.internal.FigureDocument(figOptions);

            document.Figure.AutoResizeChildren='on';

            this.TargetConfiguration=slrealtime.internal.guis.Explorer.TargetConfiguration(this,document.Figure);
            document.UserData=this.TargetConfiguration;

            this.App.add(document);

            this.TargetConfigurationDocument=document;

        end

        function addSystemLogViewerDocument(this,varargin)








            group=this.App.getDocumentGroup("explorerDocumentGroup");

            figOptions.Title=getString(message(this.Messages.systemLogViewerTabTitleMsgId));
            figOptions.DocumentGroupTag=group.Tag;
            figOptions.Closable=false;
            document=matlab.ui.internal.FigureDocument(figOptions);

            document.Figure.AutoResizeChildren='on';

            this.SystemLogTab=slrealtime.internal.guis.Explorer.SystemLogViewerExported(this,document.Figure);

            this.App.add(document);

            this.SystemLogViewerDocument=document;
        end

        function addTETMonitorDocument(this,varargin)


            group=this.App.getDocumentGroup("explorerDocumentGroup");

            figOptions.Title=getString(message('slrealtime:explorer:tetMonitorTabName'));
            figOptions.Tag="tetMonitorDoc";
            figOptions.DocumentGroupTag=group.Tag;
            figOptions.Closable=true;
            document=matlab.ui.internal.FigureDocument(figOptions);

            document.Figure.AutoResizeChildren='on';
            document.CanCloseFcn=@this.tetMonitorDocCanCloseFcn;

            this.TETMonitorTab=slrealtime.internal.guis.Explorer.TETMonitor(document.Figure);

            this.App.add(document);

            this.TETMonitorDocument=document;
        end

    end




    methods(Access=private)

        function flag=ExplorerCanCloseFcn(this,App)
            this.cleanup();

            flag=true;

        end

        function handleStateChanged(this,app,eventData,tabToFocusStr)
            if this.App.State==matlab.ui.container.internal.appcontainer.AppState.RUNNING





                switch tabToFocusStr
                case 'TargetConfiguration'
                    this.App.SelectedChild=struct('tag',this.TargetConfigurationDocument.Tag,...
                    'documentGroupTag',this.TargetConfigurationDocument.DocumentGroupTag);
                case 'SystemLogViewer'
                    this.App.SelectedChild=struct('tag',this.SystemLogViewerDocument.Tag,...
                    'documentGroupTag',this.SystemLogViewerDocument.DocumentGroupTag);
                case 'TETMonitor'



                    this.addTETMonitorDocument();
                otherwise
                    this.App.SelectedChild=struct('tag',this.TargetConfigurationDocument.Tag,...
                    'documentGroupTag',this.TargetConfigurationDocument.DocumentGroupTag);
                end


                this.CompletelyOpened=true;
            elseif this.App.State==matlab.ui.container.internal.appcontainer.AppState.TERMINATED
                this.delete();
                slrealtime.Explorer.dialogClosed();
            end
        end

        function flag=tetMonitorDocCanCloseFcn(this,doc)

            isaExplorerTab=true;
            slrealtime.TETMonitor.close(isaExplorerTab);









            if isvalid(this)&&~isempty(this.TETMonitorTab)
                delete(this.TETMonitorTab);
                this.TETMonitorTab=[];
            end







            flag=true;
        end

    end

    methods(Access={?slrealtime.Explorer})

        function openTETMonitorDocument(this)
            tetMonitorDoc=this.App.getDocument("explorerDocumentGroup","tetMonitorDoc");
            if isempty(tetMonitorDoc)

                this.addTETMonitorDocument();
            else
                this.App.SelectedChild=struct('tag',tetMonitorDoc.Tag,...
                'documentGroupTag',tetMonitorDoc.DocumentGroupTag);
            end
        end

    end
end
