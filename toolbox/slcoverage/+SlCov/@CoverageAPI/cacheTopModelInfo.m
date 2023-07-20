function cacheTopModelInfo(topModel)





    excludeTopModel=strcmpi(get_param(topModel,'RecordCoverage'),'off');
    modelRefEnable=get_param(topModel,'CovModelRefEnable');
    modelRefExcludeList=cv.ModelRefData.getExcludedModels(get_param(topModel,'CovModelRefExcluded'));
    cvi.ModelInfoCache.cacheTopModelInfo(topModel,excludeTopModel,modelRefEnable,modelRefExcludeList);
end