classdef WebMercatorProjection






















































    properties(Constant)
        EquatorialRadius=6378137
    end

    properties(SetAccess=private)
ScaleFactor
ScaledRadius
Circumference
    end

    properties(Constant)


        MaxLatitude=asind(tanh(pi))
    end

    properties(Dependent,SetAccess=private)
    end


    methods
        function obj=WebMercatorProjection(scaleFactor)
            if nargin<1
                scaleFactor=1;
            end
            obj.ScaleFactor=scaleFactor;
            obj.ScaledRadius=scaleFactor*obj.EquatorialRadius;
            obj.Circumference=2*pi*obj.ScaledRadius;
        end


        function[x,y]=projfwd(obj,lat,lon)
            lat(lat(:)<-90)=-90;
            lat(lat(:)>90)=90;
            R=obj.ScaledRadius;
            x=R*deg2rad(lon);
            y=R*atanh(sind(lat));
        end


        function[lat,lon]=projinv(obj,x,y)
            R=obj.ScaledRadius;
            lat=asind(tanh(y/R));
            lon=rad2deg(x/R);
        end


        function x=lon2x(obj,lon)
            x=obj.ScaledRadius*deg2rad(lon);
        end


        function y=lat2y(obj,lat)
            lat(lat(:)<-90)=-90;
            lat(lat(:)>90)=90;
            y=obj.ScaledRadius*atanh(sind(lat));
        end


        function lat=y2lat(obj,y)
            lat=asind(tanh(y/obj.ScaledRadius));
        end


        function lon=x2lon(obj,x)
            lon=rad2deg(x/obj.ScaledRadius);
        end


        function result=dxdLongitude(obj,lon)
            result=obj.ScaledRadius*(pi/180)+zeros(size(lon),'like',lon);
        end


        function result=dydLatitude(obj,lat)
            result=obj.ScaledRadius*(pi/180)./cosd(lat);
        end


        function d=greatCircleDistance(obj,lat1,lon1,lat2,lon2)
            a=sind((lat2-lat1)/2).^2...
            +cosd(lat1).*cosd(lat2).*sind((lon2-lon1)/2).^2;

            d=2*obj.EquatorialRadius*atan2(sqrt(a),sqrt(1-a));
        end
    end
end
