



























classdef(ConstructOnLoad)TileSetMemoryCacheReader<matlab.graphics.chart.internal.maps.TileSetReader

    properties(Access=public,Dependent)







MaxNumMapTilesInCache
    end

    properties(GetAccess=public,SetAccess=private,Dependent)




NumMapTilesInCache
    end

    properties(Access=public)







        MapTileMemoryCache matlab.graphics.chart.internal.maps.MapTileMemoryCache=matlab.graphics.chart.internal.maps.MapTileMemoryCache.empty
    end

    properties(Access=private,Dependent)





TileSetName
    end

    methods
        function reader=TileSetMemoryCacheReader(varargin)





















            reader=reader@matlab.graphics.chart.internal.maps.TileSetReader(varargin{:});
            reader.MapTileMemoryCache=matlab.graphics.chart.internal.maps.MapTileMemoryCache;
            reader.MapTileMemoryCache.CacheName=reader.TileSetName;
        end

        function mapTile=readMapTile(reader,tileRow,tileCol,zoomLevel)
















            mapTile=readMapTileFromCache(reader,tileRow,tileCol,zoomLevel);

            if isempty(mapTile)


                mapTile=readMapTile@matlab.graphics.chart.internal.maps.TileSetReader(...
                reader,tileRow,tileCol,zoomLevel);
                cacheMapTile(reader,mapTile,tileRow,tileCol,zoomLevel)
            end
        end

        function set.MaxNumMapTilesInCache(reader,value)
            reader.MapTileMemoryCache.MaxNumMapTilesInCache=value;
        end

        function value=get.MaxNumMapTilesInCache(reader)
            value=reader.MapTileMemoryCache.MaxNumMapTilesInCache;
        end

        function set.NumMapTilesInCache(reader,value)
            reader.MapTileMemoryCache.NumMapTilesInCache=value;
        end

        function value=get.NumMapTilesInCache(reader)
            value=reader.MapTileMemoryCache.NumMapTilesInCache;
        end


        function name=get.TileSetName(reader)
            name=reader.TileSetMetadata.TileSetName;
        end
    end

    methods(Access='protected')

        function setTileSetMetadata(reader,meta)
            setTileSetMetadata@matlab.graphics.chart.internal.maps.TileSetReader(reader,meta);
            cache=reader.MapTileMemoryCache;
            if~isempty(cache)&&~strcmp(cache.CacheName,meta.TileSetName)
                resetCache(cache);
                cache.CacheName=meta.TileSetName;
            end
        end

        function cacheMapTile(reader,mapTile,tileRow,tileCol,zoomLevel)





            if reader.MapTileAcquired&&~isempty(mapTile)&&~reader.EnableExceptionHandling
                cache=reader.MapTileMemoryCache;
                addMapTileToCache(cache,mapTile,tileRow,tileCol,zoomLevel)
            end
        end
    end

    methods(Access='private')
        function mapTile=readMapTileFromCache(reader,tileRow,tileCol,zoomLevel)









            canUseCache=~reader.EnableExceptionHandling...
            &&isscalar(tileRow)&&isnumeric(tileRow)...
            &&isscalar(tileCol)&&isnumeric(tileCol)...
            &&isscalar(zoomLevel)&&isnumeric(zoomLevel);

            if canUseCache
                cache=reader.MapTileMemoryCache;
                mapTile=getMapTileFromCache(cache,tileRow,tileCol,zoomLevel);
                if~isempty(mapTile)

                    reader.MapTileAcquired=true;
                    reader.TileRowIndex=tileRow;
                    reader.TileColumnIndex=tileCol;
                    reader.ZoomLevel=zoomLevel;
                    reader.Exception=MException.empty;
                end
            else
                mapTile=[];
            end
        end
    end
end

