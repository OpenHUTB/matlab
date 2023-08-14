



































classdef BaseLayerConfigurationManager<handle
    properties




        PropertiesRequireUpdate(1,1)logical





        DefaultBasemap(1,1)string="streets-light"
    end

    properties(Dependent)





MaxNumMapTilesInCache






ConfigFolder









ConfigFilename
    end

    properties(SetAccess=private)




        BaseLayers string=string.empty





        InstalledBaseLayers string=string.empty





        DynamicAttributionReader matlab.graphics.chart.internal.maps.DynamicAttributionReader...
        =matlab.graphics.chart.internal.maps.DynamicAttributionReader.empty






OfflineReader
    end

    properties(SetAccess=private,Dependent)





TileSetMetadata






MapTileMemoryCache





CustomMapTileMemoryCache
    end

    properties(Access=public,Constant,Hidden)





        DefaultConfigFolder string=matlab.graphics.chart.internal.maps.mapdatadir





        DefaultConfigFilename string="baselayer_configuration.xml"
    end

    properties(Access='private')

        pMaxNumMapTilesInCache double=256


        pDefaultBaseLayer string


        pConfigFolder string


        pConfigFilename string


        pTileSetMetadata matlab.graphics.chart.internal.maps.TileSetMetadata...
        =matlab.graphics.chart.internal.maps.TileSetMetadata.empty


        pMapTileMemoryCache matlab.graphics.chart.internal.maps.MapTileMemoryCache...
        =matlab.graphics.chart.internal.maps.MapTileMemoryCache.empty


        pCustomMapTileMemoryCache matlab.graphics.chart.internal.maps.MapTileMemoryCache...
        =matlab.graphics.chart.internal.maps.MapTileMemoryCache.empty
    end

    methods(Static)
        function manager=instance()
            persistent uniqueInstanceOfConfigurationManager
            createNewInstance=...
            isempty(uniqueInstanceOfConfigurationManager)||...
            ~isvalid(uniqueInstanceOfConfigurationManager);
            if createNewInstance
                manager=matlab.graphics.chart.internal.maps.BaseLayerConfigurationManager();
                uniqueInstanceOfConfigurationManager=manager;
            else
                manager=uniqueInstanceOfConfigurationManager;
            end
        end
    end

    methods

        function updateProperties(manager)







            if manager.PropertiesRequireUpdate
                manager.PropertiesRequireUpdate=false;

                manager.DynamicAttributionReader=...
                matlab.graphics.chart.internal.maps.DynamicAttributionReader.empty;
                manager.MapTileMemoryCache=...
                matlab.graphics.chart.internal.maps.MapTileMemoryCache.empty;
                manager.CustomMapTileMemoryCache=...
                matlab.graphics.chart.internal.maps.MapTileMemoryCache.empty;
                manager.OfflineReader=[];
                manager.InstalledBaseLayers=string.empty;

                baseLayers=readConfiguration(manager);
                n=length(baseLayers);
                metaArray(n)=matlab.graphics.chart.internal.maps.TileSetMetadata;
                index=true(1,n);

                for k=1:n
                    baseLayer=baseLayers(k);
                    meta=metaArray(k);
                    meta.TileSetName=baseLayer;
                    try
                        meta=readMetadata(meta,manager.ConfigFolder);
                        if~meta.MapTileLocation.IsMapTileURL
                            if isempty(manager.OfflineReader)
                                reader=matlab.graphics.chart.internal.maps.WebMercatorTileSetReader(meta);
                                reader.EnableMapTileFileCache=false;
                                manager.OfflineReader=reader;
                            end
                            manager.InstalledBaseLayers(end+1,1)=baseLayer;
                        end
                        metaArray(k)=meta;
                    catch
                        index(k)=false;
                    end
                end
                metaArray=metaArray(index);
                baseLayers=baseLayers(index);
                manager.TileSetMetadata=metaArray;
                manager.BaseLayers=baseLayers;
            end
        end


        function reader=findDynamicAttributionReader(...
            manager,baseLayer,readerToAdd)








            reader=findObject(baseLayer,manager.DynamicAttributionReader,"BasemapName");
            if isempty(reader)&&nargin==3&&~isempty(readerToAdd)
                manager.DynamicAttributionReader(end+1)=readerToAdd;
                reader=readerToAdd;
            end
        end

        function meta=findTileSetMetadata(manager,baseLayer)







            meta=findObject(baseLayer,manager.TileSetMetadata,"TileSetName");
        end


        function cache=findMapTileMemoryCache(manager,baseLayer)







            cache=findObject(baseLayer,manager.MapTileMemoryCache,"CacheName");
            if isempty(cache)||~isvalid(cache)
                cache=matlab.graphics.chart.internal.maps.MapTileMemoryCache;
                cache.CacheName=baseLayer;
                if~isequal(cache.MaxNumMapTilesInCache,manager.MaxNumMapTilesInCache)
                    cache.MaxNumMapTilesInCache=manager.MaxNumMapTilesInCache;
                end
                manager.MapTileMemoryCache(end+1)=cache;
            end
        end

        function cache=findCustomMapTileMemoryCache(manager,meta)










            baseLayer=meta.TileSetName;
            location=meta.MapTileLocation.ParameterizedLocation;
            cache=findObject(baseLayer,manager.CustomMapTileMemoryCache,"CacheName");
            cache=findObject(location,cache,"Location");
            if isempty(cache)||~isvalid(cache)
                cache=matlab.graphics.chart.internal.maps.MapTileMemoryCache;
                cache.CacheName=baseLayer;
                cache.Location=location;
                if~isequal(cache.MaxNumMapTilesInCache,manager.MaxNumMapTilesInCache)
                    cache.MaxNumMapTilesInCache=manager.MaxNumMapTilesInCache;
                end
                manager.CustomMapTileMemoryCache(end+1)=cache;
            end
        end


        function set.MaxNumMapTilesInCache(manager,value)
            manager.pMaxNumMapTilesInCache=value;
            for k=1:length(manager.MapTileMemoryCache)
                cache=manager.MapTileMemoryCache(k);
                cache.MaxNumMapTilesInCache=value;
            end
        end


        function value=get.MaxNumMapTilesInCache(manager)
            value=manager.pMaxNumMapTilesInCache;
        end


        function set.ConfigFolder(manager,folder)
            manager.PropertiesRequireUpdate=(manager.pConfigFolder~=string(folder));
            manager.pConfigFolder=folder;
        end


        function folder=get.ConfigFolder(manager)
            folder=manager.pConfigFolder;
        end


        function set.ConfigFilename(manager,filename)
            manager.PropertiesRequireUpdate=(manager.pConfigFilename~=string(filename));
            manager.pConfigFilename=filename;
        end


        function filename=get.ConfigFilename(manager)
            filename=manager.pConfigFilename;
        end

        function set.TileSetMetadata(manager,meta)
            manager.pTileSetMetadata=meta;
        end

        function meta=get.TileSetMetadata(manager)
            updateProperties(manager);
            meta=manager.pTileSetMetadata;
        end

        function set.MapTileMemoryCache(manager,cache)
            manager.pMapTileMemoryCache=cache;
        end

        function meta=get.MapTileMemoryCache(manager)
            updateProperties(manager);
            meta=manager.pMapTileMemoryCache;
        end

        function set.CustomMapTileMemoryCache(manager,cache)
            manager.pCustomMapTileMemoryCache=cache;
        end

        function meta=get.CustomMapTileMemoryCache(manager)
            updateProperties(manager);
            meta=manager.pCustomMapTileMemoryCache;
        end
    end

    methods(Access=private)
        function manager=BaseLayerConfigurationManager()


            manager.PropertiesRequireUpdate=true;
            manager.pConfigFolder=manager.DefaultConfigFolder;
            manager.pConfigFilename=manager.DefaultConfigFilename;
            updateProperties(manager);
        end


        function baseLayers=readConfiguration(manager)








            folder=manager.ConfigFolder;
            basename=manager.ConfigFilename;
            filename=fullfile(folder,basename);
            baseLayers=readxml(filename);
        end
    end
end



function object=findObject(baseLayer,object,objectName)


    names=[object.(objectName)];
    index=strcmpi(baseLayer,names);
    object=object(index);
end



function baseLayers=readxml(filename)




    msg='';
    try

        [fid,msg]=fopen(filename,'r','native','utf-8');



        data=fread(fid);
        fclose(fid);

    catch e
        if~isempty(msg)


            e=addCause(e,MException('MATLAB:FileIO:UnableToOpenFile',msg));
        end
        throwAsCaller(e)
    end


    data=string(native2unicode(data,'utf-8')');%#ok<N2UNI>


    entity='BaseLayer';
    baseLayers=extractBetween(data,['<',entity,'>'],['</',entity,'>']);
end
