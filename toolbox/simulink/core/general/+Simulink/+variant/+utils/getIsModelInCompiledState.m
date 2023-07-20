function flag=getIsModelInCompiledState(modelName)







    simulationStatus=get_param(modelName,'SimulationStatus');
    flag=strcmp(simulationStatus,{'compiled'});
end
