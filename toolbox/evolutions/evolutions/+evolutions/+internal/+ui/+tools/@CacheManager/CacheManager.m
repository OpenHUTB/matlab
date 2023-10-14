classdef CacheManager < handle

    properties ( SetAccess = private )
        CacheNamesToCaches
        CacheData
        Enabled
        CacheDir
        CacheFile
    end

    methods ( Access = public )
        function obj = CacheManager( options )

            arguments
                options.Enabled = true;
                options.CacheDir = fullfile( prefdir, 'evolutions', 'cache' );
            end

            obj.Enabled = options.Enabled;
            obj.CacheDir = options.CacheDir;
            obj.CacheFile = fullfile( obj.CacheDir, 'data.mat' );
            obj.CacheNamesToCaches = containers.Map;
            obj.CacheData = containers.Map;
            obj.loadCacheData;
        end

        delete( obj )

        createCache( obj, cacheName, defaultCacheValue, updateFuntion )

        data = getCacheData( obj, cacheName )

        updateCache( obj, cacheName )

        resetAllCaches( obj )

        resetCache( obj, cacheName )

        deleteCacheFile( obj )

        tf = cacheFileExists( obj )

    end

    methods ( Access = private )
        loadCacheData( obj )
    end


end


