function[wasSuccessful,errMsg]=cb_reportGeneration(sessionId,modelName,sigIds,inspecId)





    if~isempty(modelName)

        cachedHilightCell=cacheCurrentHighlightState(modelName);
        clearHighlightState(modelName);
    end

    [wasSuccessful,errMsg]=generateStaReport(sessionId,modelName,sigIds,inspecId);


    if~isempty(modelName)

        returnHighlightState(cachedHilightCell);
    end

end

