classdef ( Sealed )ConfigMetadataIndex < dynamicprops

    properties ( Constant, Hidden )
        CLI_INDEX_FILE = fullfile( matlabroot, 'toolbox/coder/coderapp/coderconfig/schemas/_generated/cli_metadata_index.json' )
        CLI_DEBUG_FILE = fullfile( matlabroot, 'toolbox/coder/coderapp/coderconfig/schemas/_generated/cli_schema_debug.mat' )
        PROJECT_INDEX_FILE = fullfile( matlabroot, 'toolbox/coder/coderapp/coderconfig/schemas/_generated/project_metadata_index.json' )
        PROJECT_DEBUG_FILE = fullfile( matlabroot, 'toolbox/coder/coderapp/coderconfig/schemas/_generated/project_schema_debug.mat' )
    end

    properties ( Dependent, SetAccess = immutable )

        MappedNewKeys
    end


    properties ( Dependent, SetAccess = immutable, Hidden )

        OrderedOldKeys

        MappedOldKeys
        Schema
    end

    properties ( SetAccess = immutable, Hidden )
        SubObjects coderapp.internal.coderconfig.SubObjectMetadataIndex
        DebugInfoFile{ mustBeTextScalar( DebugInfoFile ) } = ''
    end

    properties ( Hidden, SetAccess = private )
        DebugInfo coderapp.internal.config.util.SchemaDebugInfo
    end

    properties ( GetAccess = private, SetAccess = immutable )
        NewToOld containers.Map
        OldToNew containers.Map
        Data struct
        IndexFile char
        SchemaConfigType char
    end

    properties ( Dependent, GetAccess = private, SetAccess = immutable )
        IndexInfos( 1, : )struct{ mustHaveProperties( IndexInfos ) }
    end

    methods
        function this = ConfigMetadataIndex( opts )
            arguments
                opts.ForProject( 1, 1 ){ mustBeNumericOrLogical( opts.ForProject ) } = true
                opts.Regen( 1, 1 ){ mustBeNumericOrLogical( opts.Regen ) } = false
                opts.DebugInfo coderapp.internal.config.util.SchemaDebugInfo = coderapp.internal.config.util.SchemaDebugInfo.empty(  )
            end

            if opts.ForProject
                file = this.PROJECT_INDEX_FILE;
                debugFile = this.PROJECT_DEBUG_FILE;
                schemaConfigType = '';
            else
                file = this.CLI_INDEX_FILE;
                debugFile = this.CLI_DEBUG_FILE;
                schemaConfigType = 'coder.EmbeddedCodeConfig';
            end
            this.IndexFile = file;
            this.DebugInfoFile = debugFile;
            this.SchemaConfigType = schemaConfigType;

            debugInfo = opts.DebugInfo;
            if opts.Regen || ~isfile( file )
                if isempty( debugInfo )
                    debugInfo = loadDebugInfo( debugFile, false );
                end
                raw = analyze( coderapp.internal.config.Configuration(  ...
                    coderapp.internal.getConfigSchema( ConfigType = schemaConfigType ) ), debugInfo );
            else
                raw = jsondecode( fileread( file ) );
            end
            this.Data = raw;
            this.DebugInfo = debugInfo;


            this.NewToOld = containers.Map( fieldnames( raw.newToOld ), struct2cell( raw.newToOld ) );
            this.OldToNew = invertMultiMapStruct( raw.newToOld, true );


            subs = cell( 1, numel( this.IndexInfos ) );
            for i = 1:numel( subs )
                spec = this.IndexInfos( i );
                subData = this.Data.( spec.productionKey );
                propDesc = this.addprop( spec.property );
                subs{ i } = coderapp.internal.coderconfig.SubObjectMetadataIndex(  ...
                    this, spec, subData );
                this.( spec.property ) = subs{ i };
                propDesc.SetAccess = 'immutable';
            end
            this.SubObjects = [ subs{ : } ];
        end

        function subIndex = getSubObjectByProdKey( this, prodKey )
            arguments
                this( 1, 1 )
                prodKey{ mustBeValidVariableName( prodKey ) }
            end

            [ ~, ~, index ] = intersect( prodKey, { this.IndexInfos.productionKey } );
            if isempty( index )
                error( 'No sub-object index exists for production "%s"', prodKey );
            end
            subIndex = this.( this.IndexInfos( index ).property );
        end

        function subIndex = getSubObjectByClass( this, producedClass )
            arguments
                this( 1, 1 )
                producedClass{ mustBeA( producedClass, [ "char", "string", "handle" ] ) }
            end

            if isa( producedClass, 'handle' )
                producedClass = class( producedClass );
            end

            subIndex = [  ];
            for spec = this.IndexInfos
                current = this.( spec.property );
                if ismember( producedClass, current.ObjectClasses ) ||  ...
                        ismember( producedClass, this.getAllSuperclasses( current.ObjectClasses ) )
                    subIndex = current;
                    break
                end
            end
        end

        function result = newToOld( this, newKey )
            arguments
                this( 1, 1 )
                newKey{ mustBeTextScalar( newKey ) }
            end

            if this.NewToOld.isKey( newKey )
                result = this.NewToOld( newKey );
            else
                result = {  };
            end
        end

        function result = oldToNew( this, legacyKey )
            arguments
                this( 1, 1 )
                legacyKey{ mustBeTextScalar( legacyKey ) }
            end

            if this.OldToNew.isKey( legacyKey )
                result = this.OldToNew( legacyKey );
            else
                result = {  };
            end
        end

        function owners = owner( this, newKeys )
            arguments
                this( 1, 1 )
                newKeys{ mustBeText( newKeys ) } = this.NewToOld.keys(  )
            end

            owners = flexibleStringOp( @doOwner, newKeys, this.Data.ownership );

            function result = doOwner( newKeys, ownerData )
                result = repmat( { '' }, size( newKeys ) );
                for i = reshape( find( ismember( newKeys, fieldnames( ownerData ) ) ), 1, [  ] )
                    result{ i } = ownerData.( newKeys{ i } );
                end
            end
        end

        function oldOrdered = get.OrderedOldKeys( this )

            oldOrdered = struct2cell( this.Data.newToOld );
            oldOrdered = vertcat( oldOrdered{ : } );
        end

        function mappedNew = get.MappedNewKeys( this )
            mappedNew = fieldnames( this.Data.ownership );
        end

        function mappedOld = get.MappedOldKeys( this )
            mappedOld = this.newToOld( this.MappedNewKeys );
            mappedOld = sort( vertcat( mappedOld{ : } ) );
            mappedOld( cellfun( 'isempty', mappedOld ) ) = [  ];
        end

        function indexInfos = get.IndexInfos( this )
            indexInfos = reshape( this.Data.indexInfos, 1, [  ] );
        end

        function debugInfo = get.DebugInfo( this )
            debugInfo = this.DebugInfo;
            if isempty( debugInfo ) && isfile( this.DebugInfoFile )
                debugInfo = loadDebugInfo( this.DebugInfoFile, true );
                this.DebugInfo = debugInfo;
            end
        end

        function schema = get.Schema( this )
            schema = coderapp.internal.getConfigSchema( ConfigType = this.SchemaConfigType );
        end
    end

    methods ( Hidden )
        function saveToFile( this, file )
            arguments
                this( 1, 1 )
                file{ mustBeTextScalar( file ) } = this.IndexFile
            end


            fid = fopen( file, 'w', 'n', 'utf-8' );
            fprintf( fid, '%s', jsonencode( this.Data, PrettyPrint = true ) );
            fclose( fid );


            debugInfo = this.DebugInfo;
            save( this.DebugInfoFile, 'debugInfo' );
        end
    end

    methods ( Static, Hidden )
        function props = getMutablePublicProperties( className )
            if isa( className, 'handle' )
                className = class( className );
            end
            mc = meta.class.fromName( className );
            props = mc.PropertyList;
            props = props( { props.SetAccess } == "public" & { props.GetAccess } == "public" );
            props = { props.Name };
        end

        function sc = getAllSuperclasses( className )
            if iscellstr( className )%#ok<ISCLSTR>
                sc = cellfun( @( cn )coderapp.internal.coderconfig.ConfigMetadataIndex.getAllSuperclasses( cn ),  ...
                    className, 'UniformOutput', false );
                sc = [ sc{ : } ];
                return
            end

            sc = {  };
            mcList = meta.class.fromName( className );
            while ~isempty( mcList )
                mc = mcList( 1 );
                mcList = [ mcList( 2:end  );mc.SuperclassList ];
                sc{ end  + 1 } = mc.Name;%#ok<AGROW>
            end
            sc = setdiff( sc, className );
        end
    end
end


function result = analyze( configuration, debugInfo )
prodMap = configuration.SchemaData.Productions;
result.indexInfos = struct( 'property', {  }, 'productionKey', {  } );
for prod = reshape( prodMap.toArray(  ), 1, [  ] )
    indexProp = getMetadata( prod, 'metadataIndex' );
    if ~isempty( indexProp )
        result.indexInfos( end  + 1 ).property = indexProp;
        result.indexInfos( end  ).productionKey = prod.Key;

        if ~isempty( debugInfo )
            defInfo = debugInfo.getInfo( prod.Key );
            if ~isempty( defInfo.Fragment )
                file = defInfo.Fragment;
            else
                file = defInfo.Root;
            end
            file = strrep( strrep( file, matlabroot, '' ), '\', '/' );
            result.indexInfos( end  ).file = file( 2:end  );
        else
            result.indexInfos( end  ).file = '';
        end
    end
end
[ ~, ~, order ] = intersect( configuration.Keys, { result.indexInfos.productionKey }, 'stable' );
result.indexInfos = result.indexInfos( flip( order ) );

result.newToOld = generateLegacyKeyMapStruct( configuration );

result.ownership = struct(  );
arrayfun( @subAnalyze, result.indexInfos );
result.ownership = orderfields( result.ownership );


    function subAnalyze( trackingSpec )
        prodKey = trackingSpec.productionKey;
        prodDef = prodMap.getByKey( prodKey );
        configClasses = prodDef.AllowedClasses;

        assert( ~isempty( configClasses ),  ...
            'subAnalyze is only intended to work for productions that specify "allowedClasses"' );
        subResult.objectClasses = configClasses;

        allProps = cell( 1, numel( configClasses ) );
        for i = 1:numel( configClasses )
            allProps{ i } = coderapp.internal.coderconfig.ConfigMetadataIndex.getMutablePublicProperties( configClasses{ i } );
        end
        allProps = unique( [ allProps{ : } ] );

        producer = configuration.getProducer( prodKey );
        mappings = producer.AllPropertyMappings;
        mappedKeys = fieldnames( mappings );
        mappedProps = struct2cell( mappings );
        [ ~, uIdx ] = setdiff( mappedProps, allProps );
        assert( isempty( uIdx ), '%s has keys that map to properties that do not exist on %s: %s',  ...
            prodKey, strjoin( configClasses, ', ' ), strjoin( mappedKeys( uIdx ), ', ' ) );


        for i = 1:numel( mappedKeys )
            result.ownership.( mappedKeys{ i } ) = prodKey;
        end

        subResult.newToProp = orderfields( mappings );
        subResult.propToNew = orderfields( invertMultiMapStruct( subResult.newToProp, false ) );

        subResult.unimplementedProperties = sort( getMetadata( prodDef, 'unimplementedProperties', {  } ) );
        subResult.ignoredProperties = sort( getMetadata( prodDef, 'ignoredProperties', {  } ) );
        subResult.deprecatedProperties = sort( getMetadata( prodDef', 'deprecatedProperties', {  } ) );

        result.( prodKey ) = subResult;
    end
end


function newToOld = generateLegacyKeyMapStruct( configuration )
schemaData = configuration.SchemaData;
mappables = [ schemaData.Params.toArray(  ), schemaData.Productions.toArray(  ) ];
mappings = cell( numel( mappables ), 1 );
mappableKeys = { mappables.Key }';
[ ~, ~, order ] = intersect( configuration.Keys, mappableKeys, 'stable' );
mappableKeys = mappableKeys( order );

for i = 1:numel( order )

    mappings{ i } = getMetadata( mappables( order( i ) ), 'legacyKey' );
end


unmapped = cellfun( 'isempty', mappings );
mappableKeys( unmapped ) = [  ];
mappings( unmapped ) = [  ];


newToOld = cell2struct( mappings, mappableKeys, 1 );
end


function inverted = invertMultiMapStruct( forward, toMap )
arguments
    forward( 1, 1 )struct
    toMap( 1, 1 )logical = false
end

fKeys = fieldnames( forward );
fValues = struct2cell( forward );
if toMap
    inverted = containers.Map(  );
else
    inverted = struct(  );
end

for i = 1:numel( fValues )
    bKeys = cellstr( fValues{ i } );
    bValue = fKeys{ i };
    for j = 1:numel( bKeys )
        if toMap
            if inverted.isKey( bKeys{ j } )
                inverted( bKeys{ j } ) = [ {  }, inverted( bKeys{ j } ), bValue ];
            else
                inverted( bKeys{ j } ) = bValue;
            end
        else
            if isfield( inverted, bKeys{ j } )
                inverted.( bKeys{ j } ) = [ {  }, inverted.( bKeys{ j } ), bValue ];
            else
                inverted.( bKeys{ j } ) = bValue;
            end
        end
    end
end
end


function value = getMetadata( def, metaProp, default )
arguments
    def
    metaProp
    default = [  ]
end

entry = def.InitialState.Metadata.getByKey( metaProp );
if ~isempty( entry )
    value = entry.Value;
else
    value = [  ];
end
if isempty( value )
    value = default;
end
end


function result = flexibleStringOp( op, arg, varargin )
if ischar( arg )
    arg = { arg };
    multiple = false;
else
    assert( isstring( arg ) || iscellstr( arg ), 'Keys should be char, string, or cellstr' );
    multiple = true;
end

result = op( arg, varargin{ : } );
if ~multiple
    result = char( result{ 1 } );
end
end


function mustHaveProperties( specs )
assert( isempty( setdiff( { specs.property },  ...
    properties( 'coderapp.internal.coderconfig.ConfigMetadataIndex' ) ) ),  ...
    'All tracking spec properties must exist on ConfigMetadataIndex' );
end


function debugInfo = loadDebugInfo( file, silent )
try
    loaded = load( file, 'debugInfo' );
    debugInfo = loaded.debugInfo;
catch me
    if silent
        debugInfo = coderapp.internal.config.util.SchemaDebugInfo.empty(  );
    else
        me.rethrow(  );
    end
end
end


