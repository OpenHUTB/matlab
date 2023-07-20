























classdef MapTileSessionCachingStrategy<matlab.graphics.chart.internal.maps.MapTileCachingStrategy

    methods
        function cache=MapTileSessionCachingStrategy(varargin)









            cache=cache@matlab.graphics.chart.internal.maps.MapTileCachingStrategy(varargin{:});
        end


        function delete(cache)





            if cache.EnableDiagnostics
                fprintf('Delete %s\n',cache.CacheFolder)
            end
            deleteCacheFolder(cache)
        end
    end

    methods(Access=protected)

        function mapTileCacheLocation=computeMapTileURLCacheLocation(cache)








            if isempty(cache.CacheFolder)
                cache.CacheFolder=tempname;
            end
            sessionCacheFolder=fullfile(...
            char(cache.CacheFolder),...
            'maptiles',...
            char(cache.TileSetMetadata.TileSetName));
            mapTileCacheLocation=...
            matlab.graphics.chart.internal.maps.MapTileLocation(sessionCacheFolder);
        end
    end
end
