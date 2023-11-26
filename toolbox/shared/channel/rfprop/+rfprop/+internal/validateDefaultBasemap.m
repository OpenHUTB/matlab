function validateDefaultBasemap(newValue)

    try
        validatestring(newValue,siteviewer.basemapchoices);
    catch e
        throwAsCaller(e);
    end