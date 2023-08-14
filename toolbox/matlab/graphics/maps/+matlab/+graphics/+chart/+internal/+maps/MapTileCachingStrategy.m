























classdef MapTileCachingStrategy<handle

    properties(Dependent)





        TileSetMetadata matlab.graphics.chart.internal.maps.TileSetMetadata
    end


    properties(Dependent)




EnableDiagnostics
    end


    properties(SetAccess=protected)




        CacheFolder string
    end


    properties(Access=protected,Dependent)





        MapTileCacheLocation matlab.graphics.chart.internal.maps.MapTileLocation
    end


    properties(Access=protected)

TileSetReaderEnvironmentManager
    end


    properties(Access=private)

pTileSetMetadata
    end


    methods
        function cache=MapTileCachingStrategy(meta)









            if nargin==0
                meta=matlab.graphics.chart.internal.maps.TileSetMetadata;
            end
            cache.TileSetMetadata=meta;

            cache.TileSetReaderEnvironmentManager=...
            matlab.graphics.chart.internal.maps.TileSetReaderEnvironmentManager.instance();
        end


        function copyFileToCacheFile(cache,filename,cachename)






            if~isempty(filename)&&~isempty(cachename)
                cachename=char(cachename);
                folder=fileparts(cachename);
                diagnosticsIsEnabled=cache.EnableDiagnostics;
                try


                    if~exist(folder,'dir')
                        if diagnosticsIsEnabled
                            fprintf('mkdir: %s\n',folder);
                        end
                        mkdir(folder)
                    end

                    if diagnosticsIsEnabled
                        fprintf('copy: %s\n',cachename)
                    end
                    copyfile(filename,cachename)

                catch e

                    if diagnosticsIsEnabled
                        fprintf('error: %s\n',e.message);
                    end
                end
            end
        end


        function cachename=mapTileCacheName(cache,tileRow,tileCol,zoomLevel)
















            location=cache.MapTileCacheLocation;
            if~isempty(location)
                cachename=char(mapTileName(location,tileRow,tileCol,zoomLevel));
            else
                cachename=string.empty;
            end
        end


        function[fileExists,cachename]=cacheLocationExists(cache,...
            tileRow,tileCol,zoomLevel)











            cachename=mapTileCacheName(cache,tileRow,tileCol,zoomLevel);
            fileExists=cacheFileExists(cachename);
        end


        function deleteCacheFolder(cache)




            deleteFolder(cache)
        end



        function set.TileSetMetadata(cache,meta)
            preprocessAndSetTileSetMetadata(cache,meta);
            mapTileCacheLocation=computeMapTileCacheLocation(cache);
            if~isempty(mapTileCacheLocation)
                folder=mapTileCacheLocation.ParameterizedLocation;
                if contains(folder,'$')
                    folder=extractBefore(folder,'$');
                end
                cache.CacheFolder=folder;
            end
            cache.pTileSetMetadata.MapTileCacheLocation=mapTileCacheLocation;
        end


        function meta=get.TileSetMetadata(cache)
            meta=cache.pTileSetMetadata;
        end


        function mapTileCacheLocation=get.MapTileCacheLocation(cache)
            mapTileCacheLocation=cache.pTileSetMetadata.MapTileCacheLocation;
        end

        function set.EnableDiagnostics(cache,value)
            cache.TileSetReaderEnvironmentManager.EnableDiagnostics=value;
        end

        function tf=get.EnableDiagnostics(cache)
            if~isvalid(cache.TileSetReaderEnvironmentManager)
                cache.TileSetReaderEnvironmentManager=...
                matlab.graphics.chart.internal.maps.TileSetReaderEnvironmentManager.instance();
            end
            tf=cache.TileSetReaderEnvironmentManager.EnableDiagnostics;
        end
    end


    methods(Access=protected)

        function mapTileCacheLocation=computeMapTileURLCacheLocation(cache)%#ok<MANU>


            mapTileCacheLocation=matlab.graphics.chart.internal.maps.MapTileLocation.empty;
        end


        function preprocessAndSetTileSetMetadata(cache,meta)



            cache.pTileSetMetadata=meta;
        end


        function deleteFolder(cache,folder)







            if nargin==1
                folder=cache.CacheFolder;
            end

            try

                folder=char(folder);
                if~isempty(folder)&&exist(folder,'dir')
                    if cache.EnableDiagnostics
                        fprintf('Removing folder: %s\n',folder)
                    end
                    rmdir(folder,'s')
                end
            catch e
                if cache.EnableDiagnostics
                    disp(e.message)
                end
            end
        end
    end

    methods(Access=private)

        function mapTileCacheLocation=computeMapTileCacheLocation(cache)













            isMapTileURL=~isempty(cache.TileSetMetadata)...
            &&cache.TileSetMetadata.MapTileLocation.IsMapTileURL;

            if isMapTileURL

                location=cache.TileSetMetadata.MapTileCacheLocation;

                if~isempty(location)

                    mapTileCacheLocation=location;
                else

                    mapTileCacheLocation=computeMapTileURLCacheLocation(cache);
                end
            else

                mapTileCacheLocation=matlab.graphics.chart.internal.maps.MapTileLocation.empty;
            end
        end
    end
end



function tf=cacheFileExists(cachename)





    tf=isscalar(dir(char(cachename)));
end
