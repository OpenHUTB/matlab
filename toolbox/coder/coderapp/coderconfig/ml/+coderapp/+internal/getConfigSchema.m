function [ schema, info, metaIndex ] = getConfigSchema( opts )



R36
opts.ConfigType{ mustBeA( opts.ConfigType, [ "char", "string", "handle" ] ) } = ''
opts.Reload( 1, 1 ){ mustBeNumericOrLogical( opts.Reload ) } = false
end 


persistent schemaInfos indexLookupMap schemaStore metaIndexStore;
if opts.Reload || isempty( schemaInfos )
[ schemaInfos, indexLookupMap ] = loadSchemaMappings(  );
schemaStore = cell( 1, numel( schemaInfos ) );
metaIndexStore = schemaStore;
end 


if coderapp.internal.util.isScalarText( opts.ConfigType )
configType = opts.ConfigType;
elseif ~isempty( opts.ConfigType )
configType = class( opts.ConfigType );
else 
configType = '';
end 
if isempty( configType )
configType = 'matlab-coder-app';
end 


assert( indexLookupMap.isKey( configType ), '%s is not a supported config type', configType );
sIdx = indexLookupMap( configType );
info = schemaInfos( sIdx );
schema = schemaStore{ sIdx };
cacheSchema = true;


if isempty( schemaStore{ sIdx } )
hasRaw = isfile( info.raw );
if isfile( info.generated )
if hasRaw && dir( info.raw ).datenum > dir( info.generated ).datenum
cacheSchema = false;
warning( 'Schema source is newer than the generated schema model' );
end 
schema = coderapp.internal.config.Schema.fromFile( info.generated );
else 
validator = coderapp.internal.config.SchemaValidator(  );
schema = validator.parseFile( info.raw );
assert( schema.Valid, 'Config schema must be valid' );
end 
if cacheSchema
schemaStore{ sIdx } = schema;
end 
end 


if nargout > 2
metaIndex = metaIndexStore{ sIdx };
if isempty( metaIndex )
metaIndex = coderapp.internal.coderconfig.ConfigMetadataIndex( schema );
if cacheSchema
metaIndexStore{ sIdx } = metaIndex;
end 
end 
else 
metaIndex = [  ];
end 
end 


function [ infos, lookup ] = loadSchemaMappings(  )
infos = coderapp.internal.coderconfig.listAvailableConfigSchemas(  );
lookup = containers.Map( 'KeyType', 'char', 'ValueType', 'double' );
for i = 1:numel( infos )
info = infos( i );
if ~isempty( info.configTypes )
for j = 1:numel( info.configTypes )
lookup( info.configTypes{ j } ) = i;
end 
else 
lookup( '' ) = i;
end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmp1gsvie.p.
% Please follow local copyright laws when handling this file.

