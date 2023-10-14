classdef ( Sealed )Configuration < coderapp.internal.mfz.BackedByMfzModel & coderapp.internal.undo.StateOwner & coderapp.internal.log.HierarchyLoggable

    events ( NotifyAccess = private )
        ConfigurationChanged
    end

    events ( NotifyAccess = ?coderapp.internal.config.runtime.ConfigStoreAdapter )
        DirtyStateChanged
    end

    properties ( SetAccess = immutable, Transient )
        Schema coderapp.internal.config.Schema = coderapp.internal.config.Schema.empty
        Services( 1, 1 )struct = struct
        AssertServiceBindings( 1, 1 )logical = true
        ResolveMessages( 1, 1 )logical = true
    end

    properties
        UndoRedoTransparent( 1, 1 )logical = false
    end

    properties ( Hidden )
        Debug( 1, 1 )logical = false
        TrackedScriptDeltaKeys{ mustBeText( TrackedScriptDeltaKeys ) } = {  }
    end

    properties ( Dependent, SetAccess = immutable )
        ActivePerspective char
    end

    properties ( Hidden, SetAccess = private, Transient )
        SchemaData coderapp.internal.config.schema.SchemaData
        State coderapp.internal.config.runtime.ConfigurationState
        ConfigStore coderapp.internal.ext.ConfigStore
    end

    properties ( GetAccess = { ?coderapp.internal.config.Configuration, ?coderapp.internal.config.runtime.NodeAdapter,  ...
            ?coderapp.internal.config.runtime.ConfigStoreAdapter }, SetAccess = immutable, Transient )
        TypeManager coderapp.internal.config.ParamTypeManager
        ConfigStoreAdapter coderapp.internal.config.runtime.ConfigStoreAdapter
        ControllersByKey containers.Map
        ParamAdapters coderapp.internal.config.runtime.ParamNodeAdapter
        ScriptOptions( 1, 1 )struct = struct
        MfzExposeProductions( 1, 1 )logical = false
    end

    properties ( GetAccess = { ?coderapp.internal.config.Configuration, ?coderapp.internal.config.runtime.NodeAdapter },  ...
            SetAccess = immutable, Dependent )
        RuntimeModel mf.zero.Model
    end

    properties ( Access = private, Transient )
        PerspectiveAdapters coderapp.internal.config.runtime.PerspectiveAdapter
        UpdateVisibility logical = false
        InvalidateHistory logical = false
        PendingChanged
        FrozenPendingChanged
        ValueChangeRecords
    end

    properties ( GetAccess = private, SetAccess = immutable, Transient )
        Graph digraph = digraph(  )
        GraphNodes coderapp.internal.config.runtime.ReferableNodeAdapter
        NodeCount double
        DepMatrix logical
        TransDepMatrix logical
        TagAdapters coderapp.internal.config.runtime.TagNodeAdapter
        LayoutNodes coderapp.internal.config.runtime.ControllableNodeAdapter
        LayoutRoots coderapp.internal.config.runtime.ControllableNodeAdapter
        CategoryAdapters coderapp.internal.config.runtime.CategoryNodeAdapter
        PreInitTarget coderapp.internal.config.schema.SchemaData
        PreInitKeys = {  }
        UpgradeHandlers
        ParamLogger coderapp.internal.log.Logger = coderapp.internal.log.DummyLogger.empty(  )
        CategoryLogger coderapp.internal.log.Logger = coderapp.internal.log.DummyLogger.empty(  )
        ProductionLogger coderapp.internal.log.Logger = coderapp.internal.log.DummyLogger.empty(  )
        ServiceLogger coderapp.internal.log.Logger = coderapp.internal.log.DummyLogger.empty(  )
    end

    properties ( Dependent, Hidden, SetAccess = immutable )
        IsProcessing logical
        Keys cell
    end

    properties ( GetAccess = { ?coderapp.internal.config.Configuration,  ...
            ?coderapp.internal.config.runtime.NodeAdapter }, SetAccess = private )
        ImportOptions struct
    end

    properties ( Dependent, GetAccess = private, SetAccess = immutable )
        InternalAdapters coderapp.internal.config.runtime.InternalNodeAdapter
        AllAdapters coderapp.internal.config.runtime.NodeAdapter
    end

    methods
        function this = Configuration( schema, opts )
            arguments
                schema{ mustBeA( schema, [ "coderapp.internal.config.Schema", "char", "string" ] ) }
                opts.Debug( 1, 1 ){ mustBeNumericOrLogical( opts.Debug ) } = false
                opts.Services( 1, 1 )struct = struct(  )
                opts.LoadFrom{ mustBeA( opts.LoadFrom, [ "char", "string", "coderapp.internal.ext.ConfigStore" ] ) } = ''
                opts.AssertServiceBindings( 1, 1 ){ mustBeNumericOrLogical( opts.AssertServiceBindings ) } = false
                opts.Parent{ mustBeScalarOrEmpty( opts.Parent ) } = [  ]
                opts.ResolveMessages( 1, 1 ){ mustBeNumericOrLogical( opts.ResolveMessages ) } = true
                opts.ScriptOptions cell = {  }
                opts.TrackedScriptDeltas{ mustBeText( opts.TrackedScriptDeltas ) } = {  }
                opts.MfzExposeProductions( 1, 1 ){ mustBeNumericOrLogical( opts.MfzExposeProductions ) } = false
                opts.PreInitTarget coderapp.internal.config.schema.SchemaData{ mustBeScalarOrEmpty( opts.PreInitTarget ) } =  ...
                    coderapp.internal.config.schema.SchemaData.empty.empty
                opts.PreInitKeys{ mustBeText( opts.PreInitKeys ) } = {  }
                opts.EnableLogging logical{ mustBeScalarOrEmpty( opts.EnableLogging ) } = [  ]
            end

            this@coderapp.internal.log.HierarchyLoggable( 'config', Parent = opts.Parent, EnableLogging = opts.EnableLogging );
            this.ParamLogger = this.Logger.create( 'params' );
            this.CategoryLogger = this.Logger.create( 'categories' );
            this.ProductionLogger = this.Logger.create( 'productions' );
            this.ServiceLogger = this.Logger.create( 'services' );
            logCleanup = this.Logger.debug( 'Constructing Configuration' );%#ok<NASGU>

            if ~isempty( opts.Parent ) && isa( opts.Parent, 'coderapp.internal.mfz.BackedByMfzModel' )
                this.ModelParent = opts.Parent;
                this.Logger.trace( 'Configured to use a parent''s MF0 model: %s', class( opts.Parent ) );
            else
                this.newModel(  );
                this.Logger.trace( 'Configured to use own MF0 model' );
            end
            if coderapp.internal.util.isScalarText( schema )
                schema = coderapp.internal.config.Schema.fromFile( schema );
                this.Logger.trace( 'Loaded schema from file: %s', schema );
            end
            this.Debug = opts.Debug;
            if isempty( schema ) || ~schema.Valid
                error( 'Configuration can only be used with a valid schema' );
            end
            if ~isempty( opts.PreInitTarget )
                this.PreInitTarget = opts.PreInitTarget;
                this.PreInitKeys = opts.PreInitKeys;
                this.Logger.trace( 'Configured to run in schema validation "preinitialization" mode' );
            end
            cleanup = this.pushTransaction( Revertible = false, Cleanup = "Commit" );%#ok<NASGU>

            if ~isempty( opts.ScriptOptions )
                this.ScriptOptions = cell2struct( opts.ScriptOptions( 2:2:end  ), opts.ScriptOptions( 1:2:end  ), 2 );
            end
            if ~isfield( this.ScriptOptions, 'ZeroBased' )
                this.ScriptOptions.ZeroBased = false;
            end
            this.ScriptOptions.MfzModel = this.RuntimeModel;

            this.ResolveMessages = opts.ResolveMessages && ~schema.UpdatedInSession && isempty( this.PreInitTarget );
            this.AssertServiceBindings = opts.AssertServiceBindings;
            this.MfzExposeProductions = opts.MfzExposeProductions;

            this.Schema = schema;
            this.ConfigStoreAdapter = coderapp.internal.config.runtime.ConfigStoreAdapter( this );
            this.TypeManager = this.reloadFromSchema(  );

            txn = this.RuntimeModel.beginTransaction(  );
            [ this.GraphNodes, this.ControllersByKey, this.TagAdapters, this.PerspectiveAdapters ] =  ...
                this.populate( opts.Services );
            this.Graph = this.SchemaData.DependencyGraph;
            this.NodeCount = numel( this.GraphNodes );
            this.DepMatrix = logical( this.Graph.adjacency(  ) );
            this.TransDepMatrix = logical( this.Graph.transclosure(  ).adjacency(  ) );

            nodeTypes = [ this.GraphNodes.NodeType ];
            isParam = nodeTypes == coderapp.internal.config.runtime.NodeType.Param;
            isCat = nodeTypes == coderapp.internal.config.runtime.NodeType.Category;
            if any( isParam )
                this.ParamAdapters = this.GraphNodes( isParam );
            end
            if any( isCat )
                this.CategoryAdapters = this.GraphNodes( isCat );
            end
            this.LayoutNodes = this.GraphNodes( isParam | isCat );
            isCat( ~isParam & ~isCat ) = [  ];
            this.LayoutRoots = flip( this.LayoutNodes( isCat | ~[ this.LayoutNodes.InCategory ] ) );

            this.initNodes(  );
            txn.commit(  );

            if this.IsOwnModel && isempty( this.PreInitTarget ) && ~schema.UpdatedInSession
                serializer = mf.zero.io.XmlSerializer(  );
                schema.updateContent( serializer.serializeToString( this.RuntimeModel ) );
            end

            txn = this.RuntimeModel.beginTransaction(  );
            this.activateAll(  );
            this.updateEffectiveVisible(  );
            txn.commit(  );

            if ~isempty( this.SchemaData.UpgradeHandler )
                this.UpgradeHandlers = reshape( cellfun( @feval, this.SchemaData.UpgradeHandler.toArray(  ) ), 1, [  ] );
            end
            if ~isempty( opts.LoadFrom )
                this.load( opts.LoadFrom );
            end

            this.TrackedScriptDeltaKeys = cellstr( opts.TrackedScriptDeltas );
        end

        function varargout = get( this, key, varargin )
            narginchk( 2, Inf );
            this.assertNotPropagating(  );
            [ result, isCell ] = this.doGet( [ { key }, varargin ], Export = false );
            if isCell
                varargout{ 1 } = result;
            else
                [ varargout{ 1:numel( result ) } ] = result{ : };
            end
        end

        function varargout = export( this, key, varargin )
            narginchk( 2, Inf );
            this.assertNotPropagating(  );
            [ result, isCell ] = this.doGet( [ { key }, varargin ], Export = true );
            if isCell
                varargout{ 1 } = result;
            else
                [ varargout{ 1:numel( result ) } ] = result{ : };
            end
        end

        function set( this, key, value )
            arguments
                this( 1, 1 )
                key{ mustBeKeyOrStruct( key ) }
                value = [  ]
            end

            if isstruct( key )
                narginchk( 2, 2 );
                logCleanup = this.Logger.info( @(  )sprintf( 'Processing set for: %s',  ...
                    strjoin( strcat( '"', fieldnames( key ), '"' ), ', ' ) ) );%#ok<NASGU>
            else
                narginchk( 3, 3 );
                logCleanup = this.Logger.info( 'Processing set for "%s"', key );%#ok<NASGU>
            end
            this.assertNotPropagating(  );
            revert = this.pushTransaction(  );%#ok<NASGU>
            this.doSet( key, value, Import = false );
            this.popTransaction(  );
        end

        function import( this, key, value )
            arguments
                this( 1, 1 )
                key{ mustBeKeyOrStruct( key ) }
                value = [  ]
            end

            if isstruct( key )
                narginchk( 2, 2 );
                logCleanup = this.Logger.info( @(  )sprintf( 'Processing import for: %s',  ...
                    strjoin( strcat( '"', fieldnames( key ), '"' ), ', ' ) ) );%#ok<NASGU>
            else
                narginchk( 3, 3 );
                logCleanup = this.Logger.info( 'Processing import for "%s"', key );%#ok<NASGU>
            end
            this.assertNotPropagating(  );
            revert = this.pushTransaction(  );%#ok<NASGU>
            this.doSet( key, value, Import = true );
            this.popTransaction(  );
        end

        function varargout = getAttr( this, key, attribute, varargin )
            arguments
                this( 1, 1 )
                key{ mustBeTextScalar( key ) }
                attribute{ mustBeText( attribute ) }
            end
            arguments( Repeating )
                varargin
            end

            revert = this.pushTransaction(  );%#ok<NASGU>
            if nargin < 3 || isempty( attribute )
                attribute = '';
            end
            node = this.getNodes( key, { 'Param', 'Category' } );
            if ~node.Awake
                this.doRefresh( node );
            end
            this.popTransaction(  );

            isCell = iscellstr( attribute );
            if isCell
                attrCell = attribute;
            elseif ~isempty( varargin )
                attrCell = [ { attribute }, varargin ];
            else
                varargout{ 1 } = node.getAttr( attribute );
                return
            end

            result = cell( size( attrCell ) );
            for i = 1:numel( attrCell )
                result{ i } = node.getAttr( attrCell{ i } );
            end
            if isCell
                varargout{ 1 } = result;
            else
                [ varargout{ 1:numel( result ) } ] = result{ : };
            end
        end

        function metaValue = getSchemaMetadata( this, metaPropName )
            arguments
                this( 1, 1 )
                metaPropName{ mustBeTextScalar( metaPropName ) } = ''
            end

            if ~isempty( metaPropName )
                entry = this.MetadataMap.getByKey( prop );
                if ~isempty( entry )
                    metaValue = entry.Value;
                else
                    metaValue = [  ];
                end
            elseif this.SchemaData.Metadata.Size > 0
                entries = this.MetadataMap.toArray(  );
                metaValue = containers.Map( { entries.Property }, { entries.Value } );
            else
                metaValue = containers.Map(  );
            end
        end

        function metaValue = getMetadata( this, key, metaPropName )
            arguments
                this( 1, 1 )
                key{ mustBeTextScalar( key ) }
                metaPropName{ mustBeTextScalar( metaPropName ) } = ''
            end

            node = this.getNodes( key, { 'Param', 'Category', 'Production' } );
            if ~isempty( metaPropName )
                metaValue = node.getMetadata( metaPropName );
            else
                metaValue = node.getMetadata(  );
            end
        end

        function has = hasTag( this, key, tag )
            arguments
                this( 1, 1 )
                key{ mustBeTextScalar( key ) }
                tag{ mustBeTextScalar( tag ) }
            end

            tagAdapter = this.TagAdapters( strcmp( { this.TagAdapters.Id }, tag ) );
            has = ~isempty( tagAdapter ) && ismember( key, tagAdapter.DependencyKeys );
        end

        function code = getScriptCode( this, key, opts )
            arguments
                this( 1, 1 )
                key{ mustBeTextScalar( key ) }
                opts.ReturnType{ mustBeMember( opts.ReturnType, [ "Code", "Model" ] ) } = "Code"
            end
            this.assertNotPropagating(  );
            revert = this.pushTransaction(  );%#ok<NASGU>
            node = this.getNodes( key, { 'Param', 'Production' } );
            if opts.ReturnType == "Model"
                code = node.ScriptValue;
            else
                code = node.ScriptCode;
            end
            this.popTransaction(  );
        end

        function wake( this, keys )
            arguments
                this
                keys{ mustBeText( keys ) } = {  }
            end
            this.assertNotPropagating(  );
            revert = this.pushTransaction(  );%#ok<NASGU>
            if nargin > 1
                if ~isempty( keys )
                    nodes = this.getNodes( keys, { 'Param', 'Category' } );
                    catNodes = nodes( [ nodes.NodeType ] == "Category" );
                    if ~isempty( catNodes )
                        nodes = [ nodes;catNodes.TransitiveContentNodes ];
                    end
                    nodes( [ nodes.NodeType ] == "Category" ) = [  ];
                end
            else
                nodes = this.ParamAdapters;
            end
            nodes = nodes( ~[ nodes.Awake ] );
            if ~isempty( nodes )
                this.doRefresh( nodes );
            end
            this.popTransaction(  );
        end

        function awake = isAwake( this, keys )
            arguments
                this
                keys{ mustBeText( keys ) }
            end
            nodes = this.getNodes( keys, { 'Param', 'Category' } );
            catNodes = nodes( [ nodes.NodeType ] == "Category" );
            if ~isempty( catNodes )
                nodes = [ nodes;catNodes.TransitiveContentNodes ];
                nodes( [ nodes.NodeType ] == "Category" ) = [  ];
            end
            awake = all( [ nodes.Awake ] );
        end

        function modified = isUserModified( this, keys )
            arguments
                this
                keys{ mustBeText( keys ) }
            end
            nodes = this.getNodes( keys );
            isParam = [ nodes.NodeType ] == "Param";
            modified = false( 1, numel( nodes ) );
            modified( isParam ) = [ nodes( isParam ).UserModified ];
        end

        function internal = isInternal( this, keys )
            arguments
                this
                keys{ mustBeText( keys ) }
            end
            nodes = this.getNodes( keys );
            isParam = [ nodes.NodeType ] == "Param";
            internal = false( 1, numel( nodes ) );
            internal( isParam ) = [ nodes( isParam ).Internal ];
        end

        function types = getEntityType( this, keys )
            arguments
                this
                keys{ mustBeText( keys ) }
            end
            nodes = this.getNodes( keys );
            types = cellstr( [ nodes.NodeType ] );
        end

        function refresh( this, key )
            arguments
                this
                key{ mustBeText( key ) } = {  }
            end
            this.assertNotPropagating(  );
            revert = this.pushTransaction(  );%#ok<NASGU>
            if nargin > 1
                nodes = this.getNodes( key, { 'Param', 'Production', 'Category', 'Service' } );
                this.doRefresh( nodes );
            else
                this.doRefresh(  );
            end
            this.UpdateVisibility = true;
            this.popTransaction(  );
        end

        function reset( this, key )
            arguments
                this
                key{ mustBeText( key ) } = {  }
            end
            this.assertNotPropagating(  );
            revert = this.pushTransaction(  );%#ok<NASGU>
            nodes = this.getNodes( key, 'Param' );
            for i = 1:numel( nodes )
                if nodes( i ).resetParam( true )
                    this.propagate( nodes( i ) );
                end
            end
            this.popTransaction(  );
        end

        function varargout = setupModelSync( this, inChannel, outChannel )
            arguments
                this
                inChannel
                outChannel = inChannel
            end
            [ varargout{ 1:nargout } ] = coderapp.internal.mfz.newRemoteSync( this.RuntimeModel, inChannel, outChannel );
        end

        function markNotDirty( this )
            this.assertNotPropagating(  );
            revert = this.pushTransaction(  );%#ok<NASGU>
            this.ConfigStoreAdapter.Dirty = false;
            this.popTransaction(  );
        end

        function varargout = serialize( this, file, opts )
            arguments
                this( 1, 1 )
                file{ mustBeTextScalar( file ) } = ''
                opts.SchemaVersion( 1, 1 )uint32 = this.SchemaData.Version
            end

            this.assertNotPropagating(  );
            assert( opts.SchemaVersion <= this.SchemaData.Version,  ...
                'Cannot target future schema versions' );

            configStore = this.ConfigStore;
            serializer = mf.zero.io.XmlSerializer(  );
            serializer.registerSequenceBasedId(  );

            if opts.SchemaVersion < this.SchemaData.Version

                deser = mf.zero.io.XmlParser(  );
                configStore = deser.parseString( ser.serializeToString( configStore ) );
                for handler = this.UpgradeHandlers
                    handler.downgrade( configStore, opts.SchemaVersion );
                end
                configStore.Version = opts.SchemaVersion;
            end
            if isempty( file )
                varargout{ 1 } = serializer.serializeToString( configStore );
            else
                serializer.serializeToFile( configStore, file );
            end
        end

        function deserialize( this, serialized )
            arguments
                this( 1, 1 )
                serialized{ mustBeA( serialized, [ "char", "string", "coderapp.internal.ext.ConfigStore" ] ) }
            end

            this.assertNotPropagating(  );
            configStore = [  ];

            if isa( serialized, 'coderapp.internal.ext.ConfigStore' )
                csModel = mf.zero.getModel( serialized );
                if csModel ~= this.RuntimeModel

                    ser = mf.zero.io.XmlSerializer(  );
                    serialized = ser.serializeToString( serialized );
                else
                    configStore = serialized;
                end
            end

            cleanup = this.pushTransaction( Revertible = false );%#ok<NASGU>
            if isempty( configStore )
                deser = mf.zero.io.XmlParser(  );
                deser.RemapUuids = true;
                deser.Model = this.RuntimeModel;
                configStore = deser.parseString( serialized );
                validateattributes( configStore, { 'coderapp.internal.ext.ConfigStore' }, { 'scalar' } );
            end

            assert( configStore.Version <= this.SchemaData.Version,  ...
                'Cannot load from a future schema version' );
            if configStore.Version < this.SchemaData.Version

                for handler = this.UpgradeHandlers
                    handler.upgrade( configStore );
                end
            end

            this.loadConfigStore( configStore );
        end

        function controller = getController( this, controllerId )
            arguments
                this
                controllerId char{ mustBeNonempty( controllerId ) }
            end
            if this.ControllersByKey.isKey( controllerId )
                controller = this.ControllersByKey( controllerId );
            else
                controller = [  ];
            end
        end

        function has = hasSerializableState( this )
            has = this.ConfigStoreAdapter.hasEntries(  );
        end

        function delete( this )
            cleanup = this.pushTransaction( Revertible = false );%#ok<NASGU>

            nodes = this.AllAdapters;
            for i = 1:numel( nodes )
                nodes( i ).delete(  );
            end

            if ~this.IsOwnModel || ~isempty( this.PreInitTarget )
                this.State.destroy(  );
                this.SchemaData.destroy(  );
                this.ConfigStore.destroy(  );
            end
        end

        function perspectiveId = get.ActivePerspective( this )
            perspectiveId = '';
            pers = this.PerspectiveAdapters;
            if ~isempty( pers )
                per = pers( [ pers.IsActive ] );
                if ~isempty( per )
                    perspectiveId = per.Id;
                end
            end
        end

        function adapters = get.InternalAdapters( this )
            adapters = [ this.PerspectiveAdapters;this.TagAdapters ];
        end

        function adapters = get.AllAdapters( this )
            adapters = [ this.GraphNodes;this.InternalAdapters ];
        end

        function propagating = get.IsProcessing( this )
            propagating = this.IsTransacting;
        end

        function set.TrackedScriptDeltaKeys( this, keys )
            if isempty( this.GraphNodes )%#ok<MCSUP>
                return
            end
            prodNodes = this.GraphNodes( [ this.GraphNodes.NodeType ] == "Production" );%#ok<MCSUP>
            if isempty( prodNodes )
                return
            end
            tracked = num2cell( ismember( { prodNodes.Key }, keys ) );
            [ prodNodes.TrackScriptDeltas ] = tracked{ : };
        end

        function keys = get.Keys( this )
            keys = { this.GraphNodes.Key }';
        end

        function model = get.RuntimeModel( this )
            model = this.MfzModel;
        end

        function set.ConfigStore( this, store )
            this.ConfigStore = store;
            this.ConfigStoreAdapter.Store = store;
        end
    end

    methods ( Hidden )
        function mfzModel = getMfzModel( this )
            assert( this.Debug, 'getMfzModel can only be called in debug mode' );
            mfzModel = this.RuntimeModel;
        end

        function producer = getProducer( this, prodKey )
            arguments
                this( 1, 1 )
                prodKey{ mustBeTextScalar( prodKey ) }
            end
            node = this.getNodes( prodKey, 'Production' );
            producer = node.Producer;
        end
    end

    methods ( Access = ?coderapp.internal.config.runtime.NodeAdapter )
        function nodes = getNodes( this, keysOrOrdinals, expectedType )
            arguments
                this
                keysOrOrdinals
                expectedType = coderapp.internal.config.runtime.NodeType.empty(  )
            end
            if isempty( keysOrOrdinals )
                nodes = coderapp.internal.config.runtime.NodeAdapter.empty(  );
                return
            elseif isa( keysOrOrdinals, 'coderapp.internal.config.runtime.NodeAdapter' )
                nodes = reshape( keysOrOrdinals, [  ], 1 );
                return
            end
            if isnumeric( keysOrOrdinals )
                nodes = this.GraphNodes( keysOrOrdinals );
            else
                keysOrOrdinals = cellstr( keysOrOrdinals );
                [ found, idx ] = ismember( keysOrOrdinals, this.Graph.Nodes.Name );
                if ~all( found )
                    error( 'No nodes exist with the specified keys: %s', strjoin( keysOrOrdinals( ~found ), ', ' ) );
                end
                nodes = this.GraphNodes( idx );
            end
            if ~isempty( expectedType )
                if ~isenum( expectedType )
                    expectedType = coderapp.internal.config.runtime.NodeType( expectedType );
                end
                compatible = ismember( [ nodes.NodeType ], expectedType );
                if ~all( compatible )
                    error( 'Requested nodes are not of the expected type: %s',  ...
                        strjoin( { nodes( ~compatible ).Key }, ', ' ) );
                end
            end
            if isempty( nodes )
                nodes = coderapp.internal.config.runtime.NodeAdapter.empty(  );
            end
        end

        function controllers = getControllers( this, ids )
            controllers = this.ControllersByKey.values( ids );
            controllers = [ controllers{ : } ];
        end

        function assertNotPropagating( this )
            if this.IsProcessing
                error( 'Configuration is already processing another change' );
            end
        end
    end

    methods ( Access = ?coderapp.internal.config.runtime.ConfigStoreAdapter )
        function finishApplyConfigStore( this, params, visitor )
            arguments
                this
                params coderapp.internal.config.runtime.ParamNodeAdapter
                visitor( 1, 1 )function_handle
            end

            this.propagate( params, visitor, false );
        end
    end

    methods ( Access = ?coderapp.internal.config.runtime.NodeAdapter )
        function reportChange( this, node, attr, external )
            arguments
                this
                node
                attr = 'Value'
                external = true
            end

            if iscell( this.PendingChanged )
                this.PendingChanged{ node.Ordinal }{ end  + 1 } = attr;
                if node.NodeType == "Param" && strcmp( attr, 'Value' )
                    this.ValueChangeRecords( node.Ordinal ) = 1 + external;
                end
            end
        end

        function deferredSetPerspective( this, perspectiveId )
            per = this.PerspectiveAdapters( strcmp( { this.PerspectiveAdapters.Id }, perspectiveId ) );
            if ~per.IsActive
                this.Logger.trace( 'Enqueuing perspective change request to "%s"', perspectiveId );
                this.defer( @later );
            end

            function later(  )
                logCleanup = this.Logger.trace( 'Executing perspective change to "%s"', perspectiveId );%#ok<NASGU>
                revert = this.pushTransaction(  );%#ok<NASGU>
                this.applyPerspective( per );
                this.popTransaction(  );
            end
        end

        function deferredImport( this, source, value, opts )
            arguments
                this
                source( 1, 1 )coderapp.internal.config.runtime.ProductionNodeAdapter
                value
                opts.AsUser = false
                opts.Validate = false
            end

            this.Logger.trace( 'Enqueuing import request for "%s"', source.Key );
            this.defer( @later );

            function later(  )
                logCleanup = this.Logger.trace( 'Executing deferred import for "%s"', source.Key );%#ok<NASGU>
                cleanup = this.pushTransaction(  );%#ok<NASGU>
                this.importProductionNode( source, value, opts.AsUser, opts.Validate );
                this.popTransaction(  );
            end
        end

        function deferredRefresh( this, source )
            arguments
                this
                source( 1, 1 )coderapp.internal.config.runtime.ControllableNodeAdapter
            end

            this.Logger.trace( 'Enqueuing refresh request for "%s"', source.Key );
            this.defer( @later );

            function later(  )
                logCleanup = this.Logger.trace( 'Executing deferred refresh for "%s"', source.Key );%#ok<NASGU>
                if this.IsProcessing
                    cleanup = this.pushTransaction(  );%#ok<NASGU>
                    this.doRefresh( source );
                    this.popTransaction(  );
                else
                    this.refresh( source.Key );
                end
            end
        end
    end

    methods ( Access = private )
        function typeManager = reloadFromSchema( this )
            [ this.SchemaData, typeManager ] = this.Schema.load( this.RuntimeModel );
            this.State = this.SchemaData.RuntimeState;
            this.ConfigStore = this.State.ConfigStore;
        end

        function initNodes( this )
            logCleanup = this.Logger.debug( 'Initializing nodes' );%#ok<NASGU>
            for node = reshape( this.AllAdapters, 1, [  ] )
                node.initNode( this );
            end
        end

        function activateAll( this )
            logCleanup = this.Logger.debug( 'Activating nodes' );%#ok<NASGU>
            this.traverse( @doActivate, 'decrement' );

            function unmodified = doActivate( node, triggers )
                if ~node.NodeType.IsPrimary
                    unmodified = false;
                    return
                end
                if ~node.NodeActive || ~isempty( triggers )
                    node.activateNode(  );
                end
                unmodified = ~node.Propagate || node.NodeType == "Production";
                node.Propagate = false;
            end
        end

        function doRefresh( this, nodes )
            logCleanup = this.Logger.info( @(  )sprintf( 'Refreshing nodes: %s', strjoin( { nodes.Key }, ', ' ) ) );%#ok<NASGU>
            if nargin > 1
                isSeed = false( 1, this.NodeCount );
                isSeed( [ nodes.Ordinal ] ) = true;
                this.traverse( @updateNode, 'abort', nodes );
            else
                isSeed = true( 1, this.NodeCount );
                this.traverse( @updateNode, 'abort' );
            end
            this.UpdateVisibility = true;

            function abort = updateNode( node, triggers )
                if node.NodeType.IsPrimary
                    nodeIsSeed = isSeed( node.Ordinal );
                    if nodeIsSeed
                        triggers = node.Dependencies;
                    end
                    node.updateNode( triggers );
                    abort = ~nodeIsSeed && ~node.Propagate;
                else
                    node.updateNode( [  ] );
                end
                node.Propagate = false;
            end
        end

        function [ result, isCell ] = doGet( this, args, opts )
            arguments
                this
                args
                opts.Export = false
            end
            assert( ~isempty( args ) );
            revert = this.pushTransaction(  );%#ok<NASGU>

            if isscalar( args ) && iscell( args{ 1 } )
                isCell = true;
                keys = args{ 1 };
            else
                keys = cellstr( args );
                isCell = false;
            end

            nodes = this.getNodes( keys, { 'Param', 'Production', 'Service' } );
            if opts.Export
                result = { nodes.ExportedValue };
            else
                result = { nodes.ReferableValue };
            end
            this.popTransaction(  );
        end

        function changed = doSet( this, nodeArg, value, opts )
            arguments
                this
                nodeArg
                value
                opts.Import( 1, 1 )logical = false
                opts.External( 1, 1 )logical = true
            end

            if isstruct( nodeArg )
                keys = fieldnames( nodeArg );
                values = struct2cell( nodeArg );

                nodes = this.getNodes( keys, { 'Param', 'Production', 'Service' } );
                [ ~, sortIdx ] = sort( [ nodes.Ordinal ] );
                keys = keys( sortIdx );
                values = values( sortIdx );

                opts = namedargs2cell( opts );
                for i = 1:numel( keys )
                    this.doSet( keys{ i }, values{ i }, opts{ : } );
                end
                return
            end

            node = this.getNodes( nodeArg, { 'Param', 'Production', 'Service' } );

            switch node.NodeType
                case 'Param'
                    if node.Derived
                        error( 'Param "%s" is derived and cannot be external set', node.Key );
                    end
                    if opts.Import
                        changed = node.importValue( value, opts.External );
                    else
                        changed = node.setValue( value, opts.External );
                    end
                    if changed
                        this.propagate( node );
                    end
                case 'Service'
                    node.bind( value );
                    this.propagate( node );
                    this.InvalidateHistory = true;
                    changed = true;
                case 'Production'
                    changed = this.importProductionNode( node, value );
            end
        end

        function changed = importProductionNode( this, prodNode, value, asUser, validateValues )
            arguments
                this
                prodNode( 1, 1 )coderapp.internal.config.runtime.ProductionNodeAdapter
                value
                asUser logical = true
                validateValues logical = prodNode.Producer.ValidateOnImport
            end

            this.ImportOptions = struct( 'isUser', asUser, 'validate', validateValues );
            importCleanup = onCleanup( @(  )this.clearImportState(  ) );

            imported = this.flattenedImport( prodNode, value );
            if isempty( imported )
                changed = false;
                return
            end

            nodes = [ imported{ :, 1 } ];
            [ ~, sortIdx ] = sort( [ nodes.Ordinal ] );
            nodes = nodes( sortIdx );
            values = imported( sortIdx, 2 );
            changed = false;
            for i = 1:numel( nodes )
                node = nodes( i );
                if node.importValue( values{ i }, asUser )
                    changed = true;
                    this.propagate( node );
                end
            end
        end

        function flattened = flattenedImport( this, prodNode, value )
            importCleanup = onCleanup( @(  )clearImportFlag( prodNode ) );
            prodNode.ApplyingImport = true;
            imported = prodNode.import( value );

            flattened = [  ];
            if isempty( imported )
                return
            end
            keys = fieldnames( imported );
            if isempty( keys )
                return
            end

            values = struct2cell( imported );
            nodes = this.getNodes( keys, { 'Param', 'Production' } );
            isProd = [ nodes.NodeType ] == "Production";
            isParam = ~isProd;

            flattened = [ num2cell( nodes( isParam ) ), values( isParam ) ];
            nodes = nodes( isProd );
            values = values( isProd );

            for i = 1:numel( nodes )
                subFlattened = this.flattenedImport( nodes( i ), values{ i } );
                if ~isempty( subFlattened )
                    flattened( end  + 1:end  + size( subFlattened, 1 ), : ) = subFlattened;
                end
            end
        end

        function loadConfigStore( this, configStore )
            arguments
                this
                configStore( 1, 1 )coderapp.internal.ext.ConfigStore
            end

            if configStore ~= this.ConfigStore
                this.ConfigStoreAdapter.loadFrom( configStore );
            else
                this.ConfigStoreAdapter.apply(  );
            end
        end

        function applyPerspective( this, perspective, updateVisiblity )
            arguments
                this
                perspective = [  ]
                updateVisiblity = true
            end

            if isempty( perspective )
                perspective = this.PerspectiveAdapters( [ this.PerspectiveAdapters.IsActive ] );
            end

            inPerspective = false( 1, this.NodeCount );
            inPerspective( this.SchemaData.NonPerspectiveOrdinals ) = true;
            if ~isempty( perspective )
                for other = reshape( this.PerspectiveAdapters, 1, [  ] )
                    other.IsActive = perspective == other;
                end
                inPerspective( perspective.PerspectiveDef.MemberOrdinals ) = true;
            end

            nodes = this.LayoutNodes;
            nexts = inPerspective( [ nodes.Ordinal ] );
            changed = nexts ~= [ nodes.InPerspective ];
            nodes = nodes( changed );
            nexts = nexts( changed );
            for i = 1:numel( nodes )
                nodes( i ).InPerspective = nexts( i );
            end

            if updateVisiblity
                this.UpdateVisibility = true;
            end
        end

        function updateEffectiveVisible( this )
            changeRoots = this.LayoutRoots;
            if isempty( changeRoots )
                return
            end
            logCleanup = this.Logger.trace( 'Wholesale update of effective visibility' );%#ok<NASGU>
            isCat = [ changeRoots.NodeType ] == "Category";
            for i = 1:numel( changeRoots )
                changeRoot = changeRoots( i );
                if isCat( i ) || ~changeRoot.InCategory
                    changeRoot.updateEffectiveVisibility(  );
                end
            end
        end

        function [ nodes, controllerMap, tagAdapters, perAdapters ] = populate( this, serviceBindings )
            import( 'coderapp.internal.config.runtime.*' );
            sd = this.SchemaData;


            for i = 1:numel( sd.CustomTypes )
                this.TypeManager.registerTypes( feval( sd.CustomTypes{ i } ) );
            end


            controllerDefs = sd.Controllers.toArray(  );
            if ~isempty( controllerDefs )
                controllerMap = containers.Map( { controllerDefs.Id },  ...
                    cellfun( @( c )instantiateController( c, this ), { controllerDefs.Class }, 'UniformOutput', false ) );
            else
                controllerMap = containers.Map(  );
            end

            paramDefs = sd.Params.toArray(  );
            if ~isempty( this.PreInitTarget )
                canPreInit = ismember( { paramDefs.Key }, this.PreInitKeys );
                preInitParams = this.PreInitTarget.Params.toArray(  );
                paramDefs( canPreInit ) = preInitParams( canPreInit );
            end


            paramStates = [ paramDefs.InitialState ];
            if ~isempty( paramStates )
                paramTypes = this.TypeManager.getType( { paramStates.TypeName } );
                paramControllers = cell( 1, numel( paramTypes ) );
                [ ~, uIdx, tIdx ] = unique( { paramTypes.Name } );
                for i = reshape( uIdx, 1, [  ] )
                    paramControllers( tIdx == i ) = { paramTypes( i ).createController(  ) };
                end
            else
                paramTypes = [  ];
                paramControllers = {  };
            end

            nodes = cell( numel( sd.NodeCount ), 1 );

            serviceDefs = sd.Services.toArray(  );
            for i = 1:numel( serviceDefs )
                node = ServiceNodeAdapter( serviceDefs( i ), i );
                if isfield( serviceBindings, node.Key )
                    node.bind( serviceBindings.( node.Key ) );
                elseif ~this.AssertServiceBindings
                    node.bind( [  ] );
                end
                addNode( serviceDefs( i ), node, this.ServiceLogger );
            end

            prodStates = sd.Productions.toArray(  );
            for i = 1:numel( prodStates )
                addNode( prodStates( i ), ProductionNodeAdapter( prodStates( i ), i ), this.ProductionLogger );
            end

            for i = 1:numel( paramDefs )
                addNode( paramDefs( i ), ParamNodeAdapter( paramDefs( i ), paramTypes( i ), paramControllers{ i }, i ),  ...
                    this.ParamLogger );
            end

            catDefs = sd.Categories.toArray(  );
            if ~isempty( this.PreInitTarget )
                canPreInit = ismember( { catDefs.Key }, this.PreInitKeys );
                preInitCats = this.PreInitTarget.Categories.toArray(  );
                catDefs( canPreInit ) = preInitCats( canPreInit );
            end
            for i = 1:numel( catDefs )
                addNode( catDefs( i ), CategoryNodeAdapter( catDefs( i ), i ), this.CategoryLogger );
            end


            tags = sd.Tags.toArray(  );
            if ~isempty( tags )
                tagAdapters = cell( 1, numel( tags ) );
                for i = 1:numel( tags )
                    tagAdapters{ i } = TagNodeAdapter( tags( i ) );
                end
                tagAdapters = vertcat( tagAdapters{ : } );
            else
                tagAdapters = coderapp.internal.config.runtime.TagNodeAdapter.empty(  );
            end

            pers = sd.Perspectives.toArray(  );
            if ~isempty( pers )
                perAdapters = cell( 1, numel( pers ) );
                for i = 1:numel( pers )
                    perAdapters{ i } = PerspectiveAdapter( pers( i ) );
                end
                perAdapters = vertcat( perAdapters{ : } );
            else
                perAdapters = coderapp.internal.config.runtime.PerspectiveAdapter.empty(  );
            end

            if ~isempty( nodes )
                nodes = vertcat( nodes{ : } );
            else
                nodes = coderapp.internal.config.runtime.ParamNodeAdapter.empty(  );
            end

            function addNode( def, node, parentLogger )
                nodes{ def.Ordinal } = node;
                node.Logger = parentLogger.create( node.Key );
            end
        end

        function propagate( this, nodes, visitor, filterPropagatable )
            arguments
                this
                nodes = [  ]
                visitor function_handle = function_handle.empty(  )
                filterPropagatable( 1, 1 )logical = true
            end

            if isempty( nodes )
                return
            end

            logger = this.Logger;
            logCleanup = logger.debug( 'Propagating' );%#ok<NASGU>
            if filterPropagatable
                nodes = nodes( [ nodes.Propagate ] );
                if isempty( nodes )
                    logger.trace( 'Aborting propagation; no propagatable nodes' );
                    return
                end
            end
            if isempty( visitor )
                visitor = @forUpdate;
                nodeFilter = true( 1, this.NodeCount );
                nodeFilter( [ nodes.Ordinal ] ) = false;
                importing = ~isempty( this.ImportOptions );
            end
            this.traverse( visitor, 'abort', nodes );
            this.UpdateVisibility = true;

            function abort = forUpdate( node, triggerNodes )
                if ~node.NodeType.IsPrimary || nodeFilter( node.Ordinal )
                    if importing && node.NodeType == "Production"
                        node.ApplyingImport = true;
                        importCleanup = onCleanup( @(  )clearImportFlag( node ) );
                    end
                    node.updateNode( triggerNodes );
                    abort = ~node.Propagate;
                else
                    abort = false;
                end
                node.Propagate = false;
            end
        end

        function traverse( this, visitor, outputMode, seedNodes )
            arguments
                this
                visitor function_handle
                outputMode{ mustBeMember( outputMode, { 'abort', 'decrement', 'none' } ) } = 'none'
                seedNodes = coderapp.internal.config.runtime.ParamNodeAdapter.empty(  )
            end
            if nargin < 4
                seedNodes = [ this.GraphNodes;this.TagAdapters ];
                whole = true;
            else
                whole = false;
            end
            if iscell( seedNodes )
                seedNodes = [ seedNodes{ : } ];
            end
            if ~whole
                [ ~, uIdx ] = unique( [ seedNodes.Ordinal ] );
                seedNodes = seedNodes( uIdx );
                whole = numel( seedNodes ) == this.NodeCount;
            end

            abortable = false;
            decrement = false;
            switch outputMode
                case 'abort'
                    abortable = ~whole;
                case 'decrement'
                    decrement = true;
            end
            trackIncoming = abortable || decrement;

            seedSelect = ismember( [ seedNodes.NodeType ], coderapp.internal.config.runtime.NodeType(  ...
                { 'Param', 'Category', 'Production', 'Service' } ) );
            graphNodes = this.GraphNodes;


            incoming = Inf( 1, this.NodeCount );
            if any( seedSelect )
                seedOrdinals = [ seedNodes( seedSelect ).Ordinal ];
                needsTriggers = decrement || nargin( visitor ) > 1;
                triggerArg = {  };
                if whole
                    closure = seedOrdinals;
                    if trackIncoming
                        incoming = full( sum( this.DepMatrix ) );
                        isRoot = incoming == 0;
                    end
                else


                    [ ~, down ] = find( this.TransDepMatrix( seedOrdinals, : ) );
                    down = reshape( setdiff( down, seedOrdinals ), 1, [  ] );
                    closure = sort( [ seedOrdinals, down ] );
                    if trackIncoming


                        incoming = zeros( 1, this.NodeCount );
                        incoming( seedOrdinals ) = Inf;



                        incoming( down ) = sum( this.DepMatrix( closure, down ) );
                    end
                end

                for current = closure


                    if ~abortable || decrement || incoming( current ) > 0
                        deadEnd = false;
                        adapter = graphNodes( current );
                        if needsTriggers


                            triggerSelect = find( this.DepMatrix( :, current ) );
                            triggerSelect = triggerSelect( incoming( triggerSelect ) > 0 );
                            if ~isempty( triggerSelect )
                                triggerArg{ 1 } = graphNodes( triggerSelect );
                            else
                                triggerArg{ 1 } = coderapp.internal.config.runtime.ParamNodeAdapter.empty(  );
                            end
                        end
                        if trackIncoming
                            deadEnd = visitor( adapter, triggerArg{ : } );
                        elseif ~isempty( visitor )
                            visitor( adapter, triggerArg{ : } );
                        end
                    else
                        deadEnd = true;
                    end
                    if deadEnd
                        incoming( current ) = 0;
                        nextSelect = this.DepMatrix( current, : );
                        if ~isempty( nextSelect )

                            incoming( nextSelect ) = incoming( nextSelect ) - 1;
                        end
                    elseif whole && trackIncoming && isRoot( current )

                        incoming( current ) = Inf;
                    end
                end
            else
                closure = [  ];
            end


            visitedNodes = this.GraphNodes( closure( incoming( closure ) > 0 ) );
            internalSelect = ismember( this.InternalAdapters, seedNodes( ~seedSelect ) );
            if any( internalSelect )
                this.visitSecondaryNodes( visitor, visitedNodes, seedNodes( ~seedSelect ) );
            elseif ~isempty( visitedNodes )
                this.visitSecondaryNodes( visitor, visitedNodes );
            end
        end

        function visitSecondaryNodes( this, visitor, triggerNodes, seedNodes )
            arguments
                this
                visitor
                triggerNodes = coderapp.internal.config.runtime.InternalNodeAdapter.empty
                seedNodes = coderapp.internal.config.runtime.InternalNodeAdapter.empty
            end
            nodes = this.InternalAdapters;
            if nargin < 4
                internalSelect = true( size( nodes ) );
            else
                internalSelect = ismember( nodes, seedNodes );
            end
            triggers = coderapp.internal.config.runtime.InternalNodeAdapter.empty(  );
            needsTriggers = nargin( visitor ) > 1;
            if needsTriggers
                triggerKeys = { triggerNodes.Key };
            end
            for i = 1:numel( nodes )
                internal = nodes( i );
                if needsTriggers
                    if internal.DependsOnAll
                        triggers = triggerNodes;
                    else
                        triggers = triggerNodes( ismember( triggerKeys, internal.DependencyKeys ) );
                    end
                end
                if internalSelect( i ) || ~isempty( triggers )
                    if needsTriggers
                        visitor( internal, triggers );
                    elseif ~isempty( visitor )
                        visitor( internal );
                    end
                end
            end
        end

        function clearImportState( this )
            this.ImportOptions = struct.empty;
        end
    end

    methods ( Access = protected )
        function defer( this, func )
            if this.IsProcessing
                defer@coderapp.internal.mfz.BackedByMfzModel( this, func );
            else
                func(  );
            end
        end

        function beginTransaction( this )
            if isempty( this.Schema )
                return
            end
            this.PendingChanged = cell( 1, this.NodeCount );
            this.ValueChangeRecords = zeros( size( this.PendingChanged ) );
        end

        function proceed = preCommit( this )
            if this.UpdateVisibility
                this.UpdateVisibility = false;
                this.updateEffectiveVisible(  );
            end
            if ~this.IsRestoring && ~this.UndoRedoTransparent && any( this.ValueChangeRecords )
                this.requestStateSnapshot( this.InvalidateHistory );
            end
            this.FrozenPendingChanged = this.PendingChanged;
            proceed = true;
        end

        function postCommit( this )
            pendingChanged = this.FrozenPendingChanged;
            this.FrozenPendingChanged = [  ];
            if ~isempty( pendingChanged )
                changed = ~cellfun( 'isempty', pendingChanged );
                if any( changed )
                    changedNodes = this.GraphNodes( changed );
                    changes = struct(  ...
                        'key', { changedNodes.Key },  ...
                        'attributes', pendingChanged( changed ) );
                    this.notify( 'ConfigurationChanged',  ...
                        coderapp.internal.config.ConfigurationEventData( changes ) );
                end
            end
        end

        function postCancel( this )
            nodes = this.GraphNodes;
            for i = 1:numel( nodes )
                nodes( i ).revertNode(  );
            end
        end

        function cleanupTransaction( this )
            this.InvalidateHistory = false;
            this.PendingChanged = [  ];
            this.FrozenPendingChanged = [  ];
            this.ValueChangeRecords = [  ];
        end
    end

    methods ( Access = { ?coderapp.internal.undo.StateOwner, ?coderapp.internal.undo.StateTracker } )
        function [ allStates, unchangedIds ] = getTrackableState( this, full )
            if full
                paramNodes = this.ParamAdapters;
                ordinals = [ paramNodes.Ordinal ];
                unchangedIds = [  ];
            else
                ordinals = find( this.ValueChangeRecords );
                paramNodes = this.getNodes( ordinals );
                unchangedNodes = setdiff( this.ParamAdapters, paramNodes );
                unchangedIds = [ unchangedNodes.Ordinal ];
            end
            payloads = struct( 'value', { paramNodes.ReferableValue }, 'userModified', { paramNodes.UserModified } );
            allStates = struct( 'trackableId', num2cell( ordinals ), 'state', num2cell( payloads ) );
        end

        function applyTrackedState( this, ~, changes, ~ )
            this.assertNotPropagating(  );
            revert = this.pushTransaction(  );%#ok<NASGU>
            for i = 1:numel( changes )
                change = changes( i );
                this.doSet( change.trackableId, change.state.value, Import = false, External = change.state.userModified );
            end
            this.popTransaction(  );
        end
    end

    methods ( Static, Hidden )
        function choices = keyTabCompleter( config, key, nodeTypes, enabledOnly )
            arguments
                config( 1, 1 )coderapp.internal.config.Configuration
                key{ mustBeTextScalar( key ) } = ''
                nodeTypes{ mustBeText( nodeTypes ) } = {  }
                enabledOnly( 1, 1 ){ mustBeNumericOrLogical( enabledOnly ) } = false
            end

            nodes = config.GraphNodes;
            if ~isempty( nodeTypes )
                nodes = nodes( ismember( [ nodes.NodeType ],  ...
                    coderapp.internal.config.runtime.NodeType( nodeTypes ) ) );
            end
            if enabledOnly
                nodes = nodes( arrayfun( @( node )node.NodeType ~= "Param" || node.getAttr( 'Enabled' ), nodes ) );
            end
            choices = { nodes.Key };
            choices = choices( startsWith( lower( choices ), lower( key ) ) );
        end

        function choices = valueTabCompleter( config, key, value, isImport )
            arguments
                config( 1, 1 )coderapp.internal.config.Configuration
                key{ mustBeTextScalar( key ) } = ''
                value{ mustBeTextScalar( value ) } = ''
                isImport( 1, 1 )logical = false
            end

            choices = {  };
            try
                node = config.getNodes( key, { 'Param' } );
            catch
                return
            end
            config.wake( key );
            choices = node.getTabCompletions( value, isImport );
        end

        function choices = attrTabCompleter( config, key, attr )
            arguments
                config( 1, 1 )coderapp.internal.config.Configuration
                key{ mustBeTextScalar( key ) } = ''
                attr{ mustBeTextScalar( attr ) } = ''
            end

            try
                node = config.getNodes( key, { 'Param', 'Category' } );
            catch
                choices = {  };
                return
            end
            choices = node.getAttributeNames(  );
            choices = choices( startsWith( lower( choices ), lower( attr ) ) );
        end

        function choices = metadataTabCompleter( config, key, metaProp )
            arguments
                config( 1, 1 )coderapp.internal.config.Configuration
                key{ mustBeTextScalar( key ) } = ''
                metaProp{ mustBeTextScalar( metaProp ) } = ''
            end

            choices = {  };
            try
                node = config.getNodes( key, { 'Param', 'Category' } );
            catch
                return
            end
            metadata = node.getMetadata(  );
            if ~isempty( metadata )
                choices = metadata.keys(  );
                choices = choices( startsWith( lower( choices ), lower( metaProp ) ) );
            end
        end

        function choices = tagTabCompleter( config, tag )
            arguments
                config( 1, 1 )coderapp.internal.config.Configuration
                tag{ mustBeTextScalar( tag ) } = ''
            end

            if ~isempty( config.TagAdapters )
                choices = { config.TagAdapters.Id };
            else
                choices = {  };
            end
            choices = choices( startsWith( lower( choices ), lower( tag ) ) );
        end
    end
end


function controller = instantiateController( controllerClass, configuration )
controller = feval( controllerClass );
controller.Configuration = configuration;
end


function mustBeKeyOrStruct( arg )
if ~isscalar( arg ) || ~isstruct( arg )
    mustBeTextScalar( arg );
end
end


function clearImportFlag( prodNode )
prodNode.ApplyingImport = false;
end



