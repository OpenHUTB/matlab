function loadCacheData(obj)




    if obj.Enabled&&obj.cacheFileExists
        try
            s=load(obj.CacheFile);
            obj.CacheData=s.cacheData;
        catch


        end
    end

end
