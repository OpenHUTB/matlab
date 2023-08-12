function updateTunableParam( tunableParamName, u )



bd = bdroot( gcs );
if ~isequal( get_param( bd, 'SimulationStatus' ), 'updating' )
baseVar = evalin( 'base', tunableParamName );
baseVar.Value = u;
assignin( 'base', tunableParamName, baseVar );
set_param( bd, 'SimulationCommand', 'update' );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpuYwmN3.p.
% Please follow local copyright laws when handling this file.

