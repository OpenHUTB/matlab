classdef ClothoidCurve






%#codegen

    properties
        x0=0.0;
        y0=0.0;
        theta0=0.0;
        kappa0=0.0;
        dk=0.0;
        L=0.0;
    end

    methods
        function obj=ClothoidCurve(x0,y0,theta0,kappa0,dk,L)


            obj.x0=x0;
            obj.y0=y0;
            obj.theta0=theta0;
            obj.kappa0=kappa0;
            obj.dk=dk;
            obj.L=L;
        end

        function x=xBegin(obj)


            x=obj.x0;
        end

        function y=yBegin(obj)


            y=obj.y0;
        end

        function x1=xEnd(obj)


            if obj.L==0
                x1=obj.x0;
            else

                xy=matlabshared.tracking.internal.scenario.fresnelg(obj.L,obj.dk,obj.kappa0,obj.theta0);
                x1=obj.x0+real(xy);
            end
        end

        function y1=yEnd(obj)


            if obj.L==0
                y1=obj.y0;
            else

                xy=matlabshared.tracking.internal.scenario.fresnelg(obj.L,obj.dk,obj.kappa0,obj.theta0);
                y1=obj.y0+imag(xy);
            end
        end

        function theta1=thetaEnd(obj)


            if obj.L==0
                theta1=obj.theta0;
            else

                theta1=obj.theta0+obj.L.*(obj.kappa0+0.5.*obj.L.*obj.dk);
            end
        end

        function kappa1=kappaEnd(obj)


            if obj.L==0
                kappa1=obj.kappa0;
            else

                kappa1=obj.kappa0+obj.L.*obj.dk;
            end
        end

        function[x,y,theta,kappa]=evaluate(obj,s)




            xy=matlabshared.tracking.internal.scenario.fresnelg(s,obj.dk,obj.kappa0,obj.theta0);
            C=real(xy);
            S=imag(xy);

            x=obj.x0+C;
            y=obj.y0+S;

            theta=obj.theta0+s.*(obj.kappa0+0.5.*s.*obj.dk);
            kappa=obj.kappa0+s.*obj.dk;
        end

        function[x,y,s,d]=closestPoint(obj,xq,yq)





            zOffset=complex(obj.x0,obj.y0);
            z=complex(xq,yq);
            zStndrd=z-zOffset;



            [zcpStndrd,s,d]=matlabshared.tracking.internal.scenario.fresnelgcp(zStndrd,obj.dk,obj.kappa0,obj.theta0,0);


            zcp=zcpStndrd+zOffset;


            x=real(zcp);
            y=imag(zcp);
        end

        function hFig=plot(obj,varargin)


















            if nargin==1
                nSample=10;
                zDirection=-1;
                style='r*';
            elseif nargin==2
                nSample=varargin{1};
                zDirection=-1;
                style='r*';
            elseif nargin==3
                nSample=varargin{1};
                zDirection=varargin{2};
                style='r*';
            elseif nargin==4
                nSample=varargin{1};
                zDirection=varargin{2};
                style=varargin{3};
            end


            x=zeros(1,nSample);
            y=zeros(1,nSample);
            theta=zeros(1,nSample);
            kappa=zeros(1,nSample);
            i=1;

            for si=linspace(0,obj.L,nSample)
                [x(i),y(i),theta(i),kappa(i)]=obj.evaluate(si);
                i=i+1;
            end

            if zDirection==1
                hFig=plot(x,y,style);
            elseif zDirection==-1
                hFig=plot(y,x,style);
            end
            hold on
            axis equal

        end
    end
end

