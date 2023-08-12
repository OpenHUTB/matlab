function outputValue = wsEvaluate( wsName, varName, bIncludePath )








outputValue = wsEntry;

try 
if ( isempty( wsName ) || isequal( wsName, 'base' ) || isequal( wsName, 'Base Workspace' ) )
wsValue = evalin( 'base', varName );
else 
hws = get_param( wsName, 'modelworkspace' );
wsValue = hws.getVariable( varName );
end 
catch 
wsValue = wsEntry;
end 

if ( ~isa( wsValue, 'wsEntry' ) )
if ( isempty( wsName ) || isequal( wsName, 'base' ) )
path = 'Base Workspace';
else 
path = wsName;
end 
outputValue = slprivate( 'wrapComparisonItem', wsEntry, varName, wsValue, path, bIncludePath );
else 
outputValue = wsValue;
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpBdS3DX.p.
% Please follow local copyright laws when handling this file.

