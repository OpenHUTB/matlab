



function data = loadCovObjects( filename, analyzedModel )
R36
filename( 1, : )char;
analyzedModel( 1, : ) = '';
end 


prev_state = warning( 'query', 'backtrace' );
warning( 'backtrace', 'off' );
bt = onCleanup( @(  )warning( 'backtrace', prev_state.state ) );

if strlength( filename ) == 0
error( stm.internal.Coverage.getCovErrorMsg( analyzedModel, 'ModelModifiedError' ) );
end 




[ ~, data ] = cvload( filename );









if isempty( data ) && strlength( analyzedModel ) > 0



analyzedModel = Simulink.SimulationData.BlockPath.getModelNameForPath( analyzedModel );


if bdIsLoaded( analyzedModel ) && strcmp( get_param( analyzedModel, 'dirty' ), 'off' )



SlCov.ContextGuard.removeGuard( analyzedModel );
bdclose( analyzedModel );
[ ~, data ] = cvload( filename );
load_system( analyzedModel );
end 
end 

if isempty( data )
error( stm.internal.Coverage.getCovErrorMsg( analyzedModel, 'ModelModifiedError' ) );
elseif isa( data{ 1 }, 'cv.cvdatagroup' )

data = data{ 1 }.getAll;
end 

data = stm.internal.Coverage.flattenCovObjects( data );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp78VynW.p.
% Please follow local copyright laws when handling this file.

