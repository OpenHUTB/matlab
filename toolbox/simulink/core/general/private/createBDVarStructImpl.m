function createBDVarStructImpl( system, structName, varargin )

































narginchk( 2, Inf );


pvArgDesc.SearchMethod = { 'compiled', 'cached' };
pvArgDesc.DataObjects = { 'on', 'off' };

pvArgs = slprivate( 'slPVParser', pvArgDesc, varargin{ : } );


try 
sp = slResolve( structName, system, 'variable' );
assert( ~isempty( sp ) );
varFound = true;
catch e
varFound = false;
assert( isequal( e.identifier, 'Simulink:Data:SlResolveNotResolved' ) );
end 

if varFound
DAStudio.error( 'Simulink:tools:slVarStructAlreadyExists', structName );
end 


modelName = get_param( bdroot( system ), 'Name' );
hasAnyDD = slprivate( 'isUsingAnyDataDictionary', modelName );
varList = [  ];
if strcmp( get_param( modelName, 'HasAccessToBaseWorkspace' ), 'on' )
varList = Simulink.findVars( system,  ...
'SourceType', 'base workspace',  ...
'SearchMethod', pvArgs.SearchMethod,  ...
'ReturnResolvedVar', true );
pvArgs.SearchMethod = 'cached';
end 

if hasAnyDD
varListDD = Simulink.findVars( system,  ...
'SourceType', 'data dictionary',  ...
'SearchMethod', pvArgs.SearchMethod,  ...
'ReturnResolvedVar', true );

varList = cat( 1, varList, varListDD );
end 


sp = struct(  );
for n = 1:size( varList, 1 )
name = varList( n ).Name;
value = varList( n ).Value;
isIncluded = isnumeric( value ) || islogical( value );
if isequal( pvArgs.DataObjects, 'on' )
isIncluded = isIncluded || isa( value, 'Simulink.Parameter' );
end 
if isIncluded
val = slResolve( name, system, 'expression', 'base' );
sp.( name ) = val;
end 
end 

if ~isempty( fieldnames( sp ) )
assigninGlobalScope( modelName, structName, sp );
disp( DAStudio.message( 'Simulink:tools:slVarStructCreatedVariableGlobalWS', structName ) );
end 
end 




% Decoded using De-pcode utility v1.2 from file /tmp/tmpJddosU.p.
% Please follow local copyright laws when handling this file.

