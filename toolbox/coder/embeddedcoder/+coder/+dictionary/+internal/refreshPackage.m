function refreshPackage(dictionaryObj,isRefreshPackageList)







    try
        if isRefreshPackageList
            coder.internal.getPackageList(true,true,true);
        end
        cm=coder.internal.CoderDataStaticAPI.CacheManager();
        cm.refreshPackage(dictionaryObj.sourceDictionary);
    catch e
        throwAsCaller(e);
    end
end
