classdef AppController < handle

    properties ( SetAccess = immutable )
        AppModel
        AppView

        ErrorHandler

        EventHandler

        StateController

        CacheManager

        FileListener
    end

    properties ( Hidden, SetAccess = protected )

        ServerInterface
        CustomDialogInterface
        ProjectInterface
    end

    properties ( SetAccess = protected )

        ToolstripController
        PanelController
        DocumentController
        WizardController

        IsAppLocked( 1, 1 )logical = false;
        IsAppBeingDestroyed( 1, 1 )logical = false;
    end

    properties ( SetAccess = protected )

        EvolutionTreeSelectionChangedListener
        AppModelChangedListener
        FileListListener
        RefreshRequiredListener
    end

    properties ( SetAccess = private )
        Subscriptions
    end

    properties ( SetAccess = protected )
        Debug
    end


    methods
        function this = AppController( options )

            arguments
                options.Debug = false
                options.EnableCache = true
            end

            this.Debug = options.Debug;


            this.EventHandler = evolutions.internal.ui.tools.EventHandler;


            this.CacheManager =  ...
                evolutions.internal.ui.tools.CacheManager(  ...
                'Enabled', options.EnableCache );

            this.CacheManager.createCache( 'ManageLayout',  ...
                this.getDefaultManageLayout, @this.updateLayoutCache );
            this.CacheManager.createCache( 'WindowPosition',  ...
                [  ], @this.updateWindowPositionCache );


            createProjectInterface( this, evolutions.internal.app.ProjectInterface );


            this.AppModel = evolutions.internal.app.AppModel( this );


            this.StateController = evolutions.internal.ui.tools.StateController( this );


            this.AppView = evolutions.internal.app.AppView( this );
            this.AppView.setDefaultLayout( this.CacheManager.getCacheData( 'ManageLayout' ) );
            this.updateWindowPosition;

            createEvolutionsInterface( this, evolutions.internal.app.EvolutionInterface( this.AppModel ) );
            createCustomDialog( this, evolutions.internal.app.dialogs.DialogManager );


            if isvalid( this.AppView )



                createSubControllers( this );


                this.ErrorHandler = evolutions.internal.ui.tools.ErrorHandler(  ...
                    'evolutions:manage', getTagPrefix( this.AppView ), this );


                updateView( this );


                installListeners( this );

                finishAppLaunching( this.AppView );
                if isvalid( this.AppView )
                    addlistener( this.AppView, 'ObjectBeingDestroyed', @( ~, ~ )delete( this ) );
                    addlistener( this.AppView.ToolGroup, 'StateChanged',  ...
                        @( ~, ~ )appStateListenerCallBack( this ) );
                    this.AppView.ToolGroup.CanCloseFcn = @this.preUiClose;
                    this.AppView.show;
                else
                    delete( this );
                end
            end
        end

        function set.ServerInterface( obj, serverInterface )
            validateattributes( serverInterface,  ...
                { 'evolutions.internal.ui.tools.ServerInterface' }, { 'nonempty' } );
            obj.ServerInterface = serverInterface;
        end

        function set.CustomDialogInterface( obj, customDialog )
            validateattributes( customDialog,  ...
                { 'evolutions.internal.ui.tools.DialogManagerInterface' }, { 'nonempty' } );
            obj.CustomDialogInterface = customDialog;
        end

        function delete( this )


            this.IsAppBeingDestroyed = true;


            if ~isempty( this.AppView ) && isvalid( this.AppView )
                delete( this.AppView );
            end

            if ~isempty( this.ErrorHandler ) && isvalid( this.ErrorHandler )
                delete( this.ErrorHandler );
            end

            if ~isempty( this.FileListener ) && isvalid( this.FileListener )
                delete( this.FileListener );
            end

            deleteSubControllers( this )


            deleteListeners( this );

        end

        function closeApp( this )
            this.AppView.closeApp;
        end

        function deleteSubControllers( this )

            controllers = [ "PanelController",  ...
                "ToolstripController",  ...
                "DocumentController",  ...
                "StateController",  ...
                "WizardController" ];
            evolutions.internal.ui.deleteControllers( this, controllers );
        end

        function deleteListeners( this )

            listeners = [ "EvolutionTreeSelectionChangedListener",  ...
                "FileListListener", "Subscriptions",  ...
                "AppModelChangedListener",  ...
                "RefreshRequiredListener" ];
            evolutions.internal.ui.deleteListeners( this, listeners );
        end

        function m = getAppModel( this )
            m = this.AppModel;
        end

        function v = getAppView( this )
            v = this.AppView;
        end

        function c = getSubModel( this, type )
            c = getSubModel( getAppModel( this ), type );
        end

        function c = getSubView( this, type )
            c = getSubView( getAppView( this ), type );
        end

        function c = getSubController( this, type )
            switch type
                case 'SplitView'
                    c = this.SplitViewController;
                case 'EvolutionsTree'
                    c = getSubController( this.SplitViewController, 'EvolutionsTree' );
                case 'document'
                    c = this.DocumentController;
                case 'toolstrip'
                    c = this.ToolstripController;
                case 'panel'
                    c = this.PanelController;
                case 'wizard'
                    c = this.WizardController;
                otherwise
                    c = getSubController( this.ToolstripController, type );
            end
        end

        function updatePanel( this, varargin )
            if ~isAppValid( this )
                return ;
            end
            update( this.PanelController, varargin{ : } );
        end

        function updateDocument( this, varargin )
            if ~isAppValid( this )
                return ;
            end
            updateDocument( this.DocumentController, varargin{ : } );
        end

        function handleException( this, ME )


            if ~isAppValid( this ) || ~isvalid( this.ErrorHandler )
                return
            else

                showErrorDialog( this.ErrorHandler, ME );
                notify( this.EventHandler, 'Exception' );
            end
        end

        function flag = isAppValid( this )


            flag = isvalid( this ) && ~this.IsAppBeingDestroyed &&  ...
                ~isempty( this.AppView ) && isvalid( this.AppView );
        end

        function notify( this, eventName, eventData )
            if isequal( nargin, 2 )
                notify( this.EventHandler, eventName )
            else
                notify( this.EventHandler, eventName, eventData )
            end
        end

        function defaultLayout = getDefaultManageLayout( ~ )
            layoutFilePath = fullfile( matlabroot, 'toolbox', 'evolutions',  ...
                'evolutions', '+evolutions', '+internal', 'resources',  ...
                'layout', 'defaultManageLayout.json' );
            layoutJSON = fileread( layoutFilePath );
            defaultLayout = jsondecode( layoutJSON );
        end

        function setDefaultManageLayout( this )
            this.AppView.setLayout( this.getDefaultManageLayout );
        end
    end

    methods ( Hidden, Access = { ?matlab.unittest.TestCase, ?evolutionsTest.EvolutionUITester } )

        function createCustomDialog( this, diag )
            this.CustomDialogInterface = diag;
            this.CustomDialogInterface.setFigureHandle( this.AppView );
        end

        function createEvolutionsInterface( this, interfaceObj )
            this.ServerInterface = interfaceObj;
        end

        function createProjectInterface( this, interfaceObj )
            this.ProjectInterface = interfaceObj;
        end
    end


    methods ( Hidden, Access = protected )
        function updateView( this )

            updateDocument( this );
            updatePanel( this );
        end

        function createSubControllers( this )
            createToolstripController( this );
            createPanelController( this );
            createDocumentController( this );
            createWizardController( this );

            setupControllers( this );
        end

        function setupControllers( this )
            setup( this.ToolstripController );
            setup( this.PanelController );
            setup( this.DocumentController );
            setup( this.WizardController );

            setup( this.StateController );
        end

        function createToolstripController( this )
            this.ToolstripController =  ...
                evolutions.internal.app.toolstrip.ToolstripController( this );
        end

        function createPanelController( this )
            this.PanelController =  ...
                evolutions.internal.app.panel.Controller( this );
        end

        function createDocumentController( this )
            this.DocumentController =  ...
                evolutions.internal.app.document.DocumentController( this );
        end

        function createWizardController( this )
            this.WizardController =  ...
                evolutions.internal.app.wizard.WizardController( this );
        end

        function installListeners( this )
            installModelListeners( this );
            installViewListeners( this );
        end

        function installModelListeners( this )
            this.AppModelChangedListener =  ...
                addlistener( this.EventHandler, 'AppModelChanged', @this.onAppModelChange );
        end

        function installViewListeners( this )
            this.EvolutionTreeSelectionChangedListener =  ...
                addlistener( this.EventHandler, 'EvolutionTreeSelectionChanged', @this.onEvolutionTreeSelectionChange );
            this.RefreshRequiredListener = evolutions.internal.session ...
                .EventHandler.subscribe( 'RefreshClients', @this.onRefreshRequired );
        end

        function onAppModelChange( this, ~, ~ )
            updateView( this );
        end

        function onRefreshRequired( this, ~, data )

            update( this.AppModel.ProjectReferenceListManager );
            update( this.AppModel.EvolutionTreeListManager );
            updateModel( this.AppModel );
            handleException( this, data.EventData.ME );
        end

        function onEvolutionTreeSelectionChange( this, ~, ~ )
            updateModel( this.AppModel );
        end

        function appStateListenerCallBack( this )
            if strcmp( this.AppView.ToolGroup.State, 'TERMINATED' ) && isvalid( this.AppView )
                delete( this.AppView );
            end
        end

        function tf = preUiClose( this, ~ )



            this.CacheManager.updateCache( 'ManageLayout' );
            this.CacheManager.updateCache( 'WindowPosition' );
            tf = true;
        end

        function newData = updateLayoutCache( this, ~ )


            newData = rmfield( this.AppView.ToolGroup.Layout, 'windowBounds' );

            newData.documentLayout.tileCount = 0;
            newData.documentLayout.tileOccupancy = [  ];
        end

        function newData = updateWindowPositionCache( this, ~ )
            newData.MonitorPositions = get( 0, 'MonitorPositions' );
            newData.WindowBounds = this.AppView.ToolGroup.WindowBounds;
        end

        function updateWindowPosition( this )
            cacheData = this.CacheManager.getCacheData( 'WindowPosition' );
            newMonitorPositions = get( 0, 'MonitorPositions' );


            if ~isempty( cacheData ) &&  ...
                    isequal( newMonitorPositions, cacheData.MonitorPositions )
                this.AppView.ToolGroup.WindowBounds = cacheData.WindowBounds;
            end
        end

    end

    methods ( Hidden, Access = protected )


        function setManageContext( this )

            setManageContext( this.ToolstripController );
            setManageContext( this.DocumentController );
            setManageContext( this.PanelController );

            this.AppView.setLayout( this.CacheManager.getCacheData( 'ManageLayout' ) );
        end

    end

end

