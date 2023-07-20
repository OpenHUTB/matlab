function[simulationStopTime]=utilUpdateSimulationStopTime(sscCodeGenWorkflowObj)




    simscapeModel=sscCodeGenWorkflowObj.SimscapeModel;
    simulationStopTime=get_param(simscapeModel,'StopTime');
end
