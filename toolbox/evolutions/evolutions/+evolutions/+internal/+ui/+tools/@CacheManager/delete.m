function delete(obj)




    if obj.Enabled
        try
            cacheData=obj.CacheData;
            evolutions.internal.utils.createDirSafe(obj.CacheDir);
            save(obj.CacheFile,'cacheData');
        catch ME %#ok<NASGU>

        end
    end

end
