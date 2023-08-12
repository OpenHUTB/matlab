function [ location, locationIsValid ] = getVariableLocation( mdl_name, varName, context, searchLoc )








locationIsValid = true;

try 
location = slResolve( varName, context, 'original_context', searchLoc );

if strcmp( location, 'Global' )



location = loc_BWSDDCheck( mdl_name, varName, location );
end 
catch E
location = '';
if isequal( E.identifier, 'Simulink:Data:SlResolveNotResolved' )

ddName = get_param( mdl_name, 'DataDictionary' );
if ~isempty( ddName )
try 
Simulink.data.dictionary.open( ddName );
catch E2
if strcmp( E2.identifier, 'SLDD:sldd:DictionaryNotFound' )
locationIsValid = true;
location = 'UnknownLocation';
return ;
end 
end 
end 
existLevel = evalin( 'base', [ 'exist(''', varName, ''')' ] );
if isequal( existLevel, 8 )
[ locationIsValid, location ] = checkClass( mdl_name, varName );
elseif ( existLevel > 0 ) && ~isequal( existLevel, 1 ) && ~isequal( existLevel, 7 )






path = which( varName, "-ALL" );
isSame = false;
for i = 1:numel( path )
[ x, filename, ~ ] = fileparts( path{ i } );

if startsWith( x, 'built-in' )
filename = strip( filename, 'right', ')' );
end 
if isequal( filename, varName )
isSame = true;
break ;
end 
end 

if isSame || ( ~isempty( findpackage( varName ) ) )
locationIsValid = false;
end 
end 
if locationIsValid && ~isvarname( varName )
locationIsValid = false;
end 
elseif isequal( E.identifier, 'Simulink:Data:ResolveToDataTypeInModelWorkspace' )


locationIsValid = true;
location = 'Model';
elseif isequal( E.identifier, 'SLDD:sldd:DuplicateSymbol' ) ||  ...
isequal( E.identifier, 'SLDD:sldd:DuplicateSymbolInconsistent' )

locationIsValid = true;
location = 'DictionaryDuplicate';
else 


[ locationIsValid, location ] = loc_existCheck( mdl_name, varName );
end 
end 

end 

function [ locationIsValid, location ] = checkClass( mdl_name, var_name )
locationIsValid = true;
location = 'Class';

dataAccessor = Simulink.data.DataAccessor.createForExternalData( mdl_name );
varID = dataAccessor.identifyByName( var_name );
if ~isempty( varID )
locationIsValid = true;
location = 'Global';
end 
end 



function [ locationIsValid, location ] = loc_existCheck( mdl_name, var_name )
locationIsValid = true;
location = 'UnknownLocation';
ws = get_param( mdl_name, 'ModelWorkspace' );
if ~isempty( ws ) && ws.hasVariable( var_name )
location = 'Model';
else 
location = loc_BWSDDCheck( mdl_name, var_name, location );
end 
end 






function location = loc_BWSDDCheck( mdl_name, varName, location )
dataAccessor = Simulink.data.DataAccessor.createForExternalData( mdl_name );
varIDs = dataAccessor.identifyByName( varName );

if numel( varIDs ) == 0
return ;
elseif numel( varIDs ) == 1
srcName = varIDs.getDataSourceFriendlyName(  );
if ( strcmp( srcName, 'base workspace' ) ||  ...
contains( srcName, '.sldd' ) )

location = 'Global';
end 
else 

numVarsInDD = 0;
numVarsInBWS = 0;
for i = 1:numel( varIDs )
srcName = varIDs( i ).getDataSourceFriendlyName(  );
if strcmp( srcName, 'base workspace' )
numVarsInBWS = numVarsInBWS + 1;
elseif contains( srcName, '.sldd' )
numVarsInDD = numVarsInDD + 1;
end 
end 

if numVarsInDD == numel( varIDs )

location = 'DictionaryDuplicate';
elseif numVarsInBWS > 0 && numVarsInDD > 0
location = 'DictionaryAndBaseWS';
end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpk1AIZP.p.
% Please follow local copyright laws when handling this file.

