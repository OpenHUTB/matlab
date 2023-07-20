function isOutsideSUD=checkIfResultIsOutsideSUD(result,topSubSystemToScale)









    dHandler=fxptds.SimulinkDataArrayHandler;
    isOutsideSUD=~result.isWithinProvidedScope(dHandler.getUniqueIdentifier((struct('Object',topSubSystemToScale))));
end
