function simInput = processSimulationInputForRevert( simInput, options )

arguments
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

