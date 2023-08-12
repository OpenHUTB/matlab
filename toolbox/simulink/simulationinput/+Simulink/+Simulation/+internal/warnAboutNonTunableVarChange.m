function warnAboutNonTunableVarChange( simInput, nonTunableVarsInfo )

simInputVars = string( { simInput.Variables.Name } );
nonTunableVars = string( { nonTunableVarsInfo.name } );
[ ~, simInputVarIdx, nonTunablesVarsInfoIdx ] = intersect( simInputVars, nonTunableVars );
nonTunableSimInputVars = simInput.Variables( simInputVarIdx );
nonTunableVarsInfoSubset = nonTunableVarsInfo( nonTunablesVarsInfoIdx );

for idx = 1:numel( nonTunableSimInputVars )
if ~isequal( nonTunableSimInputVars( idx ).Value, nonTunableVarsInfoSubset( idx ).value )
nonTunableVarChanged = true;
mismatchVar = nonTunableSimInputVars( idx ).Name;

if isstruct( nonTunableSimInputVars( idx ).Value ) &&  ...
isstruct( nonTunableVarsInfoSubset( idx ).value )

nonTunableVarChanged = false;
fullQualifiedNames = getFullQualifiedNamesFromNonTunablesUses( nonTunableSimInputVars( idx ).Name,  ...
nonTunableVarsInfoSubset( idx ).nonTunableUses );

for qualifiedName = fullQualifiedNames
simInputValue = nonTunableSimInputVars( idx ).Value;
originalValue = nonTunableVarsInfoSubset( idx ).value;
if valueWasChangedUsingSimulationInput( qualifiedName, simInputValue, originalValue )
nonTunableVarChanged = true;
mismatchVar = qualifiedName;
break ;
end 
end 
end 

if ( nonTunableVarChanged )
backtraceState = warning( "off", "backtrace" );
restoreBacktraceState = onCleanup( @(  )warning( backtraceState ) );
warning( message( "Simulink:Commands:VarUsedInNonTunableParameterChanged", mismatchVar ) );
end 
end 
end 
end 

function fullQualifiedNames = getFullQualifiedNamesFromNonTunablesUses( varName, nonTunableUses )




R36
varName( 1, 1 )string
nonTunableUses string
end 


regexStr = varName + "((\.)?\w*)*";
fullQualifiedNames = regexp( nonTunableUses, regexStr, "match" );

if iscell( fullQualifiedNames )
fullQualifiedNames = [ fullQualifiedNames{ : } ];
end 
fullQualifiedNames = unique( fullQualifiedNames );
end 

function valueWasChanged = valueWasChangedUsingSimulationInput( qualifiedName, simInputValue, originalValue )



valueWasChanged = false;
fields = strsplit( qualifiedName, "." );
nonRootFields = fields( 2:end  );
try 
simInputValue = getfield( simInputValue, nonRootFields{ : } );
catch ME
if strcmp( ME.identifier, 'MATLAB:nonExistentField' )



valueWasChanged = true;
end 
end 
origFieldValue = getfield( originalValue, nonRootFields{ : } );
if ~isequal( simInputValue, origFieldValue )
valueWasChanged = true;
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmp2oJWVQ.p.
% Please follow local copyright laws when handling this file.

