function createCache(obj,cacheName,defaultCacheValue,updateFunction)




    cacheObj=evolutions.internal.ui.tools.Cache(cacheName,...
    defaultCacheValue,updateFunction);
    obj.CacheNamesToCaches(cacheName)=cacheObj;



    if~obj.CacheData.isKey(cacheName)||~obj.Enabled
        obj.CacheData(cacheName)=cacheObj.DefaultCacheValue;
    end

end
