function resetAllCaches(obj)




    cacheNames=obj.CacheNamesToCaches.keys;

    for nameIdx=1:length(cacheNames)
        curCacheName=cacheNames{nameIdx};
        obj.resetCache(curCacheName);
    end
