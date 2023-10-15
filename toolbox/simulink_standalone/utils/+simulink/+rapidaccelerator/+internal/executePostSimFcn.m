function simOut = executePostSimFcn( simInput, simOut )

arguments
    simInput( 1, 1 )Simulink.SimulationInput
    simOut( 1, 1 )Simulink.SimulationOutput
end
simOut = simInput.executePostSimFcn( simOut );
end


