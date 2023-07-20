function addModelRefToCache(modelH)




    try
        modelName=get_param(modelH,'name');
        isEnabled=SlCov.CoverageAPI.isModelRefEnabledFromTop(modelName);
        cvi.ModelInfoCache.cacheModelRef(modelName,isEnabled);
    catch MEx
        rethrow(MEx);
    end
end