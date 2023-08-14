


























classdef(Abstract,ConstructOnLoad)TileSetReader<handle
    properties(Dependent)





        TileSetMetadata matlab.graphics.chart.internal.maps.TileSetMetadata
    end

    properties








        EnableExceptionHandling logical=false
    end

    properties(Transient)





        EnableMapTileFileCache=true
    end

    properties





        OfflineReader=[]









        ReaderIsOffline=false






        EnableWarnings=true
    end

    properties(Dependent)





CacheFolder













MissingMapTileValue
    end

    properties(SetAccess='protected',GetAccess='public',Hidden)








        MapTileCachingStrategy=matlab.graphics.chart.internal.maps.MapTileCachingStrategy.empty






        UsingHighZoomLevelBasemap(1,1)logical=false
    end

    properties(SetAccess='protected')




        TileRowIndex double





        TileColumnIndex double





        ZoomLevel double





        MapTileAcquired logical=logical.empty





        Exception MException=MException.empty
    end

    properties(Access=?matlab.graphics.chart.internal.maps.BaseLayerSelector)

        DynamicAttributionReader matlab.graphics.chart.internal.maps.DynamicAttributionReader...
        =matlab.graphics.chart.internal.maps.DynamicAttributionReader.empty
    end

    properties(Access='protected')

        TilemapReader matlab.graphics.chart.internal.maps.TilemapReader=...
        matlab.graphics.chart.internal.maps.TilemapReader.empty
    end

    properties(Access='protected',Dependent)

EnableDiagnostics


EnableErrorDiagnostics


ConnectionTimeout
    end

    properties(Abstract,Access=protected)
TileSetReference
    end

    properties(Access=private)

        Options=weboptions


pMissingMapTileValue


        pTileSetMetadata matlab.graphics.chart.internal.maps.TileSetMetadata=matlab.graphics.chart.internal.maps.TileSetMetadata.empty


TileSetReaderEnvironmentManager
    end

    properties(Access=protected,Constant)

        MissingMapTileFilename=fullfile(matlab.graphics.chart.internal.maps.mapdatadir,...
        'maptiles','missing_tile.png')
    end

    methods
        function reader=TileSetReader(varargin)


















            reader.TileSetReaderEnvironmentManager=...
            matlab.graphics.chart.internal.maps.TileSetReaderEnvironmentManager.instance();

            if nargin>0
                v1=varargin{1};
                tileSetMetadataClass='matlab.graphics.chart.internal.maps.TileSetMetadata';
                validateattributes(v1,{'char','string',tileSetMetadataClass},{'nonempty'})
                if isa(v1,tileSetMetadataClass)
                    meta=v1;
                else
                    tileSetName=string(v1);
                    if nargin==2
                        folder=varargin{2};
                    else
                        folder='';
                    end
                    meta=matlab.graphics.chart.internal.maps.TileSetMetadata;
                    meta.TileSetName=tileSetName;
                    meta=readMetadata(meta,folder);
                end
            else
                meta=matlab.graphics.chart.internal.maps.TileSetMetadata;
            end



            reader.TileSetMetadata=meta;



            reader.EnableMapTileFileCache=reader.TileSetReaderEnvironmentManager.EnableMapTileFileCache;

            try


                reader.MissingMapTileValue=imread(reader.MissingMapTileFilename);
            catch


            end
        end


        function attributionString=readDynamicAttribution(...
            reader,latlim,lonlim,zoomLevel)













            attribReader=reader.DynamicAttributionReader;
            if~isempty(attribReader)
                attributionString=readDynamicAttribution(...
                attribReader,latlim,lonlim,zoomLevel);
            else
                attributionString=reader.TileSetMetadata.Attribution;
            end
        end

        function maxZoomLevel=readMaxZoomLevel(reader,xTileLimits,yTileLimits,zoomLevel)













            tileMapReader=reader.TilemapReader;
            maxZoomLevel=findMaxTileZoomLevel(tileMapReader,...
            xTileLimits,yTileLimits,zoomLevel);
        end


        function tileSetImage=readTileSet(reader,limits1,limits2,zoomLevel,coordinateType)





























            if nargin==4
                coordinateType='tile';
            end

            coordinateType=validatestring(coordinateType,{'map','geographic','tile'});
            switch coordinateType
            case 'tile'

                tileRowIndex=limits1;
                tileColIndex=limits2;

            case 'map'

                [tileRowIndex,tileColIndex]=worldToTileIndex(reader,limits1,limits2,zoomLevel);
                if all(diff(limits1)<=0)



                    tileColIndex=fliplr(tileColIndex);
                end

            case 'geographic'

                [tileRowIndex,tileColIndex]=geographicToTileIndex(reader,limits1,limits2,zoomLevel);
                if all(diff(limits2)<=0)



                    tileColIndex=fliplr(tileColIndex);
                end
            end


            tileSetImage=readMapTiles(reader,tileRowIndex,tileColIndex,zoomLevel);
        end


        function tileSetImage=readMapTiles(reader,tileRowIndex,tileColIndex,zoomLevel)













            R=reader.TileSetReference;
            R.ZoomLevel=zoomLevel;

            if~isscalar(tileRowIndex)
                maxTileRowIndex=min(max(tileRowIndex),R.NumTilesNorthSouth-1);
                minTileRowIndex=max(min(tileRowIndex),0);
                tileRowIndex=minTileRowIndex:maxTileRowIndex;
            end

            if~isscalar(tileColIndex)
                maxTileColIndex=min(max(tileColIndex),R.NumTilesEastWest-1);
                minTileColIndex=max(min(tileColIndex),0);
                if all(diff(tileColIndex)>=0)

                    tileColIndex=minTileColIndex:maxTileColIndex;
                else

                    tileColIndex=[maxTileColIndex:(R.NumTilesEastWest-1),0:minTileColIndex];
                end
            end

            numRowTiles=length(tileRowIndex);
            numColTiles=length(tileColIndex);

            tileSize=R.TileSize;
            imageSize=tileSize.*[numRowTiles,numColTiles];
            tileSetImage=zeros([imageSize,3],'uint8');

            colStart=1;
            numTiles=numRowTiles*numColTiles;
            mapTileAcquired=false(1,numTiles);
            exception=MException.empty;
            tileNumber=0;
            reader.Exception=exception;

            for tileCol=tileColIndex
                colEnd=colStart+tileSize-1;
                rowStart=1;
                for tileRow=tileRowIndex
                    tileNumber=tileNumber+1;
                    rowEnd=rowStart+tileSize-1;
                    mapTile=readMapTile(reader,tileRow,tileCol,zoomLevel);
                    tileSetImage(rowStart:rowEnd,colStart:colEnd,:)=mapTile;
                    mapTileAcquired(tileNumber)=reader.MapTileAcquired;
                    if~isempty(reader.Exception)
                        exception(end+1)=reader.Exception;%#ok<AGROW>
                    end
                    rowStart=rowEnd+1;
                end
                colStart=colEnd+1;
            end

            reader.TileRowIndex=tileRowIndex;
            reader.TileColumnIndex=tileColIndex;
            reader.MapTileAcquired=mapTileAcquired;
            reader.Exception=exception;
        end


        function mapTile=readMapTile(reader,tileRow,tileCol,zoomLevel)










            if~isscalar(tileRow)
                validateattributes(tileRow,{'double'},{'nonempty','scalar'},mfilename,'tileRow')
            end

            if~isscalar(tileCol)
                validateattributes(tileCol,{'double'},{'nonempty','scalar'},mfilename,'tileCol')
            end

            if~isscalar(zoomLevel)
                validateattributes(zoomLevel,{'double'},{'nonempty','scalar'},mfilename,'zoomLevel')
            end



            reader.TileRowIndex=tileRow;
            reader.TileColumnIndex=tileCol;
            reader.ZoomLevel=zoomLevel;

            try
                mapTile=tileread(reader,tileRow,tileCol,zoomLevel);
                reader.MapTileAcquired=true;
                reader.ReaderIsOffline=false;
            catch e
                if reader.EnableErrorDiagnostics
                    fprintf('error: %s\n',e.message)
                end

                reader.Exception=e;
                reader.MapTileAcquired=false;
                reader.ReaderIsOffline=true;

                if reader.EnableExceptionHandling
                    throwAsCaller(e)
                else




                    mapTile=readMissingMapTile(reader,tileRow,tileCol,zoomLevel);
                end
            end
        end


        function mapTile=readMissingMapTile(reader,tileRow,tileCol,zoomLevel)








            chapter=getString(message('MATLAB:graphics:maps:AccessBasemaps'));

            if~isdeployed


                quote='"';
                folder=['''',docroot,''', ','''matlab''',',','''helptargets.map'''];
                anchor='''GB_ACCDATA''';
                doclink=['<a href=',quote,'matlab:helpview(fullfile('...
                ,folder,'),',anchor,')',quote,'>',chapter,'</a>'];
            else


                doclink=chapter;
            end

            basemap=char(reader.TileSetMetadata.TileSetName);
            if isempty(reader.OfflineReader)

                mapTile=reader.MissingMapTileValue;
                if reader.EnableWarnings
                    issueWarning(reader,message('MATLAB:graphics:maps:ShowingMissingTiles',basemap,doclink));
                end
            else


                try
                    mapTile=readMapTile(reader.OfflineReader,tileRow,tileCol,zoomLevel);
                    if reader.EnableWarnings
                        installedBasemap=char(reader.OfflineReader.TileSetMetadata.TileSetName);
                        issueWarning(reader,message('MATLAB:graphics:maps:ShowingDarkwater',installedBasemap,basemap,doclink));
                    end
                catch
                    mapTile=reader.MissingMapTileValue;
                    if reader.EnableWarnings
                        issueWarning(reader,message('MATLAB:graphics:maps:ShowingMissingTiles',basemap,doclink));
                    end
                end
            end
        end


        function mapTile=readAndCopyMapTile(...
            reader,filename,cachename,tileCacheIsEnabled)











            mapTile=imtileread(reader,filename);

            if tileCacheIsEnabled

                cache=reader.MapTileCachingStrategy;
                copyFileToCacheFile(cache,filename,cachename)
            end
        end


        function fillTileQuads(reader,tilequads)





            for q=tilequads
                q.CData=readMapTile(reader,q.YTileIndex,q.XTileIndex,q.ZoomLevel);
            end
        end


        function[tileRowIndex,tileColIndex]=worldToTileIndex(...
            reader,xWorldLimits,yWorldLimits,zoomLevel)










            R=reader.TileSetReference;
            R.ZoomLevel=zoomLevel;
            tileColIndex=xWorldToTileIndex(R,xWorldLimits);
            tileRowIndex=yWorldToTileIndex(R,yWorldLimits);
        end


        function[tileRowIndex,tileColIndex]=geographicToTileIndex(...
            reader,latitudeLimits,longitudeLimits,zoomLevel)










            R=reader.TileSetReference;
            R.ZoomLevel=zoomLevel;
            tileRowIndex=latToTileIndex(R,latitudeLimits);
            tileColIndex=lonToTileIndex(R,longitudeLimits);
        end


        function deleteCacheFolder(reader)





            deleteFolder(reader.CacheFolder)
        end



        function set.TileSetMetadata(reader,meta)
            setTileSetMetadata(reader,meta)
        end

        function meta=get.TileSetMetadata(reader)
            meta=reader.pTileSetMetadata;
        end

        function folder=get.CacheFolder(reader)
            if~isempty(reader.TileSetMetadata)&&~isempty(reader.MapTileCachingStrategy)
                location=reader.TileSetMetadata.MapTileLocation;
                if reader.EnableMapTileFileCache&&~isempty(location)&&location.IsMapTileURL
                    folder=reader.MapTileCachingStrategy.CacheFolder;
                else
                    folder=string.empty;
                end
            else
                folder=string.empty;
            end
        end

        function set.ConnectionTimeout(reader,value)
            reader.TileSetReaderEnvironmentManager.ConnectionTimeout=value;
            reader.Options.Timeout=value;
        end


        function timeout=get.ConnectionTimeout(reader)
            timeout=reader.Options.Timeout;
        end

        function set.EnableDiagnostics(reader,value)
            reader.TileSetReaderEnvironmentManager.EnableDiagnostics=value;
        end

        function tf=get.EnableDiagnostics(reader)
            if~isvalid(reader.TileSetReaderEnvironmentManager)
                reader.TileSetReaderEnvironmentManager=...
                matlab.graphics.chart.internal.maps.TileSetReaderEnvironmentManager.instance();
            end
            tf=reader.TileSetReaderEnvironmentManager.EnableDiagnostics;
        end

        function set.EnableErrorDiagnostics(reader,value)
            reader.TileSetReaderEnvironmentManager.EnableErrorDiagnostics=value;
        end

        function tf=get.EnableErrorDiagnostics(reader)
            if~isvalid(reader.TileSetReaderEnvironmentManager)
                reader.TileSetReaderEnvironmentManager=...
                matlab.graphics.chart.internal.maps.TileSetReaderEnvironmentManager.instance();
            end
            tf=reader.TileSetReaderEnvironmentManager.EnableErrorDiagnostics;
        end

        function value=get.MissingMapTileValue(reader)
            value=reader.pMissingMapTileValue;
        end


        function set.MissingMapTileValue(reader,value)


            if isnumeric(value)&&isscalar(value)&&value>=0&&value<=255
                value=uint8(value);
            end

            if isscalar(value)
                validateattributes(value,{'uint8'},{'scalar','nonempty'},mfilename,'MissingMapTileValue')
                tileSize=reader.TileSetReference.TileSize;
                mapTile=value*ones([tileSize,3],'uint8');
            else
                validateattributes(value,{'uint8'},{'size',[256,256,3]},mfilename,'MissingMapTileValue')
                mapTile=value;
            end
            reader.pMissingMapTileValue=mapTile;
        end
    end

    methods(Access=protected)

        function setTileSetMetadata(reader,meta)
            assignCachingStrategyAndDynamicAtttibutionReader(reader,meta)
            reader.TilemapReader=matlab.graphics.chart.internal.maps.TilemapReader(meta);
            reader.pTileSetMetadata=meta;
        end

        function issueWarning(reader,msg)
            wstate=warning('off','backtrace');
            obj=onCleanup(@()warning(wstate));
            warning(msg)
            reader.EnableWarnings=false;
        end


        function mapTile=imtileread(reader,filename)

            diagnosticsIsEnabled=reader.EnableDiagnostics;
            filename=char(filename);
            if diagnosticsIsEnabled
                fprintf('imread: %s\n',filename);
            end
            [mapTile,cmap]=imread(filename);

            if~isempty(cmap)
                mapTile=ind2rgb(mapTile,cmap);
            end

            if~isa(mapTile,'uint8')
                mapTile=im2double(mapTile);
                mapTile=uint8(255*mapTile);
            end

            if ismatrix(mapTile)

                mapTile=cat(3,mapTile,mapTile,mapTile);
            end
        end


        function mapTile=tileread(reader,tileRow,tileCol,zoomLevel)










            tileLocation=reader.TileSetMetadata.MapTileLocation;


            mapTileIsURL=tileLocation.IsMapTileURL;

            if~mapTileIsURL


                filename=char(mapTileName(tileLocation,tileRow,tileCol,zoomLevel));


                mapTile=imtileread(reader,filename);

            else

                cache=reader.MapTileCachingStrategy;
                [fileExists,cachename]=cacheLocationExists(cache,tileRow,tileCol,zoomLevel);
                if fileExists

                    mapTile=imtileread(reader,cachename);
                else

                    url=char(mapTileName(tileLocation,tileRow,tileCol,zoomLevel));
                    options=reader.Options;
                    tileCacheIsEnabled=~isempty(cachename)&&reader.EnableMapTileFileCache;
                    readerIsOffline=reader.ReaderIsOffline&&~reader.EnableExceptionHandling;
                    mapTile=imwebread(reader,url,options,tileCacheIsEnabled,cachename,readerIsOffline);
                end
            end
        end


        function mapTile=imwebread(reader,url,options,...
            tileCacheIsEnabled,cachename,readerIsOffline)












            [filename,cleanObj]=imwebsave(reader,url,options,readerIsOffline);%#ok<ASGLU>


            mapTile=readAndCopyMapTile(reader,filename,cachename,tileCacheIsEnabled);

        end


        function[filename,cleanObj]=imwebsave(reader,url,options,readerIsOffline)




















            diagnosticsIsEnabled=reader.EnableDiagnostics;
            if diagnosticsIsEnabled
                fprintf('websave: %s\n',url);
            end

            if~readerIsOffline

                connection=matlab.internal.webservices.HTTPConnector(url,options);
                openConnectionWithMultipleAttempts(connection);




                filename=matlab.graphics.chart.internal.maps.assignFilenameFromURL(url);
                cleanObj=onCleanup(@()matlab.graphics.chart.internal.maps.deletefile(filename));




                copyContentToFile(connection,filename);
            else




                error('MATLAB:graphics:maps:ReaderIsOffline','The reader is offline.')
            end
        end


        function assignCachingStrategyAndDynamicAtttibutionReader(reader,meta)


















            isMapTileURL=~isempty(meta)&&meta.MapTileLocation.IsMapTileURL;
            if isMapTileURL
                cacheLocation=meta.MapTileCacheLocation;
                if isempty(cacheLocation)

                    reader.MapTileCachingStrategy=matlab.graphics.chart.internal.maps.MapTileSessionCachingStrategy(meta);
                    reader.DynamicAttributionReader=matlab.graphics.chart.internal.maps.DynamicAttributionReader.empty;

                elseif startsWith(cacheLocation.ParameterizedLocation,'file://')

                    reader.MapTileCachingStrategy=matlab.graphics.chart.internal.maps.MapTileTimedCachingStrategy(meta);
                    topLevelFolder=reader.MapTileCachingStrategy.TopLevelFolder;
                    reader.DynamicAttributionReader=matlab.graphics.chart.internal.maps.DynamicAttributionReader(meta,topLevelFolder);
                    reader.UsingHighZoomLevelBasemap=true;

                else

                    reader.MapTileCachingStrategy=matlab.graphics.chart.internal.maps.MapTileCachingStrategy(meta);
                    reader.DynamicAttributionReader=matlab.graphics.chart.internal.maps.DynamicAttributionReader.empty;
                end
            else

                reader.MapTileCachingStrategy=matlab.graphics.chart.internal.maps.MapTileCachingStrategy(meta);
                reader.DynamicAttributionReader=matlab.graphics.chart.internal.maps.DynamicAttributionReader.empty;
            end
        end
    end
end




function openConnectionWithMultipleAttempts(connection)



    try
        openConnection(connection);
    catch

        delay=.01;
        pause(delay)
        openConnection(connection);
    end
end



function deleteFolder(folder)





    try

        folder=char(folder);
        if~isempty(folder)&&exist(folder,'dir')
            rmdir(folder,'s')
        end
    catch
    end
end
