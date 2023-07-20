function validateDefaultBasemap(newValue)




    try
        validatestring(newValue,globe.internal.GlobeModel.basemapchoices);
    catch e
        throwAsCaller(e);
    end