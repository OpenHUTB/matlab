function simIns=createSimulationInputsFromDesignPoints(modelName,designPoints)




    simInCreator=simulink.multisim.internal.SimInputCreator(modelName,designPoints);
    simIns=simInCreator.createSimInputs();
end