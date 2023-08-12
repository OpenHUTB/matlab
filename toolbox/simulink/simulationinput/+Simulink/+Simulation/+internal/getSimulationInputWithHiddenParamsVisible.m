function simInput = getSimulationInputWithHiddenParamsVisible( simInput )


R36
simInput( 1, 1 )Simulink.SimulationInput
end 

simInput.ModelParameters = [ simInput.ModelParameters, simInput.HiddenModelParameters ];
simInput.HiddenModelParameters = [  ];

simInput.BlockParameters = [ simInput.BlockParameters, simInput.HiddenBlockParameters ];
simInput.HiddenBlockParameters = [  ];

simInput.Variables = [ simInput.Variables, simInput.HiddenVariables ];
simInput.HiddenVariables = [  ];
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpaQ3Xa6.p.
% Please follow local copyright laws when handling this file.

