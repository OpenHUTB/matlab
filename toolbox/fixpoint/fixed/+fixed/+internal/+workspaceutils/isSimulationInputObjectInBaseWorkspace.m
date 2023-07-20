function b=isSimulationInputObjectInBaseWorkspace(simulationInputVariableName)






    baseWorkspace=Simulink.data.BaseWorkspace;


    allSimulationInputs=baseWorkspace.whos('Simulink.SimulationInput');

    b=ismember(simulationInputVariableName,allSimulationInputs);

end

