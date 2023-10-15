classdef InterfaceEditor < handle





    properties ( Access = private )
        modelOrDDName
        viewModelConnectorChannelUUID;
        interfaceStorageContext;
        interfaceEditingContext;
        ddConn;

        connectionMap;


        currentStudioTagForSchema;



        isModelLocked;
        bdLockEventListener;
    end

    properties ( Constant )
        DIALOG_TAG = 'InterfaceEditorComponent';
        LAST_URL_CONNECTIONMAP_KEY = '__lasturl__';
    end

    methods ( Static, Hidden )
        function tf = debugMode( isDebugging )
            persistent debugMode;
            if isempty( debugMode )
                debugMode = false;
            end
            if nargin == 1
                debugMode = isDebugging;
            end
            tf = debugMode;
        end

        function url = LastUrl( newUrl )


            persistent lastUrl;
            if isempty( lastUrl )
                lastUrl = '';
            end
            if nargin > 0
                lastUrl = newUrl;
            end
            if isempty( lastUrl )
                url = lastUrl;
                return ;
            end
            url = connector.getUrl( lastUrl );
        end

        function url = StudioUniqueUrl( studioTag, studioUrl )


            persistent container
            if isa( container, 'double' ) && isempty( container )
                container = containers.Map(  );
            end
            if ~nargin
                error( 'You need to specify a studio tag' );
            end
            if nargin > 1
                container( studioTag ) = studioUrl;
            end
            if ~container.isKey( studioTag )
                error( 'The given studioTag is invalid' );
            end
            url = container( studioTag );
            url = connector.getUrl( url );
        end

        function interfaces = SelectedInterfaces( modelName, varargin )


            persistent lastSelectionMap;
            if isempty( lastSelectionMap )
                lastSelectionMap = containers.Map;
            end

            interfaces = [  ];

            if nargin == 2

                if isempty( varargin{ 1 } )

                    if isKey( lastSelectionMap, modelName )
                        remove( lastSelectionMap, modelName );
                    end
                else

                    lastSelectionMap( modelName ) = varargin{ 1 };
                end
            end

            if isKey( lastSelectionMap, modelName )
                interfaces = lastSelectionMap( modelName );
            end
        end

        function ExecuteAction( modelOrDDName, storageContext, actionId, actionArgs )

            inModelStorage = strcmp( storageContext, 'Model' );

            if ( inModelStorage )
                app = systemcomposer.internal.arch.load( modelOrDDName );
                ieApp = app.getInterfaceEditorApp(  );
            else
                dd = systemcomposer.internal.openSimulinkDataDictionary( modelOrDDName );
                ieApp = systemcomposer.internal.InterfaceEditorApp.getInterfaceEditorAppForDictionary( dd.filepath(  ) );
            end
            ieApp.executeActionOnInterfaceEditor( actionId, actionArgs );

        end

        function lockInterfaceEditorForBD( bdHandle, flag )

            arguments
                bdHandle( 1, 1 )double
                flag( 1, 1 )logical
            end

            studioList = [  ];
            zcEditor = GLUE2.Util.findAllEditors( get_param( bdHandle, 'Name' ) );
            if isempty( zcEditor )

                return ;
            end
            studioList = [ studioList, zcEditor.getStudio ];



            hInfo = Simulink.harness.internal.getActiveHarness( bdHandle );
            if ~isempty( hInfo )
                harnessEditor = GLUE2.Util.findAllEditors( hInfo.name );
                if ~isempty( harnessEditor )
                    studioList = [ studioList, harnessEditor.getStudio ];
                end
            end


            for i = 1:1:numel( studioList )
                studio = studioList( i );
                comp = studio.getComponent( 'GLUE2:DDG Component', 'InterfaceEditor' );
                if isempty( comp )

                end


                bdH = studio.App.blockDiagramHandle;
                app = Simulink.SystemArchitecture.internal.ApplicationManager.getAppMgrFromBDHandle( bdH );
                editorId = app.getInterfaceEditorId;
                dict = get_param( bdH, 'DataDictionary' );
                name = get_param( bdH, 'Name' );
                if ~isempty( dict )
                    dict = split( dict, '.sldd' );
                    name = dict{ 1 };
                end
                data.action = 'modelLockUnlockEvent';
                data.isModelLocked = flag;
                channel = [ '/', name, '/', editorId, '/interfaceEditor' ];
                message.publish( channel, jsonencode( data ) );
            end
        end

    end

    methods
        function obj = InterfaceEditor( modelOrDDName, connectorChannelUUID, interfaceStorageContext, interfaceEditingContext )
            connector.ensureServiceOn;

            obj.modelOrDDName = modelOrDDName;
            obj.viewModelConnectorChannelUUID = connectorChannelUUID;
            obj.ddConn = '';
            obj.interfaceStorageContext = interfaceStorageContext;
            obj.interfaceEditingContext = interfaceEditingContext;
            obj.connectionMap = containers.Map;
            obj.isModelLocked = false;
            obj.bdLockEventListener = [  ];
        end

        function delete( obj )
            connectionMapKeys = keys( obj.connectionMap );
            for i = 1:length( connectionMapKeys )
                connectionEntry = obj.connectionMap( connectionMapKeys{ i } );
                if ( ~isempty( connectionEntry.viewModelSynchronizer ) )
                    connectionEntry.viewModelSynchronizer.stop(  );
                end
            end
            if ( ~isempty( obj.ddConn ) )
                obj.ddConn.close(  );
            end
        end

        function createUrl( obj, studioTag )


            if isKey( obj.connectionMap, studioTag )
                return
            end

            if ( obj.isInModelStorageContext(  ) )
                bdH = get_param( obj.modelOrDDName, 'handle' );
                app = Simulink.SystemArchitecture.internal.ApplicationManager.getAppMgrFromBDHandle( bdH );
                viewModel = app.getInterfaceEditorViewModel(  );

                obj.ddConn = '';
            else
                obj.ddConn = systemcomposer.internal.openSimulinkDataDictionary( obj.modelOrDDName );





                Simulink.SystemArchitecture.internal.DictionaryRegistry.FetchInterfaceSemanticModel( obj.ddConn.filepath(  ) );
                ieApp = systemcomposer.internal.InterfaceEditorApp.getInterfaceEditorAppForDictionary( obj.ddConn.filepath(  ) );
                viewModel = ieApp.getViewModel;
            end

            inChannel = [ '/systemcomposer/InterfaceEditorView/server/', obj.modelOrDDName, '/', obj.viewModelConnectorChannelUUID, '/', studioTag ];
            outChannel = [ '/systemcomposer/InterfaceEditorView/client/', obj.modelOrDDName, '/', obj.viewModelConnectorChannelUUID, '/', studioTag ];

            connectionEntry.viewModelConnectorChannel = mf.zero.io.ConnectorChannelMS( inChannel, outChannel );
            connectionEntry.viewModelSynchronizer = mf.zero.io.ModelSynchronizer( viewModel, connectionEntry.viewModelConnectorChannel );
            connectionEntry.viewModelSynchronizer.start(  );


            if systemcomposer.InterfaceEditor.debugMode
                pageName = 'index-debug.html';
            else
                pageName = 'index.html';
            end

            if ( obj.isInModelStorageContext(  ) )
                interfaceCatalogStorageContext = 'Model';
                bdOrDDNameForUrl = obj.modelOrDDName;
            else
                interfaceCatalogStorageContext = 'Dictionary';
                ddFilePath = obj.ddConn.filepath(  );
                [ ~, bdOrDDNameForUrl, ~ ] = fileparts( ddFilePath );
            end


            persistent lastStudioTag;
            if strcmpi( studioTag, systemcomposer.InterfaceEditor.LAST_URL_CONNECTIONMAP_KEY )
                actualStudioTag = lastStudioTag;
            else
                actualStudioTag = studioTag;
                lastStudioTag = studioTag;
            end
            activeStudio = DAS.Studio.getStudio( actualStudioTag );
            contextModelName = get_param( activeStudio.App.blockDiagramHandle, 'Name' );
            bdH = activeStudio.App.blockDiagramHandle;


            obj.isModelLocked = obj.getDefaultLockState( contextModelName );
            obj.initBDLockListener(  );

            isSoftwareArchitecture = Simulink.internal.isArchitectureModel( bdH, 'SoftwareArchitecture' );

            baseUrl = sprintf( '/toolbox/systemcomposer/interfaces/editor/web/%s?compositionModelOrDDName=%s&studioTag=%s&connectorChannelUUID=%s&interfaceCatalogStorageContext=%s&contextModelName=%s',  ...
                pageName, bdOrDDNameForUrl, actualStudioTag, obj.viewModelConnectorChannelUUID, interfaceCatalogStorageContext, contextModelName );

            connectionEntry.viewModelConnectorUrl = baseUrl +  ...
                "&isClientServer=" + num2str( slfeature( 'ClientServerInterfaceEditor' ) && isSoftwareArchitecture ) +  ...
                "&domainContext=" + get_param( bdH, 'SimulinkSubDomain' ) +  ...
                "&ZCValueType=" + num2str( slfeature( 'SLValueType' ) ) +  ...
                "&ZCCompositeInlinedIntrf=" + num2str( slfeature( 'ZCCompositeInlinedIntrf' ) ) +  ...
                "&defaultLockState=" + num2str( cast( obj.isModelLocked, 'double' ) );
            obj.connectionMap( studioTag ) = connectionEntry;
            systemcomposer.InterfaceEditor.StudioUniqueUrl( studioTag, connectionEntry.viewModelConnectorUrl );
        end

        function toggleDDGComponent( obj )
            allStudios = DAS.Studio.getAllStudiosSortedByMostRecentlyActive;

            bdName = obj.modelOrDDName;
            if ( ~obj.isInModelStorageContext(  ) )
                bdName = obj.interfaceEditingContext;
            end

            studio = allStudios( 1 );
            isHarnessBD = strcmp( get_param( studio.App.blockDiagramHandle, 'isHarness' ), 'on' );
            if strcmp( get_param( studio.App.blockDiagramHandle, 'Name' ), bdName ) || isHarnessBD
                comp = studio.getComponent( 'GLUE2:DDG Component', 'InterfaceEditor' );
                if isempty( comp )
                    comp = GLUE2.DDGComponent( studio, 'InterfaceEditor', obj );


                    comp.PersistState = true;
                    comp.CreateCallback = 'systemcomposer.createInterfaceEditorComponent';

                    studio.registerComponent( comp );
                    studio.moveComponentToDock( comp, 'Interfaces', 'Bottom', 'Tabbed' );
                else

                    if ~comp.isVisible
                        studio.showComponent( comp );
                        studio.focusComponent( comp );
                    else
                        studio.hideComponent( comp );
                    end
                end
            end
        end

        function refreshUrl( obj, modelOrDDName, connectorChannelUUID, interfaceStorageContext, interfaceEditingContext )



            [ ~, modelOrDDName, ~ ] = fileparts( modelOrDDName );
            obj.resetLastUrl(  );

            partialTagForDDGLookup = [ obj.DIALOG_TAG, '_', obj.modelOrDDName,  ...
                '_', systemcomposer.InterfaceEditor.TranslateContextEnumToStr( obj.interfaceStorageContext ) ];

            obj.modelOrDDName = modelOrDDName;
            obj.viewModelConnectorChannelUUID = connectorChannelUUID;
            obj.interfaceStorageContext = interfaceStorageContext;
            obj.interfaceEditingContext = interfaceEditingContext;

            allStudios = DAS.Studio.getAllStudios;
            for i = 1:length( allStudios )
                studio = allStudios{ i };

                modelNameFromStudio = get_param( studio.App.blockDiagramHandle, 'Name' );
                if strcmp( modelNameFromStudio, obj.interfaceEditingContext )

                    remove( obj.connectionMap, studio.getStudioTag(  ) );


                    obj.createUrl( studio.getStudioTag(  ) );



                    obj.currentStudioTagForSchema = studio.getStudioTag(  );

                    dlg = findDDGByTag( [ partialTagForDDGLookup, '_', obj.currentStudioTagForSchema ] );
                    dlg.refresh(  );
                    obj.currentStudioTagForSchema = '';
                end
            end
        end

        function dlg = getDialogSchema( obj )
            if ( isempty( obj.currentStudioTagForSchema ) )
                allStudios = DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
                studioTagForSchema = allStudios( 1 ).getStudioTag(  );
            else

                studioTagForSchema = obj.currentStudioTagForSchema;
            end

            webbrowser.Type = 'webbrowser';
            webbrowser.Tag = [ obj.modelOrDDName, 'InterfaceEditorBrowser' ];



            webbrowser.MinimumSize = [ 300, 100 ];

            connectionEntry = obj.connectionMap( studioTagForSchema );

            webbrowser.Url = connector.getUrl( connectionEntry.viewModelConnectorUrl );
            obj.updateLastUrl(  );

            dlg.Items = { webbrowser };
            dlg.StandaloneButtonSet = { '' };
            dlg.IsScrollable = false;
            dlg.DispatcherEvents = {  };
            dlg.IgnoreESCClose = true;

            dlg.DialogTitle = '';
            dlg.DialogTag = [ obj.DIALOG_TAG, '_', obj.modelOrDDName,  ...
                '_', systemcomposer.InterfaceEditor.TranslateContextEnumToStr( obj.interfaceStorageContext ),  ...
                '_', studioTagForSchema ];
            dlg.EmbeddedButtonSet = { '' };
            dlg.CloseCallback = 'systemcomposer.InterfaceEditor.CloseCallback';
            dlg.CloseArgs = { systemcomposer.InterfaceEditor.getActiveBD(  ), obj.interfaceStorageContext };
        end

        function initBDLockListener( obj )

            if isempty( obj.bdLockEventListener )
                obj.bdLockEventListener = handle.listener( DAStudio.EventDispatcher, 'ReadOnlyChangedEvent', @( ~, eventData )obj.bdLockEventHandler( eventData ) );
            end
        end

        function bdLockEventHandler( obj, eventData )




            if ~isempty( eventData ) && strcmp( eventData.Type, 'ReadonlyChangedEvent' ) ...
                    && isa( eventData.Source, 'Simulink.BlockDiagram' ) ...
                    && Simulink.internal.isArchitectureModel( eventData.Source.Handle )
                if eventData.Source.isHierarchyReadonly

                    systemcomposer.InterfaceEditor.lockInterfaceEditorForBD( eventData.Source.Handle, true );
                    obj.isModelLocked = true;
                else

                    systemcomposer.InterfaceEditor.lockInterfaceEditorForBD( eventData.Source.Handle, false );
                    obj.isModelLocked = false;
                end
            end
        end

        function registerDAListeners( obj )
            if ( obj.isInModelStorageContext(  ) )
                bd = get_param( obj.modelOrDDName, 'Object' );
                bd.registerDAListeners;
            end
        end
    end

    methods ( Static )
        function ShowPropertyInspector( ~ )
            ueEditors = GLUE2.Util.findAllEditors( gcs );
            for i = 1:length( ueEditors )
                ueStudio = ueEditors( i ).getStudio;
                pi = ueStudio.getComponent( 'GLUE2:PropertyInspector', 'Property Inspector' );
                ueStudio.showComponent( pi );
            end
        end

        function CloseCallback( modelName, interfaceStorageContext )

            systemcomposer.InterfaceEditor.ClearSelection( modelName, interfaceStorageContext );


            systemcomposer.InterfaceEditor.SelectedInterfaces( modelName, [  ] );
        end

        function ElementSelected( modelOrDDName, interfaceStorageContext, selectedUUID )


            if ( strcmp( interfaceStorageContext, 'Model' ) )
                bdH = get_param( modelOrDDName, 'handle' );
                app = Simulink.SystemArchitecture.internal.ApplicationManager.getAppMgrFromBDHandle( bdH );
                mf0Model = app.getCompositionArchitectureModel;
                viewModel = app.getInterfaceEditorViewModel(  );
            else
                bdH = get_param( systemcomposer.InterfaceEditor.getActiveBD(  ), 'handle' );
                [ isDDOpen, ddPath ] = systemcomposer.InterfaceEditor.isDictionaryOpen( modelOrDDName );
                if ~isDDOpen
                    ddConn = systemcomposer.internal.openSimulinkDataDictionary( modelOrDDName );
                    ddPath = ddConn.filepath(  );
                end
                mf0Model = Simulink.SystemArchitecture.internal.DictionaryRegistry.FetchInterfaceSemanticModel( ddPath );
                ieApp = systemcomposer.internal.InterfaceEditorApp.getInterfaceEditorAppForDictionary( ddPath );
                viewModel = ieApp.getViewModel;
            end

            treeTable = systemcomposer.InterfaceEditor.getDictionaryTreeTable( viewModel );


            if isempty( selectedUUID )
                selectedUUIDs = [  ];
            else
                selectedUUIDs = split( selectedUUID, '|' );
            end
            selectedInterfaces = {  };

            for idx = 1:length( selectedUUIDs )
                eUUID = selectedUUIDs{ idx };
                element = mf0Model.findElement( eUUID );

                if isempty( element )


                    pic = systemcomposer.architecture.model.interface.InterfaceCatalog.getInterfaceCatalog( mf0Model );
                    element = pic.getPortInterfaceInClosureByUUID( '', eUUID );

                    if isempty( element )



                        continue ;
                    end
                end


                if element.MetaClass.isA( systemcomposer.architecture.model.interface.PortInterface.StaticMetaClass ) ||  ...
                        element.MetaClass.isA( systemcomposer.architecture.model.interface.CompositeDataInterface.StaticMetaClass ) ||  ...
                        element.MetaClass.isA( systemcomposer.architecture.model.interface.CompositePhysicalInterface.StaticMetaClass )
                    interface = element;
                elseif element.MetaClass.isA( systemcomposer.architecture.model.interface.InterfaceElement.StaticMetaClass )

                    interface = element.getInterface(  );
                else

                    continue ;
                end


                styler = systemcomposer.PortInterfaceStyler.getInstance(  );
                styler.interfaceSelected( bdH, interface );

                selectedInterfaces{ end  + 1 } = interface;%#ok<AGROW>
            end


            systemcomposer.InterfaceEditor.SelectedInterfaces(  ...
                get_param( bdH, 'Name' ), selectedInterfaces );


            dictionaries = treeTable.p_Rows.toArray;
            txn = viewModel.beginTransaction;
            for d = dictionaries
                interfaces = d.p_SubRows.toArray;
                for intrf = interfaces
                    if intrf.p_ElementProperties.getElementPropertyBool( 'isActive' )
                        intrf.p_ElementProperties.setElementPropertyBool( 'isActive', false );
                    end
                end
            end
            txn.commit;
        end

        function ClearSelection( modelName, varargin )


            styler = systemcomposer.PortInterfaceStyler.getInstance(  );
            if ( nargin == 1 )


                styler.removeAllStyles( modelName );


                harnessInfo = Simulink.harness.internal.getActiveHarness( modelName );
                if ~isempty( harnessInfo )
                    styler.removeAllStyles( harnessInfo.name );
                end
            elseif ( ( nargin == 2 ) )
                interfaceStorageContext = varargin{ 1 };
                if ( strcmp( interfaceStorageContext, 'Model' ) )
                    styler.removeAllStyles( modelName );
                else
                    bdH = get_param( systemcomposer.InterfaceEditor.getActiveBD(  ), 'handle' );
                    if ( ~isempty( bdH ) )
                        styler.removeAllStyles( bdH );
                    end
                end
            end
        end

        function HiliteInterfaceForPort( modelName, portObj )

            dd = get_param( modelName, 'DataDictionary' );
            if isempty( dd )
                storageContext = 'Model';
                uriName = modelName;
            else
                storageContext = 'Dictionary';
                uriName = dd;
            end

            systemcomposer.InterfaceEditor.ExecuteAction( uriName, storageContext, 'clearHilite', 'ignored' );
            if isa( portObj, 'systemcomposer.architecture.model.design.Port' )
                intrf = getPortInterface( portObj );
                if ~isempty( intrf )
                    systemcomposer.InterfaceEditor.ExecuteAction( uriName, storageContext, 'hiliteInterface', intrf.UUID );
                end
            end
        end

        function OpenPropertyInspector( modelOrDDName, interfaceCatalogStorageContext, studioTag, selectedObjUUID, parentObjUUID, bringToFront, varargin )

            if nargin < 7
                clearSelection = true;
                functionElemUUID =  - 1;
            elseif nargin < 8
                clearSelection = varargin{ 1 };
                functionElemUUID =  - 1;
            else
                clearSelection = varargin{ 1 };
                functionElemUUID = varargin{ 2 };
            end

            interface = [  ];
            if ~isempty( studioTag )
                activeStudio = DAS.Studio.getStudio( studioTag );
                mf0Model = get_param( activeStudio.App.blockDiagramHandle, 'SystemComposerMF0Model' );
                selectedObj = mf0Model.findElement( selectedObjUUID );
                if isa( selectedObj, 'systemcomposer.architecture.model.interface.InterfaceElement' )
                    interface = selectedObj.getInterface;
                end
            elseif ( systemcomposer.InterfaceEditor.TranslateContext( interfaceCatalogStorageContext ) == systemcomposer.architecture.model.interface.Context.MODEL )
                bdH = get_param( modelOrDDName, 'handle' );
                app = Simulink.SystemArchitecture.internal.ApplicationManager.getAppMgrFromBDHandle( bdH );
                mf0Model = app.getCompositionArchitectureModel;
                selectedObj = mf0Model.findElement( selectedObjUUID );
                if parentObjUUID ~=  - 1
                    interface = systemcomposer.InterfaceEditor.getInterfaceFromParent( mf0Model, selectedObj, parentObjUUID );
                elseif isa( selectedObj, 'systemcomposer.architecture.model.interface.InterfaceElement' )
                    interface = selectedObj.getInterface(  );
                elseif isa( selectedObj, 'systemcomposer.architecture.model.swarch.FunctionArgument' )
                    interface = selectedObj.getFunctionElement(  ).getInterface(  );
                end
            else
                ddConn = systemcomposer.internal.openSimulinkDataDictionary( modelOrDDName );
                mf0Model = Simulink.SystemArchitecture.internal.DictionaryRegistry.FetchInterfaceSemanticModel( ddConn.filepath(  ) );
                selectedObj = mf0Model.findElement( selectedObjUUID );
                if isempty( selectedObj ) && isequal( parentObjUUID,  - 1 )


                    pic = systemcomposer.architecture.model.interface.InterfaceCatalog.getInterfaceCatalog( mf0Model );
                    selectedObj = pic.getPortInterfaceInClosureByUUID( '', selectedObjUUID );
                elseif isempty( selectedObj ) && ~isequal( parentObjUUID,  - 1 )

                    pic = systemcomposer.architecture.model.interface.InterfaceCatalog.getInterfaceCatalog( mf0Model );
                    interface = pic.getPortInterfaceInClosureByUUID( '', parentObjUUID );
                    if functionElemUUID ~=  - 1
                        functionElem = interface.getElementByUUID( functionElemUUID );
                        selectedObj = functionElem.getFunctionArgumentByUUID( selectedObjUUID );
                    else
                        selectedObj = interface.getElementByUUID( selectedObjUUID );
                    end
                elseif ~isequal( parentObjUUID,  - 1 )
                    interface = systemcomposer.InterfaceEditor.getInterfaceFromParent( mf0Model, selectedObj, parentObjUUID );
                elseif isa( selectedObj, 'systemcomposer.architecture.model.interface.InterfaceElement' )
                    interface = selectedObj.getInterface(  );
                elseif isa( selectedObj, 'systemcomposer.architecture.model.swarch.FunctionArgument' )
                    interface = selectedObj.getFunctionElement(  ).getInterface(  );
                end
            end

            if isempty( selectedObj ) ||  ...
                    ( isequal( class( selectedObj ), 'systemcomposer.architecture.model.interface.InterfaceElement' ) &&  ...
                    isempty( interface ) )



                return ;
            end

            ueEditors = GLUE2.Util.findAllEditors( gcs );
            for i = 1:length( ueEditors )
                if clearSelection
                    ueEditors( i ).clearSelection(  );
                end
                ueStudio = ueEditors( i ).getStudio;
                pi = ueStudio.getComponent( 'GLUE2:PropertyInspector', 'Property Inspector' );
                switch class( selectedObj )
                    case { 'systemcomposer.architecture.model.interface.PortInterface', 'systemcomposer.architecture.model.interface.CompositeDataInterface',  ...
                            'systemcomposer.architecture.model.interface.ValueTypeInterface', 'systemcomposer.architecture.model.interface.CompositePhysicalInterface',  ...
                            'systemcomposer.architecture.model.interface.AtomicPhysicalInterface', 'systemcomposer.architecture.model.swarch.ServiceInterface' }
                        elementSchema = systemcomposer.internal.arch.internal.propertyinspector.SysarchInterfacePropertySchema(  ...
                            selectedObj, ueEditors( i ).blockDiagramHandle );
                    case { 'systemcomposer.architecture.model.interface.InterfaceElement', 'systemcomposer.architecture.model.interface.DataElement',  ...
                            'systemcomposer.architecture.model.interface.PhysicalElement' }
                        elementSchema = systemcomposer.InterfaceElementSchema( selectedObj, interface, mf0Model );
                    case { 'systemcomposer.architecture.model.swarch.FunctionElement' }
                        elementSchema = systemcomposer.FunctionElementSchema( selectedObj, interface, mf0Model );
                    case { 'systemcomposer.architecture.model.swarch.FunctionArgument' }
                        elementSchema = systemcomposer.FunctionArgumentSchema( selectedObj, interface, mf0Model );
                    case { 'systemcomposer.architecture.model.design.ArchitecturePort', 'systemcomposer.architecture.model.design.ComponentPort' }
                        if isa( selectedObj, 'systemcomposer.architecture.model.design.ComponentPort' )
                            slPort = systemcomposer.utils.getSimulinkPeer( selectedObj.getArchitecturePort );
                        else
                            slPort = systemcomposer.utils.getSimulinkPeer( selectedObj );
                        end
                        if ( bringToFront )
                            ueStudio.showComponent( pi );
                        end
                        pi.updateSource( selectedObj.getName(  ), get_param( slPort( 1 ), 'Object' ) );
                        systemcomposer.internal.arch.internal.propertyinspector.SysarchPropertySchema.refresh( slPort( 1 ) );
                        return ;
                end

                if ( bringToFront )
                    ueStudio.showComponent( pi );
                end

                if exist( 'elementSchema', 'var' )

                    pi.updateSource( selectedObj.getName(  ), elementSchema );
                end
            end
        end

        function NotifyPropertyInspectorOfElementDeletion( modelOrDDName, interfaceCatalogStorageContext )
            bdName = modelOrDDName;
            if systemcomposer.InterfaceEditor.isDictionaryContext( interfaceCatalogStorageContext )
                bdName = systemcomposer.InterfaceEditor.getActiveBD(  );
            end
            allStudios = DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
            for idx = 1:numel( allStudios )
                if strcmp( get_param( allStudios( idx ).App.blockDiagramHandle, 'Name' ), bdName )
                    pi = allStudios( idx ).getComponent( 'GLUE2:PropertyInspector', 'Property Inspector' );
                    if ( ~isempty( pi ) && pi.isVisible(  ) )
                        pi.updateSource( systemcomposer.InterfaceEditor.getActiveBD(  ),  ...
                            get_param( systemcomposer.InterfaceEditor.getActiveBD(  ), 'Object' ) );
                    end
                end
            end
        end

        function openDictionaryUI( modelOrDDName, interfaceCatalogStorageContext, contextName )

            assert( strcmpi( interfaceCatalogStorageContext, 'Dictionary' ),  ...
                'Cannot open Dictionary UI when Model-Studio Interface Editor is not in a Dictionary context.' );

            dictFileName = [ modelOrDDName, '.sldd' ];
            archModelName = systemcomposer.InterfaceEditor.getActiveBD(  );
            if Simulink.internal.isArchitectureModel( archModelName, 'AUTOSARArchitecture' )
                interfaceDicts = SLDictAPI.getTransitiveInterfaceDictsForModel( archModelName );
                if ~isempty( interfaceDicts )

                    if ~isempty( contextName )
                        dictName = contextName;
                    else
                        dictName = interfaceDicts{ 1 };
                    end
                    assert( endsWith( dictName, '.sldd' ), '%s is not a valid dictionary name', dictName );
                    if sl.interface.dict.api.isInterfaceDictionary( dictName )
                        interfaceDictAPI = Simulink.interface.dictionary.open( dictName );
                        interfaceDictAPI.show(  );
                    else
                        msgObj = message( 'SystemArchitecture:InterfaceEditor:NotAnInterfaceDictionary', dictName );
                        exception = MSLException( [  ], msgObj );
                        sldiagviewer.reportError( exception );
                    end
                else


                    opensldd( dictFileName );
                end
            else

                opensldd( dictFileName );
            end
        end

        function createInterfaceDictionary( modelOrDDName, interfaceCatalogStorageContext )%#ok
            systemcomposer.InterfaceEditor.createOrLinkInterfaceDictionary( LinkExistingDict = false );
        end

        function linkInterfaceDictionary( modelOrDDName, interfaceCatalogStorageContext )%#ok
            systemcomposer.InterfaceEditor.createOrLinkInterfaceDictionary( LinkExistingDict = true );
        end

        function createOrLinkInterfaceDictionary( namedArgs )



            arguments
                namedArgs.LinkExistingDict = false;
            end

            contextModelName = systemcomposer.InterfaceEditor.getActiveBD(  );
            assert( Simulink.internal.isArchitectureModel( contextModelName, 'AUTOSARArchitecture' ),  ...
                'Should not try to create or link an Interface Dictionary for non-AUTOSAR models' );
            assert( ~Simulink.interface.dictionary.internal.DictionaryClosureUtils.isModelLinkedToInterfaceDict( contextModelName ),  ...
                'Model should not be linked to an Interface Dictionary.' )


            allStudios = DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
            studio = allStudios( 1 );
            cbinfo = struct;
            cbinfo.model = get_param( contextModelName, 'Object' );
            cbinfo.studio = studio;

            autosar.ui.toolstrip.callback.interfaceEditorCB( cbinfo,  ...
                InitFromModelStudio = true, LinkExistingDict = namedArgs.LinkExistingDict );
        end

        function saveInterfaces( modelOrDDName, interfaceCatalogStorageContext )
            if ( systemcomposer.InterfaceEditor.TranslateContext( interfaceCatalogStorageContext ) == systemcomposer.architecture.model.interface.Context.MODEL )
                save_system( modelOrDDName );
            else
                ddConn = systemcomposer.internal.openSimulinkDataDictionary( modelOrDDName );
                ddConn.saveChanges(  );
            end
        end

        function saveInterfacesToNewDD( varargin )
            modelOrDDName = varargin{ 1 };
            interfaceCatalogStorageContext = varargin{ 2 };
            if ( nargin >= 3 )
                srcEditingContext = varargin{ 3 };
            else
                srcEditingContext = systemcomposer.InterfaceEditor.getActiveBD(  );
            end
            if ( nargin == 4 )
                newDDName = varargin{ 4 };
            else
                newDDName = '';
            end

            diagnosticViewerStage = sldiagviewer.createStage( message( 'SystemArchitecture:Interfaces:SaveToDD' ).getString(  ), 'ModelName', srcEditingContext );%#ok

            if ( isempty( newDDName ) )
                [ ddFile, ddFilePath ] = uiputfile( '*.sldd', DAStudio.message( 'SystemArchitecture:Interfaces:SaveNewDD' ) );



                ddFilePath = ddFilePath( 1:end  - 1 );

                if ( ~isequal( ddFile, 0 ) )

                    pathCell = regexp( path, pathsep, 'split' );
                    onPath = any( strcmpi( ddFilePath, pathCell ) );
                    if ( ~onPath && ~strcmpi( ddFilePath, pwd ) )
                        msgObj = message( 'SystemArchitecture:Interfaces:SaveDictionaryNotOnPath', ddFile );
                        exception = MSLException( [  ], msgObj );
                        sldiagviewer.reportError( exception );
                        return ;
                    end

                    ddFullFilePath = fullfile( ddFilePath, ddFile );
                    if exist( ddFullFilePath, 'file' )
                        try
                            Simulink.dd.delete( ddFullFilePath );
                        catch ME
                            msgObj = message( 'SLDD:sldd:DeleteOpenDictionaryError' );
                            exception = MSLException( [  ], msgObj );
                            sldiagviewer.reportError( exception );
                            rethrow( ME );
                        end
                    end
                    ddConn = Simulink.data.dictionary.create( fullfile( ddFilePath, ddFile ) );
                    newDDFullName = ddConn.filepath(  );
                else
                    return ;
                end
            else
                ddConn = Simulink.data.dictionary.create( newDDName );
                newDDFullName = ddConn.filepath(  );
            end

            if systemcomposer.InterfaceEditor.isDictionaryContext( interfaceCatalogStorageContext )
                srcDDConn = systemcomposer.internal.openSimulinkDataDictionary( modelOrDDName );
                modelOrDDName = srcDDConn.filepath(  );
            end


            pb = systemcomposer.internal.ProgressBar(  ...
                DAStudio.message( 'SystemArchitecture:studio:PleaseWait' ),  ...
                systemcomposer.InterfaceEditor.getActiveBD(  ) );
            try
                pb.setStatus( DAStudio.message( 'SystemArchitecture:studio:Saving' ) );
                dstModel = Simulink.SystemArchitecture.internal.DictionaryRegistry.FetchInterfaceSemanticModel( newDDFullName );
                assert( ~isempty( dstModel ) );


                deactivator = systemcomposer.internal.InterfaceListenerDeactivator( newDDFullName );

                if ( systemcomposer.InterfaceEditor.TranslateContext( interfaceCatalogStorageContext ) == systemcomposer.architecture.model.interface.Context.MODEL )

                    bdH = get_param( modelOrDDName, 'Handle' );
                    Simulink.SystemArchitecture.internal.ApplicationManager.setEnableStateModelWorkspaceListener( bdH, false );

                    zcModelImpl = systemcomposer.loadModel( modelOrDDName ).getImpl;
                    srcPICatalog = zcModelImpl.getPortInterfaceCatalog(  );
                    dstPICatalog = systemcomposer.architecture.model.interface.InterfaceCatalog.getInterfaceCatalog( dstModel );
                    status = systemcomposer.internal.SLDataMover.MovePortInterfaces( srcPICatalog, dstPICatalog );


                    if ~status
                        Simulink.SystemArchitecture.internal.ApplicationManager.setEnableStateModelWorkspaceListener( bdH, true );
                    end
                end

                delete( deactivator );


                set_param( modelOrDDName, 'DataDictionary', [ dstPICatalog.getStorageSource, '.sldd' ] );
            catch ex
                sldiagviewer.reportError( ex );
            end
            ddConn.saveChanges;
            pb.setStatus( DAStudio.message( 'SystemArchitecture:studio:Complete' ) );
        end

        function saveInterfacesToExistingDD( varargin )
            modelOrDDName = varargin{ 1 };
            interfaceCatalogStorageContext = varargin{ 2 };
            if ( nargin >= 3 )
                srcEditingContext = varargin{ 3 };
            else
                srcEditingContext = systemcomposer.InterfaceEditor.getActiveBD(  );
            end
            if ( nargin >= 4 )
                newDDName = varargin{ 4 };
            else
                newDDName = '';
            end
            if ( nargin == 5 )
                interfaceCollisionResolution = varargin{ 5 };
            else
                interfaceCollisionResolution = systemcomposer.architecture.model.interface.CollisionResolution.UNSPECIFIED;
            end

            if ( isempty( newDDName ) )
                [ ddFile, ddFilePath ] = uigetfile( '*.sldd', DAStudio.message( 'SystemArchitecture:Interfaces:LinkExistingDD' ) );
                if ( ~isequal( ddFile, 0 ) )
                    ddConn = Simulink.data.dictionary.open( fullfile( ddFilePath, ddFile ) );
                    newDDFullName = ddConn.filepath(  );
                else
                    return ;
                end
            else
                ddConn = Simulink.data.dictionary.open( newDDName );
                newDDFullName = ddConn.filepath(  );
            end

            if systemcomposer.InterfaceEditor.isDictionaryContext( interfaceCatalogStorageContext )
                srcDDConn = Simulink.data.dictionary.open( [ modelOrDDName, '.sldd' ] );
                modelOrDDName = srcDDConn.filepath(  );
            end


            hasActiveBD = ~isempty( systemcomposer.InterfaceEditor.getActiveBD(  ) );
            if hasActiveBD

                pb = systemcomposer.internal.ProgressBar(  ...
                    DAStudio.message( 'SystemArchitecture:studio:PleaseWait' ),  ...
                    systemcomposer.InterfaceEditor.getActiveBD(  ) );
            end

            isModelContext = systemcomposer.InterfaceEditor.TranslateContext( interfaceCatalogStorageContext ) == systemcomposer.architecture.model.interface.Context.MODEL;
            isAUTOSARArchModel = isModelContext && Simulink.internal.isArchitectureModel( modelOrDDName, 'AUTOSARArchitecture' );

            diagnosticViewerStage = sldiagviewer.createStage( message( 'SystemArchitecture:Interfaces:SaveToDD' ).getString(  ), 'ModelName', srcEditingContext );%#ok
            try
                if hasActiveBD
                    pb.setStatus( DAStudio.message( 'SystemArchitecture:studio:Saving' ) );
                end

                dstModel = Simulink.SystemArchitecture.internal.DictionaryRegistry.FetchInterfaceSemanticModel( newDDFullName );

                assert( ~isempty( dstModel ) );


                deactivator = systemcomposer.internal.InterfaceListenerDeactivator( newDDFullName );



                if isModelContext && ~isAUTOSARArchModel

                    bdH = get_param( modelOrDDName, 'Handle' );
                    Simulink.SystemArchitecture.internal.ApplicationManager.setEnableStateModelWorkspaceListener( bdH, false );

                    zcModelImpl = systemcomposer.loadModel( modelOrDDName ).getImpl;
                    srcPICatalog = zcModelImpl.getPortInterfaceCatalog(  );
                    dstPICatalog = systemcomposer.architecture.model.interface.InterfaceCatalog.getInterfaceCatalog( dstModel );
                    status = systemcomposer.internal.SLDataMover.MovePortInterfaces( srcPICatalog, dstPICatalog, interfaceCollisionResolution );


                    if ~status
                        Simulink.SystemArchitecture.internal.ApplicationManager.setEnableStateModelWorkspaceListener( bdH, true );
                    end
                end

                delete( deactivator );
                ddConn.saveChanges;


                [ ~, dictName, ext ] = fileparts( ddConn.filepath );
                set_param( modelOrDDName, 'DataDictionary', [ dictName, ext ] );

                if hasActiveBD
                    pb.setStatus( DAStudio.message( 'SystemArchitecture:studio:Complete' ) );
                end
            catch ex
                sldiagviewer.reportError( ex );
            end
        end

        function importFromBaseWS( modelOrDDName, interfaceCatalogStorageContext )
            if ( systemcomposer.InterfaceEditor.TranslateContext( interfaceCatalogStorageContext ) == systemcomposer.architecture.model.interface.Context.MODEL )
                bdH = get_param( modelOrDDName, 'handle' );
                app = Simulink.SystemArchitecture.internal.ApplicationManager.getAppMgrFromBDHandle( bdH );
                mf0Model = app.getCompositionArchitectureModel;
                sourceForErrorReporting = modelOrDDName;
                inModelStorage = true;
            else
                ddConn = systemcomposer.internal.openSimulinkDataDictionary( modelOrDDName );
                mf0Model = Simulink.SystemArchitecture.internal.DictionaryRegistry.FetchInterfaceSemanticModel( ddConn.filepath(  ) );
                sourceForErrorReporting = [ modelOrDDName, '.sldd' ];
                inModelStorage = false;

                if sl.interface.dict.api.isInterfaceDictionary( ddConn.filepath(  ) )
                    systemcomposer.InterfaceEditor.errorOutForOperationOnInterfaceDict( 'importFromBaseWS' );
                    return
                end
            end


            piCatalog = systemcomposer.architecture.model.interface.InterfaceCatalog.getInterfaceCatalog( mf0Model );
            piNames = piCatalog.getPortInterfaceNames(  );
            piNames = sort( piNames );


            baseWSVars = evalin( 'base', 'whos' );
            varNamesToImport = {  };
            for i = 1:length( baseWSVars )
                if ( strcmp( baseWSVars( i ).class, 'Simulink.Bus' ) || any( ismember( superclasses( baseWSVars( i ).class ), 'Simulink.Bus' ) ) )
                    varNamesToImport{ end  + 1 } = baseWSVars( i ).name;%#ok
                end
            end
            varNamesToImport = sort( varNamesToImport );


            varNamesToImport_NoCollisions = varNamesToImport;
            if ( ~isempty( piNames ) && ~isempty( varNamesToImport ) )
                varNamesToImport_Collisions = intersect( piNames, varNamesToImport );
                varNamesToImport_NoCollisions = setdiff( varNamesToImport, varNamesToImport_Collisions );

                if ( ~isempty( varNamesToImport_Collisions ) )
                    errID = 'SystemArchitecture:Interfaces:ImportFromBaseWSIncomplete';
                    errMsg = message( errID, sourceForErrorReporting );
                    baseException = MSLException( [  ], errMsg );

                    for i = 1:length( varNamesToImport_Collisions )
                        causeID = 'SystemArchitecture:Interfaces:InterfaceCollision';
                        causeException = MSLException( [  ], message( causeID, sourceForErrorReporting, varNamesToImport_Collisions{ i } ) );
                        baseException = addCause( baseException, causeException );
                    end

                    diagnosticViewerStage = sldiagviewer.createStage( message( 'SystemArchitecture:Interfaces:ImportFromBaseWS' ).getString(  ), 'ModelName', systemcomposer.InterfaceEditor.getActiveBD(  ) );
                    sldiagviewer.reportWarning( baseException );
                    diagnosticViewerStage.delete;
                end
            end


            for i = 1:length( varNamesToImport_NoCollisions )
                boName = varNamesToImport_NoCollisions{ i };
                bo = evalin( 'base', boName );
                systemcomposer.BusObjectManager.AddInterface( modelOrDDName, inModelStorage, boName, bo );
            end
        end

        function importFromMATFile( varargin )
            try
                modelOrDDName = varargin{ 1 };
                interfaceCatalogStorageContext = varargin{ 2 };

                if ( nargin == 3 )
                    matFile = varargin{ 3 };
                else
                    matFile = '';
                end

                if ( systemcomposer.InterfaceEditor.TranslateContext( interfaceCatalogStorageContext ) == systemcomposer.architecture.model.interface.Context.MODEL )
                    bdH = get_param( modelOrDDName, 'handle' );
                    app = Simulink.SystemArchitecture.internal.ApplicationManager.getAppMgrFromBDHandle( bdH );
                    mf0Model = app.getCompositionArchitectureModel;
                    sourceForErrorReporting = modelOrDDName;
                    inModelStorage = true;
                else
                    ddConn = systemcomposer.internal.openSimulinkDataDictionary( modelOrDDName );
                    mf0Model = Simulink.SystemArchitecture.internal.DictionaryRegistry.FetchInterfaceSemanticModel( ddConn.filepath(  ) );
                    sourceForErrorReporting = [ modelOrDDName, '.sldd' ];
                    inModelStorage = false;

                    if sl.interface.dict.api.isInterfaceDictionary( ddConn.filepath(  ) )
                        systemcomposer.InterfaceEditor.errorOutForOperationOnInterfaceDict( 'importFromMATFile' );
                        return
                    end
                end


                piCatalog = systemcomposer.architecture.model.interface.InterfaceCatalog.getInterfaceCatalog( mf0Model );
                piNames = piCatalog.getPortInterfaceNames(  );
                piNames = sort( piNames );


                if ( isempty( matFile ) )
                    [ matFile, matFilePath ] = uigetfile( '*.mat', DAStudio.message( 'SystemArchitecture:Interfaces:SelectMATFile' ) );
                    if ( isequal( matFile, 0 ) )
                        return ;
                    end
                    matFileFullName = fullfile( matFilePath, matFile );
                else
                    matFileFullName = which( matFile );
                end


                matFileVarNames = whos( '-file', matFileFullName );
                matFileVarNamesToImport = {  };
                for i = 1:length( matFileVarNames )
                    if ( strcmp( matFileVarNames( i ).class, 'Simulink.Bus' ) || any( ismember( superclasses( matFileVarNames( i ).class ), 'Simulink.Bus' ) ) )
                        matFileVarNamesToImport{ end  + 1 } = matFileVarNames( i ).name;%#ok
                    end
                end
                matFileVarNamesToImport = sort( matFileVarNamesToImport );


                matFileVarNamesToImport_NoCollisions = matFileVarNamesToImport;
                if ( ~isempty( piNames ) && ~isempty( matFileVarNamesToImport ) )
                    matFileVarNamesToImport_Collisions = intersect( piNames, matFileVarNamesToImport );
                    matFileVarNamesToImport_NoCollisions = setdiff( matFileVarNamesToImport, matFileVarNamesToImport_Collisions );

                    if ( ~isempty( matFileVarNamesToImport_Collisions ) )
                        errID = 'SystemArchitecture:Interfaces:ImportFromMATFileIncomplete';
                        errMsg = message( errID, matFileFullName, sourceForErrorReporting );
                        baseException = MSLException( [  ], errMsg );

                        for i = 1:length( matFileVarNamesToImport_Collisions )
                            causeID = 'SystemArchitecture:Interfaces:InterfaceCollision';
                            causeException = MSLException( [  ], message( causeID, sourceForErrorReporting, piNames{ i } ) );
                            baseException = addCause( baseException, causeException );
                        end

                        diagnosticViewerStage = sldiagviewer.createStage( message( 'SystemArchitecture:Interfaces:ImportFromMATFile' ).getString(  ), 'ModelName', systemcomposer.InterfaceEditor.getActiveBD(  ) );
                        sldiagviewer.reportWarning( baseException );
                        diagnosticViewerStage.delete;
                    end
                end


                if ( isempty( matFileVarNamesToImport_NoCollisions ) )
                    return
                end
                matFileVarsStruct = load( matFileFullName, matFileVarNamesToImport_NoCollisions{ : } );
                matFileVarsStructFieldNames = fieldnames( matFileVarsStruct );


                for i = 1:length( matFileVarsStructFieldNames )
                    boName = matFileVarsStructFieldNames{ i };
                    bo = getfield( matFileVarsStruct, boName );%#ok<GFLD>
                    systemcomposer.BusObjectManager.AddInterface( modelOrDDName, inModelStorage, boName, bo );
                end
            catch
                error( message( 'SystemArchitecture:InterfaceEditor:ImportFromMATFile' ) );
            end
        end

        function linkToDD( varargin )
            modelName = varargin{ 1 };
            interfaceCatalogStorageContext = varargin{ 2 };
            if ( nargin == 3 )
                ddName = varargin{ 3 };
            else
                ddName = '';
            end

            if ( systemcomposer.InterfaceEditor.TranslateContext( interfaceCatalogStorageContext ) == systemcomposer.architecture.model.interface.Context.MODEL )
                bdH = get_param( modelName, 'handle' );

                app = Simulink.SystemArchitecture.internal.ApplicationManager.getAppMgrFromBDHandle( bdH );
                mf0Model = app.getCompositionArchitectureModel;
                piCatalog = systemcomposer.architecture.model.interface.InterfaceCatalog.getInterfaceCatalog( mf0Model );
                piNames = piCatalog.getPortInterfaceNames(  );

                if ( ~isempty( piNames ) )
                    errID = 'SystemArchitecture:Interfaces:LinkToDDFailed';
                    errMsg = message( errID, modelName );
                    baseException = MSLException( [  ], errMsg );

                    causeID = 'SystemArchitecture:Interfaces:ModelContainsLocallyDefinedInterfaces';
                    causeException = MSLException( [  ], message( causeID, modelName ) );
                    baseException = addCause( baseException, causeException );

                    diagnosticViewerStage = sldiagviewer.createStage( message( 'SystemArchitecture:Interfaces:LinkToDD' ).getString(  ), 'ModelName', modelName );%#ok
                    sldiagviewer.reportError( baseException );
                    return ;
                end
            else
                bdH = get_param( systemcomposer.InterfaceEditor.getActiveBD(  ), 'handle' );
            end


            try
                if ( isempty( ddName ) )
                    [ ddFile, ddFilePath ] = uigetfile( '*.sldd', DAStudio.message( 'SystemArchitecture:Interfaces:SelectDD' ) );
                    if ( ~isequal( ddFile, 0 ) )
                        ddConn = Simulink.data.dictionary.open( fullfile( ddFilePath, ddFile ) );%#ok
                        set_param( bdH, 'DataDictionary', ddFile );
                    end
                else
                    ddConn = Simulink.data.dictionary.open( ddName );
                    [ ~, ddName, ddExt ] = fileparts( ddConn.filepath(  ) );
                    set_param( bdH, 'DataDictionary', [ ddName, ddExt ] );

                end
            catch ex
                errID = 'SystemArchitecture:Interfaces:LinkToDDFailed';
                errMsg = message( errID, modelName );
                baseException = MSLException( [  ], errMsg );

                baseException = addCause( baseException, ex );
                diagnosticViewerStage = sldiagviewer.createStage( message( 'SystemArchitecture:Interfaces:LinkToDD' ).getString(  ), 'ModelName', modelName );%#ok
                sldiagviewer.reportError( baseException );
            end
        end

        function unlinkDD(  )
            bdH = get_param( systemcomposer.InterfaceEditor.getActiveBD(  ), 'handle' );
            set_param( bdH, 'DataDictionary', '' );
        end

        function addReferenceDD( ddFullName, refdd, collisionResolutionOption )
            if nargin < 3
                collisionResolutionOption = 'Unspecified';
            end
            if ( refdd == "" )
                [ refddFile, refddFilePath ] = uigetfile( '*.sldd', DAStudio.message( 'SystemArchitecture:Interfaces:ReferenceDD' ) );
                if ( isequal( refddFile, 0 ) )
                    return ;
                else
                    refddConn = Simulink.data.dictionary.open( fullfile( refddFilePath, refddFile ) );
                end
            else
                refddConn = Simulink.data.dictionary.open( systemcomposer.InterfaceEditor.getFullDDName( refdd ) );
            end

            Simulink.SystemArchitecture.internal.DictionaryRegistry.FetchInterfaceSemanticModel(  ...
                refddConn.filepath(  ) );

            ddConn = Simulink.data.dictionary.open( systemcomposer.InterfaceEditor.getFullDDName( ddFullName ) );
            [ ~, fname, fext ] = fileparts( refddConn.filepath(  ) );

            conflictingNames =  ...
                Simulink.SystemArchitecture.internal.DictionaryRegistry.GetInterfaceNameCollisionsBetweenDictionaries(  ...
                ddConn.filepath(  ), [ fname, fext ], false );
            if ~isempty( conflictingNames )


                if strcmpi( collisionResolutionOption, 'Prompt' )



                    srcCatalog = systemcomposer.architecture.model.interface.InterfaceCatalog.getInterfaceCatalog( Simulink.SystemArchitecture.internal.DictionaryRegistry.FetchInterfaceSemanticModelFromDDConnection( ddConn ) );
                    refCatalog = systemcomposer.architecture.model.interface.InterfaceCatalog.getInterfaceCatalog( Simulink.SystemArchitecture.internal.DictionaryRegistry.FetchInterfaceSemanticModelFromDDConnection( refddConn ) );
                    collisionOption = systemcomposer.internal.queryInterfaceCollisionResolution( srcCatalog, refCatalog );
                    if collisionOption == systemcomposer.architecture.model.interface.CollisionResolution.UNSPECIFIED
                        return ;
                    elseif collisionOption == systemcomposer.architecture.model.interface.CollisionResolution.REPLACE_DST
                        collisionResolutionOption = 'KeepTop';
                    elseif collisionOption == systemcomposer.architecture.model.interface.CollisionResolution.KEEP_DST
                        collisionResolutionOption = 'KeepReference';
                    end
                end
            end


            data = [  ];
            if ( strcmpi( collisionResolutionOption, 'KeepTop' ) )

                data = refddConn.getSection( 'Design Data' );
            elseif ( strcmpi( collisionResolutionOption, 'KeepReference' ) )

                data = ddConn.getSection( 'Design Data' );
            end
            if ~isempty( data )
                for i = 1:numel( conflictingNames )
                    data.deleteEntry( conflictingNames{ i } );
                end
            end


            addDataSource( ddConn, [ fname, fext ] );

        end

        function removeReferenceDD( ddFullName, refdd )
            refDDFullName = systemcomposer.InterfaceEditor.getFullDDName( refdd );
            ddConn = Simulink.data.dictionary.open(  ...
                systemcomposer.InterfaceEditor.getFullDDName( ddFullName ) );



            refddConn = Simulink.data.dictionary.open( refDDFullName );
            Simulink.SystemArchitecture.internal.DictionaryRegistry.FetchInterfaceSemanticModel(  ...
                refddConn.filepath(  ) );


            removeDataSource( ddConn, refDDFullName );

        end

        function importProfile( modelOrDDName, interfaceCatalogStorageContext )

            if systemcomposer.InterfaceEditor.isDictionaryContext( interfaceCatalogStorageContext )
                [ file, path ] = uigetfile( '*.xml' );
                if file == 0
                    return
                end
                [ ~, profileName, ~ ] = fileparts( file );
                filePath = fullfile( path, file );
                ddConn = Simulink.data.dictionary.open( systemcomposer.InterfaceEditor.getFullDDName( modelOrDDName ) );
                mf0Model = Simulink.SystemArchitecture.internal.DictionaryRegistry.FetchInterfaceSemanticModel( ddConn.filepath(  ) );
                zcModel = systemcomposer.architecture.model.SystemComposerModel.getSystemComposerModel( mf0Model );
                piCatalog = zcModel.getPortInterfaceCatalog;
                if isempty( piCatalog.getProfile( profileName ) )
                    piCatalog.addProfile( filePath );
                else

                    errID = 'SystemArchitecture:Interfaces:ProfileAlreadyImported';
                    errMsg = message( errID, profileName );
                    baseException = MSLException( [  ], errMsg );
                    diagnosticViewerStage = sldiagviewer.createStage(  ...
                        message( 'SystemArchitecture:Interfaces:ImportProfile' ).getString(  ),  ...
                        'ModelName', systemcomposer.InterfaceEditor.getActiveBD(  ) );
                    sldiagviewer.reportWarning( baseException );
                    diagnosticViewerStage.delete;
                end
            end
        end

        function removeProfile( modelOrDDName, interfaceCatalogStorageContext, profileName )

            if systemcomposer.InterfaceEditor.isDictionaryContext( interfaceCatalogStorageContext )

                confirm = questdlg(  ...
                    message( 'SystemArchitecture:studio:ConfirmDeleteProfileDictionary', profileName ).string,  ...
                    message( 'SystemArchitecture:studio:ConfirmDeleteProfileTitle' ).string,  ...
                    message( 'SystemArchitecture:studio:ConfirmDeleteProfile_Yes' ).string,  ...
                    message( 'SystemArchitecture:studio:Cancel' ).string,  ...
                    message( 'SystemArchitecture:studio:Help' ).string,  ...
                    message( 'SystemArchitecture:studio:Cancel' ).string );

                if strcmp( confirm, message( 'SystemArchitecture:studio:ConfirmDeleteProfile_Yes' ).string )
                    ddConn = Simulink.data.dictionary.open( systemcomposer.InterfaceEditor.getFullDDName( modelOrDDName ) );
                    mf0Model = Simulink.SystemArchitecture.internal.DictionaryRegistry.FetchInterfaceSemanticModel( ddConn.filepath(  ) );
                    zcModel = systemcomposer.architecture.model.SystemComposerModel.getSystemComposerModel( mf0Model );
                    piCatalog = zcModel.getPortInterfaceCatalog;
                    try
                        piCatalog.removeProfile( profileName );
                    catch
                        error( message( 'SystemArchitecture:InterfaceEditor:RemoveProfileFailed', profileName ) );
                    end
                end
            end
        end

        function openEditorInPortScope(  )
            allStudios = DAS.Studio.getAllStudiosSortedByMostRecentlyActive;

            studio = allStudios( 1 );
            comp = studio.getComponent( 'GLUE2:DDG Component', 'InterfaceEditor' );
            if isempty( comp )

                systemcomposer.createInterfaceEditorComponent( studio, true, true );
            else

                studio.showComponent( comp );
                studio.focusComponent( comp );
            end

            bdH = studio.App.blockDiagramHandle;
            app = Simulink.SystemArchitecture.internal.ApplicationManager.getAppMgrFromBDHandle( bdH );

            editorId = app.getInterfaceEditorId;
            dict = get_param( bdH, 'DataDictionary' );
            name = get_param( bdH, 'Name' );
            if ~isempty( dict )
                [ ~, name, ~ ] = fileparts( dict );
            end

            data.action = 'openPortScope';

            channel = [ '/', name, '/', editorId, '/interfaceEditor' ];
            message.publish( channel, jsonencode( data ) );
        end

        function resetIEToDictionaryScope( bdH )
            app = Simulink.SystemArchitecture.internal.ApplicationManager.getAppMgrFromBDHandle( bdH );

            editorId = app.getInterfaceEditorId;
            dict = get_param( bdH, 'DataDictionary' );
            name = get_param( bdH, 'Name' );
            if ~isempty( dict )
                [ ~, name, ~ ] = fileparts( dict );
            end

            data.action = 'resetToDictionaryScope';

            channel = [ '/', name, '/', editorId, '/interfaceEditor' ];
            message.publish( channel, jsonencode( data ) );
        end

    end

    methods ( Static, Access = public )
        function mf0Model = getMF0Model( bdOrDDName, storageContext )
            inModelStorage = strcmp( storageContext, 'Model' );
            if ( inModelStorage )
                bdH = get_param( bdOrDDName, 'handle' );
                app = Simulink.SystemArchitecture.internal.ApplicationManager.getAppMgrFromBDHandle( bdH );
                mf0Model = app.getCompositionArchitectureModel;
            else
                dd = Simulink.data.dictionary.open( systemcomposer.InterfaceEditor.getFullDDName( bdOrDDName ) );
                mf0Model = Simulink.SystemArchitecture.internal.DictionaryRegistry.FetchInterfaceSemanticModel( dd.filepath(  ) );
            end
        end

        function deliverSaveDictionaryNotification( bdName )


            bdHandle = get_param( bdName, 'Handle' );
            ddName = get_param( bdName, 'DataDictionary' );
            allStudios = DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
            for i = 1:numel( allStudios )
                if ( allStudios( i ).App.blockDiagramHandle == bdHandle )
                    activeEditor = allStudios( i ).App.getActiveEditor(  );
                    if ~isempty( activeEditor )
                        activeEditor.deliverInfoNotification(  ...
                            'SystemArchitecture:Interfaces:SaveDictionaryToPreservePortToInterfaceAssociations',  ...
                            DAStudio.message( 'SystemArchitecture:Interfaces:SaveDictionaryToPreservePortToInterfaceAssociations',  ...
                            ddName, bdName ) );
                    end
                    break ;
                end
            end
        end

        function contextStr = TranslateContextEnumToStr( context )
            contextStr = 'Model';
            if ( context == systemcomposer.architecture.model.interface.Context.DICTIONARY )
                contextStr = 'Dictionary';
            end
        end

        function isDictContext = isDictionaryContext( context )
            context = systemcomposer.InterfaceEditor.TranslateContext( context );
            if ( context == systemcomposer.architecture.model.interface.Context.DICTIONARY )
                isDictContext = true;
            else
                isDictContext = false;
            end
        end

    end

    methods ( Static, Access = public )
        function [ bdName, bdHandle ] = getActiveBD(  )
            allStudios = DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
            bdName = [  ];
            bdHandle = [  ];
            if ( ~isempty( allStudios ) )
                bdHandle = allStudios( 1 ).App.blockDiagramHandle;
                bdName = get_param( bdHandle, 'Name' );
            end
        end


        function newDDName = getFullDDName( ddName )
            [ ~, fName, fExt ] = fileparts( ddName );
            if isempty( fExt )
                fExt = '.sldd';
            end
            newDDName = strcat( fName, fExt );
        end

        function [ open, openDDPath ] = isDictionaryOpen( archModelOrDD )

            open = false;
            openDDPath = [  ];

            openedDDs = Simulink.data.dictionary.getOpenDictionaryPaths(  );
            for idx = 1:numel( openedDDs )
                openDD = openedDDs{ idx };
                [ ~, fName, ~ ] = fileparts( openDD );
                if strcmp( fName, archModelOrDD )
                    open = true;
                    openDDPath = openDD;
                    break ;
                end
            end
        end


        function treeTable = getDictionaryTreeTable( viewModel )
            treeTable = systemcomposer.InterfaceEditor.getTreeTableWithName( viewModel, '' );
        end

        function treeTable = getTreeTableWithName( viewModel, name )
            treeTable = systemcomposer.syntax.matrix.TreeTable.empty(  );
            tle = viewModel.topLevelElements;
            for i = 1:numel( tle )
                if isa( tle( i ), 'systemcomposer.syntax.matrix.TreeTable' ) && strcmp( tle( i ).p_Name, name )
                    treeTable = tle( i );
                    return ;
                end
            end
        end
    end

    methods ( Static, Access = private )
        function context = TranslateContext( contextStr )
            switch contextStr
                case 'Model'
                    context = systemcomposer.architecture.model.interface.Context.MODEL;
                case 'Dictionary'
                    context = systemcomposer.architecture.model.interface.Context.DICTIONARY;
                otherwise
                    assert( false, 'Unexpected context string for Model-Studio Interface Editor.' );
            end
        end

        function errorOutForOperationOnInterfaceDict( operationName )
            diagnosticViewerStage = sldiagviewer.createStage(  ...
                message( 'SystemArchitecture:Interfaces:ImportFromBaseWS' ).getString(  ),  ...
                'ModelName', systemcomposer.InterfaceEditor.getActiveBD(  ) );
            msgObj = message( 'SLDD:sldd:NotAllowedOnInterfaceDictionary', operationName );
            exception = MSLException( [  ], msgObj );
            sldiagviewer.reportError( exception );
            diagnosticViewerStage.delete;
        end




        function interface = getInterfaceFromParent( mf0Model, selectedObj, parentObjUUID )
            parentElement = mf0Model.findElement( parentObjUUID );
            if isa( parentElement, 'systemcomposer.architecture.model.interface.InterfaceElement' )


                assert( isa( selectedObj, 'systemcomposer.architecture.model.interface.InterfaceElement' ) );
                interface = selectedObj.getInterface(  );
            else
                interface = parentElement;
            end
        end

        function tf = getDefaultLockState( modelName )
            tf = false;
            if strcmp( get_param( modelName, 'Lock' ), 'on' ) || strcmp( get_param( modelName, 'isHarness' ), 'on' )


                tf = true;
            end
        end
    end

    methods ( Access = private )
        function flag = isInModelStorageContext( obj )
            if ( obj.interfaceStorageContext == systemcomposer.architecture.model.interface.Context.MODEL )
                flag = true;
            else
                flag = false;
            end
        end

        function updateLastUrl( obj )
            if isKey( obj.connectionMap, systemcomposer.InterfaceEditor.LAST_URL_CONNECTIONMAP_KEY )
                remove( obj.connectionMap, systemcomposer.InterfaceEditor.LAST_URL_CONNECTIONMAP_KEY );
            end
            obj.createUrl( systemcomposer.InterfaceEditor.LAST_URL_CONNECTIONMAP_KEY );
            connectionEntry = obj.connectionMap( systemcomposer.InterfaceEditor.LAST_URL_CONNECTIONMAP_KEY );
            systemcomposer.InterfaceEditor.LastUrl( connectionEntry.viewModelConnectorUrl );
        end

        function resetLastUrl( obj )
            if isKey( obj.connectionMap, systemcomposer.InterfaceEditor.LAST_URL_CONNECTIONMAP_KEY )
                remove( obj.connectionMap, systemcomposer.InterfaceEditor.LAST_URL_CONNECTIONMAP_KEY );
            end
            systemcomposer.InterfaceEditor.LastUrl( '' );
        end
    end

end


