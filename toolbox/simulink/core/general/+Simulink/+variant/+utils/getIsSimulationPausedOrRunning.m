function flag=getIsSimulationPausedOrRunning(modelName)







    simulationStatus=get_param(modelName,'SimulationStatus');
    flag=any(strcmp(simulationStatus,{'paused','running'}));
end
