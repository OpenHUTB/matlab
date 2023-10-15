function simOut = runParallelSimOnProcessWorker( fh, simInputs, multisimInfo )

arguments
    fh( 1, 1 )function_handle
    simInputs Simulink.SimulationInput
    multisimInfo
end

simIn = simInputs( 1 );
simHelper = getSimulationInputSimHelper(  );
rtp = [  ];
simIn = simHelper.tuneParametersForRapidAccelerator( simIn, rtp );
paramNames = string( { simIn.HiddenModelParameters.Name } );
paramIdx = find( contains( paramNames, 'RapidAcceleratorParameterSets', 'IgnoreCase', true ) );
assert( ~isempty( paramIdx ) );
rtp = simIn.HiddenModelParameters( paramIdx ).Value;

assert( isa( multisimInfo.dataQueue, 'parallel.pool.DataQueue' ) );
assert( isa( multisimInfo.verboseQueue, 'parallel.pool.DataQueue' ) );

simIn = simulink.rapidaccelerator.internal.aggregateSimInputs( simInputs, rtp, multisimInfo );
simOut = MultiSim.internal.runSingleSim( fh, simIn );
end

