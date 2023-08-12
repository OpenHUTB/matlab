classdef Clipboard
properties ( Constant )
MIMEType = "application/vnd.mathworks.simbio.clipboard+json"
end 
methods ( Static )
function copy( objArray, blockInfo )
R36
objArray
blockInfo struct
end 
if isempty( objArray )
objArray = SimBiology.ModelComponent.empty;
end 
assertInternal( isa( objArray, 'SimBiology.ModelComponent' ) );
[ metadata, extraBlockInfo ] = createMetadataAndExtraBlockInfo( objArray );
bytes = SimBiology.internal.serialize( objArray );
bytes64 = matlab.net.base64encode( bytes );
info = struct( 'simbiologyClipboardVersion', 1,  ...
'metadata', { metadata },  ...
'extraBlockInfo', { extraBlockInfo },  ...
'blockInfo', { blockInfo },  ...
'bytes64', bytes64 );
data = jsonencode( info );

clipboardHelper( 'copy', data );
end 

function [ blockInfo, status, allObjects ] = paste( destination, supportedTypes )
R36
destination( 1, 1 )SimBiology.Object{ validateattributes( destination,  ...
{ 'SimBiology.Root', 'SimBiology.Model', 'SimBiology.Compartment',  ...
'SimBiology.Reaction', 'SimBiology.KineticLaw' }, {  } ) }















supportedTypes( 1, : )string
end 

switch destination.Type
case 'sbioroot'
assertInternal( isequal( supportedTypes, "sbiomodel" ) )
case 'sbiomodel'
assertInternal( isempty( supportedTypes ) ||  ...
isequal( sort( supportedTypes ), [ "repeatdose", "scheduledose" ] ) ||  ...
isequal( supportedTypes, "variant" ) );
case 'compartment'
assertInternal( isempty( supportedTypes ) )
case { 'reaction', 'kineticlaw' }
assertInternal( isequal( supportedTypes, "parameter" ) )
end 

blockInfo = [  ];
allObjects = [  ];

data = clipboardHelper( 'paste' );
if ~startsWith( data, '{"simbiologyClipboardVersion":1,' )
status = message( 'SimBiology:Clipboard:InvalidClipboardContents' );
return 
end 
try 
info = jsondecode( data );
bytes = matlab.net.base64decode( info.bytes64 );
objArray = SimBiology.internal.deserialize( bytes );
metadata = info.metadata;


tfModel = arrayfun( @( o )isa( o, 'SimBiology.Model' ), objArray );
if any( tfModel )
if ~all( tfModel ) || ~strcmp( destination.Type, 'sbioroot' )
delete( objArray );
error( message( 'SimBiology:Internal:InternalError' ) )
end 

blockInfo = info.blockInfo( [  ] );
status = message( 'SimBiology:Clipboard:Success' );
allObjects = objArray;
return 
end 


tfParentedOrOwned = arrayfun( @isParentedOrOwned, objArray );
objArray( tfParentedOrOwned ) = [  ];
metadata( tfParentedOrOwned ) = [  ];

if ~isempty( metadata )

if isempty( supportedTypes )

types = { metadata.type };
unsupportedTypes = { 'variant', 'repeatdose', 'scheduledose' };
tfMember = ismember( types, unsupportedTypes );
clipboardContainsUnsupportedTypes = any( tfMember );
else 

types = { metadata.type };
tfMember = ismember( types, supportedTypes );
clipboardContainsUnsupportedTypes = ~all( tfMember );
end 
if clipboardContainsUnsupportedTypes
status = message( 'SimBiology:Clipboard:UnsupportedType' );
return 
end 
end 

[ uuidMap, createdObjects, parentModel ] = SimBiology.internal.paste( objArray, destination, metadata );



assertInternal( all( isvalid( objArray ) ) );
assertInternal( all( ~cellfun( @isempty, { objArray.Parent } ) ) )


blockInfo = info.blockInfo;
if isempty( blockInfo )
blockInfo = struct( 'UUID', {  }, 'sessionID', {  } );
end 
oldUuids = { blockInfo.UUID };
if isempty( uuidMap )
tfKey = false( size( oldUuids ) );
vals = cell( 0, 0 );
else 
tfKey = isKey( uuidMap, oldUuids );
vals = values( uuidMap, oldUuids( tfKey ) );
end 
newUuids = cellfun( @( val )val{ 1 }, vals, 'UniformOutput', false );
newSessionIds = cellfun( @( val )val{ 2 }, vals, 'UniformOutput', false );
[ blockInfo( tfKey ).UUID ] = deal( newUuids{ : } );
[ blockInfo( tfKey ).sessionID ] = deal( newSessionIds{ : } );

if ~isempty( createdObjects ) && ~isempty( info.extraBlockInfo )

keys = createObjectMapKeys( createdObjects );
objMap = containers.Map( keys, num2cell( createdObjects ) );
keys = { info.extraBlockInfo.typeAndPQN };
tfIsKey = objMap.isKey( keys );
extraBlockInfo = vertcat( info.extraBlockInfo( tfIsKey ).blockInfo );
objectsCell = objMap.values( keys( tfIsKey ) );
objects = vertcat( objectsCell{ : } );
[ extraBlockInfo.UUID ] = deal( objects.UUID );
[ extraBlockInfo.sessionID ] = deal( objects.SessionID );
blockInfo = [ blockInfo;extraBlockInfo ];
end 



allObjects = [ objArray( : );createdObjects( : ) ];
allObjects = findobj( allObjects );
allObjects = SimBiology.internal.sortAndFilterCreatedObjectsForUI( parentModel, allObjects );

status = message( 'SimBiology:Clipboard:Success' );
catch exception
status = exception;
end 
end 

end 
end 

function [ metadata, extraBlockInfo ] = createMetadataAndExtraBlockInfo( objArray )

[ tfNeedExtraBlockInfo, model ] = needExtraBlockInfo( objArray );
c = cell( size( objArray ) );
metadata = struct( 'type', c, 'name', c, 'parentName', c, 'tokens', c, 'uuids', c, 'defaultCompartmentName', c );
if isempty( objArray )
extraBlockInfo = [  ];
return 
end 

objMap = containers.Map( { objArray.SessionID }, cell( size( objArray ) ) );
for i = 1:numel( objArray )
obj = objArray( i );
metadata( i ) = struct( 'type', obj.TypeInternal, 'name', obj.Name, 'parentName', [  ], 'tokens', [  ], 'uuids', [  ], 'defaultCompartmentName', [  ] );
switch obj.Type
case 'species'
parent = obj.Parent;
metadata( i ).parentName = parent.Name;
id = parent.SessionID;
if tfNeedExtraBlockInfo && ~isKey( objMap, id )

objMap( id ) = parent;
end 
case 'parameter'
if isa( obj.Parent, 'SimBiology.KineticLaw' )
metadata( i ).parentName = obj.Parent.Parent.Name;
end 
case 'rule'
[ lhsTokens, rhsTokens ] = obj.parserule;
tokens = unique( [ lhsTokens;rhsTokens ] );
metadata( i ).tokens = tokens;
metadata( i ).uuids = getUuids( obj, tokens );
case 'reaction'
species = [ obj.Reactants;obj.Products ];
if ~isempty( species ) && all( [ species.Parent ] == species( 1 ).Parent )


metadata( i ).defaultCompartmentName = species( 1 ).Parent.Name;
end 
if tfNeedExtraBlockInfo

parents = unique( vertcat( species.Parent ) );
allObj = [ species;parents ];
for j = 1:numel( allObj )
o = allObj( j );
id = o.SessionID;
if ~isKey( objMap, id )
objMap( id ) = o;
end 
end 
end 
tokens = obj.parserate;
metadata( i ).tokens = tokens;
metadata( i ).uuids = getUuids( obj, tokens );
case 'event'
triggerTokens = obj.parsetrigger;
[ transitionLhsTokens, transitionRhsTokens ] = obj.parseeventfcns;
tokens = unique( vertcat( triggerTokens, transitionLhsTokens{ : }, transitionRhsTokens{ : } ) );
metadata( i ).tokens = tokens;
metadata( i ).uuids = getUuids( obj, tokens );
case 'observable'
tokens = obj.parseexpression;
metadata( i ).tokens = tokens;
metadata( i ).uuids = getUuids( obj, tokens );
otherwise 

end 
end 
if nargout > 1
extraObjCell = values( objMap );
extraObj = vertcat( extraObjCell{ : } );
keys = createObjectMapKeys( extraObj );
blockInfo = SimBiology.web.diagram.clipboardhandler( 'getBlockInfoForObjects', model, extraObj );
extraBlockInfo = struct( 'typeAndPQN', keys,  ...
'blockInfo', num2cell( blockInfo ) );
end 
end 

function resolvedObjUUIDs = getUuids( obj, tokens )
resolvedObjUUIDs = repmat( { '' }, size( tokens ) );
for j = 1:numel( tokens )
resolvedObj = obj.resolveobject( tokens{ j } );
if ~isempty( resolvedObj )
resolvedObjUUIDs{ j } = resolvedObj.UUID;
end 
end 
end 

function keys = createObjectMapKeys( objects )
if isempty( objects )
keys = string.empty( size( objects ) );
else 
keys = { objects.Type } + ":" + { objects.PartiallyQualifiedName };
end 
keys = cellstr( keys );
end 

function [ tf, model ] = needExtraBlockInfo( objArray )


if isempty( objArray ) || isa( objArray, 'SimBiology.Model' )

model = [  ];
tf = false;
return 
end 
modelSessionID = objArray( 1 ).ParentModelSessionID;

assertInternal( all( modelSessionID == [ objArray.ParentModelSessionID ] ) );
model = findobj( sbioroot, 'SessionID', modelSessionID, '-depth', 1 );
tf = hasDiagramSyntax( model ) && hasDiagramEditor( model );
end 

function tf = isParentedOrOwned( obj )
if ~isempty( obj.Parent )
tf = true;
elseif strcmp( obj.Type, 'compartment' )
tf = ~isempty( obj.Owner );
else 
tf = false;
end 
end 

function assertInternal( condition )
assert( condition, message( 'SimBiology:Internal:InternalError' ) )
end 

function varargout = clipboardHelper( varargin )





varargout = cell( 1, nargout );
attemptNumber = 0;
maxAttempts = 5;
while true
attemptNumber = attemptNumber + 1;
try 
[ varargout{ : } ] = clipboard( varargin{ : } );
catch exception
if ~strcmp( exception.identifier, 'MATLAB:Java:GenericException' )

rethrow( exception );
elseif attemptNumber >= maxAttempts

rethrow( exception );
end 


pause( attemptNumber / 10 );
continue 
end 

break 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpKdKoS2.p.
% Please follow local copyright laws when handling this file.

