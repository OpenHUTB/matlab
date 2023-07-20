


















classdef TilemapReader<handle

    properties





        MaxZoomLevelCutoff(1,1)double=13
    end

    properties(SetAccess=private)





        TileSetMetadata matlab.graphics.chart.internal.maps.TileSetMetadata
    end

    properties(Hidden)





        TilemapCache matlab.graphics.chart.internal.maps.MapTileMemoryCache
    end

    properties(SetAccess=?tTilemapReader,Hidden)






        URLTemplate string=string.empty









        GridLength{mustBeInteger}=64
    end

    properties(Constant,Access=private)
        Options=weboptions('Timeout',10,'ContentType','json')
        MaxNumTilemapsInCache=2048
    end

    methods
        function reader=TilemapReader(meta)
















            reader.TilemapCache=matlab.graphics.chart.internal.maps.MapTileMemoryCache;
            reader.TilemapCache.MaxNumMapTilesInCache=reader.MaxNumTilemapsInCache;

            reader.TileSetMetadata=meta;

            url=reader.TileSetMetadata.MapTileLocation.ParameterizedLocation;
            if contains(url,"arcgisonline.com")
                url=replace(url,'server.arcgisonline.com','services.arcgisonline.com');
                url=extractBefore(url,'tile');
                urlTemplate=url+"tilemap"+...
                "/"+"$(ZOOMLEVEL)"+...
                "/"+"$(ROW)"+...
                "/"+"$(COLUMN)"+...
                "/"+"$(WIDTH)"+...
                "/"+"$(HEIGHT)";
                reader.URLTemplate=urlTemplate;
            end
        end

        function[tilemap,gridRow,gridCol]=readTilemapGrid(...
            reader,row,column,zoomLevel)






















            gridLength=reader.GridLength;
            gridRow=fix(row/gridLength)*gridLength;
            gridCol=fix(column/gridLength)*gridLength;

            cache=reader.TilemapCache;
            if mapTileIsInCache(cache,gridRow,gridCol,zoomLevel)
                data=getMapTileFromCache(cache,gridRow,gridCol,zoomLevel);
                tilemap.data=data;
            else
                tilemap=readTilemap(reader,gridRow,gridCol,zoomLevel,gridLength,gridLength);
                if~isempty(tilemap)&&isequal(length(tilemap.data),gridLength*gridLength)
                    tilemap.data=logical(reshape(tilemap.data,[gridLength,gridLength]));
                    addMapTileToCache(cache,tilemap.data,gridRow,gridCol,zoomLevel)
                end
            end
        end

        function tf=hasBlankTile(reader,row,column,zoomLevel,width,height)























            [tilemap,gridRow,gridCol]=readTilemapGrid(...
            reader,row,column,zoomLevel);
            data=getDataFromTilemap(...
            tilemap,gridRow,gridCol,row,column,width,height);

            gridLength=reader.GridLength;
            needRowData=(gridRow+gridLength-1)<(row+height-1);
            needColData=(gridCol+gridLength-1)<(column+width-1);

            if needRowData||needColData
                if needRowData



                    newRow=row+height-1;
                    [tilemap,gridRow,gridCol]=readTilemapGrid(...
                    reader,newRow,column,zoomLevel);

                    newHeight=newRow-row;
                    rowData=getDataFromTilemap(...
                    tilemap,gridRow,gridCol,newRow,column,width,newHeight);
                    data=[data(:);rowData(:)];
                end

                if needColData



                    newCol=column+width-1;
                    [tilemap,gridRow,gridCol]=readTilemapGrid(...
                    reader,row,newCol,zoomLevel);

                    newWidth=newCol-column;
                    colData=getDataFromTilemap(...
                    tilemap,gridRow,gridCol,row,newCol,newWidth,height);
                    data=[data(:);colData(:)];
                end

                if needRowData&&needColData



                    [tilemap,gridRow,gridCol]=readTilemapGrid(...
                    reader,newRow,newCol,zoomLevel);

                    rowColData=getDataFromTilemap(...
                    tilemap,gridRow,gridCol,newRow,newCol,newWidth,newHeight);
                    data=[data(:);rowColData(:)];
                end
            end






            tf=isempty(data)||~all(data(:));
        end

        function tilemap=readTilemap(reader,row,column,zoomLevel,width,height)













            urlTemplate=reader.URLTemplate;
            if~isempty(urlTemplate)
                url=replace(urlTemplate,"$(ZOOMLEVEL)",string(zoomLevel));
                url=replace(url,"$(ROW)",string(row));
                url=replace(url,"$(COLUMN)",string(column));
                url=replace(url,"$(WIDTH)",string(width));
                url=replace(url,"$(HEIGHT)",string(height));




                try
                    tilemap=webread(url,reader.Options);
                catch
                    tilemap=[];
                end
            else
                tilemap=[];
            end
        end


        function maxTileZoomLevel=findMaxTileZoomLevel(reader,...
            xTileLimits,yTileLimits,zoomLevel)













            maxTileZoomLevel=reader.TileSetMetadata.MaxZoomLevel;
            maxZoomLevelCutoff=reader.MaxZoomLevelCutoff;

            if zoomLevel>=maxZoomLevelCutoff&&~isempty(reader.URLTemplate)
                numTiles=2^zoomLevel;



                width=diff(xTileLimits);
                height=diff(yTileLimits);
                left=mod(min(xTileLimits),numTiles);
                top=min(yTileLimits);

                zoomLevelHasBlankTile=true;

                while zoomLevelHasBlankTile&&zoomLevel>=maxZoomLevelCutoff






                    try
                        row=top;
                        column=left;
                        zoomLevelHasBlankTile=hasBlankTile(reader,...
                        row,column,zoomLevel,width,height);
                    catch
                        zoomLevelHasBlankTile=false;
                    end

                    if zoomLevelHasBlankTile


                        zoomLevel=zoomLevel-1;

                        right=ceil((left+width)/2);
                        left=floor(left/2);
                        width=right-left;

                        bottom=ceil((top+height)/2);
                        top=floor(top/2);
                        height=bottom-top;
                    end
                    maxTileZoomLevel=zoomLevel;
                end
            end
        end
    end
end

function data=getDataFromTilemap(tilemap,gridRow,gridCol,row,col,width,height)
    if~isempty(tilemap)&&isfield(tilemap,'data')
        data=tilemap.data;
        rowStart=max(row-gridRow+1,1);
        colStart=max(col-gridCol+1,1);

        rowEnd=min(rowStart+height-1,size(data,1));
        colEnd=min(colStart+width-1,size(data,2));
        data=data(rowStart:rowEnd,colStart:colEnd);
    else
        data=[];
    end
end