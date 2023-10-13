classdef ( Abstract )ClassDiagramApp < handle



    properties ( Access = private )

        LoadingFactory = [  ];
        HasFileDialogOpen = false;
    end

    properties ( Constant, Access = protected )
        ErrMType = "ErrMClassDiagramApp";
        docViewerPath = 'matlab/ref/classdiagramviewer.html';
        docRoot = '/mathworks/devel/jobarchive/Bdoc21a/latest_pass/matlab/help';
        OrigDocRoot = docroot;
    end

    properties ( Constant )
        IsDebug = false;
    end

    methods ( Access = { ?classdiagram.app,  ...
            ?classdiagram.app.core.ClassDiagramApp,  ...
            ?classdiagram.app.core.notifications.WDFNotifier,  ...
            ?classdiagram.app.core.notifications.Notifier } )
        function isDebug = isGlobalDebug( ~ )
            isDebug = evalin( 'base', 'classdiagram.app.core.ClassDiagramApp.IsDebug' );
        end
    end

    properties ( Dependent, Transient = true )
        IsShowPackageNames( 1, 1 )logical;
        IsShowMixins( 1, 1 )logical;
    end

    methods
        function value = get.IsShowPackageNames( self )
            value = self.Settings.get( "ShowPackageNames" );
        end

        function set.IsShowPackageNames( self, value )
            arguments
                self( 1, 1 )classdiagram.app.core.ClassDiagramApp;
                value( 1, 1 )matlab.lang.OnOffSwitchState
            end
            self.showPackageNames( struct( key = "ShowPackageNames", val = logical( value ) ) );
        end

        function value = get.IsShowMixins( self )
            value = self.Settings.get( "ShowDetails" );
        end

        function set.IsShowMixins( self, value )
            arguments
                self( 1, 1 )classdiagram.app.core.ClassDiagramApp;
                value( 1, 1 )matlab.lang.OnOffSwitchState
            end
            self.showDetails( struct( key = "ShowDetails", val = logical( value ) ) );
        end
    end

    properties ( Access = { ?classdiagram.app,  ...
            ?classdiagram.app.core.ClassDiagramApp,  ...
            ?classdiagram.app.core.ClassDiagramConnectionHandler,  ...
            ?classdiagram.app.core.ElementCreator,  ...
            ?diagram.editor.Command,  ...
            ?classdiagram.app.core.inspector.Inspector,  ...
            ?classdiagram.app.io.ClassDiagramIOModelBuilder,  ...
            ?classdiagram.app.core.Exporter,  ...
            ?classdiagram.app.core.Importer,  ...
            ?classdiagram.app.core.Refresher,  ...
            ?classdiagram.app.core.WindowManager,  ...
            ?classdiagram.app.core.ProjectLaunchManager,  ...
            ?classdiagram.app.core.notifications.WDFNotifier,  ...
            ?classdiagram.app.core.ClassDiagramLaunchManager,  ...
            ?classdiagram.app.mcos.ClassBrowser,  ...
            ?matlab.diagram.ClassViewer,  ...
            ?classDiagramTest.ClassDiagramTestCase,  ...
            ?classDiagramTest.SaveLoadModelTester } )

        cdWindow classdiagram.app.core.ClassDiagramWindow;


        messageChannel uint64;


        editor diagram.editor.registry.EditorController;

        syntax diagram.interface.DiagramSyntax;
        connectionHandler;

        maxPackageElements;


        inspector classdiagram.app.core.inspector.Inspector;


        activeFilePath string;


        uid char;

        helpPath char;

        exporter classdiagram.app.core.Exporter;
        importer classdiagram.app.core.Importer;
        refresher classdiagram.app.core.Refresher;

        notifier;
    end

    properties ( Access = { ?classdiagram.app,  ...
            ?classdiagram.app.core.Exporter,  ...
            ?classDiagramTest.ClassDiagramTestCase,  ...
            ?classDiagramTest.SaveLoadModelTester } )
        fileDialog;
        isDiagramReady = false;


        diagramReadyTimeout = 300;
    end

    methods
        function visible = isVisible( self )
            visible = self.cdWindow.isVisible;
        end

        function saveDiagram( self, fullFilePath )
            arguments
                self( 1, 1 )classdiagram.app.core.ClassDiagramApp;
                fullFilePath string{ mustBeScalarOrEmpty } = string.empty;
            end
            if isempty( fullFilePath )
                fullFilePath = self.activeFilePath;
            else
                fullFilePath = classdiagram.app.io.getCanonicalPath( fullFilePath );
            end
            self.syntax.modify( @( ops )self.reconcileHeights( ops ) );
            mgr = classdiagram.app.io.IOMgr( self );
            mgr.saveTo( fullFilePath );
            self.activeFilePath = fullFilePath;
            self.publishData( struct( 'type', 'diagramSaved', 'path', self.activeFilePath ) );


            self.inspector.refreshInspector;
        end

        function loadDiagram( self, fullFilePath )
            arguments
                self( 1, 1 )classdiagram.app.core.ClassDiagramApp;
                fullFilePath string{ mustBeScalarOrEmpty } = string.empty;
            end
            mgr = classdiagram.app.io.IOMgr( self );
            if isempty( fullFilePath )
                fullFilePath = self.activeFilePath;
            else
                fullFilePath = classdiagram.app.io.getCanonicalPath( fullFilePath );
            end
            self.waitTillDiagramReady;
            mgr.loadFrom( fullFilePath );
            self.activeFilePath = fullFilePath;
            self.onPostLoad(  );
        end
    end

    methods ( Access = { ?classDiagramTest.ClassDiagramTestCase,  ...
            ?classDiagramTest.SaveLoadModelTester } )
        function saveDiagram_UI( self, actionInfo )


            self.notifier.setMode(  ...
                classdiagram.app.core.notifications.Mode.UI );
            self.notifier.unsetMode(  ...
                classdiagram.app.core.notifications.Mode.CL );
            try
                if ~isempty( self.activeFilePath )
                    self.saveDiagram( self.activeFilePath );
                else
                    self.saveDiagramAs_UI( self, actionInfo );
                end
            catch ex
                self.publishData( struct( 'type', 'saveDiagramError' ) );

                if isa( self.notifier, 'classdiagram.app.core.notifications.Notifier' )
                    self.notifier.processNotification( ex );
                else
                    self.notifier.processNotification(  ...
                        classdiagram.app.core.notifications.notifications.MExceptionNotification(  ...
                        ex ) );
                end
            end
        end

        function saveDiagramAs_UI( self, ~, ~ )
            if self.HasFileDialogOpen
                return ;
            end

            uiPath = self.fileDialog.pwd(  );
            if ~isempty( self.activeFilePath )
                uiPath = self.activeFilePath;
            end

            self.HasFileDialogOpen = true;
            [ filename, pathname ] = self.fileDialog.uiputfile(  ...
                { '*.mldatx', getString( message( 'classdiagram_editor:messages:FileTypName' ) ) },  ...
                getString( message( 'classdiagram_editor:messages:SaveDiagramPicker' ) ),  ...
                uiPath );
            self.HasFileDialogOpen = false;
            self.raise(  );
            if ~isequal( filename, 0 ) && ~isequal( pathname, 0 )
                fullFilePath = fullfile( pathname, filename );
                self.saveDiagram( fullFilePath );
            else
                self.publishData( struct( 'type', 'saveDiagramCanceled' ) );
            end
        end

        function loadDiagram_UI( self, ~ )
            function loadDiagram_internal( self )
                if self.HasFileDialogOpen
                    return ;
                end



                self.notifier.setMode(  ...
                    classdiagram.app.core.notifications.Mode.UI );
                self.notifier.unsetMode(  ...
                    classdiagram.app.core.notifications.Mode.CL );

                uiPath = self.fileDialog.pwd(  );
                if ~isempty( self.activeFilePath )
                    uiPath = self.activeFilePath;
                end

                self.HasFileDialogOpen = true;
                [ filename, pathname ] = self.fileDialog.uigetfile(  ...
                    { '*.mldatx', getString( message( 'classdiagram_editor:messages:FileTypName' ) ) },  ...
                    getString( message( 'classdiagram_editor:messages:LoadDiagramPicker' ) ),  ...
                    uiPath );
                self.HasFileDialogOpen = false;
                self.raise(  );
                if isequal( filename, 0 )
                    self.publishData( struct( 'type', 'loadDiagramCanceled' ) );
                elseif ~isequal( pathname, 0 )
                    fullFilePath = fullfile( pathname, filename );
                    try
                        self.loadDiagram( fullFilePath );
                    catch ME
                        self.publishData( struct( 'type', 'loadDiagramCanceled' ) );
                        if isa( self.notifier, 'classdiagram.app.core.notifications.Notifier' )
                            self.notifier.processNotification( ME );
                        else
                            self.notifier.processNotification(  ...
                                classdiagram.app.core.notifications.notifications.MExceptionNotification(  ...
                                ME ) );
                        end
                    end
                end
            end
            fh = @( batchOps )loadDiagram_internal( self );
            self.executeAction( fh, Action = 'loadDiagram_UI' );
        end

        function diagramReady( self, ~ )



            self.isDiagramReady = true;
            self.onPostLoad(  );
        end

        function newDiagram( ~, ~ )
            matlab.diagram.ClassViewer(  );
        end
    end

    methods ( Access = ?classdiagram.app.io.IOMgr )

        function loadFromFactory( self, factory )
            fh = @( batchOps )self.syntax.modify( @( ops )self.loadFromFactoryImpl( factory ) );
            self.executeAction( fh, Action = "loadDiagram" );
        end
    end

    methods ( Access = private )

        function onPostLoad( self )
            if ~isempty( self.activeFilePath )
                self.publishData( struct(  ...
                    'type', 'diagramLoaded',  ...
                    'path', self.activeFilePath,  ...
                    'ShowDetails', self.Settings.get( "ShowDetails" ),  ...
                    'ShowPackageNames', self.Settings.get( "ShowPackageNames" ) ...
                    ) );
                self.cdWindow.Tag = self.activeFilePath;
            end
            self.refresher.markOutOfDateElementsStale(  );


            self.inspector.refreshInspector;
        end

        function loadFromFactoryImpl( self, factory )

            function classNames = getClassNames( pkg )
                packageElements = [ factory.getClasses( pkg ), factory.getEnums( pkg ) ];
                classNames = arrayfun( @( c ){ c.getName }, packageElements );
            end

            self.removeAllClasses(  );
            try
                self.LoadingFactory = factory;
                factory.resetDiagramElements(  );
                cp = self.editor.commandProcessor;

                loadedSettings = factory.getLoadedSettings(  );

                settingName = "ShowPackageNames";
                value = classdiagram.app.core.Settings.getDefaultValue( settingName );
                if isfield( loadedSettings, settingName )
                    value = loadedSettings.( settingName );
                end
                settingInfo = struct( key = settingName, val = logical( value ) );
                cmd = cp.createCustomCommand( 'classdiagram.app.core.commands.ClassDiagramChangeDiagramSettingCommand', 'SettingChange', settingInfo );
                cp.execute( cmd );

                settingName = "ShowDetails";
                value = classdiagram.app.core.Settings.getDefaultValue( settingName );
                if isfield( loadedSettings, settingName )
                    value = loadedSettings.( settingName );
                end
                settingInfo = struct( key = settingName, val = logical( value ) );
                self.showDetails( settingInfo );

                classes = {  };
                pkgs = factory.getPackages(  );
                classes = arrayfun( @( pkg )cat( 2, classes, getClassNames( pkg ) ), pkgs, 'uni', 0 );


                if numel( classes )
                    classes = [ classes{ : } ];
                end

                noPkgClasses = getClassNames( [  ] );
                classes( end  + 1:end  + numel( noPkgClasses ) ) = noPkgClasses;

                positions = factory.getLoadedPositions( classes );

                data = struct(  ...
                    'bulkCreate', true,  ...
                    'classes', { classes },  ...
                    'position', { positions } ...
                    );

                cmd = cp.createCustomCommand( 'classdiagram.app.core.commands.ClassDiagramCreateCommand', 'Load', data );
                cp.execute( cmd );

                expandedStates = factory.getLoadedExpandStates( classes );
                self.setExpandState( expandedStates );

                cp.clearStack(  );
                self.LoadingFactory = [  ];
                previousFactory = self.getClassDiagramFactory(  );
                previousFactory.applyDataFrom( factory );
            catch err
                self.LoadingFactory = [  ];
                rethrow( err );
            end


            cb = self.getClassBrowser;
            cbRoots = cb.getRootNodes;
            for iroot = 1:numel( cbRoots )
                root = cbRoots{ iroot };
                cb.removeRoot( root );
            end
            newRoots = factory.getBrowserRoots(  );
            newRootTypes = string( fields( newRoots ) );
            for iRootType = 1:numel( newRootTypes )
                rootType = newRootTypes( iRootType );
                rootsOfType = newRoots.( rootType );
                for iNewRoot = 1:numel( rootsOfType )
                    newRoot = rootsOfType{ iNewRoot };
                    cb.addRoot( newRoot, rootType );
                end
            end
        end
    end

    properties ( Access = protected )
        pathToPage = '/toolbox/classdiagram/editor/index.html';
    end

    properties ( Access = { ?classdiagram.app.core.ClassDiagramApp,  ...
            ?classdiagram.app.core.ClassDiagramConnectionHandler,  ...
            ?classdiagram.app.core.commands.ClassDiagramChangeDiagramSettingCommand,  ...
            ?diagram.editor.Command } )
        Settings classdiagram.app.core.Settings;
    end

    methods ( Abstract )

        navigateToSource( self, objectID );


        updateObjectInContentView( self, object )
    end

    methods ( Abstract, Access = protected )
        virtualGetClassBrowser( self );
        virtualGetClassDiagramFactory( self );
    end

    methods
        function obj = ClassDiagramApp( varargin )
            import classdiagram.app.core.utils.*;




            obj.uid = matlab.lang.makeValidName( matlab.lang.internal.uuid );

            inputParams = [  ];
            if ~isempty( varargin ) && ~isempty( varargin{ 1 } )
                inputParams = varargin{ 1 };
            end
            obj.initSettings( inputParams );
            obj.syntax = diagram.interface.DiagramSyntax;

            obj.syntax.modify( @( ops )ops.setAttributeValue( obj.syntax.root, 'ShowPackageNames',  ...
                obj.Settings.get( 'ShowPackageNames' ) ) );

            obj.editor = diagram.editor.registry.EditorController( obj.syntax, obj.syntax.root.uuid, obj.pathToPage );
            obj.messageChannel = message.subscribe( strcat( '/Classdiagram/', obj.editor.uuid, '/messagechannel' ), @( msg )obj.processClientRequest( msg ) );
            connector.ensureServiceOn(  );
            connector.newNonce(  );

            obj.connectionHandler = classdiagram.app.core.ClassDiagramConnectionHandler( obj );

            obj.syntax.modifyPrototypes( @( operations, protoOps, diagram )classdiagram.app.core.commands.ClassDiagramCreateCommand.addPrototypes( operations, protoOps, diagram ) );

            if obj.getGlobalSetting( 'IsDebug' )

            end

            obj.maxPackageElements = obj.getGlobalSetting( 'MaxEntities' );


            classdiagram.app.core.commands.registerCustomCommands( obj, obj.editor, obj.syntax );


            obj.inspector = classdiagram.app.core.inspector.Inspector( obj );
            if classdiagram.app.core.feature.isOn( 'notifications' )
                PINotifRule = struct( 'condition', regexpPattern( ':PI_' ), 'keep', '',  ...
                    'remove', "classdiagram.app.core.notifications.notifications.PIError" );
                cleanUpRules = classdiagram.app.core.notifications.ClassDiagramCleanUpRules( keep =  ...
                    'classdiagram.app.core.notifications.notifications.OutOfSyncClass',  ...
                    conditions = PINotifRule );
                obj.notifier = classdiagram.app.core.notifications.WDFNotifier( obj, obj.editor );
                obj.notifier.registerCleanUpRules( cleanUpRules );
                obj.notifier.registerI18nActionCatalog( 'classdiagram_editor:messages' );
                obj.cdWindow = classdiagram.app.core.ClassDiagramWindow( obj, obj.notifier.url );
            else
                obj.notifier = classdiagram.app.core.notifications.Notifier( obj, obj.editor.uuid );
                obj.cdWindow = classdiagram.app.core.ClassDiagramWindow( obj, obj.editor.url );
            end
            obj.fileDialog = classdiagram.app.core.utils.FileDialog(  );
            obj.exporter = classdiagram.app.core.Exporter( obj, obj.fileDialog );
            obj.importer = classdiagram.app.core.Importer( obj );
            obj.refresher = classdiagram.app.core.Refresher( obj );
        end

        function cb = getClassBrowser( self )
            cb = self.virtualGetClassBrowser(  );
        end



        function factory = getClassDiagramFactory( self )
            if isempty( self.LoadingFactory )
                factory = self.virtualGetClassDiagramFactory(  );
            else
                factory = self.LoadingFactory;
            end
        end

        function delete( self )
            if ( ~isempty( self.messageChannel ) )
                message.unsubscribe( self.messageChannel );
            end
        end

        function executeAction( self, fh, optional )
            arguments
                self( 1, 1 )classdiagram.app.core.ClassDiagramApp;
                fh( 1, 1 )function_handle;
                optional.Action( 1, 1 )string = string.empty;
            end

            function catAction = convertActionToCatalogAction( action )
                catAction = action;
                if startsWith( action, 'add' )
                    catAction = 'add';
                elseif regexp( action, '^remove|^delete' )
                    catAction = 'remove';
                elseif startsWith( action, 'export' )
                    catAction = 'export';
                end
            end
            if isa( self.notifier, 'classdiagram.app.core.notifications.WDFNotifier' )
                action = convertActionToCatalogAction( optional.Action );
                self.notifier.batchNotifications( fh, Action = action );
            else
                fh( [  ] );
            end
        end

        function addClass( self, varargin )
            emptyClassNotif = classdiagram.app.core.notifications.notifications.ErrMInvalidMCOSClass( "" );
            if isempty( varargin )
                self.notifier.processNotification( emptyClassNotif );
                return ;
            end
            [ varargin{ : } ] = convertStringsToChars( varargin{ : } );
            classInfo = varargin{ 1 };
            if isempty( classInfo )
                self.notifier.processNotification( emptyClassNotif );
                return ;
            end
            toLayout = true;
            if nargin > 2
                toLayout = varargin{ 2 };
            end
            fh = @( batchOps )self.addClassInternal( classInfo, toLayout );
            self.executeAction( fh, Action = 'add' );
        end

        function addEnum( self, enumInfo )
            self.addClass( enumInfo );
        end

        function addPackage( self, pkgName, recurse )
            if nargin == 2
                recurse = 1;
            end
            if isempty( pkgName )
                return ;
            end
            self.addPackageInternal( pkgName, recurse );
        end

        function addFolder( self, folderPath, recurse )
            if nargin == 2
                recurse = 1;
            end
            if isempty( folderPath )
                return ;
            end
            self.addFolderInternal( folderPath, recurse );
        end

        function addProject( self, projectPath )
            if isempty( projectPath )
                return ;
            end

            self.addProjectInternal( projectPath );
        end

        function superclasses = addSuperclasses( self, elementsInfo )

            if isfield( elementsInfo, 'toShowAll' )
                toShowAll = elementsInfo.toShowAll;
                elementsInfo = elementsInfo.elementsInfo;
            else
                toShowAll = false;
            end
            factory = self.getClassDiagramFactory;


            elements = string( elementsInfo )';
            superclasses = factory.getSuperclassesForClassesSet( elements, toShowAll );
            toLayout = true;
            self.addClass( superclasses, toLayout );
        end

        function removeClass( self, inputArr )
            function internalRemoveClass( self, inputArr )
                if isempty( inputArr )
                    return ;
                end
                data = [  ];
                data.elements = inputArr;
                command = self.editor.commandProcessor.createCustomCommand(  ...
                    'classdiagram.app.core.commands.ClassDiagramDeleteCommand',  ...
                    'Custom Delete Command', data );
                self.editor.commandProcessor.execute( command );
            end
            fh = @( batchOps )internalRemoveClass( self, inputArr );
            self.executeAction( fh, Action = "remove" );
        end

        function names = getAllElementNames( self )
            factory = self.getClassDiagramFactory;
            packageElements = factory.getDiagramedEntities;
            names = arrayfun( @( el )string( el.getName ), packageElements );
        end

        function removeAllClasses( self, varargin )
            factory = self.getClassDiagramFactory;
            packageElements = factory.getDiagramedEntities;
            self.removeClass( packageElements );
        end

        function resetDiagram( self, ~, ~ )
            self.refresher.refresh(  );
        end

        function export( obj, actionArgs )
            obj.exporter.export( actionArgs );
        end

        function exportToPdf( obj, ~ )
            obj.exporter.exportToPdf(  );
        end

        function openPutFileBrowserWidget( obj, actionArgs )
            obj.exporter.openPutFileBrowserWidget( actionArgs )
        end

        function showHelp( ~, ~ )
            helpview( 'matlab', 'classdiagramviewer' );
        end

        function val = getGlobalSetting( self, actionInfo )
            if isfield( actionInfo, 'setting' )
                key = actionInfo.setting;
            else
                key = actionInfo;
            end
            val = self.Settings.get( key );
        end


        function modifyGlobalSetting( self, actionInfo )
            key = actionInfo.key;
            val = actionInfo.val;
            self.Settings = self.Settings.set( key, val );

            self.publishData( actionInfo );
            if strcmp( key, 'ShowDetails' )
                key = 'ShowHandle';
                self.Settings = self.Settings.set( key, val );
                key = 'ShowMixins';
                self.Settings = self.Settings.set( key, val );
                self.refresher.refreshForMixins(  );
            end
        end

        function showIndirectInheritance( self, settingsInfo )
            self.modifyGlobalSetting( settingsInfo );

            self.resetDiagram(  );
        end

        function showDetails( self, settingsInfo )
            self.modifyGlobalSetting( settingsInfo );
        end

        function showHandle( self, settingsInfo )
            self.modifyGlobalSetting( settingsInfo );
            self.refresher.refreshForMixins(  );
        end

        function showMixins( self, settingsInfo )
            self.modifyGlobalSetting( settingsInfo );
            self.refresher.refreshForMixins(  );
        end

        function showPackageNames( self, settingsInfo )
            prevVal = logical( self.Settings.get( settingsInfo.key ) );

            if prevVal ~= logical( settingsInfo.val )
                cp = self.editor.commandProcessor;
                cmd = cp.createCustomCommand(  ...
                    'classdiagram.app.core.commands.ClassDiagramChangeDiagramSettingCommand',  ...
                    'SettingChange', settingsInfo );
                cp.execute( cmd );
            end
        end

        function manageSettings( self, settingsInfo )
            cmd = classdiagram.app.core.Settings.propNameToFuncName( settingsInfo.key );
            self.( cmd )( settingsInfo );
        end

        function entity = findEntity( self, className )
            entity = diagram.interface.Entity.empty;
            f = self.getClassDiagramFactory;
            obj = f.getClass( className );
            if isempty( obj )
                obj = f.getEnum( className );
            end
            if ~isempty( obj )
                uuid = obj.getDiagramElementUUID;
                if ~isempty( uuid )
                    entity = self.syntax.findElement( uuid );
                    if ~isempty( entity ) && entity.isValid
                        return ;
                    end
                end
            end
            if isa( self.notifier, 'classdiagram.app.core.notifications.Notifier' )
                self.notifier.processNotification( 'ErrMNotInDiagram', className );
            else
                self.notifier.processNotification(  ...
                    classdiagram.app.core.notifications.notifications.ErrMNotInDiagram( className ) );
            end
        end






        function expandClass( self, classNames, toExpand )
            arguments
                self( 1, 1 )classdiagram.app.core.ClassDiagramApp;
                classNames( 1, : )string;
                toExpand( 1, 1 ){ mustBeNumericOrLogical } = 1;
            end
            cp = self.editor.commandProcessor;
            cmd = cp.createCustomCommand( 'classdiagram.app.core.commands.ClassDiagramExpandCommand',  ...
                'Expand Class', struct( 'entity', classNames, 'expanded', toExpand ) );
            fh = @( batchOps )cp.execute( cmd );
            if toExpand
                action = 'expandClass';
            else
                action = 'collapseClass';
            end
            self.executeAction( fh, Action = action );
        end





        function expandSection( self, className, sections, toExpand )
            arguments
                self( 1, 1 )classdiagram.app.core.ClassDiagramApp;
                className( 1, 1 )string;
                sections( 1, : )string;
                toExpand( 1, 1 ){ mustBeNumericOrLogical } = 1;
            end
            expandStruct = struct;
            for n = 1:numel( sections )
                section = sections( n );
                expandStruct.( section ) = toExpand;
            end
            cp = self.editor.commandProcessor;
            cmd = cp.createCustomCommand( 'classdiagram.app.core.commands.ClassDiagramExpandCommand',  ...
                'Expand Class', struct( 'entity', className, 'sections', expandStruct ) );
            cp.execute( cmd );

        end


        function expandAll( self, toExpand )
            arguments
                self( 1, 1 )classdiagram.app.core.ClassDiagramApp;
                toExpand( 1, 1 ){ mustBeNumericOrLogical } = 1;
            end
            cp = self.editor.commandProcessor;
            cmd = cp.createCustomCommand( 'classdiagram.app.core.commands.ClassDiagramExpandCommand', 'Expand all',  ...
                struct( 'all', toExpand ) );
            cp.execute( cmd );
        end



        function setExpandState( self, states )
            cp = self.editor.commandProcessor;
            cmd = cp.createCustomCommand( 'classdiagram.app.core.commands.ClassDiagramExpandCommand', 'Set Expand State', states );
            cp.execute( cmd );
        end


        function import( self, actionInfo )
            self.importer.import( actionInfo );
        end

        function processClientRequest( self, actionInfo )
            function innerProcessClientRequest( self, actionInfo )

                try
                    if ~strcmp( actionInfo.action, 'diagramReady' )
                        self.notifier.setMode(  ...
                            classdiagram.app.core.notifications.Mode.UI );
                        self.notifier.unsetMode(  ...
                            classdiagram.app.core.notifications.Mode.CL );

                        if isa( self.notifier, 'classdiagram.app.core.notifications.Notifier' )
                            self.notifier.setActionInfo( actionInfo );
                        end
                    end
                    feval( actionInfo.action, self, actionInfo.actionArgs );
                catch ex
                    if classdiagram.app.core.feature.isOn( 'notifications' )
                        self.notifier.processNotification(  ...
                            classdiagram.app.core.notifications.notifications.WDFNotification(  ...
                            ex, Transient = 0, Severity =  ...
                            classdiagram.app.core.notifications.Severity.Error ) );
                    else
                        if self.isGlobalDebug
                            self.notifier.processNotification( self.ErrMType, ex.getReport );
                        else
                            self.notifier.processNotification( self.ErrMType, getReport( ex, 'basic' ) );
                        end
                    end
                    self.publishResponse( actionInfo, "Fail" );
                end
                if ~strcmp( actionInfo.action, 'diagramReady' )
                    self.notifier.resetMode(  );
                end
            end
            fh = @( batchOps )innerProcessClientRequest( self, actionInfo );
            if ~strcmp( actionInfo.action, 'diagramReady' )
                self.executeAction( fh, Action = actionInfo.action );
            else
                fh( [  ] );
            end
        end

        function publishData( self, evtData )
            self.publishResponse( evtData, "Success" );
        end

        function waitTillDiagramReady( self )
            waitForDiagramReady = tic;
            while self.cdWindow.isVisible && ~self.isDiagramReady && toc( waitForDiagramReady ) < self.diagramReadyTimeout
                pause( 0.001 );
            end
            if ~self.isDiagramReady && self.cdWindow.isVisible
                error( message( "classdiagram_editor:messages:ErrMTimeout" ) );
            end
        end

        function publishResponse( self, evtData, result )
            evtData.result = result;
            self.waitTillDiagramReady;
            if self.isDiagramReady
                message.publish( strcat( '/Classdiagram/', self.editor.uuid, '/receiveRequest' ), evtData );
            end
        end

        function initSettings( self, inputParams )
            self.Settings = classdiagram.app.core.Settings;
            if isempty( inputParams )
                return ;
            end
            settings = [ "ShowAssociations", "IsDebug" ];
            for setting = settings
                self.Settings = self.Settings.set( setting, inputParams.( setting ) );
            end
        end

        function toShow = ShowEntity( self, obj )
            toShow = false;
            if strcmp( obj.getName, 'handle' )
                if self.Settings.get( "ShowHandle" )
                    toShow = true;
                end
                return ;
            end
            if self.Settings.get( "ShowMixins" )
                toShow = true;
                return ;
            end
            if ~ismember( obj.getName, classdiagram.app.core.utils.Constants.Mixins )
                toShow = true;
            end
        end

        function layout( self )
            self.syntax.modify( @( ops )self.doLayout( ops ) );
        end

        function raise( self )

            self.cdWindow.raise(  );
        end

        function close( self )
            self.cdWindow.close(  );
        end

        function show( self, isDebug )
            self.cdWindow.show( isDebug );
        end

        function uipath = getFilePath( self )

            uipath = self.activeFilePath;
        end

        function schema = getCurrentSchema( self )
            schema = self.inspector.getSchema(  );
        end

        function doLayout( self, operations )
            self.reconcileHeights( operations );
            internal.diagram.layout.treelayout.layoutDiagram( self.syntax, operations );
        end

    end

    methods ( Static, Access = protected )





        function collapsed = isCollapsed( element )
            collapsed = element.hasAttribute( 'collapsed' ) &&  ...
                element.getAttribute( 'collapsed' ).value == true;
        end
    end

    methods ( Static, Access = ?classdiagram.app.core.commands.ClassDiagramUndoRedo )
        function reconcileEntityHeight( entity, operations )
            import classdiagram.app.core.domain.*;
            import classdiagram.app.core.utils.Constants;

            oldSize = entity.getSize(  );
            height = 0;
            if strcmp( entity.type, ClassDiagramTypes.typeMap( Class.ConstantType ) )
                height = Constants.ClassTitleHeight;
            elseif strcmp( entity.type, ClassDiagramTypes.typeMap( Enum.ConstantType ) )
                height = Constants.EnumTitleHeight;
            end

            if ~classdiagram.app.core.ClassDiagramApp.isCollapsed( entity )
                sub = entity.subdiagram;
                if ~isempty( sub )
                    lines = entity.subdiagram.entities;
                    for iline = 1:numel( lines )
                        line = lines( iline );
                        if ~classdiagram.app.core.ClassDiagramApp.isCollapsed( line )
                            height = height + classdiagram.app.core.utils.Constants.LineHeight;
                        end
                    end
                end
            end
            operations.setSize( entity, oldSize.width, height );
        end
    end

    methods ( Access = private )
        function reconcileHeights( self, operations )
            for entity = self.syntax.root.entities'
                classdiagram.app.core.ClassDiagramApp.reconcileEntityHeight( entity, operations );
            end
        end
    end

    methods ( Access = { ?classdiagram.app.core.ClassDiagramApp,  ...
            ?classdiagram.app.core.ClassDiagramConnectionHandler,  ...
            ?classdiagram.app.core.commands.ClassDiagramCreateCommand,  ...
            ?classdiagram.app.mcos.ClassBrowser,  ...
            ?matlab.diagram.ClassViewer,  ...
            ?diagram.editor.Command } )
        function names = getAllDiagramEntityNames( self )

            ent = self.syntax.root.entities;
            v = [ ent.isValid ];
            ent( ~v' ) = [  ];
            names = { ent.title };

        end

        function package = getPackageWithWarning( self, factory, name )
            package = factory.getPackage( name );
            if isempty( package )
                if isa( self.notifier, 'classdiagram.app.core.notifications.Notifier' )
                    self.notifier.processNotification( 'ErrMInvalidMCOSPackage', name );
                else
                    self.notifier.processNotification(  ...
                        classdiagram.app.core.notifications.notifications.ErrMInvalidMCOSPackage(  ...
                        name ) );
                end
            end
        end

        function packageElements = addPackageItemsHelper( self, packageInfo, recurse )
            packageElements = classdiagram.app.core.domain.PackageElement.empty( 1, 0 );
            if isempty( packageInfo )
                return ;
            end
            factory = self.getClassDiagramFactory;

            packages = [  ];
            if isa( packageInfo, 'char' ) || isa( packageInfo, 'string' )
                packages = factory.getPackage( packageInfo );
            elseif isa( packageInfo, 'cell' )
                packages = arrayfun( @( name )self.getPackageWithWarning( factory, name{ : } ), packageInfo, 'uni', 0 );
            end
            for ii = 1:numel( packages )
                package = packages{ ii };
                if ~isempty( package )
                    pkgElements = self.addPackageItemsHelperRecursive( package,  ...
                        classdiagram.app.core.domain.PackageElement.empty( 1, 0 ), recurse );
                    a = length( packageElements );
                    packageElements( a + 1:a + length( pkgElements ) ) = pkgElements;
                end
            end
        end
    end

    methods ( Access = { ?classdiagram.app.core.ClassDiagramApp,  ...
            ?classdiagram.app.core.Importer ...
            } )
        function addClassInternal( self, classInfo, toLayout )
            import classdiagram.app.core.domain.*;

            classType = ClassDiagramTypes.typeMap( Class.ConstantType );
            position = struct(  );
            if isa( classInfo, 'classdiagram.app.core.domain.PackageElement' )
                data = struct( 'packageElements', classInfo, 'toLayout', toLayout,  ...
                    'position', position, 'recurse', false );
            else
                data = struct( 'classType', classType, 'title', classInfo,  ...
                    'toLayout', toLayout, 'position', position, 'recurse', false );
            end
            command = self.editor.commandProcessor.createCustomCommand(  ...
                'classdiagram.app.core.commands.ClassDiagramCreateCommand',  ...
                'Custom Create Command', data );
            self.editor.commandProcessor.execute( command );
        end

        function addPackageInternal( self, pkgName, recurse )
            import classdiagram.app.core.domain.*;

            packageType = ClassDiagramTypes.typeMap( Package.ConstantType );
            position = struct(  );
            data = struct( 'classType', packageType, 'title', pkgName, 'toLayout', true,  ...
                'position', position, 'recurse', recurse );
            command = self.editor.commandProcessor.createCustomCommand(  ...
                'classdiagram.app.core.commands.ClassDiagramCreateCommand',  ...
                'Custom Create Command', data );
            self.editor.commandProcessor.execute( command );
        end

        function addFolderInternal( self, folderPath, recurse )
            folderPath = regexprep( folderPath, '/$', '' );
            folderType = classdiagram.app.core.domain.Folder.ConstantType;
            position = struct(  );
            data = struct( 'classType', folderType, 'title', folderPath,  ...
                'toLayout', true, 'position', position, 'recurse', recurse );
            command = self.editor.commandProcessor.createCustomCommand(  ...
                'classdiagram.app.core.commands.ClassDiagramCreateCommand',  ...
                'Custom Create Command', data );
            self.editor.commandProcessor.execute( command );
            cb = self.getClassBrowser;
            cb.addRootFolders( string( folderPath ) );
        end

        function addProjectInternal( self, projectPath )
            projectType = classdiagram.app.core.domain.Project.ConstantType;
            position = struct(  );
            data = struct( 'classType', projectType, 'title', projectPath,  ...
                'toLayout', true, 'position', position );
            command = self.editor.commandProcessor.createCustomCommand(  ...
                'classdiagram.app.core.commands.ClassDiagramCreateCommand',  ...
                'Custom Create Command', data );
            self.editor.commandProcessor.execute( command );
            cb = self.getClassBrowser;
            cb.addRootProjects( { projectPath } );
        end
    end

    methods ( Access = private )
        function packageElements = addPackageItemsHelperRecursive( self, package, packageElements, recurse )
            if isempty( package )
                return ;
            end

            factory = self.getClassDiagramFactory;
            classesInPackage = factory.getClasses( package );
            enumsInPackage = factory.getEnums( package );
            packageElements = [ packageElements, classesInPackage, enumsInPackage ];

            if ~recurse
                return ;
            end
            packagesInPackage = factory.getSubPackages( package );
            for inestedPackage = 1:numel( packagesInPackage )
                nestedPackage = packagesInPackage( inestedPackage );
                packageElements = self.addPackageItemsHelperRecursive( nestedPackage, packageElements, recurse );
            end
        end
    end


    properties ( Dependent, Access = { ?classDiagramTest.ClassDiagramTestCase,  ...
            ?classDiagramTest.SaveLoadModelTester } )
        mockFileDialog;
    end

    methods
        function set.mockFileDialog( self, value )
            arguments
                self( 1, 1 )classdiagram.app.core.ClassDiagramApp;
                value( 1, 1 )classDiagramTest.MockFileDialog;
            end
            self.fileDialog.mockFileDialog = value;
        end

        function value = get.mockFileDialog( self )
            value = self.fileDialog.mockFileDialog;
        end
    end

    methods ( Access = { ?classDiagramTest.ClassDiagramTestCase,  ...
            ?classDiagramTest.SaveLoadModelTester } )
        function undo( self )
            self.editor.commandProcessor.undo(  );
        end

        function redo( self )
            self.editor.commandProcessor.redo(  );
        end

        function cefwindow = ww( self )
            cefwindow = self.cdWindow.ww;
        end


        function setBlockLimit( self, limit )
            self.maxPackageElements = limit;
            settingsInfo.key = 'MaxEntities';
            settingsInfo.val = limit;
            self.modifyGlobalSetting( settingsInfo );
        end

        function setupDiagramReadyTimeout( self, isReady, timeout )
            self.isDiagramReady = isReady;
            self.diagramReadyTimeout = timeout;
        end
    end
end



