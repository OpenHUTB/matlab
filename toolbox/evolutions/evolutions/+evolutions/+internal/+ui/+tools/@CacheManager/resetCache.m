function resetCache(obj,cacheName)




    cacheObj=obj.CacheNamesToCaches(cacheName);

    obj.CacheData(cacheName)=cacheObj.DefaultCacheValue;

end
