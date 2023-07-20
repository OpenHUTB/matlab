






























































































classdef BaseLayerSelector<handle

    properties(Dependent)





ConfigFolder









ConfigFilename
    end

    properties(SetAccess=private,Dependent)





DefaultBaseLayer





BaseLayers





CustomBaseLayers
    end

    properties(Access=private)




        ConfigReaderCache containers.Map




        CustomReaderCache containers.Map


        pEnableTileSetAsyncReader logical=true
    end

    properties(Access=private,Dependent)



BaseLayerConfigurationManager



CacheRequiresUpdate




DefaultConfigFolder





InstalledBaseLayers




OfflineReader





EnableTileSetAsyncReader
    end

    methods
        function selector=BaseLayerSelector(varargin)









            selector=matlab.graphics.chart.internal.maps.checkAndSetNameValuePairs(...
            selector,varargin{:});


            selector.ConfigReaderCache=containers.Map;
            selector.CustomReaderCache=containers.Map;


            updateConfiguration(selector);
        end


        function reader=selectReader(selector,baseLayer)















            if selector.CacheRequiresUpdate
                updateConfiguration(selector);
            end

            if nargin==1||isempty(baseLayer)


                baseLayer=selector.DefaultBaseLayer;
                [meta,readerIsCached]=findTileSetMetadata(selector,baseLayer);

            elseif isa(baseLayer,'matlab.graphics.chart.internal.maps.TileSetMetadata')








                meta=baseLayer;
                readerIsCached=readerIsInConfigurationCache(selector,meta);

            else

                validateattributes(baseLayer,{'char','string'},{'nonempty','scalartext'},'','Basemap');



                baseLayer=string(baseLayer);
                [meta,readerIsCached]=findTileSetMetadata(selector,baseLayer);
            end

            if readerIsCached

                reader=findReader(selector,meta);

            elseif isempty(meta)

                reader=matlab.graphics.chart.internal.maps.WebMercatorTileSetReader.empty;

            elseif~meta.MapTileLocation.IsMapTileURL



                if matlab.internal.maps.isTileSetFile(meta.MapTileLocation.ParameterizedLocation)
                    reader=matlab.internal.maps.TileSetFileReader(meta);
                else
                    reader=matlab.graphics.chart.internal.maps.WebMercatorTileSetReader(meta);
                end

            elseif customReaderIsCached(selector,meta)



                reader=findCustomReader(selector,meta);

            else



                reader=createTileSetReader(selector,meta);
                manager=selector.BaseLayerConfigurationManager;
                cache=findCustomMapTileMemoryCache(manager,meta);
                reader.MapTileMemoryCache=cache;
                insertCustomReader(selector,reader)
            end

            if~isempty(reader)
                reader.EnableWarnings=true;
                reader.ReaderIsOffline=false;
            end
        end


        function delete(selector)




            delete(selector.ConfigReaderCache)
        end




        function defaultBaseLayer=get.DefaultBaseLayer(selector)
            defaultBaseLayer=selector.BaseLayerConfigurationManager.InstalledBaseLayers;
            if~isempty(defaultBaseLayer)
                defaultBaseLayer=defaultBaseLayer(1);
            end
        end


        function baseLayers=get.BaseLayers(selector)
            baseLayers=selector.BaseLayerConfigurationManager.BaseLayers;
        end


        function baseLayers=get.CustomBaseLayers(selector)

            meta=matlab.graphics.chart.internal.maps.readCustomTileSetMetadata();
            baseLayers=string(vertcat(meta.TileSetName));


            baseLayers=setdiff(baseLayers,selector.BaseLayers);
            if isempty(baseLayers)
                baseLayers=string.empty;
            end
        end


        function set.ConfigFolder(selector,folder)
            selector.BaseLayerConfigurationManager.ConfigFolder=folder;
        end


        function folder=get.ConfigFolder(selector)
            folder=selector.BaseLayerConfigurationManager.ConfigFolder;
        end


        function set.ConfigFilename(selector,filename)
            selector.BaseLayerConfigurationManager.ConfigFilename=filename;
        end


        function filename=get.ConfigFilename(selector)
            filename=selector.BaseLayerConfigurationManager.ConfigFilename;
        end


        function tf=get.CacheRequiresUpdate(selector)
            tf=selector.BaseLayerConfigurationManager.PropertiesRequireUpdate;
        end


        function folder=get.DefaultConfigFolder(selector)
            folder=selector.BaseLayerConfigurationManager.DefaultConfigFolder;
        end


        function instance=get.BaseLayerConfigurationManager(~)
            instance=matlab.graphics.chart.internal.maps.BaseLayerConfigurationManager.instance();
        end


        function baseLayers=get.InstalledBaseLayers(selector)
            baseLayers=selector.BaseLayerConfigurationManager.InstalledBaseLayers;
        end


        function baseLayers=get.OfflineReader(selector)
            baseLayers=selector.BaseLayerConfigurationManager.OfflineReader;
        end


        function tf=get.EnableTileSetAsyncReader(reader)
            name='EnableTileSetAsyncReader';
            if isappdata(groot,name)
                tf=getappdata(groot,name);
                reader.pEnableTileSetAsyncReader=tf;
            else
                tf=reader.pEnableTileSetAsyncReader;
            end
        end
    end


    methods(Access='private')
        function updateConfiguration(selector)






            manager=selector.BaseLayerConfigurationManager;
            updateProperties(manager)

            baseLayers=selector.BaseLayers;
            readers=cell(size(baseLayers));
            selector.ConfigReaderCache=containers.Map(baseLayers,readers);
        end


        function reader=createTileSetReader(selector,meta)








            if selector.EnableTileSetAsyncReader&&meta.MapTileLocation.IsMapTileURL
                reader=matlab.graphics.chart.internal.maps.WebMercatorTileSetAsyncReader(meta);
                reader.IsPrinting=false;
            else
                reader=matlab.graphics.chart.internal.maps.WebMercatorTileSetReader(meta);
            end
        end


        function tf=readerIsInConfigurationCache(selector,meta)






            baseLayer=char(meta.TileSetName);
            manager=selector.BaseLayerConfigurationManager;
            cachedMeta=manager.findTileSetMetadata(baseLayer);

            if~isempty(cachedMeta)


                tf=strcmp(...
                cachedMeta.MapTileLocation.ParameterizedLocation,...
                meta.MapTileLocation.ParameterizedLocation);
            else
                tf=false;
            end
        end


        function reader=findReader(selector,meta)






            if meta.TileSetName==selector.DefaultBaseLayer
                reader=selector.BaseLayerConfigurationManager.OfflineReader;
            else
                readers=selector.ConfigReaderCache;
                baseLayer=meta.TileSetName;
                reader=readers(baseLayer);
                if isempty(reader)
                    reader=createConfigurationReader(selector,meta);
                    readers(baseLayer)=reader;
                    selector.ConfigReaderCache=readers;
                end
            end
        end


        function reader=createConfigurationReader(selector,meta)










            reader=createTileSetReader(selector,meta);
            manager=selector.BaseLayerConfigurationManager;
            baseLayer=meta.TileSetName;

            attribReader=reader.DynamicAttributionReader;
            reader.DynamicAttributionReader=...
            findDynamicAttributionReader(manager,baseLayer,attribReader);

            cache=findMapTileMemoryCache(manager,baseLayer);
            reader.MapTileMemoryCache=cache;

            if meta.MapTileLocation.IsMapTileURL
                cacheLocation=meta.MapTileCacheLocation;
                usingTimedCache=~isempty(cacheLocation)&&...
                startsWith(cacheLocation.ParameterizedLocation,"file://");
                needsOfflineReader=~usingTimedCache||isempty(cacheLocation);
                if needsOfflineReader
                    reader.OfflineReader=selector.OfflineReader;
                end
            else
                reader.EnableMapTileFileCache=false;
            end
        end


        function reader=findCustomReader(selector,meta)








            readers=selector.CustomReaderCache;
            baseLayer=meta.TileSetName;
            reader=readers(char(baseLayer));
        end


        function tf=customReaderIsCached(selector,meta)





            readers=selector.CustomReaderCache;
            baseLayer=char(meta.TileSetName);
            tf=isKey(readers,baseLayer);
            if tf


                reader=readers(baseLayer);
                tf=isequal(reader.TileSetMetadata,meta);
            end
        end


        function insertCustomReader(selector,reader)






            baseLayer=char(reader.TileSetMetadata.TileSetName);
            cache=selector.CustomReaderCache;
            cache(baseLayer)=reader;
            selector.CustomReaderCache=cache;
        end


        function[meta,readerIsCached]=findTileSetMetadata(selector,baseLayer)























            [meta,readerIsCached]=findConfigurationMetadata(selector,baseLayer);
            if isempty(meta)





                meta=readTileSetMetadata(baseLayer);
                if isempty(meta)






                    customMetadata=matlab.graphics.chart.internal.maps.readCustomTileSetMetadata();
                    customBaseLayers=string(vertcat(customMetadata.TileSetName));
                    validBaseLayers=[selector.BaseLayers;customBaseLayers];
                    baseLayer=validateBaseLayer(baseLayer,validBaseLayers);

                    if any(strcmp(baseLayer,selector.BaseLayers))





                        [meta,readerIsCached]=findConfigurationMetadata(selector,baseLayer);
                    else



                        index=strcmp(baseLayer,customBaseLayers);
                        meta=customMetadata(index);
                        readerIsCached=false;
                    end
                end
            end
        end


        function[meta,readerIsCached]=findConfigurationMetadata(selector,baseLayer)















            meta=matlab.graphics.chart.internal.maps.TileSetMetadata.empty;
            manager=selector.BaseLayerConfigurationManager;
            cachedMeta=findTileSetMetadata(manager,baseLayer);
            readerIsCached=false;
            if~isempty(cachedMeta)





                useSupportPackage=strcmp(selector.ConfigFolder,selector.DefaultConfigFolder);
                if useSupportPackage
                    meta=findSupportPackageMetadata(baseLayer);
                end
                if isempty(meta)


                    meta=cachedMeta;
                    readerIsCached=true;
                end
            end
        end
    end
end



function meta=readTileSetMetadata(baseLayer,folder)




    if nargin==1



        [folder,baseLayer]=fileparts(char(baseLayer));
    end

    meta=matlab.graphics.chart.internal.maps.TileSetMetadata;
    meta.TileSetName=baseLayer;
    try
        meta=readMetadata(meta,folder);
    catch
        meta=matlab.graphics.chart.internal.maps.TileSetMetadata.empty;
    end
end



function meta=findSupportPackageMetadata(baseLayer)



    try
        mapdataroot=matlab.graphics.chart.internal.maps.getBasemapDataSupportPackageFolder(baseLayer);
        meta=readTileSetMetadata(baseLayer,mapdataroot);
        if meta.MaxZoomLevel~=7
            meta=matlab.graphics.chart.internal.maps.TileSetMetadata.empty;
        end
    catch
        meta=matlab.graphics.chart.internal.maps.TileSetMetadata.empty;
    end
end



function baseLayer=validateBaseLayer(baseLayer,basemapNames)




    basemapNames(end+1)="none";
    baseLayer=validatestring(baseLayer,basemapNames,'graphics:maps','Basemap');
end
