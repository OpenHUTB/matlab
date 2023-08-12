function startSimulationCallback( modelName, isModelRef, varargin )




if isModelRef
return ;
end 
if ~isempty( get_param( modelName, 'RTWBuildArgs' ) )
return ;
end 
theFile = fullfile( pwd, 'socb_sim_in_progress.lock' );
if exist( theFile, 'file' )
error( message( 'soc:scheduler:SimInProgress' ) );
else 
[ fid, msg ] = fopen( theFile, 'w' );
if ( fid ==  - 1 )
error( message( 'soc:scheduler:CannotLockSim', msg ) );
end 
fclose( fid );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpxVUL0g.p.
% Please follow local copyright laws when handling this file.

