classdef ( Abstract )ToolstripApp < handle

    properties ( Abstract, Constant )

        Title

        Name

        AppIconPath
    end

    properties ( Constant )
        DocGroupTag = 'evolutionsDocumentGroup';

        ModuleName = "evolutionTree";
        ReleaseRoot = "/toolbox/evolutions/web/evolutionTree/release/evolutionTree";
        WDETag = 'wdGroup';
        DebugRoot = '/toolbox/evolutions/web/evolutionTree/';
    end

    properties ( SetAccess = immutable )
        ToolGroup
        TabGroup
        DocGroup
        QABHelpBtn
        WebDocGroup
        Debug
        MsgChannel
        messageChannel
    end

    properties

        IsLaunching( 1, 1 )logical = true;
        WantsToClose( 1, 1 )logical = false;

        CefWindow

        ProgressDialog
        ProgressDialogEnabled = true
    end

    methods ( Abstract, Access = protected )
        closeAllFigures( this );
        createAppComponents( this );
    end

    methods
        function this = ToolstripApp( debug )
            arguments
                debug = false
            end
            this.Debug = debug;


            [ ~, name ] = fileparts( tempname );

            appOptions = struct;


            appOptions.Tag = name;
            appOptions.Title = this.Title;
            appOptions.CleanStart = true;
            appOptions.ReportJavaScriptErrors = true;

            appOptions.Product = "Design Evolution";
            appOptions.Scope = "Design Evolution Manager";

            moduleInfo = matlab.ui.container.internal.appcontainer.ModuleInfo;
            moduleInfo.Name = "evolutionTree";
            moduleInfo.Path = "/toolbox/evolutions/web/evolutionTree/evolutionTree";
            moduleInfo.Exports = [ "DiagramDocumentFactory", "MinimapPanelFactory", "EvolutionInfoFactory", "InspectorPanelFactory" ];

            debugDependencies = fullfile( 'toolbox', 'evolutions', 'web', 'evolutionTree', 'js_dependencies.json' );
            moduleInfo.DebugDependenciesJSONPath = debugDependencies;


            extInfo = matlab.ui.container.internal.appcontainer.ExtensionInfo;

            extInfo.Modules( 1 ) = moduleInfo;
            appOptions.Extension = extInfo;
            appOptions.Features = "UseWebpack";
            this.MsgChannel = "/evolutions/internal/app/msg/" + matlab.lang.internal.uuid(  );
            this.messageChannel = this.MsgChannel + "/header";




            if this.Debug
                this.ToolGroup = matlab.ui.container.internal.AppContainer_Debug( appOptions );


                disp( "<a href=""matlab:wm = matlab.internal.webwindowmanager;window = wm.windowList(end);window.executeJS('cefclient.sendMessage(''openDevTools'')')"">Debug with Browser</a>" );
            else
                this.ToolGroup = matlab.ui.container.internal.AppContainer( appOptions );
            end


            import matlab.ddux.internal.*;
            eventId = UIEventIdentification(  ...
                "Design Evolution", "Design Evolution Manager",  ...
                EventType.OPENED, ElementType.APP, "OpenApp" );
            logUIEvent( eventId, struct(  ) );


            this.ToolGroup.Resizable = 1;


            this.QABHelpBtn = matlab.ui.internal.toolstrip.qab.QABHelpButton;
            this.QABHelpBtn.DocName = 'simulink/design-evolution-manager';
            this.ToolGroup.add( this.QABHelpBtn );

            this.DocGroup = matlab.ui.internal.FigureDocumentGroup( 'Tag', this.DocGroupTag );
            add( this.ToolGroup, this.DocGroup );


            groupOptions.Tag = this.WDETag;
            groupOptions.Title = "Web Diagram Group";

            groupOptions.DocumentFactory = this.ModuleName + "/js/DiagramDocumentFactory";
            this.WebDocGroup = matlab.ui.container.internal.appcontainer.DocumentGroup( groupOptions );
            add( this.ToolGroup, this.WebDocGroup );


            createAppComponents( this );

        end

        function createCefWindow( this )
            windows = matlab.internal.webwindowmanager.instance(  );
            result = windows.findAllWebwindows;
            for windowIndex = 1:numel( result )
                if strcmp( result( windowIndex ).Title, this.Title )
                    this.CefWindow = result( windowIndex );
                end
            end
            this.CefWindow.FocusGained = @( ~, ~ )notify( this.EventHandler, 'FocusChanged' );
        end

        function delete( this )
            closeAllFigures( this );
            drawnow(  );
            if ~isempty( this.ProgressDialog ) && isvalid( this.ProgressDialog )
                delete( this.ProgressDialog );
            end
        end

        function closeApp( this )
            this.getToolGroup.close(  );
        end

        function setBusy( this )
            toolGroup = getToolGroup( this );
            toolGroup.Busy = 1;
        end

        function enableProgressDialog( this )
            this.ProgressDialogEnabled = true;
        end

        function disableProgressDialog( this )
            this.ProgressDialogEnabled = false;
        end

        function clearBusy( this )
            toolGroup = getToolGroup( this );
            toolGroup.Busy = 0;
        end

        function addPanel( this, panel )
            add( getToolGroup( this ), panel );
        end

        function createProgressDialog( this, title )
            if this.ProgressDialogEnabled
                figHandle = getToolGroup( this );
                this.ProgressDialog = uiprogressdlg( figHandle, 'Title', title,  ...
                    'Message', 'Initializing', 'Cancelable', 'off' );
            end
        end

        function closeProgressDialog( this )
            pause( 2 );
            if ~isempty( this.ProgressDialog ) && isvalid( this.ProgressDialog )
                diag = this.ProgressDialog;
                diag.Message = 'Complete';
                diag.Value = 1;
                close( diag );
            end
        end

        function cancelled = setAppStatus( this, value, message )
            cancelled = 0;
            pause( 2 );
            if ~isempty( this.ProgressDialog ) && isvalid( this.ProgressDialog )
                diag = this.ProgressDialog;
                if diag.CancelRequested
                    cancelled = diag.CancelRequested;
                    return ;
                end
                diag.Value = value;
                diag.Message = message;
            end
        end

        function removePanel( this, panelTag )
            removePanel( getToolGroup( this ), panelTag );
        end

        function addDocument( this, document )
            add( getToolGroup( this ), document );
        end

        function docs = getDocuments( this )
            docs = getDocuments( this.ToolGroup );
        end

        function addContext( this, modalContext )
            this.ToolGroup.Contexts{ end  + 1 } = modalContext;
        end

        function setActiveContext( this, contextTag )
            this.ToolGroup.ActiveContexts = contextTag;
        end

        function tagPrefix = getTagPrefix( this )

            tagPrefix = strcat( lower( this.Name ), '_' );
        end

        function addTabGroup( this, tabGroup )
            this.ToolGroup.addTabGroup( getTabGroup( tabGroup ) );
        end

        function show( this )
            this.ToolGroup.Visible = 1;
            this.createCefWindow;
        end

        function title = getAppTitle( this )
            title = this.getToolGroup.Title;
        end

        function position = getAppPosition( this )
            position = this.ToolGroup.WindowBounds;
        end

        function name = getGroupName( this )
            name = this.ToolGroup.Name;
        end

        function toolGroup = getToolGroup( this )
            toolGroup = this.ToolGroup;
        end

        function docGroup = getDocGroup( this )
            docGroup = this.DocGroup;
        end

        function docGroup = getWebDocGroup( this )
            docGroup = this.WebDocGroup;
        end

        function removeViewTab( this )

            this.ToolGroup.hideViewTab(  );
        end

        function addTree( this, evolutionsTreeContainer )


            this.ToolGroup.add( evolutionsTreeContainer );
        end

        function finishAppLaunching( this )


            this.IsLaunching = false;
            if this.WantsToClose
                delete( this );
            end
        end

        function msgChannel = getMsgChannel( this )
            msgChannel = this.MsgChannel;
        end
    end

    methods ( Access = protected )
        function appGroupActionCallback( this, ~, ~ )
            this.WantsToClose = true;
            finishAppLaunching( this );
        end

    end
end



