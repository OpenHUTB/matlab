classdef(Sealed,ConstructOnLoad,UseClassDefaultsOnLoad)WebMercatorDataSpace...
    <matlab.graphics.axis.dataspace.GeographicDataSpace




    properties(Dependent,SetAccess=private)
LatitudeLimits
LongitudeLimits
LengthUnitInMeters
    end

    properties(Dependent,AffectsObject)


XMapLimits
YMapLimits
    end

    properties(Constant)

        Projection=matlab.graphics.axis.dataspace.WebMercatorProjection(1e-3)
    end


    methods(Access=public)
        function obj=WebMercatorDataSpace()



            addDependencyProduced(obj,'dataspace')
        end


        function new_ds=makeCopy(ds)


            new_ds=matlab.graphics.axis.dataspace.WebMercatorDataSpace;
            for copyprops_I={'XDataLim','YDataLim','ZDataLim','XLim','YLim','ZLim'}
                new_ds.(copyprops_I{:})=ds.([copyprops_I{:},'_I']);
            end



            for copyprops_WithInfs={'XLim','YLim','ZLim'}
                new_ds.([copyprops_WithInfs{:},'WithInfs'])=ds.(copyprops_WithInfs{:});
            end

            for copyprops={'AllowStretchExtents','XLimMode','YLimMode','ZLimMode'}
                new_ds.(copyprops{:})=ds.(copyprops{:});
            end
        end


        function tf=isLinear(~)
            tf='off';
        end


        function tf=isCurvilinear(~)



            tf='on';
        end


        function callMarkDirty(obj)
            MarkDirty(obj,'all')
        end


        function bv=doGetBoundingVolume(~)

            bv=[0,0,0;1,1,1];
        end


        function J=doGetJacobian(obj,p)




            lat=p(1);
            lon=p(2);

            dxdlon=dxdLongitude(obj.Projection,lon);
            dydlat=dydLatitude(obj.Projection,lat);

            latlim=obj.XLim_I;
            lonlim=obj.YLim_I;
            [xlimits,ylimits]=projfwd(obj.Projection,latlim,lonlim);

            J=eye(4);
            J(1:2,1:2)=[0,dxdlon/diff(xlimits);dydlat/diff(ylimits),0];
        end


        function J=doGetNormalizedJacobian(~,~)
            J=eye(4);
            J(1:2,1:2)=[0,1;1,0];
        end


        function dst=doTransformPoints(obj,~,iter)


            Resetpoint(iter);
            numPoints=GetNumPoints(iter);
            pts=transpose(NextPoints(iter,numPoints));
            lat=pts(1,:);
            lon=pts(2,:);
            z=pts(3,:);




            latlim=obj.XLim_I;
            lonlim=obj.YLim_I;
            [xlimits,ylimits]=projfwd(obj.Projection,latlim,lonlim);


            [x,y]=projfwd(obj.Projection,lat,lon);


            zlimits=obj.ZLim_I;








            dst=zeros(3,numPoints,'single');
            dst(1,:)=(x-xlimits(1))/diff(xlimits);
            y=(y-ylimits(1))/diff(ylimits);
            yclamp=1000;
            y(y>yclamp)=yclamp;
            y(y<-yclamp)=-yclamp;
            dst(2,:)=y;
            dst(3,:)=(z-zlimits(1))/diff(zlimits);


            dst(isnan(dst))=-realmax('single');
        end


        function data=doUntransformPoint(obj,~,point)

            [xProjected,yProjected]=worldToProjected(obj,point(1),point(2));
            [lat,lon]=projinv(obj.Projection,xProjected,yProjected);
            zlimits=obj.ZLim_I;
            z=zlimits(1)+diff(zlimits)*point(3);
            data=[lat;lon;z];
        end


        function data=doUntransformPoints(obj,~,iter)

            Resetpoint(iter);
            num_points=double(GetNumPoints(iter));
            xWorld=zeros(1,num_points);
            yWorld=zeros(1,num_points);
            z=zeros(1,num_points);
            for k=1:num_points
                point=NextPoints(iter,1);
                xWorld(k)=point(1);
                yWorld(k)=point(2);
                z(k)=point(3);
            end



            [xProjected,yProjected]=worldToProjected(obj,xWorld,yWorld);
            [lat,lon]=projinv(obj.Projection,xProjected,yProjected);
            zlimits=obj.ZLim_I;
            z=zlimits(1)+diff(zlimits)*z;
            data=[lat;lon;z];
        end


        function dst=doTransformLine(obj,matrix,src)

            iter=matlab.graphics.axis.dataspace.IndexPointsIterator;
            iter.Vertices=src;
            dst=doTransformPoints(obj,matrix,iter);
        end


        function[xProjected,yProjected]=worldToProjected(obj,xWorld,yWorld)



            latlim=obj.XLim_I;
            lonlim=obj.YLim_I;
            [xlimits,ylimits]=projfwd(obj.Projection,latlim,lonlim);



            xProjected=xlimits(1)+diff(xlimits)*xWorld;
            yProjected=ylimits(1)+diff(ylimits)*yWorld;
        end


        function sigma=lengthDistortionAtMapCenter(obj)




            ylimits=obj.YMapLimits;
            yCenter=(ylimits(1)+ylimits(2))/2;
            latCenter=y2lat(obj.Projection,yCenter);
            sigma=1/cosd(latCenter);
        end
    end


    methods














        function latlim=get.LatitudeLimits(obj)
            latlim=obj.XLim_I;
        end


        function lonlim=get.LongitudeLimits(obj)
            lonlim=obj.YLim_I;
        end


        function set.XMapLimits(obj,xlimits)
            obj.YLim_I=x2lon(obj.Projection,xlimits);
        end


        function set.YMapLimits(obj,ylimits)
            obj.XLim_I=y2lat(obj.Projection,ylimits);
        end


        function xlimits=get.XMapLimits(obj)
            xlimits=lon2x(obj.Projection,obj.YLim_I);
        end


        function ylimits=get.YMapLimits(obj)
            ylimits=lat2y(obj.Projection,obj.XLim_I);
        end


        function metersPerLengthUnit=get.LengthUnitInMeters(obj)
            metersPerLengthUnit=1/obj.Projection.ScaleFactor;
        end
    end
end
