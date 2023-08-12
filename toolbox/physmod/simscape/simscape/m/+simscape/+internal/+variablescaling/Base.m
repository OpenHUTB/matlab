classdef Base < handle





methods ( Static, Access = protected )
function s = getStandardCatalogMessage( tag )
R36( Repeating )
tag{ mustBeText };
end 
cmd = "'physmod:simscape:simscape:variablescaling:" + tag{ 1 } + "'";
for ii = 2:length( tag )
cmd = cmd + ", """ + tag{ ii } + """";
end 
s = eval( "getString(message(" + cmd + "))" );
end 

function result = isValidSimulinkModel( name )
if ~lIstext( name )
result = false;
return ;
end 

if isvarname( name ) && bdIsLoaded( name )
if bdIsLibrary( name )
result = false;
else 
result = true;
end 
return ;
end 

resolvedName = which( name );




if ~isempty( resolvedName )
info = Simulink.MDLInfo( name );
result = strcmpi( info.BlockDiagramType, 'Model' );
else 
result = false;
end 
end 

function mustBeSimulinkModelName( name )
if isempty( name )
pm_error( 'physmod:simscape:simscape:variablescaling:ErrorInvalidModel', [ class( name ), '.empty' ] );
else 
if ~( lIstext( name ) && simscape.internal.variablescaling.Base.isValidSimulinkModel( name ) )
pm_error( 'physmod:simscape:simscape:variablescaling:ErrorInvalidModel', name );
end 
end 
end 

function result = getSimpleEquivalentUnit( startingUnit )
result = startingUnit;

if ~pm_isunit( startingUnit )
return ;
end 


suggestedUnits = pm_suggestunits( startingUnit );



convFactors = pm_unit( suggestedUnits, startingUnit );
candidates = convFactors( :, 1 ) == 1 & convFactors( :, 2 ) == 0;


startingTerms = length( strsplit( startingUnit, { '*', '/' } ) );
unitTerms = cellfun( @( x )( length( strsplit( x, { '*', '/' } ) ) ), suggestedUnits );





minTerms = min( unitTerms( candidates ) );
if minTerms < startingTerms
candidateUnits = suggestedUnits( candidates );
resultCell = candidateUnits( unitTerms( candidates ) == minTerms );
result = resultCell{ 1 };
end 
end 
end 
end 

function tf = lIstext( text )
tf = ischar( text ) || isstring( text );
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmplF43MA.p.
% Please follow local copyright laws when handling this file.

