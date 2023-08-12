function simInput = processSimulationInputForRevert( simInput, options )





R36
simInput( 1, 1 )Simulink.SimulationInput
options.ProcessHidden( 1, 1 )matlab.lang.OnOffSwitchState = "off"
options.HasConfigSetRef( 1, 1 )matlab.lang.OnOffSwitchState = "off"
end 

simInput = Simulink.Simulation.internal.processPreSimFcnOnSimulationInput( simInput );
simInput = Simulink.Simulation.internal.transformInitialStateOnSimulationInput( simInput, "HasConfigSetRef", options.HasConfigSetRef );

if options.ProcessHidden
simInput = Simulink.Simulation.internal.transformLoggingSpecificationOnSimulationInput( simInput );
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpSyM5ye.p.
% Please follow local copyright laws when handling this file.

