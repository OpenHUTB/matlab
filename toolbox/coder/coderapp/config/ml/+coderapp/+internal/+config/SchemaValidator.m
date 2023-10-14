classdef ( Sealed )SchemaValidator < coderapp.internal.mfz.BackedByMfzModel & coderapp.internal.log.HierarchyLoggable

    properties ( Constant, Access = private )
        SharedTypeManager = coderapp.internal.config.ParamTypeManager(  )
    end

    properties ( SetAccess = private )
        Schema coderapp.internal.config.Schema = coderapp.internal.config.Schema.empty(  )
        Warnings struct
        Errors struct
        DependencyGraph digraph = digraph
        DebugInfo coderapp.internal.config.util.SchemaDebugInfo
    end

    properties ( Dependent, SetAccess = immutable )
        Valid logical
        ErrorMessages cell
        VisitedFiles cell
    end

    properties ( SetAccess = immutable )
        Verbose logical = false
        Assert logical = true
        Strict logical = true
        RequireCategories logical = false
        RequireNames logical = false
        UseSchemaImport logical = true
        AutoPreInit logical = false
        AutoPreInitServiceBindings struct
        OutputFormat char = 'xml'
        SaveTypeManager logical = false
    end

    properties ( Access = private )
        Data coderapp.internal.config.schema.SchemaData
        RuntimeState coderapp.internal.config.runtime.ConfigurationState
        Keys = {  }
        TypeManager
        ByKey
        DeclStacks
        ProducerMap
        Labels
        FragmentName
        Stack = {  }
        Visited
        ContextStack
        LastValidatedFile
        DefaultPerspectiveId
        MustBeCategorized;
        Garbage mf.zero.ModelElement
    end

    properties ( Dependent, Access = private )
        FileMode
        RootDir
        UserVisibleStrategy
        BaseStrategy
        IsRootSchema
        Rules
    end

    methods
        function this = SchemaValidator( opts )
            arguments
                opts.Verbose( 1, 1 ){ mustBeNumericOrLogical( opts.Verbose ) } = false
                opts.Assert( 1, 1 ){ mustBeNumericOrLogical( opts.Assert ) } = false
                opts.RequireCategories( 1, 1 ){ mustBeNumericOrLogical( opts.RequireCategories ) } = false
                opts.RequireNames( 1, 1 ){ mustBeNumericOrLogical( opts.RequireNames ) } = false
                opts.Strict( 1, 1 ){ mustBeNumericOrLogical( opts.Strict ) } = false
                opts.UseSchemaImport( 1, 1 ){ mustBeNumericOrLogical( opts.UseSchemaImport ) } = true
                opts.OutputFormat{ mustBeMember( opts.OutputFormat, [ "xml", "json" ] ) } = 'xml'
                opts.AutoPreInit( 1, 1 ){ mustBeNumericOrLogical( opts.AutoPreInit ) } = false
                opts.AutoPreInitServiceBindings( 1, 1 )struct = struct(  )
                opts.SaveTypeManager( 1, 1 ){ mustBeNumericOrLogical( opts.SaveTypeManager ) } = false
                opts.EnableLogging logical{ mustBeScalarOrEmpty( opts.EnableLogging ) } = [  ]
            end

            this@coderapp.internal.log.HierarchyLoggable( 'schemaValidator', EnableLogging = opts.EnableLogging );

            this.Verbose = opts.Verbose;
            this.Assert = opts.Assert;
            this.Strict = opts.Strict;
            this.OutputFormat = opts.OutputFormat;
            this.RequireCategories = opts.RequireCategories;
            this.RequireNames = opts.RequireNames;
            this.UseSchemaImport = opts.UseSchemaImport;
            this.SaveTypeManager = opts.SaveTypeManager;

            this.AutoPreInit = opts.AutoPreInit;
            if ~isempty( opts.AutoPreInitServiceBindings )
                this.AutoPreInitServiceBindings = opts.AutoPreInitServiceBindings;
            end
        end

        function varargout = parseStruct( this, root )
            this.reset(  );
            this.Labels = struct( 'singular', 'field', 'plural', 'fields', 'container', 'scalar struct' );
            varargout = this.doValidate( root, false, nargout );
        end

        function varargout = parseFile( this, rootFile )
            this.reset(  );
            this.Labels = struct( 'singular', 'property', 'plural', 'properties', 'container', 'object' );
            varargout = this.doValidate( rootFile, true, nargout );
        end

        function varargout = viewCyclicDependencies( this )
            if isempty( this.DependencyGraph )
                return
            end
            cycles = getCycles( this.DependencyGraph );
            if isempty( cycles )
                return
            end
            cycleGraph = this.DependencyGraph.subgraph( unique( [ cycles{ : } ] ) );
            if nargout > 0
                varargout{ 1 } = cycleGraph;
            else
                plot( cycleGraph );
            end
        end

        function valid = get.Valid( this )
            valid = isempty( this.Errors ) && ~isempty( this.Schema );
        end

        function errMsgs = get.ErrorMessages( this )
            if ~isempty( this.Errors )
                errMsgs = { this.Errors.message };
            else
                errMsgs = {  };
            end
        end

        function files = get.VisitedFiles( this )
            if ~isempty( this.Visited )
                files = cell( 1, numel( this.Visited ) );
                for i = 1:numel( files )
                    files{ i } = [ { this.Visited( i ).rootFile }, this.Visited( i ).fragmentFiles ];
                end
                files = unique( [ files{ : } ], 'stable' );
                files( cellfun( 'isempty', files ) ) = [  ];
            else
                files = {  };
            end
        end

        function fileMode = get.FileMode( this )
            fileMode = ~isempty( this.ContextStack ) && ~isempty( this.ContextStack( end  ).rootFile );
        end

        function rootDir = get.RootDir( this )
            if this.FileMode && ~isempty( this.ContextStack )
                rootDir = fileparts( this.ContextStack( end  ).rootFile );
            else
                rootDir = '';
            end
        end

        function yes = get.IsRootSchema( this )
            yes = isscalar( this.ContextStack );
        end

        function rules = get.Rules( this )
            rules = this.ContextStack( end  ).rules;
        end

        function uvs = get.UserVisibleStrategy( this )
            uvs = this.TypeManager.UserVisibleStrategy;
        end

        function base = get.BaseStrategy( this )
            base = this.TypeManager.BaseStrategy;
        end

        function dump( this )
            if isempty( this.Schema )
                return
            end
            if ~isempty( this.Errors )
                svprintf( '\n--------------- <strong>ERRORS (%d)</strong> ----------------\n\n', numel( this.Errors ) );
                this.dumpMessages( this.Errors );
            else
                svprintf( '\n\t<strong>Schema is valid</strong>\n\n' );
            end
            if ~isempty( this.Warnings )
                svprintf( '\n--------------- <strong> WARNINGS (%d)</strong> ---------------\n\n', numel( this.Warnings ) );
                this.dumpMessages( this.Warnings );
            end
        end

        function [ schema, preInitKeys ] = preInitSchema( this, varargin )
            arguments
                this( 1, 1 )
            end
            arguments( Repeating )
                varargin
            end

            if isempty( this.Schema ) || ~this.Valid
                error( 'Pre-initializing requires a validated schema' );
            end


            paramDefs = this.Data.Params.toArray(  );
            catDefs = this.Data.Categories.toArray(  );
            ordered = [ paramDefs, catDefs ];
            [ ~, sortIdx ] = sort( [ ordered.Ordinal ] );
            ordered = ordered( sortIdx );
            canPreInits = zeros( size( ordered ) );
            for i = 1:numel( ordered )
                canPreInits( i ) = canPreInitObject( ordered( i ) );
                reqs = ordered( i ).Requires;
                if canPreInits( i ) == 1 && ~all( [ reqs.Ordinal ] ~= 0 )

                    canPreInits( i ) = 0;
                end
            end
            ordered = ordered( canPreInits ~= 0 );


            preInitKeys = { ordered.Key };
            configuration = coderapp.internal.config.Configuration( this.Schema,  ...
                varargin{ : },  ...
                'Parent', this,  ...
                'ResolveMessages', false,  ...
                'PreInitTarget', this.Data,  ...
                'PreInitKeys', preInitKeys,  ...
                'Debug', this.Verbose );
            this.Data.RuntimeState.Preinitialized = true;


            schema = this.createSchema(  );
            configuration.delete(  );
        end

        function saveDotFile( this, file )
            if isempty( this.DependencyGraph )
                error( 'No dependency graph available' );
            end
            graph = this.DependencyGraph;

            shapes = repmat( { 'box' }, size( graph.Nodes.Type ) );
            colors = repmat( { 'grey' }, size( graph.Nodes.Type ) );
            fills = repmat( { 'grey' }, size( graph.Nodes.Type ) );
            [ matched, typeIdx ] = ismember( graph.Nodes.Type, { 'Param', 'Category', 'Production', 'Service' } );
            styleMap = {  ...
                'circle', 'doublecircle', 'star', 'diamond'
                'blue', 'darkgreen', 'goldenrod', 'darkviolet'
                'lightblue', 'lightgreen', 'gold', 'violet'
                };
            shapes( matched ) = styleMap( 1, typeIdx( matched ) );
            colors( matched ) = styleMap( 2, typeIdx( matched ) );
            fills( matched ) = styleMap( 3, typeIdx( matched ) );
            nodeSection = strcat( graph.Nodes.Name, { ' [shape=' }, shapes, ',color=', colors, ',fillcolor=', fills, ',style=filled]' );

            edges = graph.Edges.EndNodes;
            types = graph.Edges.Type;
            edgeSection = cell( size( edges, 1 ), 1 );
            for i = 1:numel( edgeSection )
                switch types{ i }
                    case 'contains'
                        edgeColor = 'darkgreen';
                        edgeStyle = 'dashed';
                    case 'contributes'
                        edgeColor = 'darkorange';
                        edgeStyle = 'bold';
                    otherwise
                        edgeColor = 'black';
                        edgeStyle = 'solid';
                end
                edgeSection{ i } = sprintf( '%s -> %s [color=%s,style=%s]', edges{ i, : }, edgeColor, edgeStyle );
            end

            body = strjoin( strcat( { sprintf( '\t' ) }, [ '// Nodes';nodeSection;newline;'// Edges';edgeSection ] ), newline );
            [ ~, graphName ] = fileparts( this.LastValidatedFile );
            if isempty( graphName )
                graphName = 'schema';
            end
            [ ~, ~, ext ] = fileparts( file );
            if isempty( ext )
                file = [ file, '.dot' ];
            end
            fid = fopen( file, 'w', 'n', 'utf-8' );
            fprintf( fid, 'digraph %s {\n%s\n}', graphName, body );
            fclose( fid );
        end
    end

    methods ( Access = private )
        function reset( this, keepResults )
            arguments
                this
                keepResults( 1, 1 )logical = false
            end

            this.ContextStack = struct( 'rootFile', {  }, 'rules', {  }, 'ownKeys', {  }, 'stack', {  }, 'fragmentFiles', {  } );
            this.Labels = [  ];
            this.ByKey = [  ];
            this.DeclStacks = [  ];
            this.TypeManager = [  ];
            this.ProducerMap = [  ];
            this.DefaultPerspectiveId = '';
            this.RuntimeState = coderapp.internal.config.runtime.ConfigurationState.empty(  );
            this.Stack = {  };
            this.MustBeCategorized = {  };

            if ~keepResults
                this.Visited = this.ContextStack;
                this.Data = coderapp.internal.config.schema.SchemaData.empty(  );
                this.MfzModel = mf.zero.Model.empty(  );
                this.Schema = coderapp.internal.config.Schema.empty(  );
                this.Errors = struct( 'message', {  }, 'stack', {  }, 'rootFile', {  } );
                this.Warnings = this.Errors;
                this.DependencyGraph = [  ];
                this.LastValidatedFile = '';
                this.DebugInfo = coderapp.internal.config.util.SchemaDebugInfo.empty(  );
            end
        end

        function outputs = doValidate( this, rootArg, isFile, nOut )
            this.MfzModel = mf.zero.Model(  );
            this.unlock(  );
            txn = this.MfzModel.beginTransaction(  );

            this.Data = coderapp.internal.config.schema.SchemaData( this.MfzModel );
            this.RuntimeState = coderapp.internal.config.runtime.ConfigurationState( this.MfzModel );
            this.RuntimeState.ConfigStore = coderapp.internal.ext.ConfigStore( this.MfzModel );
            this.Data.RuntimeState = this.RuntimeState;
            this.TypeManager = this.SharedTypeManager;
            this.ProducerMap = containers.Map(  );
            this.ByKey = containers.Map(  );
            this.DeclStacks = containers.Map(  );

            if this.Verbose
                this.DebugInfo = coderapp.internal.config.util.SchemaDebugInfo(  );
            end

            if isFile
                this.loadAndValidateRoot( rootArg );
            else
                this.ContextStack = struct( 'rootFile', { '' }, 'rules', { struct }, 'ownKeys', { {  } }, 'fragmentFiles', { {  } } );
                this.validateRoot( rootArg );
            end
            if this.SaveTypeManager
                this.Data.ParamTypeManager = this.TypeManager;
            end

            for el = this.Garbage
                el.destroy(  );
            end
            this.Garbage = mf.zero.ModelElement.empty(  );

            this.createSchema(  );
            txn.commit(  );

            if this.Schema.Valid && this.AutoPreInit
                try
                    this.preInitSchema(  );
                catch me
                    this.reset( true );
                    throw( me );
                end
            end

            this.reset( true );

            if nOut == 0 || this.Verbose
                this.dump(  );
            end
            if this.Assert
                if this.FileMode
                    format = { 'Invalid schema "%s"', this.ContextStack( end  ).rootFile };
                else
                    format = { 'Invalid schema' };
                end
                assert( this.Valid, format{ : } );
            end
            if nOut == 0
                outputs = {  };
            else
                outputs = { this.Schema, this.Errors, this.Warnings, this.DependencyGraph };
            end
        end

        function schema = createSchema( this )
            if this.OutputFormat == "xml"
                ser = mf.zero.io.XmlSerializer(  );
            else
                ser = mf.zero.io.JsonSerializer(  );
                ser.PrettyPrint = false;
            end
            ser.registerSequenceBasedId(  );
            str = ser.serializeToString( this.Data );
            schema = coderapp.internal.config.Schema.new( this.OutputFormat, str );
            schema.Valid = isempty( this.Errors );
            this.Schema = schema;
        end

        function valid = loadAndValidateRoot( this, rootFile, opts )
            arguments
                this
                rootFile
                opts.RelativeDir = ''
            end

            rootFile = resolveFile( rootFile, opts.RelativeDir );
            if ismember( rootFile, { this.Visited.rootFile } )
                this.logWarning( 'Schema file "%s" already mixed-in', rootFile );
                return
            end
            root = readJsonFile( rootFile );

            if this.Verbose
                if isempty( this.ContextStack )
                    this.DebugInfo.RootFile = rootFile;
                else
                    this.DebugInfo.MixinRootFiles{ end  + 1 } = rootFile;
                end
            end


            if ~isempty( this.ContextStack )
                this.ContextStack( end  ).stack = this.Stack;
            end
            this.Stack = {  };
            this.ContextStack( end  + 1 ) = struct( 'rootFile', { rootFile }, 'rules', { struct },  ...
                'ownKeys', { {  } }, 'stack', { {  } }, 'fragmentFiles', { {  } } );
            this.Visited( end  + 1 ) = this.ContextStack( end  );

            [ ~, rootName ] = fileparts( rootFile );
            this.validateRoot( root, rootName );


            this.Visited( end  ) = this.ContextStack( end  );
            this.ContextStack( end  ) = [  ];
            if ~isempty( this.ContextStack )
                this.Stack = this.ContextStack( end  ).stack;
            else
                this.Stack = {  };
            end

            valid = isempty( this.Errors );
            if valid
                this.LastValidatedFile = rootFile;
            else
                this.LastValidatedFile = '';
            end
        end

        function validateRoot( this, root, rootName )
            if ~isScalarStruct( root )
                if this.FileMode
                    this.logError( 'Schema root must be an object' );
                else
                    this.logError( 'Schema root must be a struct' );
                end
                return
            end
            if nargin < 3 || isempty( rootName )
                scopeArg = {  };
            else
                scopeArg = { rootName };
            end

            this.enterScope( scopeArg{ : } );
            this.validateStruct( root, true, 'fragments', 'mixedcell' );
            this.warnUnexpectedFields( root, this.ROOT_FIELDS );
            this.updateRules( root );


            if isfield( root, 'perspectives' )
                this.validatePerspectiveDefs( root.perspectives );
            end
            if isfield( root, 'tags' )
                this.validateTagDefs( root.tags );
            end
            if isfield( root, 'controllers' )
                this.validateControllers( root.controllers );
            end
            if isfield( root, 'customTypes' )
                this.validateCustomTypes( root.customTypes );
            end


            if isfield( root, 'mixins' )
                this.exitScope(  );
                if ~this.validateMixinSchemas( root.mixins )
                    this.logError( 'Cannot validate schema until all mixins are valid' );
                    return
                end
                this.enterScope( scopeArg{ : } );
            end



            if isfield( root, 'productions' )
                this.validateProductionDefs( root.productions );
            end
            if isfield( root, 'services' )
                this.validateServices( root.services );
            end
            if this.validateStruct( root, false, 'upgrade', 'string' )
                this.validateUpgradeHandler( root.upgrade );
            end
            this.validateMetadata( this.Data, root );

            if isfield( root, 'fragments' )
                this.validateFragments( root.fragments );
            end

            if this.IsRootSchema
                this.DependencyGraph = this.validateDependencyGraph( this.validateDependencyKeys(  ) );
                this.Data.DependencyGraph = this.DependencyGraph;
                this.Data.NodeCount = this.DependencyGraph.numnodes(  );

                this.postProcessCategoryContents(  );
                this.postProcessPerspectives(  );
                this.reorderProductionContributors(  );

                version = this.extractOptionalFields( root, 'version', 'integer' );
                if ~isempty( version )
                    this.Data.Version = version;
                    this.RuntimeState.ConfigStore.Version = version;
                end
            end

            this.exitScope(  );
        end

        function valid = validateMixinSchemas( this, mixins )
            valid = false;
            if ~this.FileMode
                this.logError( 'Can only use schema inheritance with file-based schemas' );
                return
            end
            if ~iscell( mixins )
                mixins = num2cell( mixins );
            end
            this.enterScope( 'mixins' );
            valid = true;
            for i = 1:numel( mixins )
                if ~coderapp.internal.util.isScalarText( mixins{ i } )
                    this.logError( '"mixins" should contain the path to the parent schema' );
                    valid = false;
                    break
                end
                if ~this.loadAndValidateRoot( mixins{ i }, RelativeDir = this.RootDir )
                    valid = false;
                end
            end
            this.exitScope(  );
        end

        function graph = validateDependencyKeys( this )
            keys = this.ByKey.keys(  );
            defs = this.ByKey.values(  );

            defTypes = cell( 1, numel( defs ) );
            for i = 1:numel( defs )
                defTypes{ i } = class( defs{ i } );
            end
            [ ~, defTypesId ] = ismember( defTypes, strcat( 'coderapp.internal.config.schema.',  ...
                { 'ParamDef', 'CategoryDef', 'ProductionDef', 'ServiceDef' } ) );
            assert( all( defTypesId ), 'Unexpected defType value' );
            defTypesRep = coderapp.internal.config.runtime.NodeType( { 'Param', 'Category', 'Production', 'Service' } );
            defTypes = defTypesRep( defTypesId );

            startKeys = cell( 1, numel( keys ) );
            isCat = false( 1, numel( keys ) );
            isParam = isCat;
            endIdx = startKeys;
            relationships = startKeys;

            for i = 1:numel( defs )
                def = defs{ i };
                missing = {  };
                this.enterScope( def.Key );
                switch defTypesId( i )
                    case 1
                        if ~isempty( def.Requires )
                            [ def.Requires, startKeys{ i }, resolvedIdx, missing ] = validateNodeRefs( def.Requires, keys );
                            if any( defTypesId( resolvedIdx ) == 2 )
                                this.logError( 'Params cannot depend on categories' );
                            end
                            relationships{ i } = repmat( { 'requires' }, numel( startKeys{ i } ), 1 );
                        end
                        isParam( i ) = true;
                    case 2
                        if ~isempty( def.Contents )
                            [ def.Contents, contentKeys, resolvedIdx, missingContents ] = validateNodeRefs( def.Contents, keys );
                            if ~isempty( intersect( [ 3, 4 ], defTypesId( resolvedIdx ) ) )
                                this.logError( 'Categories can only contain params and other categories' );
                            end
                        else
                            contentKeys = {  };
                            missingContents = {  };
                        end
                        if ~isempty( def.Requires )
                            [ def.Requires, requireKeys, ~, missingRequires ] = validateNodeRefs( def.Requires, keys );
                        else
                            requireKeys = {  };
                            missingRequires = {  };
                        end
                        relationships{ i } = [ repmat( { 'contains' }, numel( contentKeys ), 1 );repmat( { 'requires' }, numel( requireKeys ), 1 ) ];
                        [ startKeys{ i }, rIdx ] = unique( [ contentKeys, requireKeys ], 'stable' );
                        relationships{ i } = relationships{ i }( rIdx );
                        missing = unique( [ missingContents, missingRequires ], 'stable' );
                        isCat( i ) = true;
                    case 3
                        if ~isempty( def.Contributors )
                            [ def.Contributors, startKeys{ i }, resolvedIdx, missing ] = validateNodeRefs( def.Contributors, keys, true );
                            if any( defTypesId( resolvedIdx ) == 2 )
                                this.logError( 'Productions cannot depend on categories' );
                            end
                            relationships{ i } = repmat( { 'contributes' }, numel( startKeys{ i } ), 1 );
                        end
                    case 4
                    otherwise
                        error( 'Unhandled object class: %s', class( def ) );
                end
                if ~isempty( missing )
                    this.scopedLogError( def, 'Could not resolve dependencies: %s', strjoin( missing, ', ' ) );
                end
                endIdx{ i } = repmat( i, 1, numel( startKeys{ i } ) );
                if this.Verbose && isprop( def, 'Logic' ) && ~isempty( def.Logic )
                    this.warnOnUndeclaredDependencies( def, startKeys{ i }, keys );
                end
                this.exitScope(  );
            end

            startKeys = [ startKeys{ : } ];
            relationships = vertcat( relationships{ : } );
            if ~isempty( startKeys )
                [ resolved, startIdx ] = ismember( startKeys, keys );
                endIdx = [ endIdx{ : } ];
                endIdx = endIdx( resolved );
                relationships = relationships( resolved );
                startIdx = startIdx( resolved );
                edges = [ startIdx;endIdx ]';
            else
                edges = zeros( 0, 2 );
            end
            nodeTable = table( reshape( keys, [  ], 1 ), reshape( defTypes, [  ], 1 ), 'VariableNames', { 'Name', 'Type' } );
            edgeTable = table( edges, relationships, 'VariableNames', { 'EndNodes', 'Type' } );
            graph = digraph( edgeTable, nodeTable );
        end

        function graph = validateDependencyGraph( this, graph )
            cycles = getCycles( graph );
            if isempty( cycles )
                [ ~, graph ] = graph.toposort( 'Order', 'stable' );
                nodeDefs = this.ByKey.values( graph.Nodes.Name );
                nodeDefs = [ nodeDefs{ : } ];
                for i = 1:numel( nodeDefs )
                    nodeDefs( i ).Ordinal = i;
                    nodeDefs( i ).Successors = uint32( graph.successors( i ) );
                end
                if isempty( nodeDefs )
                    return
                end
            else
                for i = 1:numel( cycles )
                    keys = graph.Nodes.Name( cycles{ i } );
                    this.logError( 'Cycle detected: %s', strjoin( keys, ' -> ' ) );
                end
                return
            end


            keys = { nodeDefs.Key };
            ordinals = [ nodeDefs.Ordinal ];
            patchNodeRefs( this.Data.Params, 'Requires' );
            patchNodeRefs( this.Data.Categories, 'Requires', 'Contents' );
            patchNodeRefs( this.Data.Productions, 'Contributors' );

            function patchNodeRefs( defs, varargin )
                defs = defs.toArray(  );
                for ri = 1:numel( varargin )
                    refProp = varargin{ ri };
                    refs = [ defs.( refProp ) ];
                    if isempty( refs )
                        continue
                    end
                    [ ~, idx ] = ismember( { refs.Key }, keys );
                    refOrdinals = ordinals( idx );
                    mark = 1;
                    for def = defs
                        len = numel( def.( refProp ) );
                        subOrdinals = num2cell( refOrdinals( mark:( mark + len - 1 ) ) );
                        [ def.( refProp ).Ordinal ] = subOrdinals{ : };
                        mark = mark + len;
                    end
                end
            end
        end

        function enforceRequireCategories( this )
            params = this.ByKey.values( this.MustBeCategorized );
            params = [ params{ : } ];
            for param = params
                if ~param.InitialState.Internal && isempty( param.InitialState.Category )
                    this.scopedLogError( param, 'Param "%s" is not a member of any category', param.Key );
                end
            end
        end

        function postProcessPerspectives( this )
            if ~isempty( this.Errors ) || isempty( this.DependencyGraph ) || this.Data.Perspectives.Size == 0
                return
            end

            mask = false( 1, this.DependencyGraph.numnodes(  ) );
            for pers = this.Data.Perspectives.toArray(  )
                members = pers.InitialState.Members.toArray(  );
                [ ~, memberOrdinals ] = ismember( { members.Key }, this.DependencyGraph.Nodes.Name );
                mask( memberOrdinals ) = true;
                pers.MemberOrdinals = uint32( sort( memberOrdinals ) );
            end
            this.Data.NonPerspectiveOrdinals = uint32( find( ~mask ) );
        end

        function postProcessCategoryContents( this )


            cats = this.Data.Categories.toArray(  );
            [ ~, idx ] = sort( [ cats.Ordinal ] );
            cats = cats( idx );
            allContents = cell( 1, this.Data.NodeCount );
            validGraph = this.DependencyGraph.isdag(  );

            for categoryDef = cats
                if isempty( categoryDef.Contents )
                    continue
                end
                contents = { categoryDef.Contents.Key };
                contents = this.ByKey.values( contents( this.ByKey.isKey( contents ) ) );
                if validGraph
                    transRefs = cell( size( contents ) );
                    for i = 1:numel( contents )
                        transRefs{ i } = [ categoryDef.Contents( i ), allContents{ categoryDef.Contents( i ).Ordinal } ];
                    end
                    transRefs = [ transRefs{ : } ];
                    categoryDef.TransitiveContents = transRefs;
                    allContents{ categoryDef.Ordinal } = transRefs;
                end

                for i = 1:numel( contents )
                    categoryDef.InitialState.Contents.add( contents{ i }.InitialState );
                end
            end

            if ~isempty( this.MustBeCategorized )
                this.enforceRequireCategories(  );
            end
        end

        function reorderProductionContributors( this )
            ordered = this.DependencyGraph.Nodes.Name;
            for production = this.Data.Productions.toArray(  )
                [ ~, ~, idx ] = intersect( ordered, { production.Contributors.Key }, 'stable' );
                production.Contributors = production.Contributors( idx );
            end
        end

        function registerGlobal( this, def )
            this.ByKey( def.Key ) = def;
            this.ContextStack( end  ).ownKeys{ end  + 1 } = def.Key;
            this.recordDefinitionStack( def );
        end

        function recordDefinitionStack( this, def )
            this.DeclStacks( def.UUID ) = this.Stack;
        end

        function validateProductionDefs( this, productions )
            this.loopValidate( 'productions', productions, @validateProductionDef );

            function def = validateProductionDef( raw )
                def = [  ];
                if this.validateStruct( raw, true, 'key', 'string', 'producer', 'string' ) && ( ~this.Strict ||  ...
                        this.validateInstantiableClass( raw.producer, 'coderapp.internal.config.AbstractProducer' ) )
                    if ~this.validateKey( raw.key, false )
                        return
                    end
                    this.warnUnexpectedFields( raw, this.PRODUCTION_FIELDS );
                    [ requires, allowedClasses, constructorArgs ] = this.extractOptionalFields( raw,  ...
                        'requires', 'cellstr', 'allowedClasses', 'mixedcell', 'args', 'any' );
                    if isempty( constructorArgs )
                        constructorArgs = {  };
                    elseif ~iscell( constructorArgs )
                        constructorArgs = { constructorArgs };
                    end
                    try
                        producer = coderapp.internal.util.instantiateByName( raw.producer,  ...
                            'coderapp.internal.config.AbstractProducer', constructorArgs{ : } );
                    catch me
                        this.logError( 'Could not instantiate producer class %s: %s', raw.producer, me.message );
                        producer = [  ];
                    end

                    def = coderapp.internal.config.schema.ProductionDef( this.MfzModel );
                    state = coderapp.internal.config.runtime.ProductionState( this.MfzModel );
                    def.InitialState = state;
                    if ~isempty( constructorArgs )
                        def.ConstructorArgs = reshape( constructorArgs, 1, [  ] );
                    end
                    def.Key = raw.key;
                    state.Key = raw.key;
                    def.ProducerClass = raw.producer;
                    if ~isempty( requires )
                        def.Contributors = toNodeRefs( requires );
                    end
                    this.validateMetadata( def, raw );

                    if ~isempty( allowedClasses )
                        def.AllowedClasses = cellstr( allowedClasses );
                    end

                    this.registerGlobal( def );
                    this.Data.Productions.add( def );
                    this.RuntimeState.Productions.add( def.InitialState );
                    this.ProducerMap( raw.key ) = producer;
                    this.recordDebugInfo( 'production', raw.key );
                end
            end
        end

        function validateControllers( this, controllers )
            this.loopValidate( 'controllers', controllers, @validateController );

            function def = validateController( raw )
                if this.validateStruct( raw, true, 'id', 'string', 'class', 'string' ) && ( ~this.Strict ||  ...
                        this.validateInstantiableClass( raw.class, 'coderapp.internal.config.AbstractController' ) )
                    def = coderapp.internal.config.schema.ControllerDef(  );
                    def.Id = raw.id;
                    def.Class = raw.class;
                    this.Data.Controllers.add( def );
                else
                    def = [  ];
                end
            end
        end

        function validateFragments( this, fragments )
            if isempty( fragments )
                return
            elseif ~iscell( fragments )
                fragments = { fragments };
            end
            this.enterScope( 'fragments' );
            for i = 1:numel( fragments )
                this.loadAndValidateFragment( fragments{ i }, i );
            end
            this.exitScope(  );
        end

        function [ fragment, inline ] = loadAndValidateFragment( this, fragment, declIndex )
            fragmentName = num2str( declIndex );
            this.enterScope( fragmentName );
            inline = true;
            if coderapp.internal.util.isScalarText( fragment )
                if this.FileMode
                    [ ~, fragmentName ] = fileparts( fragment );
                    this.exitScope(  );
                    this.enterScope( fragmentName );
                    file = resolveFile( fragment, this.RootDir );
                    fragment = readJsonFile( file );
                    this.ContextStack( end  ).fragmentFiles{ end  + 1 } = file;
                    inline = false;

                    if this.Verbose
                        this.DebugInfo.FragmentFiles{ end  + 1 } = file;
                    end
                else
                    this.logError( 'Declaring fragments in files requires a physical schema file: %s', fragment );
                    fragment = [  ];
                end
            elseif ~isScalarStruct( fragment )
                if fileMode
                    this.logError( 'Fragment #%d must be declared as a relative file path or a inlined as an object', declIndex );
                else
                    this.logError( 'Fragment #%d must defined as a struct', declIndex );
                end
                fragment = [  ];
            else
                inline = true;
            end
            if ~isempty( fragment )
                this.validateFragment( fragment );
            end
            this.exitScope(  );
        end

        function validateFragment( this, fragment )
            if ~isScalarStruct( fragment )
                this.logError( 'Fragment definition does not have a top-level %s', this.Labels.singular );
                return
            end

            this.warnUnexpectedFields( fragment, this.FRAGMENT_FIELDS );
            defaults = this.validateFragmentDefaults( fragment );

            if isfield( fragment, 'params' )
                this.validateParamDefs( fragment.params, defaults );
            end
            if isfield( fragment, 'categories' )
                this.validateCategoryDefs( fragment.categories, defaults );
            end
        end

        function defaults = validateFragmentDefaults( this, fragment )
            [ rawDefaults, rawShared ] = this.extractOptionalFields( fragment, 'defaults', 'struct', 'shared', 'struct' );

            this.enterScope( 'defaults' );
            if isempty( rawDefaults )
                rawDefaults = struct(  );
            else
                this.warnUnexpectedFields( rawDefaults, this.DEFAULTS_FIELDS );
            end

            [ defaults.controller, defaults.internal, defaults.visible, defaults.enabled, defaults.transient,  ...
                defaults.derived, defaults.productionKey, defaults.perspectives, defaults.initDuringBuild, defaults.tags ] =  ...
                this.extractOptionalFields( rawDefaults,  ...
                'controllerId', 'string',  ...
                'internal', 'boolean',  ...
                'visible', 'boolean',  ...
                'enabled', 'boolean',  ...
                'transient', 'boolean',  ...
                'derived', 'boolean',  ...
                'productionKey', 'string',  ...
                'perspectives', 'any',  ...
                'stable', 'boolean',  ...
                'tags', 'any' );

            if ~isempty( defaults.controller )
                this.enterScope( 'controllerId' );
                this.validateControllerId( defaults.controller );
                this.exitScope(  );
            end
            if ~isempty( defaults.perspectives )
                defaults.perspectives = this.validatePerspectiveRefs( defaults.perspectives );
            end
            if ~isempty( defaults.tags )
                defaults.tags = this.validateTagRefs( defaults.tags );
            end
            if isempty( defaults.visible )
                defaults.visible = true;
            end
            if isempty( defaults.initDuringBuild )
                defaults.initDuringBuild = false;
            end
            this.exitScope(  );

            this.enterScope( 'shared' );
            if isempty( rawShared )
                rawShared = struct(  );
            else
                this.warnUnexpectedFields( rawShared, this.SHARED_FIELDS );
            end

            [ defaults.sharedControllers, defaults.sharedRequires, defaults.sharedTags ] = this.extractOptionalFields( rawShared,  ...
                'controllers', 'array', 'requires', 'cellstr', 'tags', 'any' );

            if ~isempty( defaults.sharedControllers )
                defaults.sharedControllers = this.validateControllerRefs( defaults.sharedControllers, defaults.controller );
                this.Garbage = [ this.Garbage, defaults.sharedControllers ];
            end
            if ~isempty( defaults.sharedRequires )
                defaults.sharedRequires = this.warnOnDuplicates( defaults.sharedRequires, 'shared.requires',  ...
                    'Duplicate dependencies were pruned' );
            else
                defaults.sharedRequires = {  };
            end
            if ~isempty( defaults.sharedTags )
                defaults.sharedTags = this.validateTagRefs( defaults.sharedTags );
            end
            this.exitScope(  );
        end

        function validateParamDefs( this, params, defaults )
            this.loopValidate( 'params', params, @( r )this.validateParamDef( r, defaults ) );
        end

        function def = validateParamDef( this, raw, defaults )
            def = [  ];
            if iscell( raw ) && isscalar( raw )
                raw = raw{ 1 };
            end
            if ~isScalarStruct( raw )
                this.logError( 'Param definition must be a %s', this.Labels.singular );
                return
            end
            this.warnUnexpectedFields( raw, this.PARAM_FIELDS );
            if ~this.validateStruct( raw, true, 'key', 'string', 'type', 'string' ) ||  ...
                    ~this.validateKey( raw.key, false )
                return
            end
            scopeCleanup = this.enterScope( raw.key );%#ok<NASGU>
            if ~this.validateKey( raw.key, false )
                return
            end
            if ~this.TypeManager.isType( raw.type )
                this.logError( 'Param type "%s" could not be resolved.' );
                return
            end

            def = coderapp.internal.config.schema.ParamDef( this.MfzModel );
            state = coderapp.internal.config.runtime.ParamState( this.MfzModel );
            def.InitialState = state;
            def.Key = raw.key;
            state.Key = raw.key;
            type = this.TypeManager.getType( raw.type );
            state.TypeName = type.Name;
            this.registerGlobal( def );

            [ transient, internal, derived, produces, awake ] = this.extractOptionalFields( raw,  ...
                'transient', 'boolean',  ...
                'internal', 'boolean',  ...
                'derived', 'boolean',  ...
                'produces', 'any',  ...
                'awake', 'boolean' );

            this.validateControllableDef( raw, def, type, defaults,  ...
                [ this.UserVisibleStrategy.Attributes;'Value' ] );
            state.Default = type.newDataObject( this.MfzModel );
            state.Default.Value = state.Data.Value;

            if isfield( raw, 'produces' )
                this.validateProductionRefs( def, produces );
            elseif ~isempty( defaults.productionKey )
                this.validateProductionRefs( def, defaults.productionKey );
            end
            if ~isempty( transient )
                state.Transient = transient;
            elseif ~isempty( defaults.transient )
                state.Transient = defaults.transient;
            end
            if ~isempty( derived )
                state.Derived = derived;
            elseif ~isempty( defaults.derived )
                state.Derived = defaults.derived;
            end
            if ~isempty( internal )
                state.Internal = internal;
            elseif ~isempty( defaults.internal )
                state.Internal = defaults.internal;
            end
            if ~state.Internal && this.Rules.requireNames
                this.validateNameRequirement( def );
            end
            if ~isempty( awake )
                state.Awake = awake;
            end

            this.Data.Params.add( def );
            this.RuntimeState.Params.add( state );
            if this.Rules.requireCategories
                this.MustBeCategorized{ end  + 1 } = raw.key;
            end
            this.recordDebugInfo( 'param', raw.key );
        end

        function validateNameRequirement( this, paramDef )
            if paramDef.InitialState.Internal
                return
            end
            if isempty( paramDef.InitialState.Data.Name ) && ~any( strcmp( 'Name', { paramDef.Logic.Attribute } ) )
                for follow = paramDef.Follows
                    if follow.Attribute == "Name"
                        return
                    end
                end
                unresolved = { paramDef.UnresolvedMessages.Path };
                for i = 1:numel( unresolved )
                    if ischar( unresolved{ i } ) && strcmp( unresolved{ i }, 'Name' )
                        return
                    end
                end
                this.logError( 'Param is missing a user-facing name' );
            end
        end

        function validateCategoryDefs( this, cats, defaults )
            if ~iscell( cats )
                if isstruct( cats )
                    cats = num2cell( cats );
                else
                    this.logError( 'Unexpected categories format' );
                    return
                end
            end
            this.loopValidate( 'categories', cats, @( c )this.validateCategoryDef( c, defaults ) );
        end

        function def = validateCategoryDef( this, raw, defaults )
            def = [  ];
            if coderapp.internal.util.isScalarText( raw )


                if this.ByKey.isKey( raw )
                    existing = this.ByKey( raw );
                    if isa( existing, 'coderapp.internal.config.schema.CategoryDef' )


                        if ~ismember( raw, this.ContextStack( end  ).ownKeys )

                            this.Data.Categories.add( existing );
                            this.RuntimeState.Categories.add( existing.InitialState );
                            return
                        end
                    end
                    this.logError( 'Can only move mixed-in root categories: %s is not a root category' );
                    return
                end
            end
            if ~isScalarStruct( raw )
                this.logError( 'Category definition must be a %s', this.Labels.singular );
                return
            elseif ~this.validateStruct( raw, true, 'key', 'string', 'contains', 'any' )
                return
            elseif ~this.validateKey( raw.key, false )
                return
            end
            this.warnUnexpectedFields( raw, this.CATEGORY_FIELDS );

            def = coderapp.internal.config.schema.CategoryDef( this.MfzModel );
            def.Key = raw.key;
            state = coderapp.internal.config.runtime.CategoryState( this.MfzModel );
            def.InitialState = state;
            state.Key = def.Key;

            if ~isempty( raw.contains )
                members = this.loopValidate( 'contains', raw.contains, @validateContains );
                if ~isempty( members )
                    def.Contents = toNodeRefs( this.warnOnDuplicates( members, 'contains', 'Duplicate members were pruned' ) );
                end
            end
            this.validateControllableDef( raw, def, this.UserVisibleStrategy, defaults );

            this.Data.Categories.add( def );
            this.RuntimeState.Categories.add( state );
            this.registerGlobal( def );
            this.recordDebugInfo( 'category', raw.key );

            function refKey = validateContains( ref )
                refKey = '';
                if isScalarStruct( ref )
                    if isfield( ref, 'contains' )
                        inlineDef = this.validateCategoryDef( ref, defaults );
                    else
                        inlineDef = this.validateParamDef( ref, defaults );
                    end
                    if ~isempty( inlineDef )
                        refKey = inlineDef.Key;
                    end
                elseif coderapp.internal.util.isScalarText( ref )
                    refKey = ref;
                else
                    this.logError( 'Elements should be category/param keys or full category/param definitions' );
                end
            end
        end

        function extraRequires = validateControllableDef( this, raw, def, doStrat, defaults, initMixinFilter )
            if nargin < 6
                initMixinFilter = {  };
            else
                initMixinFilter = { initMixinFilter };
            end
            defaultControllerId = defaults.controller;
            if ~isempty( defaults.sharedControllers )
                for i = 1:numel( defaults.sharedControllers )
                    def.Controllers( end  + 1 ) = cloneControllerRef( this.MfzModel, defaults.sharedControllers( i ) );
                end
            end

            [ requires, eval, controller, follows, init, tags, initDuringBuild ] = this.extractOptionalFields( raw,  ...
                'requires', 'cellstr', 'eval', 'struct', 'controller', 'any', 'follows', 'struct',  ...
                'init', 'struct', 'tags', 'any', 'stable', 'boolean' );

            if ~isempty( eval )
                this.enterScope( 'eval' );
                this.validateEval( def, eval, doStrat.Attributes );
                this.exitScope(  );
            end
            if ~isempty( controller )
                this.enterScope( 'controller' );
                this.validateControllerRefs( controller, defaultControllerId, def );
                this.exitScope(  );
            end
            if ~isempty( follows )
                this.enterScope( 'follows' );
                extraRequires = this.validateFollows( follows, def, doStrat );
                this.exitScope(  );
            else
                extraRequires = {  };
            end
            if ~isempty( requires )
                requires = this.warnOnDuplicates( requires, 'requires', 'Duplicate dependencies were pruned' );
            end
            def.Requires = toNodeRefs( unique( [ defaults.sharedRequires;requires;extraRequires ], 'stable' ) );

            this.enterScope( 'init' );
            [ iState, def.UnresolvedMessages ] = this.validateInit( doStrat, init, raw, defaults, initMixinFilter{ : } );
            this.exitScope(  );
            if ~isempty( iState )
                def.InitialState.Data = iState;
            else
                def.InitialState.Data = doStrat.newDataObject( this.MfzModel );
            end

            this.enterScope( 'perspectives' );
            if isfield( raw, 'perspectives' )
                perspectives = this.validatePerspectiveRefs( raw.perspectives, def );
            elseif ~isempty( defaults.perspectives )
                perspectives = defaults.perspectives;
                this.registerPerspectiveMember( perspectives, def );
            else
                perspectives = {  };
            end
            this.exitScope(  );
            def.InitialState.InPerspective = isempty( perspectives ) ||  ...
                any( strcmp( this.DefaultPerspectiveId, perspectives ) );
            def.InitialState.EffectiveVisible = def.InitialState.InPerspective && def.InitialState.Data.Visible;

            tagDefs = [  ];
            if isfield( raw, 'tags' )
                if ~isempty( tags )
                    tagDefs = this.validateTagRefs( tags, def );
                end
            elseif ~isempty( defaults.tags )
                tagDefs = defaults.tags;

            end
            if ~isempty( defaults.sharedTags )
                tagDefs = unique( [ defaults.sharedTags, tagDefs ], 'stable' );
            end
            for i = 1:numel( tagDefs )
                tagDefs( i ).Tagged.add( def.InitialState );
            end

            this.validateMessageKeys( def );

            finalInitDuringBuild = false;
            if isfield( raw, 'stable' )
                if ~isempty( initDuringBuild )
                    finalInitDuringBuild = initDuringBuild;
                end
            else
                finalInitDuringBuild = defaults.initDuringBuild;
            end
            def.InitDuringBuild = finalInitDuringBuild;

            this.validateMetadata( def, raw );
        end

        function extraDeps = validateFollows( this, follows, def, doStrat )
            attrs = doStrat.Attributes;
            followed = fieldnames( follows );
            [ found, idx ] = ismember( lower( followed ), lower( attrs ) );
            unresolved = followed( ~found );
            if ~isempty( unresolved )
                this.logError( 'Unresolved attributes: %s', strjoin( unresolved, ', ' ) );
                idx = idx( found );
            end
            followed = attrs( idx );

            rawExprs = struct2cell( follows );
            extraDeps = {  };
            if isempty( rawExprs )
                return
            end

            for i = 1:numel( rawExprs )
                if isempty( doStrat.MfzMetaClass.getPropertyByName( followed{ i } ) )
                    this.scopedLogError( followed{ i }, 'Not a valid attribute' );
                    continue
                end
                try

                    [ parsed, ~, referred ] = coderapp.internal.config.expr.parse( rawExprs{ i }, this.MfzModel );
                catch me
                    this.scopedLogError( followed{ i }, 'Invalid follows expression: %s', me.message );
                    continue
                end
                entry = coderapp.internal.config.schema.FollowsDef( this.MfzModel );
                entry.Attribute = followed{ i };
                entry.Expr = parsed;
                def.Follows( end  + 1 ) = entry;
                extraDeps( end  + 1:end  + numel( referred ), 1 ) = referred;
            end
        end

        function validateMetadata( this, def, raw )
            metadata = this.extractOptionalFields( raw, 'metadata', 'struct' );
            if ~isempty( metadata )
                if isprop( def, 'InitialState' )
                    owner = def.InitialState;
                else
                    owner = def;
                end
                this.enterScope( 'metadata' );
                mdIds = fieldnames( metadata );
                for i = 1:numel( mdIds )
                    md = coderapp.internal.config.runtime.Metadata( this.MfzModel );
                    md.Property = mdIds{ i };
                    md.Value = metadata.( mdIds{ i } );
                    codergui.internal.form.transportValue( md, md.Value );
                    owner.Metadata.add( md );
                end
                this.exitScope(  );
            end
        end

        function refs = validateControllerRefs( this, raw, defaultControllerId, ownerDef )
            if coderapp.internal.util.isScalarText( raw )
                raw = { raw };
            end
            if iscell( raw ) || ~isscalar( raw )
                refs = this.loopValidate( '', raw, @( c )this.validateControllerRef( c, defaultControllerId ) );
                refs = [ refs{ : } ];
            else
                refs = this.validateControllerRef( raw, defaultControllerId );
            end
            if isempty( refs )
                refs = coderapp.internal.config.schema.ControllerRef.empty(  );
            elseif nargin > 3 && ~isempty( ownerDef )
                for i = 1:numel( refs )
                    ownerDef.Controllers( end  + 1 ) = refs( i );
                end
            end
        end

        function ref = validateControllerRef( this, raw, defaultControllerId )
            ref = [  ];
            if ~isempty( raw )
                if coderapp.internal.util.isScalarText( raw )
                    if ~isempty( defaultControllerId )
                        if ~isempty( this.Data.Controllers.getByKey( defaultControllerId ) )

                            ref = coderapp.internal.config.schema.ControllerRef( this.MfzModel );
                            ref.Id = defaultControllerId;
                            methodRef = coderapp.internal.config.schema.MethodRef( this.MfzModel );
                            methodRef.Method = raw;
                            ref.Update = methodRef;
                        else
                            this.logWarning( 'Ignoring controller method specification(s) due to invalid defaults.controllerId' );
                        end
                    else
                        this.logError( [ 'Using the shorthand "update" method name requires ' ...
                            , 'specifying a default controller on the fragment' ] );
                    end
                elseif isScalarStruct( raw )
                    if isfield( raw, 'id' )
                        if this.validateStruct( raw, true, 'id', 'string' )
                            if ~isempty( this.Data.Controllers.getByKey( raw.id ) )
                                controllerId = raw.id;
                            else
                                this.logError( 'Could not find controller with id of "%s"', raw.id );
                                return
                            end
                        else
                            return
                        end
                    elseif isempty( defaultControllerId )
                        this.validateStruct( raw, true, 'id', 'string' );
                        return
                    elseif isempty( this.Data.Controllers.getByKey( defaultControllerId ) )
                        this.logWarning( 'Ignoring controller method specification(s) due to invalid defaults.controllerId' );
                        return
                    else
                        controllerId = defaultControllerId;
                    end
                    if ~isempty( controllerId )
                        ref = coderapp.internal.config.schema.ControllerRef( this.MfzModel );
                        ref.Id = controllerId;
                        this.warnUnexpectedFields( raw, this.CONTROLLER_FIELDS );
                        [ initialize, validate, update, postSet, importer, exporter, toCode ] = this.extractOptionalFields( raw,  ...
                            'initialize', 'any', 'validate', 'any', 'update', 'any', 'postSet', 'any',  ...
                            'import', 'any', 'export', 'any', 'toCode', 'any' );
                        if ~isempty( initialize )
                            ref.Initialize = this.validateMethodRef( 'initialize', initialize, true );
                        end
                        if ~isempty( validate )
                            ref.Validate = this.validateMethodRef( 'validate', validate, false );
                        end
                        if ~isempty( update )
                            ref.Update = this.validateMethodRef( 'update', update, true );
                        end
                        if ~isempty( postSet )
                            ref.PostSet = this.validateMethodRef( 'postSet', postSet, false );
                        end
                        if ~isempty( importer )
                            ref.Import = this.validateMethodRef( 'import', importer, false );
                        end
                        if ~isempty( exporter )
                            ref.Export = this.validateMethodRef( 'export', exporter, false );
                        end
                        if ~isempty( toCode )
                            ref.ToCode = this.validateMethodRef( 'toCode', toCode, false );
                        end
                    end
                else
                    this.logError( 'controller %s should contain a %s', raw.id, this.Labels.container );
                end
            end
            if isempty( ref )
                return
            end
            if ~this.validateControllerMethods( ref )
                ref.destroy(  );
            end
        end

        function def = validateMethodRef( this, scope, raw, allowArgs )
            this.enterScope( scope );
            def = coderapp.internal.config.schema.MethodRef.empty(  );
            if coderapp.internal.util.isScalarText( raw )
                def = coderapp.internal.config.schema.MethodRef( this.MfzModel );
                def.Method = raw;
            elseif isScalarStruct( raw )
                if this.validateStruct( raw, true, 'method', 'string' )
                    def = coderapp.internal.config.schema.MethodRef( this.MfzModel );
                    def.Method = raw.method;
                    if isfield( raw, 'args' ) && this.validateStruct( raw, false, 'args', 'any' )
                        if allowArgs
                            args = raw.args;
                            if ~iscell( args )
                                args = { args };
                            end
                            def.ConstantArgs = reshape( args, 1, [  ] );
                            def.UseConstantArgs = true;
                        else
                            this.logWarning( 'Custom arguments specification for %s methods are not allowed and will be ignored', scope );
                        end
                    end
                end
            else
                this.logError( 'Unexpected controller method specification format' );
            end
            this.exitScope(  );
        end

        function validateProductionRefs( this, ownerDef, raw )
            if ~isempty( raw )
                if ischar( raw )
                    raw = { raw };
                end
                this.loopValidate( 'produces', raw,  ...
                    @( r )this.validateProductionRef( ownerDef, r ) );
            end
        end

        function def = validateProductionRef( this, ownerDef, raw )
            def = [  ];
            if ~isempty( raw )
                if coderapp.internal.util.isScalarText( raw )

                    def = coderapp.internal.config.schema.ProductionRef( this.MfzModel );
                    def.TargetKey = raw;
                    def.ProductionConfig = struct(  );
                elseif isScalarStruct( raw )
                    if this.validateStruct( raw, true, 'targetKey', 'string' )
                        def = coderapp.internal.config.schema.ProductionRef( this.MfzModel );
                        def.TargetKey = raw.targetKey;
                        def.ProductionConfig = rmfield( raw, 'targetKey' );
                    end
                else
                    this.logError( 'production %s should contain a %s', this.Labels.container );
                end
            end
            if isempty( def )
                return
            end

            if this.ProducerMap.isKey( def.TargetKey )
                producer = this.ProducerMap( def.TargetKey );
                if ~isempty( producer )
                    [ def.ProductionConfig, valid ] = this.delegatedValidate( producer, def.ProductionConfig,  ...
                        'Warning when validating production config for "%s"',  ...
                        'Invalid production config for production "%s"',  ...
                        'Error validating production config for production "%s"',  ...
                        def.TargetKey );
                else
                    this.logWarning( 'Skipping production reference validation due to invalid production "%s"', def.TargetKey );
                    valid = true;
                end
                producerDef = this.ByKey( def.TargetKey );
                producerDef.Contributors( end  + 1 ) = toNodeRefs( { ownerDef.Key } );
            else
                this.logError( 'Could not resolve production with key of "%s"', def.TargetKey );
                valid = false;
            end
            if valid
                ownerDef.ProductionRefs.add( def );
            else
                def.destroy(  );
                def = [  ];
            end
        end

        function [ dataObj, allUnresolvedMsgs ] = validateInit( this, type, init, mixin, defaults, mixinFilter )
            arguments
                this
                type
                init struct
                mixin = [  ]
                defaults = [  ]
                mixinFilter = this.UserVisibleStrategy.Attributes
            end

            if isempty( init )
                init = struct(  );
            end
            if ischar( type )
                type = this.TypeManager.getType( type );
            end
            init = normalizeFieldCase( init, type.Attributes );
            if nargin > 3 && ~isempty( mixin )
                init = mixinFields( init, normalizeFieldCase( mixin, mixinFilter ), mixinFilter );
            end
            if nargin > 4 && ~isempty( defaults )
                if ~isfield( init, 'Visible' ) && ~isempty( defaults.visible )
                    init.Visible = defaults.visible;
                end
                if ~isfield( init, 'Enabled' ) && ~isempty( defaults.enabled )
                    init.Enabled = defaults.enabled;
                end
            end
            escapeMode = this.Rules.userFacingStringEscape;
            allUnresolvedMsgs = coderapp.internal.config.schema.UnresolvedMessage.empty(  );

            initFields = fieldnames( init );
            useSchemaImport = this.UseSchemaImport;
            processed = struct(  );
            if useSchemaImport
                mayBeMessage = ismember( initFields, type.MessageAttributes );
            end

            try
                for i = 1:numel( initFields )
                    if useSchemaImport
                        if mayBeMessage( i )
                            [ processed.( initFields{ i } ), unresolvedMsgs ] = type.fromSchema(  ...
                                initFields{ i }, init.( initFields{ i } ), this.MfzModel, escapeMode );
                        else
                            processed.( initFields{ i } ) = type.fromSchema(  ...
                                initFields{ i }, init.( initFields{ i } ) );
                            unresolvedMsgs = [  ];
                        end
                        if ~isempty( unresolvedMsgs )
                            allUnresolvedMsgs( end  + 1:end  + numel( unresolvedMsgs ) ) = unresolvedMsgs;
                        end
                    else
                        processed.( initFields{ i } ) = type.import( initFields{ i }, init.( initFields{ i } ) );
                    end
                end
                dataObj = type.newDataObject( this.MfzModel, processed );
            catch me
                this.logError( me.message );
                dataObj = type.newDataObject( this.MfzModel );
            end
        end

        function validateEval( this, ownerDef, evalDef, attrs )
            evalDef = normalizeFieldCase( evalDef, attrs );
            this.warnUnexpectedFields( evalDef, attrs );
            common = intersect( attrs, fieldnames( evalDef ) );
            this.loopValidate( '', num2cell( 1:numel( common ) ), @validateEvalEntry );

            function entry = validateEvalEntry( idx )
                entry = [  ];
                code = evalDef.( common{ idx } );
                if isScalarStruct( code )
                    if ~this.validateStruct( code, true, 'code', 'string' )
                        return
                    end
                    constant = this.extractOptionalFields( code, 'constant', 'boolean' );
                    code = code.code;
                elseif coderapp.internal.util.isScalarText( code )
                    constant = false;
                else
                    this.logError( 'Unexpected format for eval' );
                    return
                end
                mt = mtree( code );
                if mt.root.kind(  ) == "ERR"
                    this.logError( 'Not valid MATLAB Code: %s', code );
                    return
                elseif ~isempty( mt.root.Next.indices(  ) )
                    this.logError( 'Expected a single expression: %s', code );
                    return
                elseif ~isempty( mt.mtfind( 'Kind', 'EQUALS' ).indices(  ) )
                    this.logError( 'Assignments are not supported: %s', code );
                    return
                end
                entry = coderapp.internal.config.schema.EvalDef(  );
                entry.Attribute = common{ idx };
                entry.Code = code;
                entry.Constant = constant;
                ownerDef.Logic( end  + 1 ) = entry;
            end
        end

        function valid = validateControllerMethods( this, ref )
            controllerDef = this.Data.Controllers.getByKey( ref.Id );
            methodRefs = [ ref.Initialize, ref.Update, ref.PostSet, ref.Validate, ref.Import, ref.Export, ref.ToCode ];
            isConverters = [ false, false, false, true, true, true ];
            testMethods = { methodRefs.Method };
            testMethods = testMethods( ~cellfun( 'isempty', testMethods ) );
            allMethods = meta.class.fromName( controllerDef.Class ).MethodList;
            allMethods = allMethods( cellfun( 'isclass', { allMethods.Access }, 'char' ) );
            allMethods = allMethods( { allMethods.Access } == "public" );
            [ found, mIdx ] = ismember( testMethods, { allMethods.Name } );

            if all( found )
                valid = true;
            else
                this.logError( 'Controller methods are not public methods of %s: %s',  ...
                    controllerDef.Class, strjoin( testMethods( ~found ), ', ' ) );
                mIdx( ~found ) = [  ];
                methodRefs( ~found ) = [  ];
                valid = false;
            end

            for i = 1:numel( methodRefs )
                methodRef = methodRefs( i );
                isConverter = isConverters( i );

                realMethod = allMethods( mIdx( i ) );
                nIn = numel( realMethod.InputNames );
                hasVarargin = nIn > 0 && strcmp( realMethod.InputNames{ end  }, 'varargin' );
                if hasVarargin
                    nIn = Inf;
                elseif ~realMethod.Static
                    nIn = nIn - 1;
                end

                if isConverter && ( nIn < 1 || isempty( realMethod.OutputNames ) )
                    this.scopedLogError( methodRef.Method,  ...
                        'Value converter methods must have at least one input and one output' );
                elseif ~isConverter && methodRef.UseConstantArgs && numel( methodRef.ConstantArgs ) > nIn
                    this.scopedLogError( methodRef.Method,  ...
                        'Controller method only has %d inputs but will be called with %d argument(s)',  ...
                        nIn, numel( methodRef.ConstantArgs ) );
                end

                methodRef.Static = realMethod.Static;
                methodRef.DynamicArgCount = nIn;
            end
        end

        function validateCustomTypes( this, customTypes )
            if ~iscell( customTypes )
                this.logError( 'customTypes %s should contain an array of strings', this.Labels.singular );
                return
            end
            this.loopValidate( 'customTypes', customTypes, @validateCustomType );

            function type = validateCustomType( typeClass )
                type = [  ];
                if coderapp.internal.util.isScalarText( typeClass )
                    if this.TypeManager == this.SharedTypeManager
                        this.TypeManager = coderapp.internal.config.ParamTypeManager(  );
                    end
                    try
                        this.TypeManager.registerTypes( typeClass );
                    catch me
                        this.logError( me.message );
                        return
                    end
                    this.Data.CustomTypes{ end  + 1 } = typeClass;
                else
                    this.logError( 'Custom types array should contain names of type implementation classes' );
                end
            end
        end

        function validateTagDefs( this, tagDefsRaw )
            this.loopValidate( 'tags', tagDefsRaw, @validateTagDef );

            function tagDef = validateTagDef( raw )
                tags = this.RuntimeState.Tags.toArray(  );
                tagDef = this.parseGenericDef( 'coderapp.internal.config.runtime.TagState',  ...
                    'coderapp.internal.config.schema.TagDef', raw, { tags.Id } );
                if ~isempty( tagDef )
                    this.RuntimeState.Tags.add( tagDef.InitialState );
                    this.Data.Tags.add( tagDef );
                    tagType = this.extractOptionalFields( raw, 'type', 'string' );
                    if isempty( tagType )
                        tagType = 'GENERIC';
                    elseif ~ismember( upper( tagType ), string( enumeration( 'coderapp.internal.config.runtime.TagType' ) ) )
                        this.logError( 'Invalid tag type "%s"', tagType );
                        return
                    else
                        tagType = upper( tagType );
                    end
                    tagDef.InitialState.Type = tagType;
                end
            end
        end

        function result = parseGenericDef( this, stateClass, defClass, raw, existingIds )
            result = [  ];
            if ~this.validateStruct( raw, true, 'id', 'string' )
                this.logError( 'Must specify an id' );
                return
            end
            if nargin > 2 && ismember( raw.id, existingIds )
                this.logError( 'IDs should be unique: %s', raw.id );
                return
            end
            result = feval( defClass, this.MfzModel, struct(  ...
                'Id', raw.id,  ...
                'InitialState', feval( stateClass, this.MfzModel, struct( 'Id', raw.id ) ) ) );
            init = this.extractOptionalFields( raw, 'init', 'struct' );
            [ parsed, result.UnresolvedMessages ] = this.validateInit( this.UserVisibleStrategy, init, raw );
            result.InitialState.Name = parsed.Name;
            result.InitialState.Description = parsed.Description;
            this.validateMetadata( result, raw );
            this.validateMessageKeys( result );
            parsed.destroy(  );
        end

        function tagDefs = validateTagRefs( this, tags, ownerDef )
            if nargin < 3
                ownerDef = [  ];
            end
            tags = cellstr( tags );
            tagDefs = coderapp.internal.config.schema.TagDef.empty(  );
            this.loopValidate( 'tags', tags, @validateTagRef );

            function raw = validateTagRef( raw )
                if ~coderapp.internal.util.isScalarText( raw )
                    this.logError( 'Tags must be strings' );
                else
                    tag = this.RuntimeState.Tags.getByKey( raw );
                    if isempty( tag )
                        this.logError( 'No tag with ID of "%s" is defined', raw );
                    else
                        tagDefs( end  + 1 ) = tag;
                        if ~isempty( ownerDef )
                            tag.Tagged.add( ownerDef.InitialState );
                        end
                    end
                end
            end
        end

        function validateServices( this, services )
            this.loopValidate( 'services', services, @validateServiceId );

            function service = validateServiceId( service )
                if this.validateKey( service, false )
                    arg.Key = service;
                    def = coderapp.internal.config.schema.ServiceDef( this.MfzModel, arg );
                    this.registerGlobal( def );
                    this.Data.Services.add( def );
                    this.recordDebugInfo( 'service', service );
                else
                    service = [  ];
                end
            end
        end

        function validatePerspectiveDefs( this, rawArr )
            this.loopValidate( 'perspectives', rawArr, @validatePerspectiveDef );

            function def = validatePerspectiveDef( raw )
                def = this.parseGenericDef( 'coderapp.internal.config.runtime.PerspectiveState',  ...
                    'coderapp.internal.config.schema.PerspectiveDef', raw, this.Data.Perspectives.keys(  ) );
                if isempty( def )
                    return
                end
                this.warnUnexpectedFields( raw, this.PERSPECTIVE_FIELDS );
                [ members, default ] = this.extractOptionalFields( raw,  ...
                    'members', 'cellstr', 'default', 'boolean' );
                if ~isempty( members )
                    def.Members = members;
                end
                if ~isempty( default )
                    if default
                        allPers = this.RuntimeState.Perspectives.toArray(  );
                        if any( [ allPers.IsDefault ] )
                            this.logError( 'Multiple perspectives were marked as default: %s', strjoin( { allPers.Id, def.Id }, ', ' ) );
                        end
                    end
                    def.InitialState.IsDefault = default;
                    def.InitialState.IsActive = default;
                    if default
                        this.DefaultPerspectiveId = def.InitialState.Id;
                    end
                end
                this.validateMetadata( def, raw );
                this.Data.Perspectives.add( def );
                this.RuntimeState.Perspectives.add( def.InitialState );
            end
        end

        function perspectives = validatePerspectiveRefs( this, raw, ownerDef )
            arguments
                this
                raw
                ownerDef = [  ]
            end
            try
                perspectives = cellstr( raw );
            catch
                this.logError( 'Perspective references must be text or text arrays' );
                return
            end

            resolved = false( size( perspectives ) );
            for i = 1:numel( perspectives )
                perDef = this.Data.Perspectives.getByKey( perspectives{ i } );
                if isempty( perDef )
                    this.logError( 'Unrecognized perspective ID "%s"', perspectives{ i } );
                else
                    resolved( i ) = true;
                end
            end
            perspectives = perspectives( resolved );

            if ~isempty( perspectives ) && ~isempty( ownerDef )
                this.registerPerspectiveMember( perspectives, ownerDef );
            end
        end

        function registerPerspectiveMember( this, perspectives, ownerDef )
            perspectives = cellstr( perspectives );
            for i = 1:numel( perspectives )
                perDef = this.Data.Perspectives.getByKey( perspectives{ i } );
                perDef.InitialState.Members.add( ownerDef.InitialState );
            end
        end

        function valid = validateMessageKeys( this, baseDef )
            valid = true;
            for unresolved = baseDef.UnresolvedMessages
                try
                    message( unresolved.MessageKey ).getString(  );
                catch me
                    valid = false;
                    this.logError( me.message );
                end
            end
        end

        function validateUpgradeHandler( this, upgradeHandler )
            this.enterScope( 'upgrade' );
            if this.validateInstantiableClass( upgradeHandler, 'coderapp.internal.config.UpgradeHandler' )
                this.Data.UpgradeHandler.add( upgradeHandler );
            end
            this.exitScope(  );
        end

        function valid = validateInstantiableClass( this, className, baseClass )
            valid = false;
            [ onPath, descends ] = validateClass( className, baseClass );
            if ~onPath
                this.logError( 'Unresolvable class "%s"', className );
            elseif ~descends
                this.logError( 'Class must descend from "%s"', baseClass );
            else
                valid = true;
            end
        end

        function valid = validateKey( this, key, shouldExist )
            exist = this.ByKey.isKey( key );
            valid = false;
            if exist && ~shouldExist
                owner = this.ContextStack( end  ).rootFile;
                for i = 1:numel( this.Visited )
                    if ismember( key, this.Visited( i ).ownKeys )
                        owner = this.Visited( i ).rootFile;
                        break
                    end
                end
                if ~isempty( owner )
                    this.logError( 'Key "%s" is not unique. Already defined by: %s', key, owner );
                else
                    this.logError( 'Key "%s" is not unique', key );
                end
            elseif ~exist && shouldExist
                this.logError( 'Referenced key "%s" could not be resolved', key );
            elseif ~exist && ~isvarname( key )
                this.logError( 'Key "%s" must be a valid MATLAB variable name', key );
            else
                valid = true;
            end
        end

        function valid = validateProductionKey( this, key )
            valid = ismember( key, this.Data.Productions.keys(  ) );
            if ~valid
                this.logError( 'No production with a key of "%s" is defined', key );
            end
        end

        function valid = validateControllerId( this, id )
            valid = ~isempty( this.Data.Controllers.getByKey( id ) );
            if ~valid
                this.logError( 'No controller with a key of "%s" is defined', id );
            end
        end

        function [ data, valid ] = delegatedValidate( this, subValidator, data, warnFormat, invalidFormat, errFormat, varargin )
            valid = false;
            try
                [ data, valid, msg ] = subValidator.validateSchemaData( data );
                if valid
                    if ~isempty( msg )
                        this.logWarning( [ warnFormat, ': %s' ], varargin{ : }, msg );
                    end
                elseif ~isempty( msg )
                    this.logError( [ invalidFormat, ': %s' ], varargin{ : }, msg );
                else
                    this.logError( invalidFormat, varargin{ : } );
                end
            catch me
                this.logError( [ errFormat, ': %s' ], varargin{ : }, me.message );
            end
        end

        function logError( this, format, varargin )
            this.doLogMessage( true, format, varargin{ : } );
        end

        function logWarning( this, format, varargin )
            if this.Verbose
                this.doLogMessage( false, format, varargin{ : } );
            end
        end

        function scopedLogWarning( this, scope, format, varargin )
            this.doScopedLogMessage( false, scope, format, varargin{ : } );
        end

        function scopedLogError( this, scope, format, varargin )
            this.doScopedLogMessage( true, scope, format, varargin{ : } );
        end

        function doScopedLogMessage( this, isError, scope, format, varargin )
            if isstruct( scope ) || isobject( scope )
                if isobject( scope )
                    scope = this.DeclStacks( scope.UUID );
                end
                realStack = this.Stack;
                this.Stack = scope;
                this.doLogMessage( isError, format, varargin{ : } );
                this.Stack = realStack;
            else
                this.enterScope( scope );
                this.doLogMessage( isError, format, varargin{ : } );
                this.exitScope(  );
            end
        end

        function doLogMessage( this, isError, format, varargin )
            message.message = sprintf( format, varargin{ : } );
            message.stack = this.Stack;
            message.rootFile = this.ContextStack( end  ).rootFile;
            if isError
                this.Errors( end  + 1 ) = message;
            else
                this.Warnings( end  + 1 ) = message;
            end
        end

        function uniques = warnOnDuplicates( this, strs, scope, format, varargin )
            uniques = unique( strs, 'stable' );
            if this.Verbose && numel( uniques ) ~= numel( strs )
                this.enterScope( scope );
                this.logWarning( format, varargin{ : } );
                this.exitScope(  );
            end
        end

        function result = loopValidate( this, scopeName, array, loopFun )
            if isempty( array )
                return
            elseif ~isempty( scopeName )
                this.enterScope( scopeName );
            end
            if ~iscell( array ) && ~isstruct( array )
                this.logError( 'Expected a %s array', this.Labels.singular );
                result = [  ];
            else
                if ~iscell( array )
                    array = num2cell( array );
                end
                result = cell( 1, numel( array ) );
                for i = 1:numel( array )
                    this.enterScope( '%d', i );
                    result{ i } = loopFun( array{ i } );
                    this.exitScope(  );
                end
                result( cellfun( 'isempty', result ) ) = [  ];
            end
            if ~isempty( scopeName )
                this.exitScope(  );
            end
        end

        function warnOnUndeclaredDependencies( this, def, depKeys, allKeys )
            logic = def.Logic;

            mtArgStr = [ '-param=', strjoin( allKeys, ',' ) ];
            if isa( logic, 'handle' )
                logic = logic.toArray(  );
            end
            for i = 1:numel( logic )
                possibleKeys = mtree( logic( i ).Code, mtArgStr ).mtfind( 'Isvar', true ).strings(  );
                possibleKeys = intersect( setdiff( possibleKeys, depKeys, 'stable' ), allKeys, 'stable' );
                if ~isempty( possibleKeys )
                    this.enterScope( logic( i ).Attribute );
                    this.scopedLogWarning( def, 'Check eval code for possible undeclared dependencies: %s',  ...
                        strjoin( possibleKeys, ', ' ) );
                    this.exitScope(  );
                end
            end
        end

        function varargout = enterScope( this, format, varargin )
            if nargin < 2
                format = 'schema';
            end
            this.Stack{ end  + 1 } = sprintf( format, varargin{ : } );
            if nargout > 0
                varargout{ 1 } = onCleanup( @this.exitScope );
            end
        end

        function exitScope( this )
            this.Stack( end  ) = [  ];
        end

        function warnUnexpectedFields( this, structs, expected )
            if this.Verbose
                unexpected = setdiff( fieldnames( structs ), [ reshape( expected, 1, [  ] ), { 'x_comment' } ] );
                if ~isempty( unexpected )
                    this.logWarning( 'Encountered unexpected %s: %s', this.Labels.plural, strjoin( unexpected, ', ' ) );
                end
            end
        end

        function valid = validateStruct( this, structVal, isRequired, varargin )
            valid = false;
            if ~isScalarStruct( structVal )
                this.logError( 'Expected a %s', this.Labels.container );
                return
            elseif isempty( varargin )
                valid = true;
                return
            end

            assert( mod( nargin - 3, 2 ) == 0, 'Expecting name-type pairs' );
            expectedNames = varargin( 1:2:end  );
            expectedTypes = varargin( 2:2:end  );
            isMissing = ~isfield( structVal, expectedNames );

            if any( isMissing )
                if isRequired
                    this.logError( 'Required %s missing: %s', strjoin( expectedNames( isMissing ), ', ' ) );
                end
                expectedNames( isMissing ) = [  ];
                expectedTypes( isMissing ) = [  ];
            else
                valid = true;
            end

            valuesValid = true;
            for i = 1:numel( expectedNames )
                fieldVal = structVal.( expectedNames{ i } );
                goodValue = false;
                switch expectedTypes{ i }
                    case 'string'
                        goodValue = coderapp.internal.util.isScalarText( fieldVal );
                    case 'integer'
                        goodValue = isSimpleNumber( fieldVal ) && int64( fieldVal ) == fieldVal;
                    case 'decimal'
                        goodValue = isSimpleNumber( fieldVal );
                    case 'boolean'
                        goodValue = isscalar( fieldVal ) && islogical( fieldVal );
                    case 'cellstr'
                        goodValue = iscellstr( fieldVal );%#ok<ISCLSTR>
                    case 'mixedcell'
                        goodValue = iscell( fieldVal ) || isempty( fieldVal ) || isscalar( fieldVal ) ||  ...
                            coderapp.internal.util.isScalarText( fieldVal );
                        if goodValue
                            if ~iscell( fieldVal )
                                fieldVal = {  };
                            end
                            for j = 1:numel( fieldVal )
                                goodValue = coderapp.internal.util.isScalarText( fieldVal{ j } ) || isScalarStruct( fieldVal{ j } );
                                if ~goodValue
                                    break
                                end
                            end
                        end
                    case 'struct'
                        goodValue = isScalarStruct( fieldVal );
                    case 'structarray'
                        goodValue = isstruct( fieldVal ) || isempty( fieldVal ) || iscell( fieldVal );
                    case 'array'
                        goodValue = iscell( fieldVal ) || isempty( fieldVal ) || isscalar( fieldVal );
                    case 'any'
                        continue
                    otherwise
                        assert( false, 'Unexpected expectedTypes value' );
                end
                if ~goodValue
                    valuesValid = false;
                    this.logError( 'Expected %s "%s" to contain %s', this.Labels.singular,  ...
                        expectedNames{ i }, sprintf( this.TYPE_ERROR_PHRASES.( expectedTypes{ i } ), this.Labels.plural ) );
                end
            end
            valid = valid && valuesValid;
        end

        function varargout = extractOptionalFields( this, structVal, varargin )
            names = varargin( 1:2:end  );
            types = varargin( 2:2:end  );
            varargout = cell( 1, numel( names ) );
            for i = 1:numel( names )
                if this.validateStruct( structVal, false, names{ i }, types{ i } )
                    varargout{ i } = structVal.( names{ i } );
                end
            end
        end

        function effective = updateRules( this, root )
            if ~isscalar( this.ContextStack )
                effective = this.ContextStack( end  - 1 ).rules;
            else
                effective = struct(  ...
                    'requireCategories', this.RequireCategories,  ...
                    'requireNames', this.RequireNames,  ...
                    'userFacingStringEscape', coderapp.internal.config.schema.UserFacingStringEscape.ESCAPE_NONE );
            end
            [ requireCategories, requireNames, userFacingStringEscape ] = this.extractOptionalFields( root,  ...
                'requireCategories', 'boolean', 'requireNames', 'boolean', 'userFacingStringEscape', 'string' );
            if isfield( root, 'requireCategories' )
                effective.requireCategories = ~isempty( requireCategories ) && requireCategories;
            end
            if isfield( root, 'requireNames' )
                effective.requireNames = ~isempty( requireNames ) && requireNames;
            end
            if isfield( root, 'userFacingStringEscape' )
                if ~isempty( userFacingStringEscape )
                    switch lower( userFacingStringEscape )
                        case 'literals'
                            conArg = 'ESCAPE_LITERALS';
                        case 'messages'
                            conArg = 'ESCAPE_MESSAGES';
                        case 'none'
                            conArg = 'ESCAPE_NONE';
                        otherwise
                            this.logError( 'Unrecognized userFacingStringEscape mode "%s"', userFacingStringEscape );
                            conArg = 'ESCAPE_NONE';
                    end
                else
                    conArg = 'ESCAPE_NONE';
                end
                effective.userFacingStringEscape = coderapp.internal.config.schema.UserFacingStringEscape( conArg );
            end
            this.ContextStack( end  ).rules = effective;
        end

        function recordDebugInfo( this, entityType, key )
            if ~this.Verbose
                return
            end

            context = this.ContextStack( end  );
            curRoot = context.rootFile;
            if ~isempty( context.fragmentFiles )
                curFragment = context.fragmentFiles{ end  };
            else
                curFragment = '';
            end
            this.DebugInfo.appendDefinition( entityType, key, curRoot, curFragment );
        end
    end

    methods ( Static, Access = private )
        function dumpMessages( messages )
            if isempty( messages )
                return
            end
            [ ~, uIdx ] = unique( { messages.rootFile }, 'stable' );
            for i = 1:numel( uIdx )
                if i < numel( uIdx )
                    endIdx = uIdx( i + 1 ) - 1;
                else
                    endIdx = numel( messages );
                end
                startIdx = uIdx( i );
                if ~isempty( messages( startIdx ).rootFile )
                    svprintf( '<strong>%s</strong>\n', messages( startIdx ).rootFile );
                end
                chunk = cell( endIdx - startIdx + 1, 1 );
                for j = startIdx:endIdx
                    prefix = strjoin( strcat( '[', messages( j ).stack, ']' ), '' );
                    chunk{ j - startIdx + 1 } = sprintf( '\t%s\n\t\t%s\n', prefix, messages( j ).message );
                end
                fprintf( '%s\n', strjoin( chunk, '' ) );
                if i < numel( uIdx )
                    fprintf( '\n' );
                end
            end
        end
    end

    properties ( Constant, Access = private )
        ROOT_FIELDS = { 'version', 'fragments', 'productions', 'controllers', 'userFacingStringEscape',  ...
            'services', 'customTypes', 'upgrade', 'metadata', 'tags', 'mixins', 'requireCategories',  ...
            'requireNames', 'perspectives', 'x_schema' }
        DEFAULTS_FIELDS = { 'controllerId', 'perspectives', 'enabled', 'visible', 'internal', 'transient',  ...
            'productionKey', 'tags', 'stable', 'derived' }
        SHARED_FIELDS = { 'controllers', 'requires', 'tags' }
        FRAGMENT_FIELDS = { 'params', 'categories', 'defaults', 'shared', 'x_schema' }
        PARAM_FIELDS = { 'key', 'type', 'transient', 'internal', 'requires', 'follows', 'perspectives', 'stable', 'awake', 'derived',  ...
            'init', 'eval', 'controller', 'produces', 'metadata', 'tags', 'name', 'description', 'visible', 'enabled', 'value' }
        CATEGORY_FIELDS = { 'key', 'contains', 'metadata', 'name', 'description', 'requires', 'init', 'eval', 'controller',  ...
            'perspectives', 'visible', 'enabled', 'follows', 'tags', 'stable' }
        CONTROLLER_FIELDS = { 'id', 'update', 'initialize', 'validate', 'postSet', 'import', 'export', 'wake', 'toCode' }
        PERSPECTIVE_FIELDS = { 'id', 'default', 'members', 'init', 'name', 'visible' }
        PRODUCTION_FIELDS = { 'key', 'producer', 'requires', 'args', 'metadata', 'allowedClasses' }
        TYPE_ERROR_PHRASES = struct(  ...
            'string', 'a string',  ...
            'integer', 'an integer',  ...
            'decimal', 'a number',  ...
            'cellstr', 'an array of strings',  ...
            'mixedcell', 'an array of strings or %s',  ...
            'scalarstruct', 'a scalar %s',  ...
            'structarray', 'a %s array',  ...
            'struct', 'a struct',  ...
            'array', 'an array',  ...
            'boolean', 'a boolean' )
    end
end


function result = canPreInitObject( def )
if def.InitDuringBuild
    result = 2;
elseif isempty( def.Controllers ) && numel( def.Logic ) == 0
    result = 1;
else
    result = 0;
end
end


function refs = toNodeRefs( keys )
if ~isempty( keys )
    refs = repmat( coderapp.internal.config.schema.GlobalNodeRef, 1, numel( keys ) );
    [ refs.Key ] = keys{ : };
else
    refs = coderapp.internal.config.schema.GlobalNodeRef.empty(  );
end
end


function [ validRefs, validKeys, resolvedIdx, missingKeys ] = validateNodeRefs( refs, allKeys, uniqify )
arguments
    refs
    allKeys
    uniqify = false
end
depKeys = { refs.Key };
if uniqify
    [ depKeys, uIdx ] = unique( depKeys, 'stable' );
    refs = refs( uIdx );
end
[ resolved, dIdx ] = ismember( depKeys, allKeys );
missingKeys = depKeys( ~resolved );
validRefs = refs( resolved );
validKeys = depKeys( resolved );
resolvedIdx = dIdx( resolved );
end


function [ onPath, descends ] = validateClass( className, expectedSuperclass )
mc = meta.class.fromName( className );
onPath = ~isempty( mc );
descends = onPath && ismember( expectedSuperclass, superclasses( className ) );
end


function yes = isScalarStruct( val )
yes = isstruct( val ) && isscalar( val );
end


function yes = isSimpleNumber( val )
yes = isscalar( val ) && isnumeric( val ) && isscalar( val ) && isreal( val ) && ~issparse( val ) &&  ...
    ~isa( val, 'gpuArray' ) && ~isa( val, 'embedded.fi' );
end


function root = readJsonFile( file )
try
    fid = fopen( file, 'r', 'n', 'UTF-8' );
    root = fread( fid, [ 1, Inf ], '*char' );
    fclose( fid );
catch
    error( 'Could not read file "%s"', file );
end
try
    root = jsondecode( root );
catch me
    wrapped = MException( 'coderApp:config:invalidJsonFile', 'File "%s" contains invalid JSON', file );
    wrapped.addCause( me );
    wrapped.throw(  );
end
end


function target = mixinFields( target, overlay, filter )
if isempty( overlay )
    return
end
if nargin < 3
    filter = fieldnames( overlay );
end
if isstruct( target )
    targetFields = fieldnames( target );
else
    targetFields = properties( target );
end
fields = setdiff( intersect( fieldnames( overlay ), filter ), targetFields );
for i = 1:numel( fields )
    target.( fields{ i } ) = overlay.( fields{ i } );
end
end


function imported = normalizeFieldCase( schemaDef, attrs )
imported = struct(  );
fields = fieldnames( schemaDef );
[ ~, fIdx, aIdx ] = intersect( lower( fields ), lower( attrs ) );
for i = 1:numel( fIdx )
    imported.( attrs{ aIdx( i ) } ) = schemaDef.( fields{ fIdx( i ) } );
end
end


function paths = getCycles( graph )
if graph.isdag(  )
    paths = {  };
    return
end
cyclicIdx = union( find( diag( graph.transclosure.adjacency ) ), find( diag( graph.adjacency ) ) );
paths = repmat( { {  } }, 1, numel( cyclicIdx ) );
if ~isempty( paths )
    for i = 1:numel( cyclicIdx )
        idx = cyclicIdx( i );
        successors = graph.successors( idx );
        for j = 1:numel( successors )
            path = graph.shortestpath( successors( j ), idx );
            if ~isempty( path )
                paths{ i }{ end  + 1 } = [ idx, path ];
            end
        end
    end
    paths = [ paths{ : } ];
end


fingerprints = cellfun( @( p )num2str( unique( p ) ), paths, 'UniformOutput', false );
[ ~, uIdx ] = unique( fingerprints );
paths = paths( uIdx );
end


function file = resolveFile( file, relDir )
if nargin < 2 || isempty( relDir )
    relDir = pwd(  );
end
file = fullfile( file );
if ispc(  )
    if ~startsWith( file, '\\' ) && ( numel( file ) < 3 || file( 2 ) ~= ':' )
        file = fullfile( relDir, file );
    end
elseif ~startsWith( file, '/' )
    file = fullfile( relDir, file );
end
if isfile( file )
    self = dir( file );
    file = fullfile( self.folder, self.name );
end
end


function clone = cloneControllerRef( mfz, ref )
clone = coderapp.internal.config.schema.ControllerRef( mfz );
clone.Id = ref.Id;
clone.Initialize = cloneMethodRef( mfz, ref.Initialize );
clone.PostSet = cloneMethodRef( mfz, ref.PostSet );
clone.Update = cloneMethodRef( mfz, ref.Update );
clone.Validate = cloneMethodRef( mfz, ref.Validate );
clone.Import = cloneMethodRef( mfz, ref.Import );
clone.Export = cloneMethodRef( mfz, ref.Export );
end


function clone = cloneMethodRef( mfz, ref )
if isempty( ref )
    clone = ref;
else
    clone = coderapp.internal.config.schema.MethodRef( mfz );
    clone.Method = ref.Method;
    clone.UseConstantArgs = ref.UseConstantArgs;
    clone.ConstantArgs = ref.ConstantArgs;
    clone.Static = ref.Static;
    clone.DynamicArgCount = ref.DynamicArgCount;
end
end


function formatStr = svprintf( formatStr, varargin )
persistent hasInteractiveCli;
if isempty( hasInteractiveCli )
    import( 'matlab.internal.lang.capability.Capability' );
    hasInteractiveCli = Capability.isSupported( Capability.InteractiveCommandLine );
end
if ~hasInteractiveCli
    formatStr = regexprep( formatStr, '(<strong>)|(</strong>)', '' );
end
fprintf( formatStr, varargin{ : } );
end


