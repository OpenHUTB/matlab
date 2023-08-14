
















































classdef(Abstract)TileSetReference
    properties(Abstract)





ZoomLevel
    end

    properties(SetAccess=protected,Abstract)




LatitudeLimits





LongitudeLimits





XWorldLimits





YWorldLimits
    end

    properties(Dependent,SetAccess=protected,Abstract)




NumTilesEastWest





NumTilesNorthSouth
    end

    properties(Dependent,SetAccess=protected)




TileRowLimits





TileColumnLimits





NumTilesInTileSet







TileSetSize
    end

    properties(Constant)




        TileSize=[256,256]
    end


    methods
        function R=TileSetReference(varargin)
            R=matlab.graphics.chart.internal.maps.checkAndSetNameValuePairs(...
            R,varargin{:});
        end
    end

    methods(Abstract)
        [x,y]=fwdproj(R,lat,lon)
        [lat,lon]=invproj(R,x,y)
        row=latToTileRow(R,lat)
        col=lonToTileCol(R,lon)
        y=tileRowToYWorld(R,row)
        row=yWorldToTileRow(R,y)
        x=tileColToXWorld(R,col)
        col=xWorldToTileCol(R,x)
    end

    methods
        function lat=tileRowToLat(R,row)





            [x,y]=tileToWorld(R,row,0);
            lat=invproj(R,x,y);
        end

        function lon=tileColToLon(R,col)





            [x,y]=tileToWorld(R,0,col);
            [~,lon]=invproj(R,x,y);
        end

        function[row,col]=geographicToTile(R,lat,lon)






            row=latToTileRow(R,lat);
            col=lonToTileCol(R,lon);
        end

        function[lat,lon]=tileToGeographic(R,row,col)






            lat=tileRowToLat(R,row);
            lon=tileColToLon(R,col);
        end

        function tileIndex=lonToTileIndex(R,lon)






            lonlim=[min(lon),max(lon)];
            tileIndex=lonToTileCol(R,lonlim);
            tileIndex=max(tileIndex,0);
            tileIndex(1)=floor(tileIndex(1));
            tileIndex(2)=ceil(tileIndex(2)-1);
            tileIndex=[min(tileIndex),max(tileIndex)];
        end

        function tileIndex=latToTileIndex(R,lat)






            latlim=[min(lat),max(lat)];
            tileIndex=latToTileRow(R,latlim);
            tileIndex=max(tileIndex,0);
            tileIndex(1)=ceil(tileIndex(1)-1);
            tileIndex(2)=floor(tileIndex(2));
            tileIndex=[min(tileIndex),max(tileIndex)];
        end

        function[row,col]=worldToTile(R,x,y)






            row=yWorldToTileRow(R,y);
            col=xWorldToTileCol(R,x);
        end

        function[x,y]=tileToWorld(R,row,col)






            x=tileColToXWorld(R,col);
            y=tileRowToYWorld(R,row);
        end

        function tileIndex=xWorldToTileIndex(R,x)






            xLimits=[min(x),max(x)];
            tileIndex=xWorldToTileCol(R,xLimits);
            tileIndex=max(tileIndex,0);
            tileIndex(1)=floor(tileIndex(1));
            tileIndex(2)=ceil(tileIndex(2)-1);
            tileIndex=[min(tileIndex),max(tileIndex)];
        end

        function tileIndex=yWorldToTileIndex(R,y)






            yLimits=[min(y),max(y)];
            tileIndex=yWorldToTileRow(R,yLimits);
            tileIndex=max(tileIndex,0);
            tileIndex(1)=ceil(tileIndex(1)-1);
            tileIndex(2)=floor(tileIndex(2));
            tileIndex=[min(tileIndex),max(tileIndex)];
        end



        function value=get.TileRowLimits(R)
            value=[0,R.NumTilesNorthSouth];
        end

        function value=get.TileColumnLimits(R)
            value=[0,R.NumTilesEastWest];
        end

        function value=get.TileSetSize(R)
            value=R.TileSize.*[R.NumTilesNorthSouth,R.NumTilesEastWest];
        end

        function value=get.NumTilesInTileSet(R)
            value=R.NumTilesEastWest*R.NumTilesNorthSouth;
        end
    end
end
