classdef CheckerboardTileReader






    properties
        TileSetMetadata=struct('MaxZoomLevel',25)
        UsingHighZoomLevelBasemap(1,1)logical=false
    end

    properties(Access=private)
ReadTileFcn
    end

    methods
        function obj=CheckerboardTileReader(cbBasemap)
            obj.ReadTileFcn=checkerboardTileEmulator(cbBasemap);
        end

        function fillTileQuads(obj,tilequads)
            readTileFcn=obj.ReadTileFcn;
            for q=tilequads
                q.CData=readTileFcn(q.XTileIndex,q.YTileIndex,q.ZoomLevel);
            end
        end

        function attributionString=readDynamicAttribution(obj,latlim,lonlim,zoomLevel)%#ok<INUSD>
            attributionString="";
        end

        function maxZoomLevel=readMaxZoomLevel(obj,xTileLimits,yTileLimits,tileZoomLevel)%#ok<INUSD>
            maxZoomLevel=obj.TileSetMetadata.MaxZoomLevel;
        end
    end
end


function readTileFcn=checkerboardTileEmulator(cbBaseLayer)




    landgray=uint8([217,217,217]);
    waterwhite=uint8([255,255,255]);
    watergray=uint8([166,166,166]);
    landgreen=uint8([210,233,184]);
    waterblue=uint8([157,215,238]);

    readTileFcn=[];
    switch cbBaseLayer
    case 'cbgrayland'
        readTileFcn=@(xTileIndex,yTileIndex,zoomLevel)...
        twoToneCheckerboard(xTileIndex,yTileIndex,landgray,waterwhite);

    case 'cbdarkwater'
        readTileFcn=@(xTileIndex,yTileIndex,zoomLevel)...
        twoToneCheckerboard(xTileIndex,yTileIndex,landgray,watergray);

    case 'cbbluegreen'
        readTileFcn=@(xTileIndex,yTileIndex,zoomLevel)...
        twoToneCheckerboard(xTileIndex,yTileIndex,landgreen,waterblue);

    case 'cbloading'
        tilepath=fullfile(matlab.graphics.chart.internal.maps.mapdatadir,'maptiles');
        darkgray=imread(fullfile(tilepath,'darkgray_loading_tile.png'));
        lightgray=imread(fullfile(tilepath,'lightgray_loading_tile.png'));
        readTileFcn=@(xTileIndex,yTileIndex,zoomLevel)...
        twoToneLoadingCheckerboard(xTileIndex,yTileIndex,darkgray,lightgray);
    end
end


function cdata=twoToneCheckerboard(xTileIndex,yTileIndex,evencolor,oddcolor)
    pixelsPerTileDimension=256;
    if mod(xTileIndex+yTileIndex,2)==0
        cdata=evencolor;
    else
        cdata=oddcolor;
    end
    cdata=reshape(cdata,[1,1,3]);
    cdata=repmat(cdata,[pixelsPerTileDimension,pixelsPerTileDimension,1]);
    cdata(1,:,:)=255;
    cdata(:,1,:)=255;
    cdata(end,:,:)=255;
    cdata(end,:,:)=255;
end


function cdata=twoToneLoadingCheckerboard(xTileIndex,yTileIndex,evencolor,oddcolor)
    if mod(xTileIndex+yTileIndex,2)==0
        cdata=evencolor;
    else
        cdata=oddcolor;
    end
end
