classdef AffineTransform<handle&matlab.mixin.Copyable

    properties
        T=eye(4,4)
    end

    methods
        function translate(obj,vx,vy,vz)
            if nargin==2
                vec=vx(:);
            elseif nargin==4
                vec=[vx;vy;vz];
            end
            Ttrans=eye(4);
            Ttrans(1:3,4)=vec;
            obj.T=Ttrans*obj.T;
        end

        function scale(obj,r)
            T=diag([r,r,r,1]);
            obj.T=T*obj.T;
        end


        function rotate(obj,vec1,vec2,origin)

            if nargin==3
                origin=[0,0,0];
            end

            n1=vec1/norm(vec1);
            n2=vec2/norm(vec2);
            ax=cross(n1,n2);
            ax=ax/norm(ax);
            if~any(ax)
                [~,i]=min(abs(n1));
                c=zeros(1,3);
                c(i)=1;
                ax=cross(n1,c);
                ax=ax/norm(ax);
            end

            x=ax(1);
            y=ax(2);
            z=ax(3);
            c=min(dot(n1,n2),1);
            s=sin(acos(c));
            t=1-c;
            rot=[...
            x*x*t+c,y*x*t-z*s,z*x*t+y*s,0;...
            x*y*t+z*s,y*y*t+c,z*y*t-x*s,0;...
            x*z*t-y*s,y*z*t+x*s,z*z*t+c,0;...
            0,0,0,1];
            translate(obj,-origin);
            obj.T=rot*obj.T;
            translate(obj,origin);
        end

        function rotateX(obj,theta,origin)
            if nargin==2
                origin=[0,0,0];
            end
            s=sin(theta);
            c=cos(theta);
            rot=[...
            1,0,0,0;...
            0,c,-s,0;...
            0,s,c,0;...
            0,0,0,1];
            translate(obj,-origin);
            obj.T=rot*obj.T;
            translate(obj,origin);
        end

        function rotateY(obj,theta,origin)
            if nargin==2
                origin=[0,0,0];
            end
            s=sin(theta);
            c=cos(theta);
            rot=[...
            c,0,s,0;...
            0,1,0,0;...
            -s,0,c,0;...
            0,0,0,1];
            translate(obj,-origin);
            obj.T=rot*obj.T;
            translate(obj,origin);
        end

        function rotateZ(obj,theta,origin)
            if nargin==2
                origin=[0,0,0];
            end
            s=sin(theta);
            c=cos(theta);
            rot=[...
            c,-s,0,0;...
            s,c,0,0;...
            0,0,1,0;...
            0,0,0,1];
            translate(obj,-origin);
            obj.T=rot*obj.T;
            translate(obj,origin);
        end

        function out=transform(obj,in)

            out=obj.T*[in';ones(1,size(in,1))];
            out=out(1:3,:)';
        end
    end
end
