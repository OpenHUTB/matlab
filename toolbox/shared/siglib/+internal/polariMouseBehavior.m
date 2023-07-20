classdef polariMouseBehavior<handle










    properties
InstallFcn
MotionEvent
DownEvent
UpEvent
ScrollEvent
    end

    methods
        function obj=polariMouseBehavior(i,m,d,u,s)







            if nargin>0
                obj.InstallFcn=i;
            end
            if nargin>1
                obj.MotionEvent=m;
            end
            if nargin>2
                obj.DownEvent=d;
            end
            if nargin>3
                obj.UpEvent=u;
            end
            if nargin>4
                obj.ScrollEvent=s;
            end
        end
    end

    methods(Sealed)
        function install(obj,p)




            f=obj.InstallFcn;
            if~isempty(f)
                f(p);
            end
        end

        function motion(obj,p,ev)


            f=obj.MotionEvent;
            if~isempty(f)
                f(p,ev);
            end
        end

        function down(obj,p,ev)


            f=obj.DownEvent;
            if~isempty(f)
                f(p,ev);
            end
        end

        function up(obj,p,ev)


            f=obj.UpEvent;
            if~isempty(f)
                f(p,ev);
            end
        end

        function scroll(obj,p,ev)


            f=obj.ScrollEvent;
            if~isempty(f)
                f(p,ev);
            end
        end
    end
end
