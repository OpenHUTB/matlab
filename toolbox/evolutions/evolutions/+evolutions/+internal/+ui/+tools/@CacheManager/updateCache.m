function updateCache(obj,cacheName)




    if obj.Enabled

        cacheObj=obj.CacheNamesToCaches(cacheName);

        oldData=obj.CacheData(cacheName);

        obj.CacheData(cacheName)=cacheObj.UpdateFunction(oldData);

    end