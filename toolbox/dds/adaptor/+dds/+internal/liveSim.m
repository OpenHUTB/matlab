function simout = liveSim( siminp )

arguments
    siminp Simulink.SimulationInput
end

prev_value = slfeature( 'LiveSimulation', 1 );
cleanup_obj = onCleanup( @(  )slfeature( 'LiveSimulation', prev_value ) );
live_siminp = siminp.setModelParameter( 'LiveSimulationEnabled', 'on' );
simout = sim( live_siminp );

end


