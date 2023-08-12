function simout = liveSim( siminp )






















R36
siminp Simulink.SimulationInput
end 

prev_value = slfeature( 'LiveSimulation', 1 );
cleanup_obj = onCleanup( @(  )slfeature( 'LiveSimulation', prev_value ) );
live_siminp = siminp.setModelParameter( 'LiveSimulationEnabled', 'on' );
simout = sim( live_siminp );
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpBTYPP5.p.
% Please follow local copyright laws when handling this file.

