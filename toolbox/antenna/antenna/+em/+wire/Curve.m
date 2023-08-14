classdef Curve<handle


    properties
X
Y
Z
    end

    methods
        function c=Curve(x,y,z)
            if nargin==1
                c.X=real(x(:,1));
                c.Y=real(x(:,2));
                c.Z=real(x(:,3));
            elseif nargin==3
                c.X=x;
                c.Y=y;
                c.Z=z;
            end
        end

        function c=copy(obj)
            c=em.wire.Curve(obj.X,obj.Y,obj.Z);
        end

        function plot3(obj,varargin)
            plot3(obj.X,obj.Y,obj.Z,varargin{:});
            view(3)
            rotate3d on
            grid on
            box on
            axis equal
        end

        function transform(obj,T)
            temp=transform(T,[obj.X,obj.Y,obj.Z]);
            obj.X=temp(:,1);
            obj.Y=temp(:,2);
            obj.Z=temp(:,3);
        end

        function vol=extruder(obj,T,n,clr,clrPrev,startCap,endCap)
            if nargin==4
                clrPrev=clr;
            end
            if nargin<=5
                startCap=false;
                endCap=false;
            end
            npts=numel(obj.X);
            lastCurve=obj;
            vol=em.wire.Volume;
            if startCap

                if npts>2||n==0
                    add(vol,em.wire.Surface(lastCurve),clr);
                end
            end

            for i=1:n
                nextCurve=copy(lastCurve);
                transform(nextCurve,T(min(i,numel(T))));
                add(vol,em.wire.Surface(lastCurve,nextCurve),clr,clrPrev);
                lastCurve=nextCurve;
            end
            if endCap

                if isempty(vol.Surfaces)||(npts>2&&n>0)
                    add(vol,em.wire.Surface(lastCurve),clr);
                end
            end
        end
    end
end
