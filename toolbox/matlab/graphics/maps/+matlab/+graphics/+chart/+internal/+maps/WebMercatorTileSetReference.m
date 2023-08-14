

















































classdef WebMercatorTileSetReference<matlab.graphics.chart.internal.maps.TileSetReference
    properties





        ZoomLevel=0
    end

    properties(SetAccess=protected)




LatitudeLimits





LongitudeLimits





XWorldLimits





YWorldLimits
    end

    properties(Dependent,SetAccess=protected)




NumTilesEastWest





NumTilesNorthSouth
    end

    properties(Hidden,Dependent,Access=private)
XTileDimension
YTileDimension
    end

    methods
        function R=WebMercatorTileSetReference(varargin)








            R=R@matlab.graphics.chart.internal.maps.TileSetReference(varargin{:});

            x=fwdproj(R,0,180);
            R.XWorldLimits=[-x,x];
            R.YWorldLimits=[-x,x];
            lat=invproj(R,x,x);
            R.LatitudeLimits=[-lat,lat];
            R.LongitudeLimits=[-180,180];
        end

        function[x,y]=fwdproj(R,lat,lon)






            radius=6378137;
            x=radius*deg2rad(lon);
            y=radius*atanh(sind(lat));


            index=(y>max(R.YWorldLimits))|(y<min(R.YWorldLimits));
            y(index)=NaN;
            x(index)=NaN;
        end

        function[lat,lon]=invproj(R,x,y)






            radius=6378137;
            lat=asind(tanh(y/radius));
            lon=rad2deg(x/radius);


            index=(lat>max(R.LatitudeLimits))|(lat<min(R.LatitudeLimits));
            lat(index)=NaN;
            lon(index)=NaN;
        end


        function row=latToTileRow(R,lat)





            lat=deg2rad(lat);
            y=(1-log(tan(lat)+sec(lat))/pi)/2;
            row=y*R.NumTilesNorthSouth;
        end

        function col=lonToTileCol(R,lon)





            x=(lon+180)/360;
            col=x*R.NumTilesEastWest;
        end

        function y=tileRowToYWorld(R,row)






            y=R.YWorldLimits(2)-(row*R.YTileDimension);
        end

        function x=tileColToXWorld(R,col)






            x=R.XWorldLimits(1)+(col*R.XTileDimension);
        end


        function row=yWorldToTileRow(R,y)





            row=(R.YWorldLimits(2)-y)/R.YTileDimension;
        end

        function col=xWorldToTileCol(R,x)






            col=(x-R.XWorldLimits(1))/R.XTileDimension;
        end

        function R=set.ZoomLevel(R,value)
            validateattributes(value,{'numeric'},...
            {'integer','<',26,'>=',0,'real','nonempty'},...
            'TileSetReference','ZoomLevel');
            R.ZoomLevel=double(value);
        end

        function value=get.NumTilesEastWest(R)
            value=2^R.ZoomLevel;
        end

        function value=get.NumTilesNorthSouth(R)
            value=2^R.ZoomLevel;
        end

        function xTileDimension=get.XTileDimension(R)
            xTileDimension=(2*max(R.XWorldLimits))/R.NumTilesEastWest;
        end

        function yTileDimension=get.YTileDimension(R)
            yTileDimension=(2*max(R.YWorldLimits))/R.NumTilesNorthSouth;
        end
    end
end
