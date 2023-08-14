



































classdef(ConstructOnLoad)WebMercatorTileSetAsyncReader<matlab.graphics.chart.internal.maps.WebMercatorTileSetReader

    properties




        IsPrinting logical=false





        SourceObject=[]







        Action(1,1)string="download"
    end

    properties(Dependent)




AsyncReadCount
    end

    properties(GetAccess=public,SetAccess=private)




        TileCacheIsEnabled logical=true
    end

    properties(Access=protected)





        URL string=string.empty






        Filename string=string.empty








        Tempname string=string.empty





        UsingAsynchronous logical=false






        TileQuadReference matlab.graphics.chart.internal.maps.TileQuadReference...
        =matlab.graphics.chart.internal.maps.TileQuadReference.empty






        MapTileReaderManager matlab.graphics.chart.internal.maps.MapTileReaderManager...
        =matlab.graphics.chart.internal.maps.MapTileReaderManager.empty






        MapTileReader matlab.graphics.chart.internal.maps.MapTileAsyncReader...
        =matlab.graphics.chart.internal.maps.MapTileAsyncReader.empty;








        TileQuadRequestManager matlab.graphics.chart.internal.maps.TileQuadRequestManager...
        =matlab.graphics.chart.internal.maps.TileQuadRequestManager.empty
    end


    methods
        function reader=WebMercatorTileSetAsyncReader(varargin)





















            reader=reader@matlab.graphics.chart.internal.maps.WebMercatorTileSetReader(varargin{:});
            reader.MapTileReaderManager=matlab.graphics.chart.internal.maps.MapTileReaderManager;
            reader.TileQuadRequestManager=matlab.graphics.chart.internal.maps.TileQuadRequestManager;
        end

        function initialize(reader)







            reset(reader)
            if~isempty(reader.MapTileReaderManager)
                delete(reader.MapTileReaderManager)
            end
            if~isempty(reader.TileQuadRequestManager)
                delete(reader.TileQuadRequestManager)
            end

            reader.MapTileReaderManager=matlab.graphics.chart.internal.maps.MapTileReaderManager;
            reader.TileQuadRequestManager=matlab.graphics.chart.internal.maps.TileQuadRequestManager;
        end


        function fillTileQuads(reader,tileQuadRefs)



















            reset(reader)
            reader.UsingAsynchronous=true;

            readerIsOffline=reader.ReaderIsOffline;
            reader.ReaderIsOffline=false;
            mapTileFoundIndex=false(1,length(tileQuadRefs));
            for k=1:length(tileQuadRefs)
                q=tileQuadRefs(k);
                mapTile=readMapTile(reader,q.YTileIndex,q.XTileIndex,q.ZoomLevel);

                if~isempty(mapTile)
                    q.CData=mapTile;
                    mapTileFoundIndex(k)=true;

















                end
            end
            tileQuadRefs(mapTileFoundIndex)=[];
            reader.TileQuadReference=tileQuadRefs;
            reader.ReaderIsOffline=readerIsOffline;
            reader.UsingAsynchronous=false;




            if~isempty(reader.URL)
                try
                    mapTileReader=getNextAvailableReader(reader.MapTileReaderManager);
                    manager=reader.TileQuadRequestManager;
                    newRequestIndex=newRequest(manager,reader.URL,reader.TileQuadReference);

                    if reader.IsPrinting

                        newRequestIndex(~newRequestIndex)=true;
                    end

                    if any(newRequestIndex)
                        mapTileReader.Action=reader.Action;
                        mapTileReader.URL=reader.URL(newRequestIndex);
                        mapTileReader.Filename=reader.Filename(newRequestIndex);
                        mapTileReader.Tempname=reader.Tempname(newRequestIndex);
                        mapTileReader.TileQuadReference=reader.TileQuadReference(newRequestIndex);

                        mapTileReader.IsPrinting=reader.IsPrinting;
                        mapTileReader.SourceObject=reader.SourceObject;
                        mapTileReader.TileSetReader=reader;
                        mapTileReader.TileQuadRequestManager=manager;
                        reader.MapTileReader=mapTileReader;
                        fillTileQuads(mapTileReader);
                    end
                catch
                end
            end
            reader.UsingAsynchronous=false;
        end

        function fillTileQuadsWithMissingTile(reader,url)





            reader.MapTileAcquired=false;
            tileQuadRefs=findTileQuadReference(reader.TileQuadRequestManager,url);
            removeRequest(reader.TileQuadRequestManager,url);

            if~isempty(tileQuadRefs)
                q=tileQuadRefs(1);
                mapTile=readMissingMapTile(reader,...
                q.YTileIndex,q.XTileIndex,q.ZoomLevel);

                for k=1:length(tileQuadRefs)
                    tileQuad=tileQuadRefs(k);
                    reader.ReaderIsOffline=true;
                    tileQuad.CData=mapTile;
                end
            end
        end

        function fillTileQuadsWithMapTile(reader,mapTile,url)







            if~isempty(mapTile)
                reader.MapTileAcquired=true;
                tileQuadRefs=findTileQuadReference(reader.TileQuadRequestManager,url);
                removeRequest(reader.TileQuadRequestManager,url,tileQuadRefs);

                for k=1:length(tileQuadRefs)
                    tileQuadRef=tileQuadRefs(k);
                    if~isempty(tileQuadRef.TileQuad)
                        tileQuadRef.CData=mapTile;

                        if reader.MaxNumMapTilesInCache>0
                            tileRow=tileQuadRef.YTileIndex;
                            tileCol=tileQuadRef.XTileIndex;
                            zoomLevel=tileQuadRef.ZoomLevel;
                            cacheMapTile(reader,mapTile,tileRow,tileCol,zoomLevel)
                        end
                    end
                end
            end
        end


        function delete(reader)





            delete(reader.MapTileReaderManager)
        end








        function value=get.AsyncReadCount(reader)
            mapTileReader=reader.MapTileReader;
            if~isempty(mapTileReader)&&isvalid(mapTileReader)
                value=mapTileReader.AsyncReadCount;
            else
                value=0;
            end
        end
    end

    methods(Access=protected)
        function mapTile=imwebread(reader,url,options,tileCacheIsEnabled,...
            cachename,readerIsOffline)








            if readerIsOffline||~reader.UsingAsynchronous
                mapTile=imwebread@matlab.graphics.chart.internal.maps.TileSetReader(...
                reader,url,options,tileCacheIsEnabled,cachename,readerIsOffline);
            else
                mapTile=[];
                reader.MapTileAcquired=false;
                reader.URL(end+1)=url;
                reader.Filename(end+1)=cachename;
                reader.Tempname(end+1)=matlab.graphics.chart.internal.maps.assignFilenameFromURL(url);
                reader.TileCacheIsEnabled=tileCacheIsEnabled;
            end
        end


        function reset(reader)




            reader.UsingAsynchronous=false;
            reader.URL=string.empty;
            reader.Filename=string.empty;
            reader.Tempname=string.empty;
            reader.TileQuadReference=...
            matlab.graphics.chart.internal.maps.TileQuadReference.empty;
        end
    end
end
