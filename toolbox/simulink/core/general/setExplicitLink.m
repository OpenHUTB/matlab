function setExplicitLink( blockPath, parameterName, workspace )













if slfeature( 'ExplicitDataLinks' ) == 0
return ;
end 

assert( ischar( blockPath ), 'Expected char array for block path' )
assert( ischar( parameterName ), 'Expected char array for block path' )
assert( ischar( workspace ), 'Expected char array for block path' )
assert( strcmp( workspace, 'base workspace' ) ...
 || strcmp( workspace, 'model workspace' ) ...
 || endsWith( workspace, '.sldd' ), 'Unsupported workspace is supplied' )


mdlName = bdroot( blockPath );
ds = get_param( mdlName, 'DictionarySystem' );


keyToAdd = [ blockPath, ':', parameterName ];


currentEntry = ds.ExplicitDataLinkMap.getByKey( keyToAdd );
if ~isempty( currentEntry )



if ~strcmp( currentEntry.DataSource, workspace )
currentEntry.DataSource = workspace;
end 

if ~strcmp( currentEntry.IDinSection, get_param( blockPath, parameterName ) )
currentEntry.IDinSection = get_param( blockPath, parameterName );
end 
else 

if endsWith( workspace, '.sldd' )
modelDDs = slprivate( 'getAllDataDictionaries', mdlName );
assert( any( matches( modelDDs, '.sldd' ) ),  ...
'Data dictionary is not in set of dictionaries used by model.' )
end 


emptyStruct = ds.createIntoExplicitDataLinkMap;
emptyStruct.ParameterID = keyToAdd;
emptyStruct.DataSource = workspace;
emptyStruct.IDinSection = get_param( blockPath, parameterName );
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpNCxDUs.p.
% Please follow local copyright laws when handling this file.

