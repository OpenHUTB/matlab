function simInput = getSimulationInputWithHiddenParamsVisible( simInput )


arguments
    simInput( 1, 1 )Simulink.SimulationInput
end

simInput.ModelParameters = [ simInput.ModelParameters, simInput.HiddenModelParameters ];
simInput.HiddenModelParameters = [  ];

simInput.BlockParameters = [ simInput.BlockParameters, simInput.HiddenBlockParameters ];
simInput.HiddenBlockParameters = [  ];

simInput.Variables = [ simInput.Variables, simInput.HiddenVariables ];
simInput.HiddenVariables = [  ];
end
