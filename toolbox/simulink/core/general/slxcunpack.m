function result = slxcunpack( varargin )

































































try 
[ varargin{ : } ] = convertStringsToChars( varargin{ : } );
p = inputParser(  );
p.addRequired( 'slxcFile', @Simulink.packagedmodel.validateSLXCFile );
p.addParameter( 'Target', 'All', @loc_validateTarget );
p.addParameter( 'Verbose', false, @loc_validateVerbose );
p.addParameter( 'UnpackReferencedModels', true, @loc_validateUnpackReferencedModels );
p.parse( varargin{ : } );

results = p.Results;
results.slxcFile = Simulink.packagedmodel.getSLXCFileOnPath( results.slxcFile );

clUnpacker = Simulink.packagedmodel.CommandLineUnpacker(  );
clUnpacker.unpack( results );
result = clUnpacker.getUnpackedInfo(  );
catch ME
throw( ME );
end 
end 

function result = loc_validateTarget( x )
if isempty( x ) || ~ischar( x ) || ~ismember( x, { 'All', 'Simulation', 'CodeGeneration' } )
DAStudio.error( 'Simulink:cache:clInvalidTarget' );
end 

result = true;
end 

function result = validLogical( x )
result = ~isempty( x ) && ( islogical( x ) || isequal( x, 0 ) || isequal( x, 1 ) ) ...
 && isscalar( x );
end 

function result = loc_validateVerbose( x )
if ~validLogical( x )
DAStudio.error( 'Simulink:cache:clInvalidVerbose' );
end 
result = true;
end 

function result = loc_validateUnpackReferencedModels( x )
if ~validLogical( x )
DAStudio.error( 'Simulink:cache:clInvalidUnpackReferencedModels' );
end 
result = true;
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpWlytYr.p.
% Please follow local copyright laws when handling this file.

