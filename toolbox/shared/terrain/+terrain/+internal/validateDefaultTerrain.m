function validateDefaultTerrain(newValue)




    try
        validatestring(newValue,terrain.internal.TerrainSource.terrainchoices);
    catch e
        throwAsCaller(e);
    end