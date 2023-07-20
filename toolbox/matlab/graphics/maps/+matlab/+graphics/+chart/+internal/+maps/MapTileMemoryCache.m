




















classdef MapTileMemoryCache<handle
    properties




        CacheName(1,1)string="basemap"






        Location(1,1)string=""
    end

    properties(Access=public,Dependent)










MaxNumMapTilesInCache
    end

    properties(GetAccess=public,SetAccess=private)




        NumMapTilesInCache double=0








        MapTileCacheTable table=table.empty
    end

    properties(Access=private)




        CacheIndex=0


        pMaxNumMapTilesInCache=128
    end

    methods
        function cache=MapTileMemoryCache(cacheName)










            if nargin>0
                cache.CacheName=cacheName;
            end
            cache.MapTileCacheTable=createMapTileCacheTable(cache.MaxNumMapTilesInCache);
        end


        function set.MaxNumMapTilesInCache(cache,value)
            validateattributes(value,{'numeric'},...
            {'integer','nonnegative','scalar'},mfilename,'MaxNumMapTilesInCache')

            maxNumMapTilesInCache=cache.pMaxNumMapTilesInCache;
            if~isempty(cache.MapTileCacheTable)
                if value>maxNumMapTilesInCache

                    numCacheMapTiles=value-maxNumMapTilesInCache;
                    t=createMapTileCacheTable(numCacheMapTiles);
                    cache.MapTileCacheTable=[cache.MapTileCacheTable;t];

                elseif value<maxNumMapTilesInCache

                    value=double(value);
                    numElementsToRemove=maxNumMapTilesInCache-value;
                    cache.MapTileCacheTable(end-numElementsToRemove+1:end,:)=[];
                    if cache.NumMapTilesInCache>value
                        cache.NumMapTilesInCache=value;
                    end
                end
            else

                if value>0
                    cache.MapTileCacheTable=createMapTileCacheTable(value);
                end
            end

            if cache.CacheIndex>value
                cache.CacheIndex=value;
            end
            cache.pMaxNumMapTilesInCache=double(value);
        end


        function value=get.MaxNumMapTilesInCache(cache)
            value=cache.pMaxNumMapTilesInCache;
        end


        function addMapTileToCache(cache,mapTile,tileRow,tileCol,zoomLevel)







            canAddToCache=...
            ~mapTileIsInCache(cache,tileRow,tileCol,zoomLevel)&&...
            cache.MaxNumMapTilesInCache>0;
            if canAddToCache



                cache.CacheIndex=cache.CacheIndex+1;
                if cache.CacheIndex>cache.MaxNumMapTilesInCache
                    cache.CacheIndex=1;
                end




                cache.NumMapTilesInCache=cache.NumMapTilesInCache+1;
                if cache.NumMapTilesInCache>cache.MaxNumMapTilesInCache
                    cache.NumMapTilesInCache=cache.MaxNumMapTilesInCache;
                end


                cache.MapTileCacheTable(cache.CacheIndex,:)=...
                {{mapTile},tileRow,tileCol,zoomLevel};

            end
        end


        function mapTile=getMapTileFromCache(cache,tileRow,tileCol,zoomLevel)







            index=mapTileCacheIndex(cache,tileRow,tileCol,zoomLevel);
            if any(index)

                t=cache.MapTileCacheTable;
                mapTile=t.MapTile{index};

            else
                mapTile=[];
            end
        end


        function resetCache(cache)





            cache.NumMapTilesInCache=0;
            cache.CacheIndex=0;
            cache.MapTileCacheTable=createMapTileCacheTable(cache.MaxNumMapTilesInCache);
        end


        function tf=mapTileIsInCache(cache,tileRow,tileCol,zoomLevel)






            tf=any(mapTileCacheIndex(cache,tileRow,tileCol,zoomLevel));
        end
    end

    methods(Access=private)
        function index=mapTileCacheIndex(cache,tileRow,tileCol,zoomLevel)








            cacheTable=cache.MapTileCacheTable;
            index=...
            tileRow==cacheTable.TileRow&...
            tileCol==cacheTable.TileColumn&...
            zoomLevel==cacheTable.ZoomLevel;
        end
    end

end



function t=createMapTileCacheTable(numCacheMapTiles)



    c=cell(numCacheMapTiles,1);
    d=-1*ones(numCacheMapTiles,1);
    variableNames=["MapTile","TileRow","TileColumn","ZoomLevel"];
    t=table(c,d,d,d,'VariableNames',variableNames);
end

